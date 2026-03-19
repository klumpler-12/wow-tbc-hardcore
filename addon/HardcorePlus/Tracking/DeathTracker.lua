--[[
    HardcorePlus — Death Tracker (Phase 2)
    Detects player deaths via combat log and PLAYER_DEAD.
    Records full death context: zone, killer, ability, level.
    Fires HCP_PLAYER_DEATH for other modules to react.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local DeathTracker = {}
HCP.DeathTracker = DeathTracker

-- Recent combat data for death context
local recentDamage = {}  -- last 5 damage events
local MAX_RECENT = 5

-- ═══════════════════════════════════════════
--  Combat Log Tracking
-- ═══════════════════════════════════════════

local function OnCombatLogEvent()
    -- TBC Classic CLEU layout (first 11 fields are always the same):
    -- 1=timestamp, 2=subevent, 3=hideCaster, 4=sourceGUID, 5=sourceName,
    -- 6=sourceFlags, 7=sourceRaidFlags, 8=destGUID, 9=destName,
    -- 10=destFlags, 11=destRaidFlags
    -- After that: layout varies by subevent type.
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

    local playerGUID = UnitGUID("player")

    -- Track damage TO the player for death context
    if destGUID == playerGUID then
        if subevent == "SWING_DAMAGE" then
            -- SWING_DAMAGE: no spell prefix. Field 12 = amount, 13 = overkill, ...
            local _, _, _, _, _, _, _, _, _, _, _,
                swingAmount = CombatLogGetCurrentEventInfo()
            table.insert(recentDamage, {
                time = timestamp,
                source = sourceName or "Unknown",
                ability = "Melee",
                amount = swingAmount or 0,
                type = "melee",
            })
        elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE"
            or subevent == "RANGE_DAMAGE" then
            -- SPELL_DAMAGE: field 12=spellId, 13=spellName, 14=spellSchool, 15=amount
            local _, _, _, _, _, _, _, _, _, _, _,
                _, spellName, _, spellAmount = CombatLogGetCurrentEventInfo()
            table.insert(recentDamage, {
                time = timestamp,
                source = sourceName or "Unknown",
                ability = spellName or "Unknown",
                amount = spellAmount or 0,
                type = subevent,
            })
        elseif subevent == "ENVIRONMENTAL_DAMAGE" then
            -- ENVIRONMENTAL_DAMAGE: field 12=environmentalType (string), 13=amount
            local _, _, _, _, _, _, _, _, _, _, _,
                envType, envAmount = CombatLogGetCurrentEventInfo()
            table.insert(recentDamage, {
                time = timestamp,
                source = "Environment",
                ability = envType or "Unknown",
                amount = envAmount or 0,
                type = "environment",
            })
        end

        -- Keep only recent
        while #recentDamage > MAX_RECENT do
            table.remove(recentDamage, 1)
        end
    end

    -- Detect player death
    if subevent == "UNIT_DIED" then
        if destGUID == playerGUID then
            DeathTracker:OnPlayerDied()
        else
            -- Another player died nearby — notify Verification for witness tracking
            HardcorePlus:SendMessage("HCP_NEARBY_PLAYER_DIED", destGUID, destName)
        end
    end
end

-- ═══════════════════════════════════════════
--  Death Processing
-- ═══════════════════════════════════════════

local deathProcessed = false  -- prevent double-processing

function DeathTracker:OnPlayerDied()
    if deathProcessed then return end
    deathProcessed = true

    -- Reset flag after 5 seconds (in case of spirit release mechanics)
    HardcorePlus:ScheduleTimer(function() deathProcessed = false end, 5)

    if not HCP.db.char.registered then return end
    if not HCP.Utils.IsSystemEnabled("deathTracking") then
        HCP.Utils.DebugLog("Death tracking disabled — death ignored")
        return
    end

    local data = HCP.db.char
    local zoneInfo = HCP.Utils.GetZoneInfo()
    local inInstance, instanceType = HCP.Utils.IsInInstance()
    local instanceData = HCP.Utils.GetInstanceData()  -- nil if not in instance

    -- Determine killer from recent damage
    local killer = "Unknown"
    local killingAbility = "Unknown"
    local killingDamage = 0
    if #recentDamage > 0 then
        local last = recentDamage[#recentDamage]
        killer = last.source
        killingAbility = last.ability
        killingDamage = last.amount
    end

    -- Build death record
    local deathRecord = {
        timestamp = HCP.Utils.GetTimestamp(),
        zone = zoneInfo.zone,
        subzone = zoneInfo.subzone,
        level = HCP.Utils.GetLevel(),
        killer = killer,
        ability = killingAbility,
        damage = killingDamage,
        inInstance = inInstance,
        instanceType = instanceType or "none",
        -- Canonical instance name from GetInstanceInfo() for bonus life lookup (Phase 5).
        -- GetRealZoneText() can return subzone names; this always returns the instance name.
        instanceName = instanceData and instanceData.name or nil,
        isHeroic = instanceData and instanceData.isHeroic or false,
        recentDamage = HCP.Utils.DeepCopy(recentDamage),
        inventoryHash = HCP.Utils.GetInventoryHash(),
        gold = HCP.Utils.GetGold(),
    }

    -- Store death record (always logged, even if life consumed)
    table.insert(data.deaths, deathRecord)

    -- Open world deaths are always permanent — count immediately.
    -- Instance deaths: deferred until InstanceTracker resolves whether a life was consumed.
    -- If life consumed → NOT counted as a "death" on permanent record.
    -- If no life → counted via HCP_INSTANCE_DEATH_RESOLVED handler below.
    if not inInstance then
        data.openWorldDeaths = data.openWorldDeaths + 1
    end

    -- Clear recent damage
    recentDamage = {}

    -- Print death notification
    local c = HCP.CC
    HardcorePlus:Print(c.RED .. "══ DEATH RECORDED ══" .. c.CLOSE)
    HardcorePlus:Print(c.RED .. "Killed by: " .. c.WHITE .. killer .. c.CLOSE ..
        c.DIM .. " (" .. killingAbility .. ")" .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Zone: " .. zoneInfo.zone ..
        (zoneInfo.subzone ~= "" and (" — " .. zoneInfo.subzone) or "") ..
        " | Level " .. deathRecord.level .. c.CLOSE)

    if inInstance then
        HardcorePlus:Print(c.BLUE .. "Instance death — checking lives..." .. c.CLOSE)
    else
        HardcorePlus:Print(c.RED .. "Open world death — this is PERMANENT." .. c.CLOSE)
    end

    -- Fire event for other modules (status system, instance lives, network)
    HardcorePlus:SendMessage("HCP_PLAYER_DEATH", deathRecord)
end

-- ═══════════════════════════════════════════
--  PLAYER_DEAD backup event
-- ═══════════════════════════════════════════

local function OnPlayerDead()
    -- PLAYER_DEAD fires when release spirit dialog appears
    -- Use as backup in case combat log missed it
    if not deathProcessed then
        DeathTracker:OnPlayerDied()
    end
end

-- ═══════════════════════════════════════════
--  Death Log UI population
-- ═══════════════════════════════════════════

function DeathTracker:PopulateDeathLog(contentFrame)
    -- Clear existing
    local children = { contentFrame:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
    local regions = { contentFrame:GetRegions() }
    for _, region in ipairs(regions) do
        if region.SetText then region:SetText("") end
    end
    if contentFrame.placeholder then contentFrame.placeholder:Hide() end

    local c = HCP.CC
    local deaths = HCP.db.char.deaths
    local yOff = -8

    local function Line(text)
        local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, yOff)
        fs:SetPoint("RIGHT", contentFrame, "RIGHT", -8, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        fs:SetWordWrap(true)
        yOff = yOff - 16
        return fs
    end

    if #deaths == 0 then
        Line(c.GREEN .. "No deaths recorded. Stay alive!" .. c.CLOSE)
        return
    end

    Line(c.GOLD .. "Death Log" .. c.CLOSE .. c.DIM .. " (" .. #deaths .. " total)" .. c.CLOSE)
    yOff = yOff - 4

    -- Show most recent deaths (last 10)
    for i = #deaths, math.max(1, #deaths - 9), -1 do
        local d = deaths[i]
        local isInstance = d.inInstance and (c.BLUE .. "[INST]" .. c.CLOSE .. " ") or ""
        Line(c.RED .. "#" .. i .. c.CLOSE .. "  " .. isInstance ..
            c.WHITE .. (d.killer or "?") .. c.CLOSE ..
            c.DIM .. " (" .. (d.ability or "?") .. ")" .. c.CLOSE)
        Line("    " .. c.DIM .. (d.zone or "?") ..
            " | Lvl " .. (d.level or "?") ..
            " | " .. HCP.Utils.FormatDate(d.timestamp) .. c.CLOSE)
        yOff = yOff - 4
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    HardcorePlus:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, ...)
        -- TBC 2.4.3: CLEU passes args directly to handler in a different format.
        -- StoreCLEUArgs normalizes TBC (8 base fields) → modern (11 base fields)
        -- so CombatLogGetCurrentEventInfo() returns consistent positions.
        HCP.Compat.StoreCLEUArgs(...)
        OnCombatLogEvent()
    end)
    HardcorePlus:RegisterEvent("PLAYER_DEAD", function()
        OnPlayerDead()
    end)
end)

-- Count instance death as permanent if no life was consumed
HardcorePlus:RegisterMessage("HCP_INSTANCE_DEATH_RESOLVED", function(_, deathRecord, lifeConsumed, reason)
    if not lifeConsumed then
        -- No life consumed → this is a permanent instance death
        HCP.db.char.instanceDeaths = HCP.db.char.instanceDeaths + 1
    end
    -- If life was consumed, it's already logged in deaths[] but NOT counted in instanceDeaths
end)

-- Populate death log when tab selected
HardcorePlus:RegisterMessage("HCP_TAB_SELECTED", function(_, tabId)
    if tabId == "deaths" and HCP.MainPanel then
        local cf = HCP.MainPanel:GetContentFrame("deaths")
        if cf then
            DeathTracker:PopulateDeathLog(cf)
        end
    end
end)
