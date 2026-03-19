--[[
    HardcorePlus — TBC 2.4.3 Compatibility Layer
    Shims for APIs that don't exist in the original TBC 2.4.3 client (Interface 20400).

    MUST load before all other addon files (after Constants.lua, before Utils.lua).

    Provides:
      - CombatLogGetCurrentEventInfo() polyfill + CLEU arg normalization
      - BackdropTemplateMixin fallback (SetBackdrop is native in TBC)
      - IsInGroup() / GetNumGroupMembers() polyfills
      - Safe C_Map stub
      - GetInstanceInfo() polyfill (added in WotLK 3.2.0)
      - SetColorTexture() polyfill (added in Legion 7.0.3)
      - HCP.Compat.CreateBackdropFrame() helper

    Each shim is guarded: if the native API already exists (e.g., on a backporting
    server or WotLK+), it's left alone. This file is safe on any client version.
]]

local ADDON_NAME, HCP = ...

HCP.Compat = {}

-- ═══════════════════════════════════════════
--  1. COMBAT_LOG_EVENT_UNFILTERED Argument Normalization
--
--  TBC 2.4.3 CLEU arg layout (8 base fields):
--    timestamp, subevent, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, [eventArgs...]
--
--  Modern (BFA 8.0+) CLEU arg layout (11 base fields):
--    timestamp, subevent, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags,
--    dstGUID, dstName, dstFlags, dstRaidFlags, [eventArgs...]
--
--  We normalize TBC args → modern format by inserting the 3 missing fields
--  (hideCaster=false, srcRaidFlags=0, dstRaidFlags=0) so all downstream
--  parsing code can use modern field positions unchanged.
-- ═══════════════════════════════════════════

HCP.Compat._cleuArgs = {}

if not CombatLogGetCurrentEventInfo then
    -- TBC 2.4.3 path: polyfill the function
    CombatLogGetCurrentEventInfo = function()
        return unpack(HCP.Compat._cleuArgs)
    end
    HCP.Compat.CLEU_NEEDS_ARGS = true
else
    HCP.Compat.CLEU_NEEDS_ARGS = false
end

