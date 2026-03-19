--[[
    HardcorePlus — Instance Tracker (Phase 5)
    Manages instance lives: per-instance bonus lives, weekly pool,
    death-with-lives consumption, and zone enter/leave detection.

    Life Consumption Order:
      1. Instance-specific bonus lives (if qualifying heroic/raid)
      2. Weekly pool lives
      3. If both exhausted → PERMADEATH

    Normal dungeons have NO bonus lives — death is always permadeath.
    Heroic dungeons only grant bonus if in BonusLifeHeroics table AND on heroic difficulty.
    Raids grant bonus if in BonusLifeRaids table.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local InstanceTracker = {}
HCP.InstanceTracker = InstanceTracker

-- Current instance state (transient, not saved)
local currentInstance = nil  -- { name, instanceType, isHeroic, entered }

-- ═══════════════════════════════════════════
--  Weekly Pool Management
-- ═══════════════════════════════════════════

local function GetNextWeeklyReset()
    -- WoW weekly reset is Tuesday. Offset by 4 days so week boundaries align with Tuesday.
    local TUESDAY_OFFSET = 345600  -- 4 days in seconds (Thu→Tue)
    local now = HCP.Utils.GetTimestamp()
    local currentWeek = math.floor((now - TUESDAY_OFFSET) / (7 * 86400))
    local nextReset = (currentWeek + 1) * (7 * 86400) + TUESDAY_OFFSET
    return nextReset
end

local function CheckWeeklyPoolReset()
    local data = HCP.db.char
    local pool = data.weeklyPool
    local now = HCP.Utils.GetTimestamp()

    if pool.resetTime == 0 then
        -- First time: set next reset
        pool.resetTime = GetNextWeeklyReset()
    elseif now >= pool.resetTime then
        -- Weekly reset occurred
        pool.used = 0
        pool.bonus = 0
        pool.resetTime = GetNextWeeklyReset()

        local c = HCP.CC
        HardcorePlus:Print(c.GOLD .. "Weekly life pool reset!" .. c.CLOSE ..
            c.DIM .. " " .. pool.max .. " lives available." .. c.CLOSE)
    end
end

function InstanceTracker:GetWeeklyPoolRemaining()
    local pool = HCP.db.char.weeklyPool
    return math.max(0, (pool.max + pool.bonus) - pool.used)
end

-- ═══════════════════════════════════════════
--  Instance Life Data
-- ═══════════════════════════════════════════

-- Get or create the life record for a specific instance+difficulty combo
local function GetInstanceLifeRecord(instanceName, isHeroic)
    local data = HCP.db.char
    -- Key includes difficulty to separate normal/heroic tracking
    local key = instanceName .. (isHeroic and ":Heroic" or ":Normal")

    if not data.instanceLives[key] then
        local bonusLives = HCP.GetBonusLives(instanceName, isHeroic)
        data.instanceLives[key] = {
            livesMax = bonusLives,
            livesUsed = 0,
            deaths = {},        -- timestamps of deaths consumed by lives
            lastEntry = 0,
        }
    end

    return data.instanceLives[key], key
end

function InstanceTracker:GetInstanceLivesRemaining(instanceName, isHeroic)
    local record = GetInstanceLifeRecord(instanceName, isHeroic)
    return math.max(0, record.livesMax - record.livesUsed)
end

-- ═══════════════════════════════════════════
--  Instance Enter/Leave Detection
-- ═══════════════════════════════════════════

function InstanceTracker:OnZoneChanged()
    local instanceData = HCP.Utils.GetInstanceData()

    if instanceData then
        -- Entered an instance
        if not currentInstance or currentInstance.name ~= instanceData.name then
            currentInstance = {
                name = instanceData.name,
                instanceType = instanceData.instanceType,
                isHeroic = instanceData.isHeroic,
                entered = HCP.Utils.GetTimestamp(),
            }

            local record = GetInstanceLifeRecord(instanceData.name, instanceData.isHeroic)
            record.lastEntry = HCP.Utils.GetTimestamp()

            local c = HCP.CC
            local bonusLives = HCP.GetBonusLives(instanceData.name, instanceData.isHeroic)
            local instanceRemaining = self:GetInstanceLivesRemaining(instanceData.name, instanceData.isHeroic)
            local weeklyRemaining = self:GetWeeklyPoolRemaining()

            if bonusLives > 0 then
                HardcorePlus:Print(c.BLUE .. "Entered: " .. instanceData.name ..
                    (instanceData.isHeroic and " (Heroic)" or "") .. c.CLOSE)
                HardcorePlus:Print(c.BLUE .. "Instance lives: " .. c.WHITE ..
                    instanceRemaining .. "/" .. bonusLives .. c.CLOSE ..
                    c.DIM .. " | Weekly pool: " .. weeklyRemaining .. c.CLOSE)
            else
                HardcorePlus:Print(c.RED .. "Entered: " .. instanceData.name ..
                    (instanceData.isHeroic and " (Heroic)" or "") .. c.CLOSE)
                HardcorePlus:Print(c.RED .. "NO bonus lives — death here is PERMANENT." .. c.CLOSE)
                if weeklyRemaining > 0 then
                    HardcorePlus:Print(c.DIM .. "Weekly pool available: " .. weeklyRemaining ..
                        " (used only for qualifying instances)" .. c.CLOSE)
                end
            end

            -- Warn about addon disabling
            if bonusLives > 0 then
                HardcorePlus:Print(c.GOLD .. "WARNING: " .. c.CLOSE ..
                    c.DIM .. "Disabling the addon during this instance may void your HC status." .. c.CLOSE)
            end

            -- Fire event for UI
            HardcorePlus:SendMessage("HCP_INSTANCE_ENTERED", currentInstance)
        end
    else
        -- Left instance
        if currentInstance then
            local c = HCP.CC
            local leftInstance = currentInstance
            currentInstance = nil

            HardcorePlus:Print(c.DIM .. "Left instance: " .. leftInstance.name .. c.CLOSE)

            -- Check for deathless completion bonus
            self:CheckDeathlessBonus(leftInstance)

            -- Fire event for UI
            HardcorePlus:SendMessage("HCP_INSTANCE_LEFT", leftInstance)
        end
    end
end

-- ═══════════════════════════════════════════
--  Deathless Completion Bonus
-- ═══════════════════════════════════════════

function InstanceTracker:CheckDeathlessBonus(instanceInfo)
    if not HCP.db.char.instanceLivesEnabled then return end

    local bonusLives = HCP.GetBonusLives(instanceInfo.name, instanceInfo.isHeroic)
    if bonusLives == 0 then return end  -- only qualifying instances

    local record = GetInstanceLifeRecord(instanceInfo.name, instanceInfo.isHeroic)
    -- If no deaths during this instance visit → deathless clear
    local deathsDuringVisit = 0
    for _, deathTime in ipairs(record.deaths) do
        if deathTime >= instanceInfo.entered then
            deathsDuringVisit = deathsDuringVisit + 1
        end
    end

    if deathsDuringVisit == 0 then
        local pool = HCP.db.char.weeklyPool
        local cap = pool.max + 5  -- bonus cap: base + 5
        if (pool.max + pool.bonus) < cap then
            pool.bonus = pool.bonus + 1
            local c = HCP.CC
            HardcorePlus:Print(c.GREEN .. "Deathless clear: " .. instanceInfo.name .. "!" .. c.CLOSE)
            HardcorePlus:Print(c.GREEN .. "+1 weekly pool bonus life" .. c.CLOSE ..
                c.DIM .. " (Pool: " .. self:GetWeeklyPoolRemaining() .. " remaining)" .. c.CLOSE)
        end
    end
end

-- ═══════════════════════════════════════════
--  Death in Instance — Life Consumption
-- ═══════════════════════════════════════════

--- Process an instance death. Returns true if a life was consumed, false if permadeath.
function InstanceTracker:OnInstanceDeath(deathRecord)
    if not HCP.Utils.IsSystemEnabled("instanceLives") then
        HCP.Utils.DebugLog("Instance lives disabled via debug toggle — treating as permadeath")
        return false, "Instance lives disabled (debug)"
    end
    if not HCP.db.char.instanceLivesEnabled then
        -- Instance lives disabled (Juggernaut/True-HC mode) → always permadeath
        return false, "Instance lives disabled"
    end

    local instanceName = deathRecord.instanceName
    local isHeroic = deathRecord.isHeroic
    if not instanceName then
        -- Fallback: use zone from death record
        instanceName = deathRecord.zone or "Unknown"
        isHeroic = false
    end

    local bonusLives = HCP.GetBonusLives(instanceName, isHeroic)
    local c = HCP.CC

    -- Step 1: Check instance-specific lives
    if bonusLives > 0 then
        local record, key = GetInstanceLifeRecord(instanceName, isHeroic)
        local remaining = record.livesMax - record.livesUsed

        if remaining > 0 then
            -- Consume an instance life
            record.livesUsed = record.livesUsed + 1
            table.insert(record.deaths, HCP.Utils.GetTimestamp())
            remaining = remaining - 1

            HardcorePlus:Print(c.BLUE .. "══ INSTANCE LIFE CONSUMED ══" .. c.CLOSE)
            HardcorePlus:Print(c.BLUE .. "Instance: " .. c.WHITE .. instanceName ..
                (isHeroic and " (Heroic)" or "") .. c.CLOSE)
            HardcorePlus:Print(c.BLUE .. "Lives remaining: " .. c.WHITE ..
                remaining .. "/" .. record.livesMax .. c.CLOSE)
            if remaining == 0 then
                HardcorePlus:Print(c.RED .. "All instance lives exhausted for " ..
                    instanceName .. "!" .. c.CLOSE)
            end

            HardcorePlus:SendMessage("HCP_INSTANCE_LIFE_CONSUMED", {
                instance = instanceName,
                isHeroic = isHeroic,
                livesRemaining = remaining,
                livesMax = record.livesMax,
                source = "instance",
            })

            return true, "Instance life consumed"
        end
    end

    -- Step 2: Check weekly pool
    local weeklyRemaining = self:GetWeeklyPoolRemaining()
    if weeklyRemaining > 0 and bonusLives > 0 then
        -- Weekly pool only applies to qualifying instances (that have bonus lives)
        local pool = HCP.db.char.weeklyPool
        pool.used = pool.used + 1
        weeklyRemaining = weeklyRemaining - 1

        -- Also record in instance data
        local record = GetInstanceLifeRecord(instanceName, isHeroic)
        table.insert(record.deaths, HCP.Utils.GetTimestamp())

        HardcorePlus:Print(c.GOLD .. "══ WEEKLY POOL LIFE CONSUMED ══" .. c.CLOSE)
        HardcorePlus:Print(c.GOLD .. "Instance: " .. c.WHITE .. instanceName ..
            (isHeroic and " (Heroic)" or "") .. c.CLOSE)
        HardcorePlus:Print(c.GOLD .. "Weekly pool remaining: " .. c.WHITE ..
            weeklyRemaining .. "/" .. (pool.max + pool.bonus) .. c.CLOSE)
        if weeklyRemaining == 0 then
            HardcorePlus:Print(c.RED .. "Weekly pool exhausted! " ..
                "Further instance deaths will be PERMANENT." .. c.CLOSE)
        end

        HardcorePlus:SendMessage("HCP_INSTANCE_LIFE_CONSUMED", {
            instance = instanceName,
            isHeroic = isHeroic,
            livesRemaining = weeklyRemaining,
            livesMax = pool.max + pool.bonus,
            source = "weekly",
        })

        return true, "Weekly pool life consumed"
    end

    -- Step 3: No lives left → permadeath
    if bonusLives > 0 then
        HardcorePlus:Print(c.RED .. "══ NO LIVES REMAINING ══" .. c.CLOSE)
        HardcorePlus:Print(c.RED .. "All instance and weekly lives exhausted." .. c.CLOSE)
        HardcorePlus:Print(c.RED .. "This death is PERMANENT." .. c.CLOSE)
    else
        -- Normal dungeon or non-qualifying instance → always permadeath
        HardcorePlus:Print(c.RED .. "══ PERMADEATH ══" .. c.CLOSE)
        HardcorePlus:Print(c.RED .. instanceName .. " has no bonus lives." .. c.CLOSE)
        HardcorePlus:Print(c.RED .. "This death is PERMANENT." .. c.CLOSE)
    end

    return false, "No lives remaining"
end

-- ═══════════════════════════════════════════
--  Get Current Instance Info (for UI)
-- ═══════════════════════════════════════════

function InstanceTracker:GetCurrentInstance()
    return currentInstance
end

function InstanceTracker:GetFullStatus()
    local data = HCP.db.char
    local pool = data.weeklyPool
    local status = {
        inInstance = currentInstance ~= nil,
        instanceName = currentInstance and currentInstance.name or nil,
        isHeroic = currentInstance and currentInstance.isHeroic or false,
        instanceLivesEnabled = data.instanceLivesEnabled,
        weeklyPool = {
            remaining = self:GetWeeklyPoolRemaining(),
            used = pool.used,
            max = pool.max,
            bonus = pool.bonus,
        },
        currentInstanceLives = nil,
    }

    if currentInstance then
        local bonusLives = HCP.GetBonusLives(currentInstance.name, currentInstance.isHeroic)
        if bonusLives > 0 then
            local record = GetInstanceLifeRecord(currentInstance.name, currentInstance.isHeroic)
            status.currentInstanceLives = {
                remaining = record.livesMax - record.livesUsed,
                max = record.livesMax,
            }
        end
    end

    return status
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    if not HCP.db.char.instanceLivesEnabled then return end

    CheckWeeklyPoolReset()

    -- Periodic weekly pool reset check (catches Tuesday reset while logged in)
    HardcorePlus:ScheduleRepeatingTimer(CheckWeeklyPoolReset, 300)

    -- Zone change detection
    HardcorePlus:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        InstanceTracker:OnZoneChanged()
    end)

    -- Also check on initial load (player may already be in instance)
    HardcorePlus:ScheduleTimer(function()
        InstanceTracker:OnZoneChanged()
    end, 1)

    -- Listen for player deaths to process instance lives
    HardcorePlus:RegisterMessage("HCP_PLAYER_DEATH", function(_, deathRecord)
        if deathRecord.inInstance then
            local lifeConsumed, reason = InstanceTracker:OnInstanceDeath(deathRecord)
            -- Fire result event so VerificationTracker can decide status transition
            HardcorePlus:SendMessage("HCP_INSTANCE_DEATH_RESOLVED", deathRecord, lifeConsumed, reason)
        end
    end)
end)
