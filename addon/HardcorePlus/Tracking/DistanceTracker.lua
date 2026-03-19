--[[
    HardcorePlus — Distance Tracker
    Monitors zone transitions and zones visited.
    Tracks zone changes and unique zones visited during session.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local DistanceTracker = {}
HCP.DistanceTracker = DistanceTracker

-- ═══════════════════════════════════════════
--  Zone Tracking
-- ═══════════════════════════════════════════

local currentZone = nil

local function OnZoneChanged()
    if not HCP.Utils.IsSystemEnabled("distanceTracking") then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.distanceTracker = HCP.db.char.trackerData.distanceTracker or {
        zoneChanges = 0,
        zonesVisited = {},
    }

    local zoneInfo = HCP.Utils.GetZoneInfo()
    local zone = zoneInfo.zone

    -- Only count if zone actually changed
    if zone ~= currentZone then
        currentZone = zone
        local data = HCP.db.char.trackerData.distanceTracker

        -- Increment zone changes
        data.zoneChanges = data.zoneChanges + 1

        -- Track unique zones
        if not data.zonesVisited[zone] then
            data.zonesVisited[zone] = true
        end
    end
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function DistanceTracker:GetZoneStats()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.distanceTracker then
        return { zoneChanges = 0, uniqueZones = 0 }
    end

    local data = HCP.db.char.trackerData.distanceTracker
    local uniqueCount = 0

    for _ in pairs(data.zonesVisited) do
        uniqueCount = uniqueCount + 1
    end

    return {
        zoneChanges = data.zoneChanges,
        uniqueZones = uniqueCount,
    }
end

function DistanceTracker:GetZonesVisited()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.distanceTracker then
        return {}
    end

    local visited = {}
    for zone, _ in pairs(HCP.db.char.trackerData.distanceTracker.zonesVisited) do
        table.insert(visited, zone)
    end

    table.sort(visited)
    return visited
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.distanceTracker = HCP.db.char.trackerData.distanceTracker or {
        zoneChanges = 0,
        zonesVisited = {},
    }

    -- Set initial zone
    local zoneInfo = HCP.Utils.GetZoneInfo()
    currentZone = zoneInfo.zone
    HCP.db.char.trackerData.distanceTracker.zonesVisited[currentZone] = true

    HardcorePlus:RegisterEvent("ZONE_CHANGED", function()
        OnZoneChanged()
    end)

    HardcorePlus:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        OnZoneChanged()
    end)
end)
