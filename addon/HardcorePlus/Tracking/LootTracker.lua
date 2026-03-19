--[[
    HardcorePlus — Loot Tracker
    Monitors looted items from mobs, chests, and other containers.
    Tracks timestamp, zone, item links, and quantities looted.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local LootTracker = {}
HCP.LootTracker = LootTracker

-- ═══════════════════════════════════════════
--  Loot State Tracking
-- ═══════════════════════════════════════════

local lootActive = false
local currentLoot = {}

local function OnLootOpened()
    if not HCP.Utils.IsSystemEnabled("lootTracking") then
        return
    end

    lootActive = true
    currentLoot = {}

    -- Collect all loot items currently visible
    local numLootItems = GetNumLootItems()
    for i = 1, numLootItems do
        local link = GetLootSlotLink(i)
        if link then
            local quantity = select(3, GetLootSlotInfo(i))
            table.insert(currentLoot, {
                link = link,
                quantity = quantity or 1,
            })
        end
    end
end

local function OnLootClosed()
    if not HCP.Utils.IsSystemEnabled("lootTracking") then
        return
    end

    if not lootActive or #currentLoot == 0 then
        lootActive = false
        currentLoot = {}
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.lootTracker = HCP.db.char.trackerData.lootTracker or {
        loots = {},
        totalItems = 0,
    }

    -- Record loot
    local zoneInfo = HCP.Utils.GetZoneInfo()
    local loot = {
        timestamp = HCP.Utils.GetTimestamp(),
        zone = zoneInfo.zone,
        items = HCP.Utils.DeepCopy(currentLoot),
    }

    local data = HCP.db.char.trackerData.lootTracker
    table.insert(data.loots, loot)
    -- Cap at 300 entries
    while #data.loots > 300 do
        table.remove(data.loots, 1)
    end

    -- Count items
    for _, item in ipairs(currentLoot) do
        data.totalItems = data.totalItems + (item.quantity or 1)
    end

    lootActive = false
    currentLoot = {}
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function LootTracker:GetLootHistory(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.lootTracker then
        return {}
    end

    limit = limit or 50
    local loots = HCP.db.char.trackerData.lootTracker.loots
    local result = {}

    local startIdx = math.max(1, #loots - limit + 1)
    for i = startIdx, #loots do
        table.insert(result, loots[i])
    end

    return result
end

function LootTracker:GetLootStats()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.lootTracker then
        return { totalLoots = 0, totalItems = 0 }
    end

    local data = HCP.db.char.trackerData.lootTracker
    return {
        totalLoots = #data.loots,
        totalItems = data.totalItems,
    }
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.lootTracker = HCP.db.char.trackerData.lootTracker or {
        loots = {},
        totalItems = 0,
    }

    HardcorePlus:RegisterEvent("LOOT_OPENED", function()
        OnLootOpened()
    end)

    HardcorePlus:RegisterEvent("LOOT_CLOSED", function()
        OnLootClosed()
    end)
end)
