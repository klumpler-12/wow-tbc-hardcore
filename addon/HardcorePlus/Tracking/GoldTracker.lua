--[[
    HardcorePlus — Gold Tracker
    Monitors gold changes and stores snapshots of gold at each change.
    Tracks session gold gain/loss and historical gold data.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local GoldTracker = {}
HCP.GoldTracker = GoldTracker

-- ═══════════════════════════════════════════
--  Gold Tracking
-- ═══════════════════════════════════════════

local lastGoldAmount = 0

local function OnPlayerMoney()
    if not HCP.Utils.IsSystemEnabled("goldTracking") then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.goldTracker = HCP.db.char.trackerData.goldTracker or {
        snapshots = {},
        sessionStart = HCP.Utils.GetTimestamp(),
    }

    local currentGold = HCP.Utils.GetGold()
    local delta = currentGold - lastGoldAmount
    lastGoldAmount = currentGold

    -- Only record if there was actual change
    if delta ~= 0 then
        local snapshot = {
            timestamp = HCP.Utils.GetTimestamp(),
            amount = currentGold,
            delta = delta,
        }
        table.insert(HCP.db.char.trackerData.goldTracker.snapshots, snapshot)
        -- Cap at 500 entries
        while #HCP.db.char.trackerData.goldTracker.snapshots > 500 do
            table.remove(HCP.db.char.trackerData.goldTracker.snapshots, 1)
        end
    end
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function GoldTracker:GetSessionGold()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.goldTracker then
        return 0
    end

    local data = HCP.db.char.trackerData.goldTracker
    if #data.snapshots == 0 then
        return 0
    end

    -- Session gold = current - snapshot at session start
    local currentGold = HCP.Utils.GetGold()
    return currentGold - (HCP.Utils.GetGold() - data.snapshots[1].delta)
end

function GoldTracker:GetGoldHistory(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.goldTracker then
        return {}
    end

    limit = limit or 50
    local data = HCP.db.char.trackerData.goldTracker
    local snapshots = data.snapshots
    local result = {}

    -- Return last N snapshots
    local startIdx = math.max(1, #snapshots - limit + 1)
    for i = startIdx, #snapshots do
        table.insert(result, snapshots[i])
    end

    return result
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    lastGoldAmount = HCP.Utils.GetGold()

    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.goldTracker = HCP.db.char.trackerData.goldTracker or {
        snapshots = {},
        sessionStart = HCP.Utils.GetTimestamp(),
    }

    HardcorePlus:RegisterEvent("PLAYER_MONEY", function()
        OnPlayerMoney()
    end)
end)
