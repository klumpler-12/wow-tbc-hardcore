--[[
    HardcorePlus — Checkpoint System (Phase 6)
    Allows a dead character at level 58+ to register a NEW level 58 boosted character.

    Flow:
      1. Character reaches level 58 → checkpoint unlocked (tracked in Core.lua OnLevelUp)
      2. Character dies (permadeath, status = DEAD, level >= 58)
      3. Addon generates a one-time checkpoint token in global SavedVariables
      4. Player creates/boosts a new character to 58
      5. New character runs /hcp checkpoint claim → consumes token, registers as HC

    Token stored in global SV so any character on the same account can read it.
    Token expires after 24 hours, single-use.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local Checkpoint = {}
HCP.Checkpoint = Checkpoint

local TOKEN_EXPIRY = 86400  -- 24 hours in seconds

-- ═══════════════════════════════════════════
--  Token Management
-- ═══════════════════════════════════════════

--- Generate a checkpoint token for a dead character.
-- Called when a registered character at 58+ dies.
function Checkpoint:GenerateToken()
    if not HCP.Utils.IsSystemEnabled("checkpoint") then
        HCP.Utils.DebugLog("Checkpoint system disabled — token not generated")
        return
    end
    local data = HCP.db.char
    if data.status ~= HCP.Status.DEAD then return end
    if HCP.Utils.GetLevel() < 58 then return end
    if not data.checkpointEnabled then return end

    local token = {
        sourceChar = HCP.Utils.GetPlayerKey(),
        sourceLevel = HCP.Utils.GetLevel(),
        sourceClass = HCP.Utils.GetClass(),
        tradeMode = data.tradeMode,
        instanceLivesEnabled = data.instanceLivesEnabled,
        checkpointEnabled = data.checkpointEnabled,
        createdAt = HCP.Utils.GetTimestamp(),
        expiresAt = HCP.Utils.GetTimestamp() + TOKEN_EXPIRY,
        used = false,
    }

    -- Store in global SV (accessible by all characters on this account)
    local tokens = HCP.db.global.checkpointTokens
    table.insert(tokens, token)

    local c = HCP.CC
    HardcorePlus:Print(c.GOLD .. "Checkpoint token generated!" .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Source: " .. token.sourceChar ..
        " (Level " .. token.sourceLevel .. " " .. token.sourceClass .. ")" .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Expires in 24 hours. Use /hcp checkpoint claim on a new character." .. c.CLOSE)

    -- Broadcast to network
    if HCP.Protocol then
        HCP.Protocol:SendAll(HCP.Protocol.MessageType.PEER_REGISTER, {
            status = data.status,
            level = token.sourceLevel,
            regAt = data.registeredAt,
            checkpoint = true,
        })
    end
end

--- Find a valid (unexpired, unused) checkpoint token.
-- @return table|nil: the token, or nil if none available
function Checkpoint:FindValidToken()
    local tokens = HCP.db.global.checkpointTokens
    local now = HCP.Utils.GetTimestamp()

    for i = #tokens, 1, -1 do  -- newest first
        local token = tokens[i]
        if not token.used and now < token.expiresAt then
            return token, i
        end
    end
    return nil, nil
end

--- Claim a checkpoint token on the current character.
-- Registers the character as HC with inherited settings from the dead character.
function Checkpoint:ClaimToken()
    local data = HCP.db.char
    local c = HCP.CC

    -- Prevent claiming if already registered
    if data.registered then
        HardcorePlus:Print(c.RED .. "Already registered for HC. Cannot claim checkpoint." .. c.CLOSE)
        return false, "Already registered"
    end

    -- Must be level 58+
    local level = HCP.Utils.GetLevel()
    if level < 58 then
        HardcorePlus:Print(c.RED .. "Must be level 58+ to claim a checkpoint." .. c.CLOSE)
        return false, "Level too low"
    end

    -- Find valid token
    local token, tokenIndex = self:FindValidToken()
    if not token then
        HardcorePlus:Print(c.RED .. "No valid checkpoint token found." .. c.CLOSE)
        HardcorePlus:Print(c.DIM .. "Tokens expire after 24 hours." .. c.CLOSE)
        return false, "No valid token"
    end

    -- Prevent claiming your own token on the same character
    if token.sourceChar == HCP.Utils.GetPlayerKey() then
        HardcorePlus:Print(c.RED .. "Cannot claim your own checkpoint token." .. c.CLOSE)
        return false, "Same character"
    end

    -- Consume the token
    token.used = true
    token.usedBy = HCP.Utils.GetPlayerKey()
    token.usedAt = HCP.Utils.GetTimestamp()

    -- Register with inherited settings
    data.registered = true
    data.registeredAt = HCP.Utils.GetTimestamp()
    data.tradeMode = token.tradeMode or HCP.TradeMode.OPEN
    data.instanceLivesEnabled = token.instanceLivesEnabled
    data.checkpointEnabled = token.checkpointEnabled
    data.status = HCP.Status.PENDING

    -- Record checkpoint usage
    data.checkpoint.unlocked = true
    data.checkpoint.usedCount = data.checkpoint.usedCount + 1
    data.checkpoint.sourceChar = token.sourceChar

    -- Snapshot baseline state
    data.lastLevel = level
    data.lastGold = HCP.Utils.GetGold()
    data.lastInventoryHash = HCP.Utils.GetInventoryHash()
    data.lastProfCount = HCP.Utils.GetProfessionCount()

    -- Inherit title eligibility
    if not token.checkpointEnabled and not token.instanceLivesEnabled then
        data.title = HCP.Titles.JUGGERNAUT
    end

    HardcorePlus:Print(c.GOLD .. "Checkpoint claimed!" .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "From: " .. token.sourceChar ..
        " (Level " .. token.sourceLevel .. " " .. token.sourceClass .. ")" .. c.CLOSE)
    HardcorePlus:Print(c.DIM .. "Settings inherited. Status: Awaiting Peer Validation" .. c.CLOSE)

    HardcorePlus:SendMessage("HCP_REGISTERED")
    HardcorePlus:SendMessage("HCP_STATUS_CHANGED", data.status, nil, "Checkpoint from " .. token.sourceChar)

    return true
end

-- ═══════════════════════════════════════════
--  Token Cleanup
-- ═══════════════════════════════════════════

function Checkpoint:CleanupExpiredTokens()
    local tokens = HCP.db.global.checkpointTokens
    local now = HCP.Utils.GetTimestamp()
    local cleaned = 0

    for i = #tokens, 1, -1 do
        if tokens[i].used or now >= tokens[i].expiresAt then
            table.remove(tokens, i)
            cleaned = cleaned + 1
        end
    end

    return cleaned
end

-- ═══════════════════════════════════════════
--  Status Queries
-- ═══════════════════════════════════════════

function Checkpoint:GetStatus()
    local data = HCP.db.char
    local token = self:FindValidToken()

    return {
        unlocked = data.checkpoint.unlocked,
        enabled = data.checkpointEnabled,
        usedCount = data.checkpoint.usedCount,
        sourceChar = data.checkpoint.sourceChar,
        tokenAvailable = token ~= nil,
        tokenSource = token and token.sourceChar or nil,
        tokenExpires = token and token.expiresAt or nil,
    }
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Cleanup expired tokens on load
    Checkpoint:CleanupExpiredTokens()

    -- Generate token on permadeath if eligible
    HardcorePlus:RegisterMessage("HCP_STATUS_CHANGED", function(_, newStatus, oldStatus, reason)
        if newStatus == HCP.Status.DEAD then
            local data = HCP.db.char
            if data.checkpointEnabled and HCP.Utils.GetLevel() >= 58 then
                Checkpoint:GenerateToken()
            end
        end
    end)
end)