--- Store and normalize TBC CLEU args to modern (BFA+) format.
-- Call this from the CLEU event handler BEFORE any parsing.
-- On modern clients (CLEU_NEEDS_ARGS == false), this is a no-op.
-- @param ... varargs: the raw CLEU args from the event handler
function HCP.Compat.StoreCLEUArgs(...)
    if not HCP.Compat.CLEU_NEEDS_ARGS then return end

    -- TBC 2.4.3 format: timestamp, subevent, srcGUID, srcName, srcFlags,
    --                    dstGUID, dstName, dstFlags, [eventSpecificArgs...]
    local n = select('#', ...)
    local args = {}

    -- Base fields (8 in TBC → 11 in modern)
    local timestamp  = select(1, ...)
    local subevent   = select(2, ...)
    local srcGUID    = select(3, ...)
    local srcName    = select(4, ...)
    local srcFlags   = select(5, ...)
    local dstGUID    = select(6, ...)
    local dstName    = select(7, ...)
    local dstFlags   = select(8, ...)

    -- Build modern-format arg table
    args[1]  = timestamp
    args[2]  = subevent
    args[3]  = false        -- hideCaster (added 4.1.0, not in TBC)
    args[4]  = srcGUID
    args[5]  = srcName
    args[6]  = srcFlags
    args[7]  = 0            -- sourceRaidFlags (added 4.2.0, not in TBC)
    args[8]  = dstGUID
    args[9]  = dstName
    args[10] = dstFlags
    args[11] = 0            -- destRaidFlags (added 4.2.0, not in TBC)

    -- Append event-specific args (starting from TBC position 9 → modern position 12)
    for i = 9, n do
        args[#args + 1] = select(i, ...)
    end

    HCP.Compat._cleuArgs = args
end

-- ═══════════════════════════════════════════
--  2. BackdropTemplate
--  TBC 2.4.3: SetBackdrop() is native on all frames. "BackdropTemplate"
--  doesn't exist as a registered mixin.
--  9.0+ (SL): SetBackdrop() removed; BackdropTemplate mixin required.
--  We provide a helper that works on both.
-- ═══════════════════════════════════════════

HCP.Compat.HAS_BACKDROP_TEMPLATE = (BackdropTemplateMixin ~= nil)

--- Create a frame with backdrop support on any client version.
-- On TBC 2.4.3: creates a plain frame (SetBackdrop is native).
-- On 9.0+: creates with BackdropTemplate.
-- @param frameType string: "Frame", "Button", etc.
-- @param name string|nil: global frame name
-- @param parent frame: parent frame
-- @param extraTemplate string|nil: additional template to inherit
-- @return frame
function HCP.Compat.CreateBackdropFrame(frameType, name, parent, extraTemplate)
    if HCP.Compat.HAS_BACKDROP_TEMPLATE then
        -- Modern client: needs BackdropTemplate
        local template = "BackdropTemplate"
        if extraTemplate then
            template = template .. "," .. extraTemplate
        end
        return CreateFrame(frameType, name, parent, template)
    else
        -- TBC 2.4.3: SetBackdrop is native, no template needed
        return CreateFrame(frameType, name, parent, extraTemplate)
    end
end

-- ═══════════════════════════════════════════
--  3. Group / Raid API Polyfills
--  TBC 2.4.3 has: GetNumRaidMembers(), GetNumPartyMembers()
--  5.0+ (MoP): replaced with IsInGroup(), GetNumGroupMembers()
-- ═══════════════════════════════════════════

if not IsInGroup then
    IsInGroup = function()
        return (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0)
    end
end

if not IsInRaid then
    IsInRaid = function()
        return GetNumRaidMembers() > 0
    end
end

if not GetNumGroupMembers then
    GetNumGroupMembers = function()
        local raid = GetNumRaidMembers()
        if raid > 0 then return raid end
        local party = GetNumPartyMembers()
        if party > 0 then return party + 1 end  -- +1 for self
        return 0
    end
end

-- ═══════════════════════════════════════════
--  4. C_Map Stub
--  TBC 2.4.3: C_Map doesn't exist. Stub it so nil checks pass.
-- ═══════════════════════════════════════════

if not C_Map then
    C_Map = {}
end
if not C_Map.GetBestMapForUnit then
    C_Map.GetBestMapForUnit = function() return 0 end
end

-- ═══════════════════════════════════════════
--  5. GetInstanceInfo() Polyfill
--  TBC 2.4.3: GetInstanceInfo() does NOT exist (added in WotLK 3.2.0).
--  We polyfill it using available TBC APIs:
--    - IsInInstance() → inInstance, instanceType
--    - GetRealZoneText() → instance/zone name
--    - GetInstanceDifficulty() → 1=Normal, 2=Heroic (native in TBC)
-- ═══════════════════════════════════════════

if not GetInstanceInfo then
    GetInstanceInfo = function()
        local inInstance, instanceType = IsInInstance()
        if not inInstance then
            return GetRealZoneText() or "Unknown", "none", 0, "", 0
        end

        local name = GetRealZoneText() or "Unknown"
        local difficultyID = GetInstanceDifficulty and GetInstanceDifficulty() or 1
        local difficultyName = ""
        local maxPlayers = 0

        -- Map TBC difficulty IDs to labels and player counts
        if instanceType == "party" then
            maxPlayers = 5
            if difficultyID == 2 then
                difficultyName = "Heroic"
            else
                difficultyName = "Normal"
            end
        elseif instanceType == "raid" then
            -- TBC raids: 10-man (Karazhan, ZA) or 25-man (everything else)
            -- difficultyID in TBC for raids: 1=Normal(10/25), no heroic raids in TBC
            difficultyName = "Normal"
            -- Estimate maxPlayers from known instances
            if name == "Karazhan" or name == "Zul'Aman" then
                maxPlayers = 10
            else
                maxPlayers = 25
            end
        elseif instanceType == "pvp" or instanceType == "arena" then
            difficultyName = "Normal"
            maxPlayers = 0  -- varies
        end

        return name, instanceType, difficultyID, difficultyName, maxPlayers
    end
    HCP.Compat.POLYFILLED_INSTANCE_INFO = true
end

-- ═══════════════════════════════════════════
--  6. SetColorTexture() Polyfill
--  TBC 2.4.3: SetColorTexture() does NOT exist (added in Legion 7.0.3).
--  In TBC, use SetTexture(r, g, b, a) with numeric RGBA values,
--  or use SetTexture("path") + SetVertexColor().
-- ═══════════════════════════════════════════

-- Patch the Texture metatable if SetColorTexture doesn't exist.
-- We hook it once here; all textures created afterward inherit it.
do
    local testFrame = CreateFrame("Frame")
    local testTexture = testFrame:CreateTexture()
    if not testTexture.SetColorTexture then
        local meta = getmetatable(testTexture).__index
        meta.SetColorTexture = function(self, r, g, b, a)
            self:SetTexture(r, g, b, a)
        end
    end
    testTexture:Hide()
    testFrame:Hide()
end

-- ═══════════════════════════════════════════
--  7. GetInstanceDifficulty Compat
--  TBC 2.4.3: GetInstanceDifficulty() returns 1=Normal, 2=Heroic
--  This exists natively in TBC, just documenting for clarity.
-- ═══════════════════════════════════════════

-- No shim needed — GetInstanceDifficulty() is native in TBC 2.4.3.

-- ═══════════════════════════════════════════
--  8. Logging
-- ═══════════════════════════════════════════

function HCP.Compat.Log(msg)
    if HCP.Utils and HCP.Utils.DebugLog then
        HCP.Utils.DebugLog("[Compat] ", msg)
    end
end

-- Report what shims are active (printed once on load if verbose)
function HCP.Compat.PrintStatus()
    local shims = {}
    if HCP.Compat.CLEU_NEEDS_ARGS then
        table.insert(shims, "CombatLogGetCurrentEventInfo (polyfilled + normalized)")
    end
    if not HCP.Compat.HAS_BACKDROP_TEMPLATE then
        table.insert(shims, "BackdropTemplate (using native SetBackdrop)")
    end
    if HCP.Compat.POLYFILLED_INSTANCE_INFO then
        table.insert(shims, "GetInstanceInfo (polyfilled via GetRealZoneText + GetInstanceDifficulty)")
    end
    -- IsInGroup polyfill detection
    if GetNumPartyMembers then
        table.insert(shims, "IsInGroup/IsInRaid/GetNumGroupMembers (polyfilled)")
    end

    if #shims > 0 then
        HCP.Compat.Log("Active shims: " .. table.concat(shims, ", "))
    else
        HCP.Compat.Log("No shims needed — all APIs native")
    end
end
