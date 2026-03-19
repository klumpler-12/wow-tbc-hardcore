--[[
    TBC Hybrid Hardcore — Core
    Main addon initialization, event bus, slash commands, module loader.
    AceAddon-3.0 based with AceDB for persistence.
]]

local ADDON_NAME, HCP = ...

-- Create the main addon object
local HardcorePlus = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME,
    "AceEvent-3.0",
    "AceTimer-3.0",
    "AceComm-3.0",
    "AceSerializer-3.0",
    "AceConsole-3.0"
)

-- Store reference in shared namespace
HCP.Addon = HardcorePlus

-- ═══════════════════════════════════════════
--  Database Defaults
-- ═══════════════════════════════════════════

local DB_DEFAULTS = {
    global = {
        version = HCP.DB_VERSION,
        settings = {
            graceMinutes = HCP.Violations.GRACE_MINUTES,
            minorWeeklyMax = HCP.Violations.MINOR_WEEKLY_MAX,
        },
        -- Minimap button position (LibDBIcon)
        minimap = { hide = false },
        -- Checkpoint tokens (shared across account characters)
        checkpointTokens = {},
        -- Peer registry (known players and their validation records)
        peerRegistry = {},
        -- Debug/tester mode toggles (alpha — shared across all chars)
        debug = HCP.DebugDefaults,
    },
    char = {
        -- Registration
        registered = false,
        registeredAt = 0,
        status = HCP.Status.PENDING,
        tradeMode = HCP.TradeMode.OPEN,
        instanceLivesEnabled = true,
        checkpointEnabled = true,
        title = nil,

        -- Death tracking
        deaths = {},
        -- deathCount removed: use #deaths or (openWorldDeaths + instanceDeaths) instead
        openWorldDeaths = 0,
        instanceDeaths = 0,

        -- Instance lives
        instanceLives = {},
        weeklyPool = {
            used = 0,
            max = HCP.WeeklyPoolDefault,
            bonus = 0,
            resetTime = 0,
        },

        -- Soul of Iron
        soulOfIron = false,
        soulOfIronTimestamp = 0,
        soulOfIronLost = false,

        -- Uptime tracking
        sessions = {},
        currentSession = nil,

        -- Violation tracking
        minorViolations = 0,
        violationResetWeek = 0,
        suspiciousFlags = {},

        -- Inventory snapshots
        lastInventoryHash = 0,
        lastGold = 0,
        lastLevel = 0,
        lastProfCount = 0,

        -- Checkpoint
        checkpoint = {
            level = 58,
            unlocked = false,
            usedCount = 0,
            sourceChar = nil,
        },

        -- Soft reset
        softResets = 0,
        softResetInProgress = false,
        softResetStartPlayed = 0,
        deletedItemHashes = {},

        -- Item source tracking
        itemSources = {},

        -- Played time
        playedTotal = 0,
        playedAtSessionStart = 0,

        -- Plugin tracker data (each tracker stores its own subtable here)
        trackerData = {},
    },
}

-- ═══════════════════════════════════════════
--  Initialization
-- ═══════════════════════════════════════════

function HardcorePlus:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("HardcorePlusDB", DB_DEFAULTS, true)
    HCP.db = self.db

    -- Register slash commands
    self:RegisterChatCommand("hcp", "SlashCommand")
    self:RegisterChatCommand("hardcoreplus", "SlashCommand")

    -- Suppress /played chat output so periodic addon requests don't spam the player.
    -- Hook ChatFrame_DisplayTimePlayed (the Blizzard function that formats and shows /played
    -- output in chat). This is locale-independent and the proven pattern used by the
    -- established Hardcore addon (Zarant/WoW_Hardcore).
    -- TIME_PLAYED_MSG event still fires normally for our tracking; only the chat display is hidden.
    HCP._suppressPlayedCount = 0       -- how many /played outputs to suppress
    HCP._suppressPlayedCountMax = 2    -- safety cap
    local Orig_ChatFrame_DisplayTimePlayed = ChatFrame_DisplayTimePlayed
    ChatFrame_DisplayTimePlayed = function(...)
        if HCP._suppressPlayedCount > 0 then
            HCP._suppressPlayedCount = HCP._suppressPlayedCount - 1
            return  -- swallow the chat output
        end
        return Orig_ChatFrame_DisplayTimePlayed(...)
    end

    self:Print(HCP.CC.GOLD .. "TBC Hybrid Hardcore" .. HCP.CC.CLOSE ..
        " v" .. HCP.VERSION .. " loaded. Type " ..
        HCP.CC.NEON .. "/hcp" .. HCP.CC.CLOSE .. " for help.")
