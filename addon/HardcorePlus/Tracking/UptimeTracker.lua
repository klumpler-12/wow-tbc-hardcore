--[[
    HardcorePlus — Uptime Tracker (Phase 2)
    Monitors addon session time vs /played to detect gaps.
    Implements tiered violation system: minor (gap only) vs major (gap + gains).
    Gap analysis compares inventory, gold, level, professions before/after.
    Fires HCP_VIOLATION for other modules to react.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local UptimeTracker = {}
HCP.UptimeTracker = UptimeTracker

-- ═══════════════════════════════════════════
--  Session & /played Tracking
-- ═══════════════════════════════════════════

local sessionStartTime = 0
local playedAtLogin = nil       -- set by first TIME_PLAYED_MSG
local pendingPlayedCheck = false
local PLAYED_CHECK_INTERVAL = 120  -- request /played every 2 min

local PLAYED_CHECK_TIMEOUT = 30  -- seconds before resetting stuck flag

local function PeriodicPlayedRequest()
    if not pendingPlayedCheck then
        pendingPlayedCheck = true
        -- Bump suppress counter so ChatFrame_DisplayTimePlayed hook swallows the output
        HCP._suppressPlayedCount = math.min(
            (HCP._suppressPlayedCount or 0) + 1,
            HCP._suppressPlayedCountMax or 2
        )
        RequestTimePlayed()
        -- Safety: reset flag if TIME_PLAYED_MSG never arrives (loading screen, disconnect)
        HardcorePlus:ScheduleTimer(function()
            if pendingPlayedCheck then
                pendingPlayedCheck = false
            end
        end, PLAYED_CHECK_TIMEOUT)
    end
end

-- ═══════════════════════════════════════════
--  Gap Detection (runs on login after TIME_PLAYED_MSG)
-- ═══════════════════════════════════════════

function UptimeTracker:AnalyzeGap(gapMinutes)
    if not HCP.db.char.registered then return end
    if not HCP.Utils.IsSystemEnabled("uptimeTracking") then
        HCP.Utils.DebugLog("Uptime tracking disabled — gap ignored (", gapMinutes, " min)")
        return
    end

    local data = HCP.db.char
    local c = HCP.CC
    local graceMinutes = HCP.Violations.GRACE_MINUTES

    -- Under grace threshold → ignore
    if gapMinutes < graceMinutes then return end

    -- Snapshot current state
    local currentHash = HCP.Utils.GetInventoryHash()
    local currentGold = HCP.Utils.GetGold()
    local currentLevel = HCP.Utils.GetLevel()
    local currentProfs = HCP.Utils.GetProfessionCount()

    -- Compare against last-known state (stored at end of previous session / on enable)
    local hashChanged = currentHash ~= data.lastInventoryHash
    local goldChanged = math.abs(currentGold - data.lastGold) > 100  -- >1s tolerance
    local levelChanged = currentLevel > data.lastLevel
    local profChanged = currentProfs > data.lastProfCount

    local hasGains = hashChanged or goldChanged or levelChanged or profChanged

    -- Build violation record
    local violation = {
        timestamp = HCP.Utils.GetTimestamp(),
        gapMinutes = gapMinutes,
        hasGains = hasGains,
        details = {},
    }

    if hashChanged then table.insert(violation.details, "Inventory changed") end
    if goldChanged then
        local diff = currentGold - data.lastGold
        table.insert(violation.details, "Gold " ..
            (diff > 0 and "+" or "") .. HCP.Utils.FormatGold(diff))
    end
    if levelChanged then
        table.insert(violation.details, "Level " .. data.lastLevel .. " → " .. currentLevel)
    end
    if profChanged then
        table.insert(violation.details, "New professions learned")
    end

    -- Classify: minor vs major
    if hasGains then
        violation.severity = "major"
        -- Major: gains during gap. Resolution depends on peer confirmation.
        -- For now (pre-network), flag as critical — Phase 4 will add peer resolution.
        HardcorePlus:Print(c.RED .. "══ MAJOR VIOLATION ══" .. c.CLOSE)
        HardcorePlus:Print(c.RED .. "Addon was disabled for " .. gapMinutes ..
            " min with gains detected!" .. c.CLOSE)
        for _, detail in ipairs(violation.details) do
            HardcorePlus:Print(c.RED .. "  • " .. detail .. c.CLOSE)
        end
        HardcorePlus:Print(c.DIM .. "Awaiting peer confirmation. Without peer verification " ..
            "of survival, this may result in permadeath." .. c.CLOSE)
    else
        violation.severity = "minor"
        -- Minor: gap only, no gains. Count toward weekly threshold.
        data.minorViolations = data.minorViolations + 1

        HardcorePlus:Print(c.GOLD .. "══ MINOR VIOLATION ══" .. c.CLOSE)
        HardcorePlus:Print(c.GOLD .. "Addon was disabled for " .. gapMinutes ..
            " min (no gains detected)." .. c.CLOSE)
        HardcorePlus:Print(c.DIM .. "Minor violations this week: " ..
            data.minorViolations .. "/" .. HCP.Violations.MINOR_WEEKLY_MAX .. c.CLOSE)

        -- Escalation check
        if data.minorViolations >= HCP.Violations.MINOR_WEEKLY_MAX then
            HardcorePlus:Print(c.RED .. "WARNING: Systematic addon disabling pattern detected! " ..
                "Further gaps will be treated as major violations." .. c.CLOSE)
            violation.escalated = true
        end
    end

    -- Store flag
    table.insert(data.suspiciousFlags, violation)

    -- Update snapshots to current state
    data.lastInventoryHash = currentHash
    data.lastGold = currentGold
    data.lastLevel = currentLevel
    data.lastProfCount = currentProfs

    -- Fire event for other modules
    HardcorePlus:SendMessage("HCP_VIOLATION", violation)
end

-- ═══════════════════════════════════════════
--  Weekly Violation Reset
-- ═══════════════════════════════════════════

local function CheckWeeklyReset()
    local data = HCP.db.char
    -- WoW weekly reset is Tuesday. Unix epoch (Jan 1 1970) was a Thursday.
    -- Offset by 4 days (345600 seconds) so week boundaries align with Tuesday.
    local TUESDAY_OFFSET = 345600  -- 4 days in seconds (Thu→Tue)
    local currentWeek = math.floor((HCP.Utils.GetTimestamp() - TUESDAY_OFFSET) / (7 * 86400))
    if data.violationResetWeek ~= currentWeek then
        data.violationResetWeek = currentWeek
        data.minorViolations = 0
    end
end

-- ═══════════════════════════════════════════
--  Populate Flags Tab in Main Panel
-- ═══════════════════════════════════════════

function UptimeTracker:PopulateFlagsLog(contentFrame)
    -- Clear existing
    local children = { contentFrame:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
    local regions = { contentFrame:GetRegions() }
    for _, region in ipairs(regions) do
        if region.SetText then region:SetText("") end
    end
    if contentFrame.placeholder then contentFrame.placeholder:Hide() end

    local c = HCP.CC
    local flags = HCP.db.char.suspiciousFlags
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

    if #flags == 0 then
        Line(c.GREEN .. "No violations recorded. Clean record!" .. c.CLOSE)
        return
    end

    Line(c.GOLD .. "Violation Log" .. c.CLOSE .. c.DIM .. " (" .. #flags .. " total)" .. c.CLOSE)
    Line(c.DIM .. "Minor this week: " .. HCP.db.char.minorViolations ..
        "/" .. HCP.Violations.MINOR_WEEKLY_MAX .. c.CLOSE)
    yOff = yOff - 4

    -- Show last 10 flags
    for i = #flags, math.max(1, #flags - 9), -1 do
        local f = flags[i]
        local sevColor = f.severity == "major" and c.RED or c.GOLD
        Line(sevColor .. "#" .. i .. " [" .. (f.severity or "?"):upper() .. "]" .. c.CLOSE ..
            "  " .. c.DIM .. "Gap: " .. (f.gapMinutes or "?") .. " min" ..
            (f.hasGains and (" | " .. c.RED .. "GAINS" .. c.CLOSE) or "") ..
            " | " .. HCP.Utils.FormatDate(f.timestamp) .. c.CLOSE)

        if f.details and #f.details > 0 then
            for _, detail in ipairs(f.details) do
                Line("    " .. c.DIM .. "• " .. detail .. c.CLOSE)
            end
        end

        if f.escalated then
            Line("    " .. c.RED .. "↑ ESCALATED — systematic pattern" .. c.CLOSE)
        end
        yOff = yOff - 4
    end
end

-- ═══════════════════════════════════════════
--  Session Info for Overview Tab
-- ═══════════════════════════════════════════

function UptimeTracker:GetSessionInfo()
    local data = HCP.db.char
    local uptime = 0
    if sessionStartTime > 0 then
        uptime = HCP.Utils.GetTimestamp() - sessionStartTime
    end
    return {
        sessionCount = #data.sessions,
        currentUptime = uptime,
        totalPlayed = data.playedTotal,
        minorViolations = data.minorViolations,
        totalFlags = #data.suspiciousFlags,
    }
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    sessionStartTime = HCP.Utils.GetTimestamp()
    CheckWeeklyReset()

    -- Periodic /played requests to keep tracking accurate
    HardcorePlus:ScheduleRepeatingTimer(PeriodicPlayedRequest, PLAYED_CHECK_INTERVAL)

    -- Listen for gap detection from Core.lua's OnTimePlayed
    HardcorePlus:RegisterMessage("HCP_ADDON_GAP_DETECTED", function(_, gapMinutes)
        UptimeTracker:AnalyzeGap(gapMinutes)
    end)

    -- Update snapshots when /played comes in
    HardcorePlus:RegisterMessage("HCP_TIME_PLAYED", function()
        pendingPlayedCheck = false
    end)
end)

-- Populate flags tab when selected
HardcorePlus:RegisterMessage("HCP_TAB_SELECTED", function(_, tabId)
    if tabId == "flags" and HCP.MainPanel then
        local cf = HCP.MainPanel:GetContentFrame("flags")
        if cf then
            UptimeTracker:PopulateFlagsLog(cf)
        end
    end
end)
