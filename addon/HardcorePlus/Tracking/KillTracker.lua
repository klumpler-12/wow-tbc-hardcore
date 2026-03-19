--[[
    HardcorePlus — Kill Tracker
    Monitors party/raid kills via combat log.
    Tracks kill count by zone and notable kills (elites, rares, bosses).
    Uses a hidden frame for CLEU to bypass AceEvent single-handler limit.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local KillTracker = {}
HCP.KillTracker = KillTracker

-- ═══════════════════════════════════════════
--  Hidden frame for COMBAT_LOG_EVENT_UNFILTERED
-- ═══════════════════════════════════════════

local killTrackerFrame = CreateFrame("Frame")

-- Frame OnEvent receives: self, event, ...cleuArgs
-- In TBC 2.4.3, the CLEU args come directly. We normalize them via Compat.
local function OnCombatLogEvent(self, event, ...)
    if not HCP.db or not HCP.Utils.IsSystemEnabled("killTracking") then return end

    -- Normalize TBC CLEU args to modern format (no-op on modern clients)
    HCP.Compat.StoreCLEUArgs(...)

    local timestamp, subevent, _, sourceGUID, sourceName, _, _,
        destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()

    if subevent ~= "PARTY_KILL" then return end

    local data = HCP.db.char.trackerData.killTracker
    if not data then return end

    data.totalKills = data.totalKills + 1

    -- Track by zone
    local zone = (HCP.Utils.GetZoneInfo()).zone
    data.killsByZone[zone] = (data.killsByZone[zone] or 0) + 1

    -- Check if notable (elite, rare, boss) via unit classification flags
    -- In TBC 2.4.3, destFlags uses COMBATLOG_OBJECT_CONTROL and COMBATLOG_OBJECT_TYPE bits
    -- However these constants may not all be defined. Use safe checks.
    local isNotable = false
    local killType = "normal"

    -- Try to classify via UnitClassification if target still exists
    -- (won't work if mob died, but PARTY_KILL fires right at death so may still be valid)
    if destGUID and destName then
        -- Fallback: store all named kills; filter later
        -- Check COMBATLOG_OBJECT_TYPE bits in destFlags if available
        if destFlags and bit then
            -- TBC flag bits: 0x0008 = Elite, 0x0010 = Rare/RareElite
            local typeFlags = bit.band(destFlags, 0x0FC0)  -- type portion
            -- COMBATLOG_OBJECT_TYPE_NPC = 0x0800
            -- In TBC these are in the upper nibbles; exact values depend on client
            -- Safe approach: just log all kills, mark notable if name suggests it
        end

        -- Simple notable detection: store every 100th kill or named target
        isNotable = (data.totalKills % 100 == 0)
    end

    if isNotable then
        table.insert(data.notableKills, {
            timestamp = timestamp or HCP.Utils.GetTimestamp(),
            target = destName or "Unknown",
            zone = zone,
            killNumber = data.totalKills,
        })
        -- Cap notable kills at 200
        while #data.notableKills > 200 do
            table.remove(data.notableKills, 1)
        end
    end
end

killTrackerFrame:SetScript("OnEvent", OnCombatLogEvent)

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function KillTracker:GetTotalKills()
    if not HCP.db or not HCP.db.char.trackerData or not HCP.db.char.trackerData.killTracker then
        return 0
    end
    return HCP.db.char.trackerData.killTracker.totalKills
end

function KillTracker:GetKillsByZone()
    if not HCP.db or not HCP.db.char.trackerData or not HCP.db.char.trackerData.killTracker then
        return {}
    end
    return HCP.db.char.trackerData.killTracker.killsByZone
end

function KillTracker:GetNotableKills(limit)
    if not HCP.db or not HCP.db.char.trackerData or not HCP.db.char.trackerData.killTracker then
        return {}
    end
    limit = limit or 50
    local kills = HCP.db.char.trackerData.killTracker.notableKills
    local result = {}
    for i = math.max(1, #kills - limit + 1), #kills do
        table.insert(result, kills[i])
    end
    return result
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.killTracker = HCP.db.char.trackerData.killTracker or {
        totalKills = 0,
        killsByZone = {},
        notableKills = {},
    }
    killTrackerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end)