end

function HardcorePlus:OnEnable()
    -- Record session start
    local charData = self.db.char
    charData.currentSession = {
        start = HCP.Utils.GetTimestamp(),
        playedAtStart = charData.playedTotal,
    }

    -- Request /played to get baseline (response comes async via TIME_PLAYED_MSG)
    self:RegisterEvent("TIME_PLAYED_MSG", "OnTimePlayed")
    HCP._suppressPlayedCount = HCP._suppressPlayedCount + 1  -- suppress initial /played chat output
    RequestTimePlayed()

    -- Track level changes
    self:RegisterEvent("PLAYER_LEVEL_UP", "OnLevelUp")

    -- PLAYER_LEAVING_WORLD fires on /reload, logout, disconnect, and zone transitions.
    -- Save session data here as a safety net — OnDisable may not fire on /reload.
    self:RegisterEvent("PLAYER_LEAVING_WORLD", function()
        self:SaveSession()
    end)

    -- Store current state for gap detection
    charData.lastLevel = HCP.Utils.GetLevel()
    charData.lastGold = HCP.Utils.GetGold()
    charData.lastInventoryHash = HCP.Utils.GetInventoryHash()
    charData.lastProfCount = HCP.Utils.GetProfessionCount()

    -- Fire addon-ready event for modules
    -- Phase 1: Core systems (tracking, verification) init first
    self:SendMessage("HCP_ADDON_READY")
    -- Phase 2: UI modules can safely query system state
    self:ScheduleTimer(function()
        self:SendMessage("HCP_UI_READY")
    end, 0.1)
end

function HardcorePlus:OnDisable()
    self:SaveSession()
end

function HardcorePlus:SaveSession()
    -- Record session end and snapshot state for gap detection
    local charData = self.db.char
    if charData.currentSession then
        charData.currentSession["end"] = HCP.Utils.GetTimestamp()
        table.insert(charData.sessions, charData.currentSession)
        charData.currentSession = nil
    end
    -- Snapshot current state so next login can detect gaps
    charData.lastLevel = HCP.Utils.GetLevel()
    charData.lastGold = HCP.Utils.GetGold()
    charData.lastInventoryHash = HCP.Utils.GetInventoryHash()
    charData.lastProfCount = HCP.Utils.GetProfessionCount()
end

-- ═══════════════════════════════════════════
--  Event Handlers
-- ═══════════════════════════════════════════

function HardcorePlus:OnTimePlayed(_, totalPlayed, levelPlayed)
    local charData = self.db.char

    -- Check for gap: if played advanced more than our session tracking
    if charData.playedTotal > 0 and totalPlayed > charData.playedTotal then
        local gap = totalPlayed - charData.playedTotal
        local sessionTime = HCP.Utils.GetTimestamp() - (charData.currentSession and charData.currentSession.start or HCP.Utils.GetTimestamp())

        -- If /played advanced significantly more than our session → addon was off while player was on
        if gap > (sessionTime + 60) then  -- 60s tolerance
            local gapMinutes = math.floor((gap - sessionTime) / 60)
            self:SendMessage("HCP_ADDON_GAP_DETECTED", gapMinutes)
        end
    end

    charData.playedTotal = totalPlayed
    if charData.currentSession then
        charData.currentSession.playedAtStart = totalPlayed
    end

    -- Notify other modules that /played data was received
    self:SendMessage("HCP_TIME_PLAYED", totalPlayed, levelPlayed)
end

function HardcorePlus:OnLevelUp(_, level)
    self.db.char.lastLevel = level
    self:SendMessage("HCP_LEVEL_UP", level)

    -- Check checkpoint unlock
    if level >= 58 and self.db.char.checkpointEnabled then
        if not self.db.char.checkpoint.unlocked then
            self.db.char.checkpoint.unlocked = true
            self:Print(HCP.CC.GOLD .. "Checkpoint unlocked!" .. HCP.CC.CLOSE ..
                " Level 58 reached. If you die, you can register a new character.")
        end
    end
end

