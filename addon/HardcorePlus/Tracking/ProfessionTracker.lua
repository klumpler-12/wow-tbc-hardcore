--[[
    HardcorePlus — Profession Tracker
    Monitors profession skill changes and levels.
    Snapshots professions and skill levels on each change.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local ProfessionTracker = {}
HCP.ProfessionTracker = ProfessionTracker

-- ═══════════════════════════════════════════
--  Profession Tracking
-- ═══════════════════════════════════════════

local lastProfSnapshot = nil

local function GetCurrentProfessions()
    local profs = {}
    local numSkillLines = GetNumSkillLines()

    for i = 1, numSkillLines do
        local skillName, isHeader, _, skillRank, maxSkillRank = GetSkillLineInfo(i)

        -- Skip headers and non-profession skills
        if not isHeader and skillName then
            local isProfession = false
            -- Common profession names (TBC 2.4.3)
            local professions = {
                "Alchemy", "Blacksmithing", "Cooking", "Enchanting",
                "Engineering", "Herbalism", "Jewelcrafting", "Leatherworking",
                "Mining", "Skinning", "Tailoring", "First Aid", "Fishing",
            }

            for _, prof in ipairs(professions) do
                if skillName == prof then
                    isProfession = true
                    break
                end
            end

            if isProfession then
                table.insert(profs, {
                    name = skillName,
                    rank = skillRank or 0,
                    maxRank = maxSkillRank or 0,
                })
            end
        end
    end

    return profs
end

local function ProfessionsChanged(old, new)
    if #old ~= #new then
        return true
    end

    for i = 1, #old do
        if old[i].name ~= new[i].name or
           old[i].rank ~= new[i].rank or
           old[i].maxRank ~= new[i].maxRank then
            return true
        end
    end

    return false
end

local function OnSkillLinesChanged()
    if not HCP.Utils.IsSystemEnabled("professionTracking") then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.professionTracker = HCP.db.char.trackerData.professionTracker or {
        snapshots = {},
    }

    local currentProfs = GetCurrentProfessions()

    -- Only record if professions changed
    if not lastProfSnapshot or ProfessionsChanged(lastProfSnapshot, currentProfs) then
        local snapshot = {
            timestamp = HCP.Utils.GetTimestamp(),
            professions = HCP.Utils.DeepCopy(currentProfs),
        }
        table.insert(HCP.db.char.trackerData.professionTracker.snapshots, snapshot)
        -- Cap at 100 entries
        while #HCP.db.char.trackerData.professionTracker.snapshots > 100 do
            table.remove(HCP.db.char.trackerData.professionTracker.snapshots, 1)
        end
        lastProfSnapshot = HCP.Utils.DeepCopy(currentProfs)
    end
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function ProfessionTracker:GetProfessionHistory(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.professionTracker then
        return {}
    end

    limit = limit or 50
    local snapshots = HCP.db.char.trackerData.professionTracker.snapshots
    local result = {}

    local startIdx = math.max(1, #snapshots - limit + 1)
    for i = startIdx, #snapshots do
        table.insert(result, snapshots[i])
    end

    return result
end

function ProfessionTracker:GetCurrentProfessions()
    return GetCurrentProfessions()
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.professionTracker = HCP.db.char.trackerData.professionTracker or {
        snapshots = {},
    }

    -- Capture initial profession state
    lastProfSnapshot = GetCurrentProfessions()

    HardcorePlus:RegisterEvent("SKILL_LINES_CHANGED", function()
        OnSkillLinesChanged()
    end)
end)
