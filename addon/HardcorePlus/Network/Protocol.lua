--[[
    HardcorePlus — Network Protocol (Phase 4)
    Message types, encoding/decoding, version handshake.
    Network communication uses AceComm over GUILD, PARTY, and RAID channels.

    Message format: { type = "HEARTBEAT", version = 1, payload = {...} }
    Serialized with AceSerializer, sent via AceComm with prefix "HCPlus".
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local Protocol = {}
HCP.Protocol = Protocol

-- Protocol version (bump when message format changes)
Protocol.VERSION = 1

-- ═══════════════════════════════════════════
--  Network Rate Tracking (for debug panel)
-- ═══════════════════════════════════════════

Protocol.Stats = {
    msgsSent = 0,
    msgsReceived = 0,
    bytesSent = 0,
    bytesReceived = 0,
    lastResetTime = 0,       -- GetTime() at last stats reset
    sentByType = {},         -- [msgType] = count
    receivedByType = {},     -- [msgType] = count
}

function Protocol:ResetStats()
    self.Stats.msgsSent = 0
    self.Stats.msgsReceived = 0
    self.Stats.bytesSent = 0
    self.Stats.bytesReceived = 0
    self.Stats.lastResetTime = GetTime()
    self.Stats.sentByType = {}
    self.Stats.receivedByType = {}
end

function Protocol:TrackSent(msgType, byteCount)
    self.Stats.msgsSent = self.Stats.msgsSent + 1
    self.Stats.bytesSent = self.Stats.bytesSent + (byteCount or 0)
    self.Stats.sentByType[msgType] = (self.Stats.sentByType[msgType] or 0) + 1
end

function Protocol:TrackReceived(msgType, byteCount)
    self.Stats.msgsReceived = self.Stats.msgsReceived + 1
    self.Stats.bytesReceived = self.Stats.bytesReceived + (byteCount or 0)
    self.Stats.receivedByType[msgType] = (self.Stats.receivedByType[msgType] or 0) + 1
end

function Protocol:GetRates()
    local elapsed = GetTime() - (self.Stats.lastResetTime or GetTime())
    if elapsed < 1 then elapsed = 1 end
    return {
        sentPerMin = self.Stats.msgsSent / elapsed * 60,
        recvPerMin = self.Stats.msgsReceived / elapsed * 60,
        bytesSentPerMin = self.Stats.bytesSent / elapsed * 60,
        bytesRecvPerMin = self.Stats.bytesReceived / elapsed * 60,
        totalSent = self.Stats.msgsSent,
        totalRecv = self.Stats.msgsReceived,
        elapsed = elapsed,
        sentByType = self.Stats.sentByType,
        receivedByType = self.Stats.receivedByType,
    }
end

-- ═══════════════════════════════════════════
--  Message Types
-- ═══════════════════════════════════════════

Protocol.MessageType = {
    HEARTBEAT       = "HB",     -- Periodic status broadcast
    DEATH_REPORT    = "DR",     -- Player died, broadcasting death record
    DEATH_VERIFY    = "DV",     -- Response to death report (witnessed/confirmed)
    STATUS_QUERY    = "SQ",     -- Request someone's full status
    STATUS_REPLY    = "SR",     -- Response to status query
    DATA_HASH       = "DH",     -- Periodic integrity hash broadcast
    FLAG_REPORT     = "FR",     -- Report suspicious activity on a player
    PEER_REGISTER   = "PR",     -- Register a new player in peer network
}

-- ═══════════════════════════════════════════
--  Encoding / Decoding
-- ═══════════════════════════════════════════

--- Encode a message for transmission.
-- @param msgType string: one of Protocol.MessageType values
-- @param payload table: message-specific data
-- @return string: serialized message ready for AceComm
function Protocol:Encode(msgType, payload)
    local message = {
        t = msgType,
        v = Protocol.VERSION,
        s = HCP.Utils.GetPlayerKey(),  -- sender
        ts = HCP.Utils.GetTimestamp(),
        p = payload or {},
    }
    return HardcorePlus:Serialize(message)
end

--- Decode a received message.
-- @param data string: raw serialized data from AceComm
-- @return table|nil: decoded message, or nil if invalid
-- @return string|nil: error reason if decode failed
function Protocol:Decode(data)
    local success, message = HardcorePlus:Deserialize(data)
    if not success then
        return nil, "Deserialization failed"
    end

    if type(message) ~= "table" then
        return nil, "Message is not a table"
    end

    -- Version check
    if not message.v then
        return nil, "No protocol version"
    end
    if message.v > Protocol.VERSION then
        return nil, "Newer protocol version: " .. message.v .. " (we have " .. Protocol.VERSION .. ")"
    end

    -- Validate required fields
    if not message.t then
        return nil, "No message type"
    end
    if not message.s then
        return nil, "No sender"
    end

    return message, nil
end

-- ═══════════════════════════════════════════
--  Send Helpers
-- ═══════════════════════════════════════════

--- Send a message to the GUILD channel (if in a guild).
-- @param msgType string: message type
-- @param payload table: message data
function Protocol:SendGuild(msgType, payload)
    if not IsInGuild() then return end
    local encoded = self:Encode(msgType, payload)
    self:TrackSent(msgType, #encoded)
    HardcorePlus:SendCommMessage(HCP.Net.PREFIX, encoded, "GUILD")
end

--- Send a message to a specific player via WHISPER.
-- @param msgType string: message type
-- @param payload table: message data
-- @param target string: player name (or Name-Realm)
function Protocol:SendWhisper(msgType, payload, target)
    local encoded = self:Encode(msgType, payload)
    self:TrackSent(msgType, #encoded)
    HardcorePlus:SendCommMessage(HCP.Net.PREFIX, encoded, "WHISPER", target)
end

--- Send a message to the party/raid (if in a group).
-- @param msgType string: message type
-- @param payload table: message data
function Protocol:SendGroup(msgType, payload)
    local encoded = self:Encode(msgType, payload)
    self:TrackSent(msgType, #encoded)
    local channel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil)
    if channel then
        HardcorePlus:SendCommMessage(HCP.Net.PREFIX, encoded, channel)
    end
end

--- Broadcast a message to ALL available channels (guild + group).
-- Prevents duplicate delivery: guild members in the same party/raid
-- will receive via both channels but dedup happens in the message router
-- (we already ignore our own messages; AceComm deduplicates by prefix+sender).
-- @param msgType string: message type
-- @param payload table: message data
function Protocol:SendAll(msgType, payload)
    local encoded = self:Encode(msgType, payload)
    self:TrackSent(msgType, #encoded)

    -- Guild
    if IsInGuild() then
        HardcorePlus:SendCommMessage(HCP.Net.PREFIX, encoded, "GUILD")
    end

    -- Party or Raid
    local groupChannel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil)
    if groupChannel then
        HardcorePlus:SendCommMessage(HCP.Net.PREFIX, encoded, groupChannel)
    end
end

-- ═══════════════════════════════════════════
--  Payload Builders
-- ═══════════════════════════════════════════

function Protocol:BuildHeartbeat()
    local data = HCP.db.char
    return {
        status = data.status,
        level = HCP.Utils.GetLevel(),
        owDeaths = data.openWorldDeaths,
        instDeaths = data.instanceDeaths,
        soi = data.soulOfIron,
        flags = #data.suspiciousFlags,
        title = data.title,
        reg = data.registered,
    }
end

function Protocol:BuildDataHash()
    local data = HCP.db.char
    return {
        invHash = HCP.Utils.GetInventoryHash(),
        deathHash = HCP.Utils.SimpleHash(tostring(#data.deaths) .. ":" ..
            tostring(data.openWorldDeaths) .. ":" .. tostring(data.instanceDeaths)),
        sessionHash = HCP.Utils.SimpleHash(tostring(#data.sessions) .. ":" ..
            tostring(data.playedTotal)),
        level = HCP.Utils.GetLevel(),
    }
end

function Protocol:BuildDeathReport(deathRecord)
    return {
        zone = deathRecord.zone,
        killer = deathRecord.killer,
        ability = deathRecord.ability,
        level = deathRecord.level,
        inInstance = deathRecord.inInstance,
        instanceName = deathRecord.instanceName,
        isHeroic = deathRecord.isHeroic,
        timestamp = deathRecord.timestamp,
    }
end

function Protocol:BuildDeathVerify(deathReport, witnessed)
    return {
        target = deathReport.s,  -- who died (sender of the death report)
        timestamp = deathReport.p.timestamp,
        witnessed = witnessed,   -- did we see it in our combat log?
        verifier = HCP.Utils.GetPlayerKey(),
    }
end

function Protocol:BuildStatusReply()
    local data = HCP.db.char
    return {
        status = data.status,
        level = HCP.Utils.GetLevel(),
        owDeaths = data.openWorldDeaths,
        instDeaths = data.instanceDeaths,
        soi = data.soulOfIron,
        soiLost = data.soulOfIronLost,
        flags = #data.suspiciousFlags,
        title = data.title,
        tradeMode = data.tradeMode,
        reg = data.registered,
        regAt = data.registeredAt,
        softResets = data.softResets,
        instanceLives = data.instanceLivesEnabled,
        checkpoint = data.checkpointEnabled,
    }
end
