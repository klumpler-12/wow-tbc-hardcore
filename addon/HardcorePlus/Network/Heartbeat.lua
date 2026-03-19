--[[
    HardcorePlus — Heartbeat System (Phase 4)
    Periodic status broadcast to GUILD, PARTY, and RAID channels.
    Tracks online peers and their last heartbeat.
    Detects peer gaps (went silent then came back).

    Works fully for:
      - Guild members (GUILD channel)
      - Party/raid members (PARTY/RAID channel)
      - Solo players (core features work; peer validation auto-promotes after timeout)

    Peer Registry (global SavedVariables):
      peerRegistry[playerKey] = {
        status, level, deaths, soi, flags, title, lastSeen, lastHash, registered
      }

    Online Peers (session-only, transient):
      onlinePeers[playerKey] = {
        lastHeartbeat, status, level, ...
      }
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local Heartbeat = {}
HCP.Heartbeat = Heartbeat

-- Transient: online peers this session
local onlinePeers = {}

-- ═══════════════════════════════════════════
--  Peer Data Access
-- ═══════════════════════════════════════════

function Heartbeat:GetOnlinePeers()
    return onlinePeers
end

function Heartbeat:GetOnlinePeerCount()
    local count = 0
    for _ in pairs(onlinePeers) do
        count = count + 1
    end
    return count
end

function Heartbeat:GetPeerInfo(playerKey)
    return onlinePeers[playerKey]
end

function Heartbeat:GetPeerRegistry()
    return HCP.db.global.peerRegistry
end

-- ═══════════════════════════════════════════
--  Heartbeat Broadcasting
-- ═══════════════════════════════════════════

local function SendHeartbeat()
    if not HCP.db.char.registered then return end
    if not HCP.Utils.IsSystemEnabled("network") then return end
    local payload = HCP.Protocol:BuildHeartbeat()
    HCP.Protocol:SendAll(HCP.Protocol.MessageType.HEARTBEAT, payload)
end

local function SendDataHash()
    if not HCP.db.char.registered then return end
    if not HCP.Utils.IsSystemEnabled("network") then return end
    local payload = HCP.Protocol:BuildDataHash()
    HCP.Protocol:SendAll(HCP.Protocol.MessageType.DATA_HASH, payload)
end

-- ═══════════════════════════════════════════
--  Incoming Message Router
-- ═══════════════════════════════════════════

-- Dedup: when broadcasting to GUILD + PARTY/RAID, the same message may arrive
-- via multiple channels. Track recent message timestamps per sender to ignore dupes.
local recentMessages = {}  -- [senderKey..msgType..ts] = receivedTime
local DEDUP_WINDOW = 5     -- seconds

local function IsDuplicate(senderKey, msgType, ts)
    local key = senderKey .. msgType .. tostring(ts or 0)
    local now = GetTime()

    -- Cleanup old entries periodically
    if math.random(1, 20) == 1 then
        for k, t in pairs(recentMessages) do
            if (now - t) > DEDUP_WINDOW * 2 then
                recentMessages[k] = nil
            end
        end
    end

    if recentMessages[key] and (now - recentMessages[key]) < DEDUP_WINDOW then
        return true
    end
    recentMessages[key] = now
    return false
end

local function OnCommReceived(prefix, data, channel, sender)
    -- Ignore our own messages
    local myName = UnitName("player")
    if sender == myName then return end

    local message, err = HCP.Protocol:Decode(data)
    if not message then
        return  -- silently drop malformed messages
    end

    local msgType = message.t
    local payload = message.p
    local senderKey = message.s

    -- Track received message stats
    HCP.Protocol:TrackReceived(msgType, #data)

    -- Dedup: skip if we already processed this exact message from another channel
    if IsDuplicate(senderKey, msgType, message.ts) then return end

    if msgType == HCP.Protocol.MessageType.HEARTBEAT then
        Heartbeat:OnHeartbeatReceived(senderKey, payload)

    elseif msgType == HCP.Protocol.MessageType.DATA_HASH then
        Heartbeat:OnDataHashReceived(senderKey, payload)

    elseif msgType == HCP.Protocol.MessageType.DEATH_REPORT then
        -- Forward to Verification module
        HardcorePlus:SendMessage("HCP_NET_DEATH_REPORT", message)

    elseif msgType == HCP.Protocol.MessageType.DEATH_VERIFY then
        HardcorePlus:SendMessage("HCP_NET_DEATH_VERIFY", message)

    elseif msgType == HCP.Protocol.MessageType.STATUS_QUERY then
        -- Someone asked for our status — reply
        Heartbeat:OnStatusQuery(senderKey)

    elseif msgType == HCP.Protocol.MessageType.STATUS_REPLY then
        Heartbeat:OnStatusReply(senderKey, payload)

    elseif msgType == HCP.Protocol.MessageType.FLAG_REPORT then
        HardcorePlus:SendMessage("HCP_NET_FLAG_REPORT", message)

    elseif msgType == HCP.Protocol.MessageType.PEER_REGISTER then
        Heartbeat:OnPeerRegister(senderKey, payload)
    end
end

-- ═══════════════════════════════════════════
--  Heartbeat Processing
-- ═══════════════════════════════════════════

function Heartbeat:OnHeartbeatReceived(senderKey, payload)
    local now = HCP.Utils.GetTimestamp()
    local wasOnline = onlinePeers[senderKey] ~= nil
    local previousSeen = wasOnline and onlinePeers[senderKey].lastHeartbeat or 0

    -- Update online peer
    onlinePeers[senderKey] = {
        lastHeartbeat = now,
        status = payload.status,
        level = payload.level or 0,
        owDeaths = payload.owDeaths or 0,
        instDeaths = payload.instDeaths or 0,
        soi = payload.soi or false,
        flags = payload.flags or 0,
        title = payload.title,
        registered = payload.reg or false,
    }

    -- Update persistent peer registry
    local registry = HCP.db.global.peerRegistry
    if not registry[senderKey] then
        registry[senderKey] = {}
    end
    local reg = registry[senderKey]
    reg.status = payload.status
    reg.level = payload.level or 0
    reg.owDeaths = payload.owDeaths or 0
    reg.instDeaths = payload.instDeaths or 0
    reg.soi = payload.soi or false
    reg.flags = payload.flags or 0
    reg.title = payload.title
    reg.lastSeen = now
    reg.registered = payload.reg or false

    -- Detect peer gap: was previously online, went silent, came back
    if wasOnline and previousSeen > 0 then
        local silentTime = now - previousSeen
        if silentTime > HCP.Net.PEER_TIMEOUT then
            local gapMinutes = math.floor(silentTime / 60)
            HardcorePlus:SendMessage("HCP_PEER_GAP_DETECTED", senderKey, gapMinutes)
        end
    end

    -- Notify UI
    HardcorePlus:SendMessage("HCP_PEER_UPDATED", senderKey)
end

-- ═══════════════════════════════════════════
--  Data Hash Comparison
-- ═══════════════════════════════════════════

function Heartbeat:OnDataHashReceived(senderKey, payload)
    local registry = HCP.db.global.peerRegistry
    if not registry[senderKey] then return end

    local reg = registry[senderKey]
    local previousHash = reg.lastHash

    -- Store new hash
    reg.lastHash = {
        invHash = payload.invHash,
        deathHash = payload.deathHash,
        sessionHash = payload.sessionHash,
        level = payload.level,
        timestamp = HCP.Utils.GetTimestamp(),
    }

    -- Compare with previous (if exists)
    if previousHash then
        local mismatches = {}
        if previousHash.deathHash and payload.deathHash ~= previousHash.deathHash then
            -- Death hash changed — expected if they died. Check if death count matches.
            -- This is informational, not a flag by itself.
        end
        if previousHash.level and payload.level and payload.level < previousHash.level then
            -- Level went DOWN? That's impossible without manipulation.
            table.insert(mismatches, "Level decreased: " ..
                previousHash.level .. " → " .. payload.level)
        end

        if #mismatches > 0 then
            HardcorePlus:SendMessage("HCP_PEER_HASH_MISMATCH", senderKey, mismatches)
        end
    end
end

-- ═══════════════════════════════════════════
--  Status Query / Reply
-- ═══════════════════════════════════════════

function Heartbeat:OnStatusQuery(senderKey)
    if not HCP.db.char.registered then return end
    -- Extract player name from senderKey for whisper (Name-Realm → Name)
    local name = senderKey:match("^(.+)-") or senderKey
    local payload = HCP.Protocol:BuildStatusReply()
    HCP.Protocol:SendWhisper(HCP.Protocol.MessageType.STATUS_REPLY, payload, name)
end

function Heartbeat:OnStatusReply(senderKey, payload)
    -- Store full status in registry
    local registry = HCP.db.global.peerRegistry
    if not registry[senderKey] then
        registry[senderKey] = {}
    end
    local reg = registry[senderKey]
    reg.status = payload.status
    reg.level = payload.level
    reg.owDeaths = payload.owDeaths
    reg.instDeaths = payload.instDeaths
    reg.soi = payload.soi
    reg.soiLost = payload.soiLost
    reg.flags = payload.flags
    reg.title = payload.title
    reg.tradeMode = payload.tradeMode
    reg.registered = payload.reg
    reg.registeredAt = payload.regAt
    reg.softResets = payload.softResets
    reg.instanceLives = payload.instanceLives
    reg.checkpoint = payload.checkpoint
    reg.lastSeen = HCP.Utils.GetTimestamp()

    HardcorePlus:SendMessage("HCP_PEER_STATUS_RECEIVED", senderKey, payload)
end

-- ═══════════════════════════════════════════
--  Peer Registration (chain of trust)
-- ═══════════════════════════════════════════

function Heartbeat:OnPeerRegister(senderKey, payload)
    -- A peer is announcing their HC registration
    local registry = HCP.db.global.peerRegistry
    if not registry[senderKey] then
        registry[senderKey] = {}
    end
    local reg = registry[senderKey]
    reg.status = payload.status
    reg.level = payload.level
    reg.registered = true
    reg.registeredAt = payload.regAt
    reg.lastSeen = HCP.Utils.GetTimestamp()
    reg.registeredBy = HCP.Utils.GetPlayerKey()  -- we vouched for them

    local c = HCP.CC
    HardcorePlus:Print(c.BLUE .. "Peer registered: " .. c.WHITE .. senderKey .. c.CLOSE ..
        c.DIM .. " — Lvl " .. (payload.level or "?") ..
        " | Status: " .. (payload.status or "?") .. c.CLOSE)

    HardcorePlus:SendMessage("HCP_PEER_REGISTERED", senderKey)
end

-- ═══════════════════════════════════════════
--  Peer Timeout Cleanup
-- ═══════════════════════════════════════════

local function CleanupOfflinePeers()
    local now = HCP.Utils.GetTimestamp()
    local timeout = HCP.Net.PEER_TIMEOUT
    local removed = {}

    for key, peer in pairs(onlinePeers) do
        if (now - peer.lastHeartbeat) > timeout then
            table.insert(removed, key)
        end
    end

    for _, key in ipairs(removed) do
        onlinePeers[key] = nil
        HardcorePlus:SendMessage("HCP_PEER_OFFLINE", key)
    end
end

-- ═══════════════════════════════════════════
--  Offline Ping Detection (Exponential Backoff)
--  When a peer goes "offline" (stops heartbeating), send whisper pings
--  at increasing intervals. If they reply → they're online with addon
--  disabled = suspicious. Uses STATUS_QUERY which triggers a STATUS_REPLY.
-- ═══════════════════════════════════════════

-- Active ping schedules: [playerKey] = { nextPing, interval, attempts, maxAttempts }
local activePings = {}
local PING_INITIAL_INTERVAL = 30    -- first ping 30s after going offline
local PING_MAX_INTERVAL = 600       -- cap at 10 minutes
local PING_MAX_ATTEMPTS = 6         -- stop after 6 attempts (~20 min total)
local PING_BACKOFF_FACTOR = 2       -- double interval each time

function Heartbeat:StartOfflinePing(playerKey)
    if not HCP.Utils.IsSystemEnabled("network") then return end
    -- Extract player name from key for whisper
    local name = playerKey:match("^(.+)-") or playerKey
    activePings[playerKey] = {
        name = name,
        nextPing = HCP.Utils.GetTimestamp() + PING_INITIAL_INTERVAL,
        interval = PING_INITIAL_INTERVAL,
        attempts = 0,
        maxAttempts = PING_MAX_ATTEMPTS,
        startedAt = HCP.Utils.GetTimestamp(),
    }
    HCP.Utils.DebugLog("Offline ping started for ", playerKey,
        " (", PING_MAX_ATTEMPTS, " attempts, backoff x", PING_BACKOFF_FACTOR, ")")
end

function Heartbeat:StopOfflinePing(playerKey)
    if activePings[playerKey] then
        HCP.Utils.DebugLog("Offline ping stopped for ", playerKey)
        activePings[playerKey] = nil
    end
end

function Heartbeat:GetActivePings()
    return activePings
end

local function ProcessOfflinePings()
    if not HCP.Utils.IsSystemEnabled("network") then return end
    local now = HCP.Utils.GetTimestamp()

    for key, ping in pairs(activePings) do
        -- If they came back online, stop pinging
        if onlinePeers[key] then
            activePings[key] = nil
        elseif now >= ping.nextPing then
            ping.attempts = ping.attempts + 1

            if ping.attempts > ping.maxAttempts then
                -- Done pinging — player is genuinely offline or ignoring us
                HCP.Utils.DebugLog("Offline ping expired for ", key,
                    " after ", ping.maxAttempts, " attempts")
                activePings[key] = nil
            else
                -- Send whisper ping (STATUS_QUERY)
                -- If their addon is running, they'll auto-reply with STATUS_REPLY
                -- which means they went offline from OUR perspective but addon is actually on
                -- → they may have left guild/party but are still playing (not suspicious)
                -- If their addon is NOT running but they're online, the whisper is silently ignored
                -- by WoW (no addon to process it) — no reply = no detection possible via addon msg
                --
                -- HOWEVER: if they disabled addon and re-enabled it, the STATUS_REPLY
                -- arriving after they were marked offline IS detectable and suspicious.
                HCP.Protocol:SendWhisper(
                    HCP.Protocol.MessageType.STATUS_QUERY,
                    { ping = true, attempt = ping.attempts },
                    ping.name
                )

                HCP.Utils.DebugLog("Ping #", ping.attempts, " sent to ", key,
                    " (next in ", ping.interval * PING_BACKOFF_FACTOR, "s)")

                -- Exponential backoff
                ping.interval = math.min(ping.interval * PING_BACKOFF_FACTOR, PING_MAX_INTERVAL)
                ping.nextPing = now + ping.interval
            end
        end
    end
end

-- ═══════════════════════════════════════════
--  Peer Validation for Status Transitions
-- ═══════════════════════════════════════════

--- Check if there are online peers who can validate our status.
-- Used by VerificationTracker to upgrade PENDING → UNVERIFIED.
function Heartbeat:HasOnlinePeers()
    return self:GetOnlinePeerCount() > 0
end

--- Broadcast our registration to all available channels.
function Heartbeat:BroadcastRegistration()
    if not HCP.db.char.registered then return end
    local data = HCP.db.char
    HCP.Protocol:SendAll(HCP.Protocol.MessageType.PEER_REGISTER, {
        status = data.status,
        level = HCP.Utils.GetLevel(),
        regAt = data.registeredAt,
    })
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize network stats
    HCP.Protocol:ResetStats()

    -- Register AceComm prefix and handler
    HardcorePlus:RegisterComm(HCP.Net.PREFIX, OnCommReceived)

    -- Start periodic heartbeat
    HardcorePlus:ScheduleRepeatingTimer(SendHeartbeat, HCP.Net.HEARTBEAT_INTERVAL)

    -- Start periodic data hash broadcast
    HardcorePlus:ScheduleRepeatingTimer(SendDataHash, HCP.Net.HASH_INTERVAL)

    -- Periodic peer timeout cleanup (every 60s)
    HardcorePlus:ScheduleRepeatingTimer(CleanupOfflinePeers, 60)

    -- Process offline pings every 15 seconds
    HardcorePlus:ScheduleRepeatingTimer(ProcessOfflinePings, 15)

    -- Start offline pings when a peer drops off
    HardcorePlus:RegisterMessage("HCP_PEER_OFFLINE", function(_, peerKey)
        -- Only ping registered peers (not random first-time contacts)
        local registry = HCP.db.global.peerRegistry
        if registry[peerKey] and registry[peerKey].registered then
            Heartbeat:StartOfflinePing(peerKey)
        end
    end)

    -- Stop pinging when a peer comes back
    HardcorePlus:RegisterMessage("HCP_PEER_UPDATED", function(_, peerKey)
        Heartbeat:StopOfflinePing(peerKey)
    end)

    -- Detect suspicious STATUS_REPLY from a supposedly-offline peer
    HardcorePlus:RegisterMessage("HCP_PEER_STATUS_RECEIVED", function(_, peerKey, payload)
        if activePings[peerKey] then
            -- They replied to our ping! They're online but weren't heartbeating.
            -- This means they either left guild/party (benign) or re-enabled addon after a gap.
            local ping = activePings[peerKey]
            local c = HCP.CC
            HardcorePlus:Print(c.GOLD .. "Offline ping response from " ..
                c.WHITE .. peerKey .. c.CLOSE ..
                c.DIM .. " — peer is online (was silent for " ..
                (HCP.Utils.GetTimestamp() - ping.startedAt) .. "s)" .. c.CLOSE)

            Heartbeat:StopOfflinePing(peerKey)
        end
    end)

    -- Also handle StatusReply as a peer coming back (it already fires HCP_PEER_STATUS_RECEIVED)

    -- Send initial heartbeat after short delay (let other modules init)
    HardcorePlus:ScheduleTimer(function()
        SendHeartbeat()
        SendDataHash()
    end, 3)

    -- When we register, broadcast to network
    HardcorePlus:RegisterMessage("HCP_REGISTERED", function()
        Heartbeat:BroadcastRegistration()
    end)

    -- When a peer comes online and we're pending, check for validation opportunity
    HardcorePlus:RegisterMessage("HCP_PEER_UPDATED", function(_, peerKey)
        local data = HCP.db.char
        if data.status == HCP.Status.PENDING and data.registered then
            -- A peer sees us → we can transition to UNVERIFIED
            -- (VERIFIED requires SoI; UNVERIFIED = peer-acknowledged but no SoI)
            local peer = onlinePeers[peerKey]
            if peer and peer.registered then
                HCP.VerificationTracker:TransitionStatus(HCP.Status.UNVERIFIED,
                    "Peer validated by " .. peerKey)
            end
        end
    end)

    -- Auto-promote PENDING → UNVERIFIED after timeout if no peers are available.
    -- This ensures solo players (no guild, no party) aren't stuck in PENDING forever.
    -- Peer validation is a nice-to-have, not a blocker for core functionality.
    HardcorePlus:ScheduleTimer(function()
        local data = HCP.db.char
        if data.status == HCP.Status.PENDING and data.registered then
            if Heartbeat:GetOnlinePeerCount() == 0 then
                local c = HCP.CC
                HCP.VerificationTracker:TransitionStatus(HCP.Status.UNVERIFIED,
                    "Auto-promoted (no peers available within " ..
                    HCP.Net.PENDING_AUTO_TIMEOUT .. "s)")
                HardcorePlus:Print(c.GOLD .. "No peers detected — status promoted to Unverified." .. c.CLOSE)
                HardcorePlus:Print(c.DIM .. "Peer validation is optional. Core tracking is fully active." .. c.CLOSE)
            end
        end
    end, HCP.Net.PENDING_AUTO_TIMEOUT)
end)
