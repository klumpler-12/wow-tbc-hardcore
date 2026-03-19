--[[
    HardcorePlus — Network Verification (Phase 4)
    Cross-verification of deaths and data integrity.
    Works across GUILD, PARTY, and RAID channels.

    When a player dies:
      1. DeathTracker fires HCP_PLAYER_DEATH locally
      2. This module broadcasts DEATH_REPORT to all available channels
      3. Nearby peers who saw the death in their combat log send DEATH_VERIFY
      4. Death record updated with verification count

    Data integrity:
      - Periodic DATA_HASH broadcasts are compared by Heartbeat module
      - Mismatches flagged via HCP_PEER_HASH_MISMATCH
      - This module processes mismatches and creates peer flags
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local Verification = {}
HCP.Verification = Verification

-- Track pending death verifications
local pendingVerifications = {}  -- [timestamp] = { report, verifiers = {} }

-- Track recent nearby deaths (from combat log) for witness confirmation
local recentNearbyDeaths = {}  -- [playerGUID] = { timestamp, zone }
local NEARBY_DEATH_WINDOW = 30  -- seconds to consider a death "witnessed"

-- ═══════════════════════════════════════════
--  Death Broadcasting
-- ═══════════════════════════════════════════

function Verification:BroadcastDeath(deathRecord)
    local payload = HCP.Protocol:BuildDeathReport(deathRecord)

    -- Broadcast to all available channels (guild + party/raid)
    HCP.Protocol:SendAll(HCP.Protocol.MessageType.DEATH_REPORT, payload)

    -- Track pending verification
    pendingVerifications[deathRecord.timestamp] = {
        report = deathRecord,
        verifiers = {},
        broadcastTime = HCP.Utils.GetTimestamp(),
    }

    -- Timeout: stop waiting after 5 minutes
    HardcorePlus:ScheduleTimer(function()
        local pending = pendingVerifications[deathRecord.timestamp]
        if pending then
            local count = 0
            for _ in pairs(pending.verifiers) do count = count + 1 end

            -- Update death record with verification info
            Verification:FinalizeVerification(deathRecord.timestamp, count)
        end
    end, 300)
end

-- ═══════════════════════════════════════════
--  Death Verification (receiving reports)
-- ═══════════════════════════════════════════

function Verification:OnDeathReportReceived(message)
    local senderKey = message.s
    local payload = message.p
    local c = HCP.CC

    -- Log the death in our peer registry
    local registry = HCP.db.global.peerRegistry
    if registry[senderKey] then
        registry[senderKey].lastKnownDeath = {
            timestamp = payload.timestamp,
            zone = payload.zone,
            killer = payload.killer,
        }
    end

    -- Check if we witnessed this death (were we nearby?)
    local witnessed = false
    local playerGUID = nil

    -- Check recent nearby deaths from combat log
    for guid, deathInfo in pairs(recentNearbyDeaths) do
        local timeDiff = math.abs((payload.timestamp or 0) - (deathInfo.timestamp or 0))
        if timeDiff < NEARBY_DEATH_WINDOW and deathInfo.name == senderKey:match("^(.+)-") then
            witnessed = true
            break
        end
    end

    -- Send verification response
    local verifyPayload = HCP.Protocol:BuildDeathVerify(message, witnessed)

    -- Reply via all available channels (so others can also see)
    HCP.Protocol:SendAll(HCP.Protocol.MessageType.DEATH_VERIFY, verifyPayload)

    -- Notify locally
    HardcorePlus:Print(c.BLUE .. "Death report: " .. c.WHITE .. senderKey .. c.CLOSE ..
        c.DIM .. " died in " .. (payload.zone or "?") ..
        " — " .. (payload.killer or "?") ..
        (witnessed and (" " .. c.GREEN .. "[WITNESSED]" .. c.CLOSE) or "") ..
        c.CLOSE)

    HardcorePlus:SendMessage("HCP_PEER_DEATH_REPORTED", senderKey, payload)
end

-- ═══════════════════════════════════════════
--  Death Verify Response Processing
-- ═══════════════════════════════════════════

function Verification:OnDeathVerifyReceived(message)
    local payload = message.p
    local verifierKey = payload.verifier

    -- Is this for one of our pending death reports?
    if payload.target == HCP.Utils.GetPlayerKey() then
        -- Find the pending verification
        for ts, pending in pairs(pendingVerifications) do
            local timeDiff = math.abs(ts - (payload.timestamp or 0))
            if timeDiff < 5 then  -- within 5 seconds tolerance
                pending.verifiers[verifierKey] = {
                    witnessed = payload.witnessed,
                    time = HCP.Utils.GetTimestamp(),
                }
                local count = 0
                for _ in pairs(pending.verifiers) do count = count + 1 end

                local c = HCP.CC
                HardcorePlus:Print(c.DIM .. "Death verified by " ..
                    verifierKey ..
                    (payload.witnessed and " (witnessed)" or " (confirmed)") ..
                    " — " .. count .. " verifier(s)" .. c.CLOSE)

                HardcorePlus:SendMessage("HCP_DEATH_VERIFICATION_UPDATE",
                    ts, count, payload.witnessed)
                break
            end
        end
    end
end

-- ═══════════════════════════════════════════
--  Finalize Verification
-- ═══════════════════════════════════════════

function Verification:FinalizeVerification(deathTimestamp, verifierCount)
    local pending = pendingVerifications[deathTimestamp]
    if not pending then return end

    -- Find and update the death record in our deaths array
    local deaths = HCP.db.char.deaths
    for _, death in ipairs(deaths) do
        if death.timestamp == deathTimestamp then
            death.peerVerified = verifierCount > 0
            death.peerVerifierCount = verifierCount
            death.peerWitnessed = false

            -- Check if any verifier actually witnessed it
            for _, v in pairs(pending.verifiers) do
                if v.witnessed then
                    death.peerWitnessed = true
                    break
                end
            end
            break
        end
    end

    pendingVerifications[deathTimestamp] = nil

    local c = HCP.CC
    if verifierCount > 0 then
        HardcorePlus:Print(c.GREEN .. "Death verification complete: " ..
            verifierCount .. " peer(s) confirmed." .. c.CLOSE)
    else
        HardcorePlus:Print(c.GOLD .. "Death unverified — no peers responded." .. c.CLOSE)
    end
end

-- ═══════════════════════════════════════════
--  Combat Log Monitoring (for witnessing others' deaths)
-- ═══════════════════════════════════════════

-- Called via HCP_NEARBY_PLAYER_DIED message from DeathTracker's CLEU handler.
-- (We do NOT register our own CLEU — DeathTracker owns the single CLEU registration
--  to avoid AceEvent overwrite conflicts.)
local function OnNearbyPlayerDied(destGUID, destName)
    if not destGUID or not destName then return end
    recentNearbyDeaths[destGUID] = {
        timestamp = HCP.Utils.GetTimestamp(),
        name = destName,
        guid = destGUID,
    }

    -- Cleanup old entries
    local now = HCP.Utils.GetTimestamp()
    for guid, info in pairs(recentNearbyDeaths) do
        if (now - info.timestamp) > NEARBY_DEATH_WINDOW * 2 then
            recentNearbyDeaths[guid] = nil
        end
    end
end

-- ═══════════════════════════════════════════
--  Peer Hash Mismatch Handler
-- ═══════════════════════════════════════════

function Verification:OnPeerHashMismatch(peerKey, mismatches)
    local c = HCP.CC

    HardcorePlus:Print(c.GOLD .. "Peer data anomaly: " .. c.WHITE .. peerKey .. c.CLOSE)
    for _, mismatch in ipairs(mismatches) do
        HardcorePlus:Print(c.DIM .. "  • " .. mismatch .. c.CLOSE)
    end

    -- Store in peer registry as a flag
    local registry = HCP.db.global.peerRegistry
    if registry[peerKey] then
        if not registry[peerKey].peerFlags then
            registry[peerKey].peerFlags = {}
        end
        table.insert(registry[peerKey].peerFlags, {
            timestamp = HCP.Utils.GetTimestamp(),
            mismatches = mismatches,
        })
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Listen for nearby player deaths (fired by DeathTracker's CLEU handler)
    HardcorePlus:RegisterMessage("HCP_NEARBY_PLAYER_DIED", function(_, destGUID, destName)
        OnNearbyPlayerDied(destGUID, destName)
    end)

    -- Broadcast our death to network
    HardcorePlus:RegisterMessage("HCP_PLAYER_DEATH", function(_, deathRecord)
        Verification:BroadcastDeath(deathRecord)
    end)

    -- Receive death reports from peers
    HardcorePlus:RegisterMessage("HCP_NET_DEATH_REPORT", function(_, message)
        Verification:OnDeathReportReceived(message)
    end)

    -- Receive death verification responses
    HardcorePlus:RegisterMessage("HCP_NET_DEATH_VERIFY", function(_, message)
        Verification:OnDeathVerifyReceived(message)
    end)

    -- Handle hash mismatches from Heartbeat module
    HardcorePlus:RegisterMessage("HCP_PEER_HASH_MISMATCH", function(_, peerKey, mismatches)
        Verification:OnPeerHashMismatch(peerKey, mismatches)
    end)
end)
