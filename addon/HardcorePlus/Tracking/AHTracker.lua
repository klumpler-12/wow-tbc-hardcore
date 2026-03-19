--[[
    HardcorePlus — Auction House Tracker
    Monitors auction house visits and session duration.
    Tracks visit timestamps and time spent in AH.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local AHTracker = {}
HCP.AHTracker = AHTracker

-- ═══════════════════════════════════════════
--  AH Visit Tracking
-- ═══════════════════════════════════════════

local ahOpenTime = nil

local function OnAuctionHouseShow()
    if not HCP.Utils.IsSystemEnabled("ahTracking") then
        return
    end

    ahOpenTime = HCP.Utils.GetTimestamp()
end

local function OnAuctionHouseClosed()
    if not HCP.Utils.IsSystemEnabled("ahTracking") then
        return
    end

    if not ahOpenTime then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.ahTracker = HCP.db.char.trackerData.ahTracker or {
        visits = {},
        totalVisits = 0,
    }

    local closeTime = HCP.Utils.GetTimestamp()
    local duration = closeTime - ahOpenTime

    local visit = {
        timestamp = ahOpenTime,
        duration = duration,
    }

    local data = HCP.db.char.trackerData.ahTracker
    table.insert(data.visits, visit)
    -- Cap at 200 entries
    while #data.visits > 200 do
        table.remove(data.visits, 1)
    end
    data.totalVisits = data.totalVisits + 1

    ahOpenTime = nil
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function AHTracker:GetVisitHistory(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.ahTracker then
        return {}
    end

    limit = limit or 50
    local visits = HCP.db.char.trackerData.ahTracker.visits
    local result = {}

    local startIdx = math.max(1, #visits - limit + 1)
    for i = startIdx, #visits do
        table.insert(result, visits[i])
    end

    return result
end

function AHTracker:GetAHStats()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.ahTracker then
        return { totalVisits = 0, totalTime = 0 }
    end

    local data = HCP.db.char.trackerData.ahTracker
    local totalTime = 0

    for _, visit in ipairs(data.visits) do
        totalTime = totalTime + visit.duration
    end

    return {
        totalVisits = data.totalVisits,
        totalTime = totalTime,
    }
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.ahTracker = HCP.db.char.trackerData.ahTracker or {
        visits = {},
        totalVisits = 0,
    }

    HardcorePlus:RegisterEvent("AUCTION_HOUSE_SHOW", function()
        OnAuctionHouseShow()
    end)

    HardcorePlus:RegisterEvent("AUCTION_HOUSE_CLOSED", function()
        OnAuctionHouseClosed()
    end)
end)
