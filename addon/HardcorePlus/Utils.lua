--[[
    HardcorePlus — Utils
    Shared utility functions.
]]

local ADDON_NAME, HCP = ...

HCP.Utils = {}

-- Format seconds into readable time (1h 23m 45s)
function HCP.Utils.FormatTime(seconds)
    if not seconds or seconds < 0 then return "0s" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then
        return string.format("%dh %dm %ds", h, m, s)
    elseif m > 0 then
        return string.format("%dm %ds", m, s)
    else
        return string.format("%ds", s)
    end
end

-- Format gold amount (copper → Xg Ys Zc). Supports negative values.
function HCP.Utils.FormatGold(copper)
    if not copper then copper = 0 end
    local prefix = ""
    if copper < 0 then
        prefix = "-"
        copper = math.abs(copper)
    end
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop = copper % 100
    if gold > 0 then
        return prefix .. string.format("%dg %ds %dc", gold, silver, cop)
    elseif silver > 0 then
        return prefix .. string.format("%ds %dc", silver, cop)
    else
        return prefix .. string.format("%dc", cop)
    end
end

-- Simple string hash for inventory comparison
function HCP.Utils.SimpleHash(str)
    if not str then return 0 end
    local hash = 5381
    for i = 1, #str do
        hash = ((hash * 33) + string.byte(str, i)) % 2147483647
    end
    return hash
end

-- Deep copy a table
function HCP.Utils.DeepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[HCP.Utils.DeepCopy(k)] = HCP.Utils.DeepCopy(v)
    end
    return setmetatable(copy, getmetatable(orig))
end

-- Get current timestamp. TBC Classic 2.5.x does not have GetServerTime(),
-- so we use time() which returns local system epoch time.
function HCP.Utils.GetTimestamp()
    return time()
end

-- Format a timestamp for display (server time, consistent across clients)
function HCP.Utils.FormatDate(timestamp, fmt)
    fmt = fmt or "%m/%d %H:%M"
    return date(fmt, timestamp or 0)
end

-- Colorize text with HCP color codes
function HCP.Utils.Colorize(text, colorCode)
    return colorCode .. text .. HCP.CC.CLOSE
end

-- Get player's full name-realm
function HCP.Utils.GetPlayerKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    return name .. "-" .. realm
end

-- Check if player is in an instance
function HCP.Utils.IsInInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance, instanceType
end

-- Get instance info via GetInstanceInfo().
-- On TBC 2.4.3: polyfilled by Compat.lua using GetRealZoneText() + GetInstanceDifficulty().
-- Returns: name, instanceType, difficultyID, difficultyName, maxPlayers
-- difficultyID: 1 = Normal, 2 = Heroic for 5-man dungeons
function HCP.Utils.GetInstanceData()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return nil
    end
    local name, iType, difficultyID, difficultyName, maxPlayers = GetInstanceInfo()
    return {
        name = name or "Unknown",
        instanceType = iType or instanceType,  -- "party", "raid", "arena", "pvp"
        difficultyID = difficultyID or 0,
        difficultyName = difficultyName or "",
        maxPlayers = maxPlayers or 0,
        isHeroic = (iType == "party" and difficultyID == 2),
    }
end

-- Check if player is in a heroic dungeon.
-- difficultyID: 1=Normal, 2=Heroic for 5-man dungeons in TBC.
function HCP.Utils.IsHeroicDungeon()
    local data = HCP.Utils.GetInstanceData()
    if not data then return false end
    return data.isHeroic
end

-- Get current zone info.
-- Inside instances, uses GetInstanceInfo() for the canonical instance name.
-- On TBC 2.4.3: polyfilled by Compat.lua (returns GetRealZoneText()).
function HCP.Utils.GetZoneInfo()
    local inInstance = IsInInstance()
    local zone

    if inInstance then
        -- GetInstanceInfo() returns the top-level instance name, never a subzone
        zone = select(1, GetInstanceInfo()) or GetRealZoneText() or "Unknown"
    else
        zone = GetRealZoneText() or "Unknown"
    end

    return {
        zone = zone,
        subzone = GetSubZoneText() or "",
        mapID = (C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")) or 0,
    }
end

-- Count items in all bags
function HCP.Utils.CountBagItems()
    local count = 0
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            if GetContainerItemLink(bag, slot) then
                count = count + 1
            end
        end
    end
    return count
end

-- Generate inventory hash (bags + equipped)
function HCP.Utils.GetInventoryHash()
    local parts = {}

    -- Bags
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, count = GetContainerItemInfo(bag, slot)
                table.insert(parts, link .. "x" .. (count or 1))
            end
        end
    end

    -- Equipped gear
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            table.insert(parts, "eq" .. slot .. ":" .. link)
        end
    end

    return HCP.Utils.SimpleHash(table.concat(parts, "|"))
end

-- Get gold amount
function HCP.Utils.GetGold()
    return GetMoney() or 0
end

-- Get player level
function HCP.Utils.GetLevel()
    return UnitLevel("player") or 0
end

-- Get player class
function HCP.Utils.GetClass()
    local _, class = UnitClass("player")
    return class
end

-- Get player race
function HCP.Utils.GetRace()
    local _, race = UnitRace("player")
    return race
end

-- Check if gear is only starting quality (white/grey)
function HCP.Utils.HasOnlyStartingGear()
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local _, _, quality = GetItemInfo(link)
            if quality and quality > 1 then  -- 0=Poor(grey), 1=Common(white), 2+=uncommon+
                return false
            end
        end
    end
    return true
end

-- Count spent talent points
function HCP.Utils.GetSpentTalentPoints()
    local total = 0
    for tab = 1, GetNumTalentTabs() do
        for talent = 1, GetNumTalents(tab) do
            local _, _, _, _, rank = GetTalentInfo(tab, talent)
            total = total + (rank or 0)
        end
    end
    return total
end

-- Count primary professions (exclude secondary, weapon skills, defense, etc.)
function HCP.Utils.GetProfessionCount()
    local count = 0
    -- Known primary professions in TBC
    local primaryProfs = {
        ["Alchemy"] = true, ["Blacksmithing"] = true, ["Enchanting"] = true,
        ["Engineering"] = true, ["Herbalism"] = true, ["Jewelcrafting"] = true,
        ["Leatherworking"] = true, ["Mining"] = true, ["Skinning"] = true,
        ["Tailoring"] = true,
    }
    for i = 1, GetNumSkillLines() do
        local name, isHeader = GetSkillLineInfo(i)
        if not isHeader and primaryProfs[name] then
            count = count + 1
        end
    end
    return count
end

-- ═══════════════════════════════════════════
--  Debug / Tester Mode Helpers
-- ═══════════════════════════════════════════

--- Check if a specific debug system toggle is enabled.
-- Safe to call before DB is initialized (returns true = default active).
-- @param systemKey string: key from HCP.DebugDefaults (e.g. "deathTracking")
-- @return boolean
function HCP.Utils.IsSystemEnabled(systemKey)
    if not HCP.db or not HCP.db.global then return true end
    local debug = HCP.db.global.debug
    if not debug then return true end
    if debug[systemKey] == nil then return true end  -- unknown key = enabled
    return debug[systemKey]
end

--- Print a debug message to chat (only if verbose mode is on).
-- @param ... varargs: strings to concatenate
function HCP.Utils.DebugLog(...)
    if not HCP.db or not HCP.db.global then return end
    local debug = HCP.db.global.debug
    if not debug or not debug.verbose then return end
    local msg = table.concat({...})
    HCP.Addon:Print(HCP.CC.DIM .. "[DBG] " .. msg .. HCP.CC.CLOSE)
end