-- ═══════════════════════════════════════════
--  Slash Command Handler
-- ═══════════════════════════════════════════

function HardcorePlus:SlashCommand(input)
    local cmd = self:GetArgs(input, 1)
    cmd = cmd and cmd:lower() or ""

    if cmd == "" or cmd == "help" then
        self:PrintHelp()
    elseif cmd == "show" or cmd == "toggle" then
        self:SendMessage("HCP_TOGGLE_PANEL")
    elseif cmd == "status" then
        self:PrintStatus()
    elseif cmd == "deaths" then
        self:PrintDeaths()
    elseif cmd == "lives" then
        self:PrintLives()
    elseif cmd == "monitor" then
        self:SendMessage("HCP_TOGGLE_MONITOR")
    elseif cmd == "network" then
        self:SendMessage("HCP_TOGGLE_PANEL")
        -- Switch to network tab after panel opens
        HardcorePlus:ScheduleTimer(function()
            if HCP.MainPanel then HCP.MainPanel:SwitchTab("network") end
        end, 0.05)
    elseif cmd == "checkpoint" then
        -- Subcommand: /hcp checkpoint claim
        local _, sub = self:GetArgs(input, 2)
        if sub and sub:lower() == "claim" then
            HCP.Checkpoint:ClaimToken()
        else
            self:SendMessage("HCP_SHOW_CHECKPOINT")
        end
    elseif cmd == "reset" then
        -- Subcommand: /hcp reset scan
        local _, sub = self:GetArgs(input, 2)
        if sub and sub:lower() == "scan" then
            self:PrintStripScan()
        else
            self:SendMessage("HCP_SHOW_SOFT_RESET")
        end
    elseif cmd == "debug" or cmd == "test" then
        -- Subcommand: /hcp debug verbose
        local _, sub = self:GetArgs(input, 2)
        if sub and sub:lower() == "verbose" then
            local debug = HCP.db.global.debug
            debug.verbose = not debug.verbose
            self:Print(HCP.CC.GOLD .. "Verbose logging: " .. HCP.CC.CLOSE ..
                (debug.verbose and (HCP.CC.NEON .. "ON") or (HCP.CC.DIM .. "OFF")) .. HCP.CC.CLOSE)
        else
            self:SendMessage("HCP_SHOW_DEBUG")
        end
    elseif cmd == "config" or cmd == "settings" then
        self:SendMessage("HCP_SHOW_SETTINGS")
    else
        self:Print("Unknown command: " .. cmd .. ". Type /hcp for help.")
    end
end

function HardcorePlus:PrintStripScan()
    local c = HCP.CC
    if not HCP.SoftReset:IsInProgress() then
        self:Print(c.DIM .. "No soft reset in progress." .. c.CLOSE)
        return
    end
    local allPass, checks = HCP.SoftReset:RunStripVerification()
    self:Print(c.PURPLE .. "═══ Strip Scan ═══" .. c.CLOSE)
    for _, check in ipairs(checks) do
        local icon = check.pass and (c.GREEN .. "✓") or (c.RED .. "✗")
        self:Print(icon .. " " .. check.name .. ": " .. c.CLOSE .. check.detail)
    end
    local remaining = HCP.SoftReset:GetWindowRemaining()
    if remaining then
        self:Print(c.DIM .. "Time remaining: " .. HCP.Utils.FormatTime(remaining) .. c.CLOSE)
    end
    if allPass then
        self:Print(c.GREEN .. "All clear! Use /hcp reset to confirm." .. c.CLOSE)
    end
end

