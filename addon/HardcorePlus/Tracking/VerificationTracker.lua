--[[
    HardcorePlus — Verification Tracker (Phase 3)
    Soul of Iron buff detection, status state machine management,
    and suspicious activity flagging.

    Status Flow:
      PENDING → UNVERIFIED → VERIFIED (SoI) → TARNISHED → DEAD
      DEAD → (checkpoint) → UNVERIFIED
      DEAD → (soft reset) → SOFT_RESET_N

    SoI becomes unreliable after level 58 (instance content).
    Two separate counters: openWorldDeaths and instanceDeaths.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local VerificationTracker = {}
HCP.VerificationTracker = VerificationTracker

local SOI_SCAN_INTERVAL = 30  -- seconds
local SOI_BUFF_NAME = "Soul of Iron"

-- ═══════════════════════════════════════════
--  Soul of Iron Buff Detection
-- ═══════════════════════════════════════════

local function ScanForSoulOfIron()
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        if name == SOI_BUFF_NAME then
            return true
        end
    end
    return false
end

function VerificationTracker:CheckSoulOfIron()
    if not HCP.db.char.registered then return end
    if not HCP.Utils.IsSystemEnabled("soiTracking") then return end

    local data = HCP.db.char
    local hasSoI = ScanForSoulOfIron()
    local previousSoI = data.soulOfIron

    if hasSoI and not previousSoI then
        -- SoI detected for first time
        data.soulOfIron = true
        data.soulOfIronTimestamp = HCP.Utils.GetTimestamp()

        local c = HCP.CC
        HardcorePlus:Print(c.GREEN .. "Soul of Iron detected!" .. c.CLOSE ..
            c.DIM .. " Verification status upgraded." .. c.CLOSE)

        -- Transition to VERIFIED if currently PENDING, UNVERIFIED, or LATE_REG
        if data.status == HCP.Status.PENDING or data.status == HCP.Status.UNVERIFIED
            or data.status == HCP.Status.LATE_REG then
            self:TransitionStatus(HCP.Status.VERIFIED, "Soul of Iron buff confirmed")
        end

        -- Check for True-HC title upgrade:
        -- Requires SoI + no checkpoints + no instance lives (already has Juggernaut title)
        if data.title == HCP.Titles.JUGGERNAUT
            and not data.checkpointEnabled and not data.instanceLivesEnabled then
            data.title = HCP.Titles.TRUE_HC
            HardcorePlus:Print(c.GOLD .. "Title upgraded: " .. HCP.Titles.TRUE_HC .. c.CLOSE ..
                c.DIM .. " — Soul of Iron + no checkpoints + no instance lives." .. c.CLOSE)
        end

    elseif not hasSoI and previousSoI and not data.soulOfIronLost then
        -- SoI was active and is now gone
        data.soulOfIron = false
        data.soulOfIronLost = true

        local c = HCP.CC

        -- Check if this was due to a death (deaths module would have fired already)
        -- If no recent death → suspicious (manual removal?)
        local recentDeath = false
        local deaths = data.deaths
        if #deaths > 0 then
            local lastDeath = deaths[#deaths]
            local timeSinceDeath = HCP.Utils.GetTimestamp() - (lastDeath.timestamp or 0)
            if timeSinceDeath < 60 then  -- within 1 minute
                recentDeath = true
            end
        end

        if recentDeath then
            HardcorePlus:Print(c.RED .. "Soul of Iron lost due to death." .. c.CLOSE)
        else
            -- Suspicious: SoI removed without death
            HardcorePlus:Print(c.RED .. "══ WARNING ══" .. c.CLOSE)
            HardcorePlus:Print(c.RED .. "Soul of Iron buff removed without a recorded death!" .. c.CLOSE)
            HardcorePlus:Print(c.DIM .. "This has been flagged for review." .. c.CLOSE)

            table.insert(data.suspiciousFlags, {
                timestamp = HCP.Utils.GetTimestamp(),
                severity = "high",
                reason = "SoI removed without death event",
                details = { "Previous SoI timestamp: " ..
                    HCP.Utils.FormatDate(data.soulOfIronTimestamp, "%Y-%m-%d %H:%M") },
            })

            HardcorePlus:SendMessage("HCP_VIOLATION", {
                severity = "high",
                reason = "SoI removed without death",
            })
        end

        -- Downgrade True-HC → Juggernaut (lost SoI requirement)
        if data.title == HCP.Titles.TRUE_HC then
            data.title = HCP.Titles.JUGGERNAUT
            HardcorePlus:Print(c.GOLD .. "Title reverted to " .. HCP.Titles.JUGGERNAUT .. c.CLOSE ..
                c.DIM .. " — Soul of Iron lost." .. c.CLOSE)
        end

        -- Transition to TARNISHED
        if data.status == HCP.Status.VERIFIED then
            self:TransitionStatus(HCP.Status.TARNISHED, "Soul of Iron lost")
        end
    end
end

-- ═══════════════════════════════════════════
--  Status State Machine
-- ═══════════════════════════════════════════

function VerificationTracker:TransitionStatus(newStatus, reason)
    local data = HCP.db.char
    local oldStatus = data.status
    local c = HCP.CC

    -- Validate transition
    local valid = false
    if newStatus == HCP.Status.VERIFIED then
        valid = (oldStatus == HCP.Status.PENDING or oldStatus == HCP.Status.UNVERIFIED
            or oldStatus == HCP.Status.LATE_REG or oldStatus == HCP.Status.SOFT_RESET)
    elseif newStatus == HCP.Status.TARNISHED then
        valid = (oldStatus == HCP.Status.VERIFIED)
    elseif newStatus == HCP.Status.DEAD then
        valid = (oldStatus ~= HCP.Status.DEAD)  -- can die from any living state
    elseif newStatus == HCP.Status.UNVERIFIED then
        valid = (oldStatus == HCP.Status.DEAD or oldStatus == HCP.Status.PENDING
            or oldStatus == HCP.Status.SOFT_RESET)
    elseif newStatus == HCP.Status.SOFT_RESET then
        valid = (oldStatus == HCP.Status.DEAD)
    else
        valid = true  -- allow other transitions
    end

    if not valid then
        HardcorePlus:Print(c.DIM .. "Status transition " .. oldStatus .. " → " ..
            newStatus .. " not valid." .. c.CLOSE)
        return false
    end

    data.status = newStatus

    local oldColor = HCP.StatusColors[oldStatus] or c.DIM
    local newColor = HCP.StatusColors[newStatus] or c.DIM
    local oldLabel = HCP.StatusLabels[oldStatus] or oldStatus
    local newLabel = HCP.StatusLabels[newStatus] or newStatus

    HardcorePlus:Print(c.GOLD .. "Status: " .. c.CLOSE ..
        oldColor .. oldLabel .. c.CLOSE ..
        c.DIM .. " → " .. c.CLOSE ..
        newColor .. newLabel .. c.CLOSE)

    if reason then
        HardcorePlus:Print(c.DIM .. "Reason: " .. reason .. c.CLOSE)
    end

    HardcorePlus:SendMessage("HCP_STATUS_CHANGED", newStatus, oldStatus, reason)
    return true
end

-- ═══════════════════════════════════════════
--  Death Handler (status transitions on death)
-- ═══════════════════════════════════════════

function VerificationTracker:OnPlayerDeath(deathRecord)
    if not HCP.Utils.IsSystemEnabled("verification") then
        HCP.Utils.DebugLog("Verification disabled — death status transition skipped")
        return
    end
    local data = HCP.db.char

    if deathRecord.inInstance then
        -- Instance death: InstanceTracker handles life consumption and fires
        -- HCP_INSTANCE_DEATH_RESOLVED with (deathRecord, lifeConsumed, reason).
        -- If instance lives are disabled or InstanceTracker not loaded, treat as permadeath.
        if not data.instanceLivesEnabled or not HCP.InstanceTracker then
            self:TransitionStatus(HCP.Status.DEAD,
                "Instance death (lives disabled) — killed by " .. (deathRecord.killer or "Unknown") ..
                " in " .. (deathRecord.zone or "Unknown"))
        end
        -- Otherwise wait for HCP_INSTANCE_DEATH_RESOLVED (handled in init below)
    else
        -- Open world death = PERMADEATH
        self:TransitionStatus(HCP.Status.DEAD,
            "Open world death — killed by " .. (deathRecord.killer or "Unknown") ..
            " in " .. (deathRecord.zone or "Unknown"))
    end
end

-- ═══════════════════════════════════════════
--  SoI Reliability Check (Level 58+)
-- ═══════════════════════════════════════════

function VerificationTracker:IsSoIReliable()
    local level = HCP.Utils.GetLevel()
    return level < 58
end

function VerificationTracker:GetSoIStatus()
    local data = HCP.db.char
    if not data.registered then
        return "N/A"
    end
    if data.soulOfIron then
        if self:IsSoIReliable() then
            return "Active"
        else
            return "Active (unreliable — Lvl 58+)"
        end
    elseif data.soulOfIronLost then
        return "Lost"
    else
        return "Not detected"
    end
end

-- ═══════════════════════════════════════════
--  Suspicious Activity Checks
-- ═══════════════════════════════════════════

function VerificationTracker:CheckInstanceZoneOnReload()
    -- If addon reloads and player is inside an instance, flag it
    local inInstance, instanceType = HCP.Utils.IsInInstance()
    if inInstance and HCP.db.char.registered then
        local zone = HCP.Utils.GetZoneInfo().zone
        local c = HCP.CC

        HardcorePlus:Print(c.GOLD .. "WARNING: " .. c.CLOSE ..
            c.TEXT .. "Addon loaded while inside instance: " ..
            c.BLUE .. zone .. c.CLOSE)
        HardcorePlus:Print(c.DIM .. "Instance activity during addon downtime may affect your status." .. c.CLOSE)

        table.insert(HCP.db.char.suspiciousFlags, {
            timestamp = HCP.Utils.GetTimestamp(),
            severity = "high",
            reason = "Addon loaded inside instance",
            details = { "Zone: " .. zone, "Type: " .. (instanceType or "unknown") },
        })

        HardcorePlus:SendMessage("HCP_VIOLATION", {
            severity = "high",
            reason = "Addon loaded inside instance: " .. zone,
        })
    end
end

-- ═══════════════════════════════════════════
--  Populate Overview Status Section
-- ═══════════════════════════════════════════

function VerificationTracker:GetVerificationSummary()
    local data = HCP.db.char
    return {
        status = data.status,
        statusLabel = HCP.StatusLabels[data.status] or data.status,
        statusColor = HCP.StatusColors[data.status] or HCP.CC.DIM,
        soulOfIron = self:GetSoIStatus(),
        soulOfIronReliable = self:IsSoIReliable(),
        flagCount = #data.suspiciousFlags,
        title = data.title,
    }
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Check if we reloaded inside an instance
    VerificationTracker:CheckInstanceZoneOnReload()

    -- Initial SoI check
    VerificationTracker:CheckSoulOfIron()

    -- Periodic SoI scan
    HardcorePlus:ScheduleRepeatingTimer(function()
        VerificationTracker:CheckSoulOfIron()
    end, SOI_SCAN_INTERVAL)

    -- React to deaths
    HardcorePlus:RegisterMessage("HCP_PLAYER_DEATH", function(_, deathRecord)
        VerificationTracker:OnPlayerDeath(deathRecord)
    end)

    -- React to instance death resolution (from InstanceTracker)
    HardcorePlus:RegisterMessage("HCP_INSTANCE_DEATH_RESOLVED", function(_, deathRecord, lifeConsumed, reason)
        local data = HCP.db.char
        if lifeConsumed then
            -- Life was consumed — player survives but status may change
            if data.status == HCP.Status.VERIFIED then
                VerificationTracker:TransitionStatus(HCP.Status.TARNISHED,
                    "Instance death (life consumed) in " .. (deathRecord.instanceName or deathRecord.zone or "Unknown"))
            end
        else
            -- No lives left → PERMADEATH
            VerificationTracker:TransitionStatus(HCP.Status.DEAD,
                "Instance death (no lives) — killed by " .. (deathRecord.killer or "Unknown") ..
                " in " .. (deathRecord.instanceName or deathRecord.zone or "Unknown"))
        end
    end)

    -- React to level up (SoI reliability change at 58)
    HardcorePlus:RegisterMessage("HCP_LEVEL_UP", function(_, level)
        if level == 58 then
            local c = HCP.CC
            HardcorePlus:Print(c.GOLD .. "Level 58 reached." .. c.CLOSE ..
                c.DIM .. " Soul of Iron verification is now unreliable " ..
                "(instance content may interfere)." .. c.CLOSE)
        end
    end)
end)
