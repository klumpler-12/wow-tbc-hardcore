--[[
    HardcorePlus — Soft Reset System (Phase 7)
    Allows dead SSF/Guildfound characters at 58+ to re-enter HC by stripping all progress.

    Eligibility:
      - Status = DEAD
      - Trade mode = SSF or Guildfound (from registration)
      - Level >= 58
      - Checkpoints must have been enabled (fresh-start verification prerequisite)

    Verification Scan (all must pass):
      □ Inventory: All bag slots empty
      □ Equipment: All slots empty
      □ Gold: < 1g
      □ Professions: 0 primary professions
      □ Talents: 0 spent points
      □ Quest Log: Empty (excluding hidden/tracking quests)

    2-hour /played window to complete stripping.
    Voiding actions during window: fights, looting, sending items.

    Item source tracking: after soft reset, restored items detected = void.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local SoftReset = {}
HCP.SoftReset = SoftReset

-- ═══════════════════════════════════════════
--  Eligibility Check
-- ═══════════════════════════════════════════

function SoftReset:CheckEligibility()
    local data = HCP.db.char
    local checks = {}
    local eligible = true

    -- Must be dead
    local isDead = data.status == HCP.Status.DEAD
    table.insert(checks, {
        name = "Status",
        pass = isDead,
        detail = isDead and "Dead (permadeath)" or "Must be Dead status (current: " .. (data.status or "?") .. ")",
    })
    if not isDead then eligible = false end

    -- Must be SSF or Guildfound
    local validTrade = data.tradeMode == HCP.TradeMode.SSF or data.tradeMode == HCP.TradeMode.GUILDFOUND
    table.insert(checks, {
        name = "Trade Mode",
        pass = validTrade,
        detail = validTrade and (HCP.TradeModeLabels[data.tradeMode] or data.tradeMode) or
            "Must be SSF or Guildfound (current: " .. (HCP.TradeModeLabels[data.tradeMode] or data.tradeMode) .. ")",
    })
    if not validTrade then eligible = false end

    -- Level 58+
    local level = HCP.Utils.GetLevel()
    local levelOk = level >= 58
    table.insert(checks, {
        name = "Level",
        pass = levelOk,
        detail = levelOk and ("Level " .. level) or ("Must be 58+ (current: " .. level .. ")"),
    })
    if not levelOk then eligible = false end

    -- Checkpoint must have been enabled
    local cpEnabled = data.checkpointEnabled
    table.insert(checks, {
        name = "Checkpoint",
        pass = cpEnabled,
        detail = cpEnabled and "Enabled" or "Checkpoints must be enabled at registration",
    })
    if not cpEnabled then eligible = false end

    return eligible, checks
end

-- ═══════════════════════════════════════════
--  Strip Verification Scan
-- ═══════════════════════════════════════════

function SoftReset:RunStripVerification()
    local checks = {}
    local allPass = true

    -- Bags empty
    local bagItems = HCP.Utils.CountBagItems()
    local bagsPass = bagItems == 0
    table.insert(checks, {
        name = "Inventory",
        pass = bagsPass,
        detail = bagsPass and "Empty" or (bagItems .. " items remaining"),
    })
    if not bagsPass then allPass = false end

    -- Equipment empty
    local equippedCount = 0
    for slot = 1, 19 do
        if GetInventoryItemLink("player", slot) then
            equippedCount = equippedCount + 1
        end
    end
    local equipPass = equippedCount == 0
    table.insert(checks, {
        name = "Equipment",
        pass = equipPass,
        detail = equipPass and "All slots empty" or (equippedCount .. " slot(s) still equipped"),
    })
    if not equipPass then allPass = false end

    -- Gold < 1g
    local gold = HCP.Utils.GetGold()
    local goldPass = gold < HCP.SoftResetConfig.MAX_GOLD
    table.insert(checks, {
        name = "Gold",
        pass = goldPass,
        detail = goldPass and HCP.Utils.FormatGold(gold) or
            (HCP.Utils.FormatGold(gold) .. " — must be under " .. HCP.Utils.FormatGold(HCP.SoftResetConfig.MAX_GOLD)),
    })
    if not goldPass then allPass = false end

    -- Professions = 0
    local profCount = HCP.Utils.GetProfessionCount()
    local profPass = profCount == 0
    table.insert(checks, {
        name = "Professions",
        pass = profPass,
        detail = profPass and "None" or (profCount .. " primary profession(s) — must unlearn all"),
    })
    if not profPass then allPass = false end

    -- Talents = 0
    local talents = HCP.Utils.GetSpentTalentPoints()
    local talentPass = talents == 0
    table.insert(checks, {
        name = "Talents",
        pass = talentPass,
        detail = talentPass and "Reset" or (talents .. " points spent — must reset"),
    })
    if not talentPass then allPass = false end

    -- Quest log empty
    local questCount = 0
    local numEntries = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local _, _, _, isHeader = GetQuestLogTitle(i)
        if not isHeader then
            questCount = questCount + 1
        end
    end
    local questPass = questCount == 0
    table.insert(checks, {
        name = "Quest Log",
        pass = questPass,
        detail = questPass and "Empty" or (questCount .. " quest(s) — must abandon all"),
    })
    if not questPass then allPass = false end

    return allPass, checks
end

-- ═══════════════════════════════════════════
--  Soft Reset Execution
-- ═══════════════════════════════════════════

--- Initiate the soft reset process. Starts the 2-hour timer.
function SoftReset:Initiate()
    if not HCP.Utils.IsSystemEnabled("softReset") then
        HCP.Utils.DebugLog("Soft reset system disabled")
        HardcorePlus:Print(HCP.CC.RED .. "Soft reset system is disabled (debug toggle)." .. HCP.CC.CLOSE)
        return false
    end
    local data = HCP.db.char
    local c = HCP.CC

    local eligible, _ = self:CheckEligibility()
    if not eligible then
        HardcorePlus:Print(c.RED .. "Not eligible for soft reset." .. c.CLOSE)
        return false
    end

    -- Snapshot items before stripping for restoration detection later
    data.deletedItemHashes = {}
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                table.insert(data.deletedItemHashes,
                    HCP.Utils.SimpleHash(link))
            end
        end
    end
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            table.insert(data.deletedItemHashes,
                HCP.Utils.SimpleHash(link))
        end
    end

    data.softResetInProgress = true
    -- Request /played to get current value for the window timer
    HCP._suppressPlayedCount = math.min(
        (HCP._suppressPlayedCount or 0) + 1,
        HCP._suppressPlayedCountMax or 2
    )
    data.softResetStartPlayed = data.playedTotal
    RequestTimePlayed()

    HardcorePlus:Print(c.GOLD .. "══ SOFT RESET INITIATED ══" .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "You have 2 hours of /played time to strip all progress." .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Remove: gear, bags, gold, professions, talents, quests." .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Type /hcp reset scan to check progress." .. c.CLOSE)

    -- Request /played frequently during soft reset for accurate window tracking
    -- (UptimeTracker only requests every 2 min; we need ~30s during reset)
    self._resetPlayedTimer = HardcorePlus:ScheduleRepeatingTimer(function()
        if not HCP.db.char.softResetInProgress then
            if SoftReset._resetPlayedTimer then
                HardcorePlus:CancelTimer(SoftReset._resetPlayedTimer)
                SoftReset._resetPlayedTimer = nil
            end
            return
        end
        HCP._suppressPlayedCount = math.min(
            (HCP._suppressPlayedCount or 0) + 1,
            HCP._suppressPlayedCountMax or 2
        )
        RequestTimePlayed()
    end, 30)

    HardcorePlus:SendMessage("HCP_SOFT_RESET_INITIATED")
    return true
end

--- Complete the soft reset (called when all checks pass within the window).
function SoftReset:Complete()
    local data = HCP.db.char
    local c = HCP.CC

    -- Verify strip is complete
    local allPass, _ = self:RunStripVerification()
    if not allPass then
        HardcorePlus:Print(c.RED .. "Strip verification failed. Complete all requirements first." .. c.CLOSE)
        return false
    end

    -- Check time window
    local elapsed = data.playedTotal - data.softResetStartPlayed
    if elapsed > HCP.SoftResetConfig.COMPLETION_WINDOW then
        HardcorePlus:Print(c.RED .. "Soft reset window expired (" ..
            HCP.Utils.FormatTime(elapsed) .. " elapsed, max " ..
            HCP.Utils.FormatTime(HCP.SoftResetConfig.COMPLETION_WINDOW) .. ")." .. c.CLOSE)
        data.softResetInProgress = false
        return false
    end

    -- Execute soft reset
    data.softResetInProgress = false
    if self._resetPlayedTimer then
        HardcorePlus:CancelTimer(self._resetPlayedTimer)
        self._resetPlayedTimer = nil
    end
    data.softResets = data.softResets + 1

    -- Transition status
    HCP.VerificationTracker:TransitionStatus(HCP.Status.SOFT_RESET,
        "Soft Reset #" .. data.softResets .. " completed")

    -- Reset death counters (fresh start)
    data.openWorldDeaths = 0
    data.instanceDeaths = 0
    -- Keep deaths[] log intact but add a marker
    table.insert(data.deaths, {
        timestamp = HCP.Utils.GetTimestamp(),
        zone = "Soft Reset",
        killer = "SYSTEM",
        ability = "Soft Reset #" .. data.softResets,
        level = HCP.Utils.GetLevel(),
        damage = 0,
        inInstance = false,
        isSoftResetMarker = true,
    })

    -- Reset instance lives
    data.instanceLives = {}
    data.weeklyPool.used = 0
    data.weeklyPool.bonus = 0

    -- Snapshot new baseline
    data.lastLevel = HCP.Utils.GetLevel()
    data.lastGold = HCP.Utils.GetGold()
    data.lastInventoryHash = HCP.Utils.GetInventoryHash()
    data.lastProfCount = HCP.Utils.GetProfessionCount()

    HardcorePlus:Print(c.GOLD .. "══ SOFT RESET COMPLETE ══" .. c.CLOSE)
    HardcorePlus:Print(c.PURPLE .. "Soft Reset x" .. data.softResets .. c.CLOSE ..
        c.DIM .. " — permanent tag applied." .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Reputation remains (cannot be removed in TBC). " ..
        "This is documented and accepted." .. c.CLOSE)

    -- Broadcast to network
    HardcorePlus:SendMessage("HCP_SOFT_RESET_COMPLETE", data.softResets)

    return true
end

-- ═══════════════════════════════════════════
--  Time Window Check
-- ═══════════════════════════════════════════

function SoftReset:GetWindowRemaining()
    local data = HCP.db.char
    if not data.softResetInProgress then return nil end

    local elapsed = data.playedTotal - data.softResetStartPlayed
    local remaining = HCP.SoftResetConfig.COMPLETION_WINDOW - elapsed
    return math.max(0, remaining), elapsed
end

function SoftReset:IsInProgress()
    return HCP.db.char.softResetInProgress
end

-- ═══════════════════════════════════════════
--  Item Restoration Detection
-- ═══════════════════════════════════════════

--- Check if any deleted items reappeared (Blizzard item restore abuse).
-- Run periodically after a soft reset is completed.
function SoftReset:CheckRestoredItems()
    local data = HCP.db.char
    if data.softResets == 0 then return end
    if #data.deletedItemHashes == 0 then return end

    local restoredFound = {}

    -- Scan current inventory for items matching deleted hashes
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local hash = HCP.Utils.SimpleHash(link)
                for _, deletedHash in ipairs(data.deletedItemHashes) do
                    if hash == deletedHash then
                        table.insert(restoredFound, link)
                        break
                    end
                end
            end
        end
    end

    -- Check equipped
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local hash = HCP.Utils.SimpleHash(link)
            for _, deletedHash in ipairs(data.deletedItemHashes) do
                if hash == deletedHash then
                    table.insert(restoredFound, link)
                    break
                end
            end
        end
    end

    if #restoredFound > 0 then
        local c = HCP.CC
        HardcorePlus:Print(c.RED .. "══ RESTORED ITEMS DETECTED ══" .. c.CLOSE)
        HardcorePlus:Print(c.RED .. "Items deleted during soft reset have reappeared!" .. c.CLOSE)
        for _, link in ipairs(restoredFound) do
            HardcorePlus:Print(c.RED .. "  • " .. link .. c.CLOSE)
        end
        HardcorePlus:Print(c.RED .. "HC status VOIDED — item restoration after soft reset is not allowed." .. c.CLOSE)

        -- Void the character
        table.insert(data.suspiciousFlags, {
            timestamp = HCP.Utils.GetTimestamp(),
            severity = "major",
            reason = "Restored items detected after soft reset",
            details = { #restoredFound .. " item(s) restored" },
        })

        HCP.VerificationTracker:TransitionStatus(HCP.Status.DEAD,
            "Item restoration detected after Soft Reset #" .. data.softResets)

        HardcorePlus:SendMessage("HCP_VIOLATION", {
            severity = "major",
            reason = "Item restoration after soft reset",
        })
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Periodically check for restored items after soft reset
    if HCP.db.char.softResets > 0 and #HCP.db.char.deletedItemHashes > 0 then
        HardcorePlus:ScheduleRepeatingTimer(function()
            SoftReset:CheckRestoredItems()
        end, 300)  -- every 5 minutes

        -- Also check on login
        HardcorePlus:ScheduleTimer(function()
            SoftReset:CheckRestoredItems()
        end, 10)
    end

    -- Update /played for window tracking during soft reset
    if HCP.db.char.softResetInProgress then
        HardcorePlus:RegisterMessage("HCP_TIME_PLAYED", function(_, totalPlayed)
            local data = HCP.db.char
            if data.softResetInProgress then
                local remaining = SoftReset:GetWindowRemaining()
                if remaining and remaining <= 0 then
                    local c = HCP.CC
                    HardcorePlus:Print(c.RED .. "Soft reset window expired!" .. c.CLOSE)
                    data.softResetInProgress = false
                end
            end
        end)
    end
end)