function HardcorePlus:PrintHelp()
    local c = HCP.CC
    self:Print(c.GOLD .. "═══ TBC Hybrid Hardcore Commands ═══" .. c.CLOSE)
    self:Print(c.NEON .. "/hcp show" .. c.CLOSE .. "             — Toggle main panel")
    self:Print(c.NEON .. "/hcp status" .. c.CLOSE .. "           — Show current HC status")
    self:Print(c.NEON .. "/hcp deaths" .. c.CLOSE .. "           — Show death log")
    self:Print(c.NEON .. "/hcp lives" .. c.CLOSE .. "            — Show instance lives")
    self:Print(c.NEON .. "/hcp monitor" .. c.CLOSE .. "          — Toggle death monitor widget")
    self:Print(c.NEON .. "/hcp network" .. c.CLOSE .. "          — Show peer network status")
    self:Print(c.NEON .. "/hcp checkpoint" .. c.CLOSE .. "       — Checkpoint management")
    self:Print(c.NEON .. "/hcp checkpoint claim" .. c.CLOSE .. " — Claim a checkpoint token")
    self:Print(c.NEON .. "/hcp reset" .. c.CLOSE .. "            — Soft reset wizard")
    self:Print(c.NEON .. "/hcp reset scan" .. c.CLOSE .. "       — Check strip progress")
    self:Print(c.NEON .. "/hcp config" .. c.CLOSE .. "           — Open settings")
    self:Print(c.NEON .. "/hcp debug" .. c.CLOSE .. "            — Tester mode (toggle systems)")
    self:Print(c.NEON .. "/hcp debug verbose" .. c.CLOSE .. "    — Toggle verbose debug logging")
end

function HardcorePlus:PrintStatus()
    local c = HCP.CC
    local data = self.db.char
    local statusColor = HCP.StatusColors[data.status] or c.DIM
    local statusLabel = HCP.StatusLabels[data.status] or data.status

    self:Print(c.GOLD .. "═══ HC Status ═══" .. c.CLOSE)
    self:Print("Status: " .. statusColor .. statusLabel .. c.CLOSE)
    self:Print("Level: " .. c.WHITE .. HCP.Utils.GetLevel() .. c.CLOSE)
    self:Print("Deaths (Open World): " .. c.RED .. data.openWorldDeaths .. c.CLOSE)
    self:Print("Deaths (Instance): " .. c.BLUE .. data.instanceDeaths .. c.CLOSE)
    self:Print("Soul of Iron: " .. (data.soulOfIron and (c.GREEN .. "Active" .. c.CLOSE) or (c.DIM .. "No" .. c.CLOSE)))
    self:Print("Trade Mode: " .. c.WHITE .. (HCP.TradeModeLabels[data.tradeMode] or data.tradeMode) .. c.CLOSE)

    if data.title then
        self:Print("Title: " .. c.GOLD .. data.title .. c.CLOSE)
    end

    if data.softResets > 0 then
        self:Print("Soft Resets: " .. c.PURPLE .. data.softResets .. c.CLOSE)
    end

    local flagCount = #data.suspiciousFlags
    if flagCount > 0 then
        self:Print("Flags: " .. c.RED .. flagCount .. c.CLOSE)
    end
end

function HardcorePlus:PrintDeaths()
    local c = HCP.CC
    local deaths = self.db.char.deaths

    if #deaths == 0 then
        self:Print(c.GREEN .. "No deaths recorded." .. c.CLOSE)
        return
    end

    self:Print(c.GOLD .. "═══ Death Log ═══" .. c.CLOSE)
    for i = #deaths, math.max(1, #deaths - 4), -1 do
        local d = deaths[i]
        self:Print(c.RED .. "#" .. i .. c.CLOSE ..
            " — " .. (d.zone or "Unknown") ..
            " (Lvl " .. (d.level or "?") .. ")" ..
            " — " .. (d.killer or "Unknown") ..
            " [" .. HCP.Utils.FormatDate(d.timestamp, "%Y-%m-%d %H:%M") .. "]")
    end
end

function HardcorePlus:PrintLives()
    local c = HCP.CC
    local data = self.db.char

    if not data.instanceLivesEnabled then
        self:Print(c.DIM .. "Instance Lives: Disabled (Juggernaut/True-HC mode)" .. c.CLOSE)
        return
    end

    self:Print(c.GOLD .. "═══ Instance Lives ═══" .. c.CLOSE)
    self:Print("Weekly Pool: " .. c.BLUE ..
        (data.weeklyPool.max - data.weeklyPool.used) .. "/" .. data.weeklyPool.max ..
        c.CLOSE .. " remaining")

    local hasInstanceData = false
    for instance, lifeData in pairs(data.instanceLives) do
        hasInstanceData = true
        local remaining = lifeData.livesMax - lifeData.livesUsed
        local color = remaining > 0 and c.GREEN or c.RED
        self:Print("  " .. instance .. ": " .. color .. remaining .. "/" .. lifeData.livesMax .. c.CLOSE)
    end

    if not hasInstanceData then
        self:Print(c.DIM .. "  No instance data yet." .. c.CLOSE)
    end
end
