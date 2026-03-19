--[[
    HardcorePlus — Equipment Tracker
    Monitors equipment changes across all armor/weapon slots.
    Logs item swaps with timestamps and item links.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local EquipmentTracker = {}
HCP.EquipmentTracker = EquipmentTracker

-- ═══════════════════════════════════════════
--  Equipment Slot Tracking
-- ═══════════════════════════════════════════

local currentEquipment = {}

local EQUIPMENT_SLOTS = {
    "head",
    "neck",
    "shoulder",
    "chest",
    "waist",
    "legs",
    "feet",
    "wrist",
    "hands",
    "finger0",
    "finger1",
    "trinket0",
    "trinket1",
    "back",
    "main",
    "off",
    "ranged",
}

local function OnPlayerEquipmentChanged(slot, hasItem)
    if not HCP.Utils.IsSystemEnabled("equipmentTracking") then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.equipmentTracker = HCP.db.char.trackerData.equipmentTracker or {
        changes = {},
    }

    -- Get old and new item
    local oldItem = currentEquipment[slot] or nil
    local newItem = GetInventoryItemLink("player", slot) or nil

    -- Only record if item actually changed
    if oldItem ~= newItem then
        local change = {
            timestamp = HCP.Utils.GetTimestamp(),
            slot = slot,
            oldItem = oldItem,
            newItem = newItem,
        }
        table.insert(HCP.db.char.trackerData.equipmentTracker.changes, change)
        -- Cap at 500 entries
        while #HCP.db.char.trackerData.equipmentTracker.changes > 500 do
            table.remove(HCP.db.char.trackerData.equipmentTracker.changes, 1)
        end

        -- Update current equipment
        if newItem then
            currentEquipment[slot] = newItem
        else
            currentEquipment[slot] = nil
        end
    end
end

local function CaptureCurrentEquipment()
    currentEquipment = {}

    -- Map numeric slot indices to slot names
    local slotMap = {
        "head",     -- 1
        "neck",     -- 2
        "shoulder", -- 3
        "chest",    -- 5
        "waist",    -- 6
        "legs",     -- 7
        "feet",     -- 8
        "wrist",    -- 9
        "hands",    -- 10
        "finger0",  -- 11
        "finger1",  -- 12
        "trinket0", -- 13
        "trinket1", -- 14
        "back",     -- 15
        "main",     -- 16
        "off",      -- 17
        "ranged",   -- 18
    }

    for idx, slotName in ipairs(slotMap) do
        local link = GetInventoryItemLink("player", idx)
        if link then
            currentEquipment[slotName] = link
        end
    end
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function EquipmentTracker:GetEquipmentChanges(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.equipmentTracker then
        return {}
    end

    limit = limit or 50
    local changes = HCP.db.char.trackerData.equipmentTracker.changes
    local result = {}

    local startIdx = math.max(1, #changes - limit + 1)
    for i = startIdx, #changes do
        table.insert(result, changes[i])
    end

    return result
end

function EquipmentTracker:GetTotalChanges()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.equipmentTracker then
        return 0
    end
    return #HCP.db.char.trackerData.equipmentTracker.changes
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.equipmentTracker = HCP.db.char.trackerData.equipmentTracker or {
        changes = {},
    }

    -- Capture initial equipment state
    CaptureCurrentEquipment()

    HardcorePlus:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function(_, slot, hasItem)
        OnPlayerEquipmentChanged(slot, hasItem)
    end)
end)
