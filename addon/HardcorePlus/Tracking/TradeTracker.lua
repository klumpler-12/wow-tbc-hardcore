--[[
    HardcorePlus — Trade Tracker
    Monitors completed trades and logs what was exchanged.
    Tracks trade partners, items given/received, and timestamps.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local TradeTracker = {}
HCP.TradeTracker = TradeTracker

-- ═══════════════════════════════════════════
--  Trade State Tracking
-- ═══════════════════════════════════════════

local tradeActive = false
local tradePartner = nil

local function OnTradeShow()
    if not HCP.Utils.IsSystemEnabled("tradeTracking") then
        return
    end

    tradeActive = true
    tradePartner = UnitName("NPC") or "Unknown"
end

local function OnTradeClosed()
    tradeActive = false
    tradePartner = nil
end

local function OnTradeAcceptUpdate()
    if not HCP.Utils.IsSystemEnabled("tradeTracking") then
        return
    end

    -- Check if both players have accepted (trade is completing)
    local playerAccepted = GetTradePlayerItemLink(1) ~= nil or GetTradePlayerItemLink(2) ~= nil or
                          GetTradePlayerItemLink(3) ~= nil or GetTradePlayerItemLink(4) ~= nil or
                          GetTradePlayerItemLink(5) ~= nil or GetTradePlayerItemLink(6) ~= nil
    local targetAccepted = GetTradeTargetItemLink(1) ~= nil or GetTradeTargetItemLink(2) ~= nil or
                          GetTradeTargetItemLink(3) ~= nil or GetTradeTargetItemLink(4) ~= nil or
                          GetTradeTargetItemLink(5) ~= nil or GetTradeTargetItemLink(6) ~= nil

    if playerAccepted and targetAccepted then
        -- Trade is completing — log it
        RecordTrade()
    end
end

function RecordTrade()
    if not tradeActive or not tradePartner then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.tradeTracker = HCP.db.char.trackerData.tradeTracker or {
        trades = {},
    }

    -- Collect player items given
    local given = {}
    for i = 1, 6 do
        local link = GetTradePlayerItemLink(i)
        if link then
            table.insert(given, {
                link = link,
                quantity = GetTradePlayerItemInfo(i),
            })
        end
    end

    -- Collect target items received
    local received = {}
    for i = 1, 6 do
        local link = GetTradeTargetItemLink(i)
        if link then
            table.insert(received, {
                link = link,
                quantity = GetTradeTargetItemInfo(i),
            })
        end
    end

    -- Only log if items actually exchanged
    if #given > 0 or #received > 0 then
        local trade = {
            timestamp = HCP.Utils.GetTimestamp(),
            partner = tradePartner,
            given = given,
            received = received,
        }
        table.insert(HCP.db.char.trackerData.tradeTracker.trades, trade)
        -- Cap at 200 entries
        while #HCP.db.char.trackerData.tradeTracker.trades > 200 do
            table.remove(HCP.db.char.trackerData.tradeTracker.trades, 1)
        end
    end
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function TradeTracker:GetTradeHistory(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.tradeTracker then
        return {}
    end

    limit = limit or 50
    local trades = HCP.db.char.trackerData.tradeTracker.trades
    local result = {}

    local startIdx = math.max(1, #trades - limit + 1)
    for i = startIdx, #trades do
        table.insert(result, trades[i])
    end

    return result
end

function TradeTracker:GetTotalTrades()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.tradeTracker then
        return 0
    end
    return #HCP.db.char.trackerData.tradeTracker.trades
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.tradeTracker = HCP.db.char.trackerData.tradeTracker or {
        trades = {},
    }

    HardcorePlus:RegisterEvent("TRADE_SHOW", function()
        OnTradeShow()
    end)

    HardcorePlus:RegisterEvent("TRADE_CLOSED", function()
        OnTradeClosed()
    end)

    HardcorePlus:RegisterEvent("TRADE_ACCEPT_UPDATE", function()
        OnTradeAcceptUpdate()
    end)
end)
