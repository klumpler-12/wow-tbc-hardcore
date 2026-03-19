--[[
    TBC Hybrid Hardcore — Constants
    Static data, color palette, enums, and configuration defaults.
]]

local ADDON_NAME, HCP = ...

-- Version
HCP.VERSION = "0.1.0-alpha"
HCP.DB_VERSION = 1

-- ═══════════════════════════════════════════
--  Color Palette (matches HC website)
-- ═══════════════════════════════════════════

HCP.Colors = {
    -- Backgrounds (used for frame backdrop references)
    BG_DARK         = { r = 0.039, g = 0.039, b = 0.059, a = 0.95 },  -- #0a0a0f
    BG_CARD         = { r = 0.071, g = 0.071, b = 0.102, a = 0.95 },  -- #12121a
    BG_CARD_HOVER   = { r = 0.102, g = 0.102, b = 0.149, a = 0.95 },  -- #1a1a26

    -- Accent
    ACCENT          = { r = 0.910, g = 0.651, b = 0.141 },  -- #e8a624 (gold)
    ACCENT_GLOW     = { r = 1.000, g = 0.745, b = 0.239 },  -- #ffbe3d
    ACCENT_DIM      = { r = 0.769, g = 0.537, b = 0.110 },  -- #c4891c

    -- Text
    TEXT            = { r = 0.878, g = 0.867, b = 0.835 },  -- #e0ddd5
    TEXT_DIM        = { r = 0.541, g = 0.529, b = 0.498 },  -- #8a877f
    TEXT_BRIGHT     = { r = 1.000, g = 1.000, b = 1.000 },  -- #ffffff

    -- Status colors
    RED             = { r = 0.831, g = 0.251, b = 0.251 },  -- #d44040
    GREEN           = { r = 0.251, g = 0.690, b = 0.376 },  -- #40b060
    NEON_GREEN      = { r = 0.224, g = 1.000, b = 0.078 },  -- #39ff14
    BLUE            = { r = 0.251, g = 0.502, b = 0.831 },  -- #4080d4
    PURPLE          = { r = 0.502, g = 0.251, b = 0.831 },  -- #8040d4

    -- Border
    BORDER          = { r = 0.165, g = 0.165, b = 0.227 },  -- #2a2a3a
}

-- WoW color codes for text formatting
HCP.CC = {
    GOLD        = "|cFFE8A624",
    GOLD_GLOW   = "|cFFFFBE3D",
    TEXT        = "|cFFE0DDD5",
    DIM         = "|cFF8A877F",
    RED         = "|cFFD44040",
    GREEN       = "|cFF40B060",
    NEON        = "|cFF39FF14",
    BLUE        = "|cFF4080D4",
    PURPLE      = "|cFF8040D4",
    WHITE       = "|cFFFFFFFF",
    CLOSE       = "|r",
}

-- ═══════════════════════════════════════════
--  Player Status Enums
-- ═══════════════════════════════════════════

HCP.Status = {
    PENDING     = "pending",        -- Registered, awaiting peer validation
    UNVERIFIED  = "unverified",     -- No SoI, no peer validation yet
    VERIFIED    = "verified",       -- SoI confirmed OR peer-validated
    TARNISHED   = "tarnished",      -- SoI lost or death with lives remaining
    DEAD        = "dead",           -- Permadeath
    SOFT_RESET  = "softReset",      -- After soft reset, re-entering HC
    LATE_REG    = "lateRegistration", -- Registered with existing progress
}

HCP.StatusColors = {
    [HCP.Status.PENDING]    = HCP.CC.DIM,
    [HCP.Status.UNVERIFIED] = HCP.CC.GOLD,
    [HCP.Status.VERIFIED]   = HCP.CC.GREEN,
    [HCP.Status.TARNISHED]  = HCP.CC.GOLD_GLOW,
    [HCP.Status.DEAD]       = HCP.CC.RED,
    [HCP.Status.SOFT_RESET] = HCP.CC.PURPLE,
    [HCP.Status.LATE_REG]   = HCP.CC.DIM,
}

HCP.StatusLabels = {
    [HCP.Status.PENDING]    = "Awaiting Peer Validation",
    [HCP.Status.UNVERIFIED] = "Unverified",
    [HCP.Status.VERIFIED]   = "Verified",
    [HCP.Status.TARNISHED]  = "Tarnished",
    [HCP.Status.DEAD]       = "Dead",
    [HCP.Status.SOFT_RESET] = "Soft Reset",
    [HCP.Status.LATE_REG]   = "Late Registration",
}

-- ═══════════════════════════════════════════
--  Trade Modes
-- ═══════════════════════════════════════════

HCP.TradeMode = {
    SSF         = "ssf",            -- Solo Self-Found
    GUILDFOUND  = "guildfound",     -- Guild trading only
    OPEN        = "open",           -- No trade restrictions
}

HCP.TradeModeLabels = {
    [HCP.TradeMode.SSF]         = "Solo Self-Found (SSF)",
    [HCP.TradeMode.GUILDFOUND]  = "Guildfound",
    [HCP.TradeMode.OPEN]        = "Open Trading",
}

-- ═══════════════════════════════════════════
--  Achievement Titles
-- ═══════════════════════════════════════════

HCP.Titles = {
    JUGGERNAUT  = "Juggernaut",     -- No checkpoints AND no instance lives
    TRUE_HC     = "True-HC",        -- No checkpoints, no instance lives, must maintain SoI
}

-- ═══════════════════════════════════════════
--  Instance Lives — Simple: +1 bonus life for the hardest content only
--  All other instances = 0 bonus lives (death = permadeath)
-- ═══════════════════════════════════════════

HCP.INSTANCE_BONUS_LIFE = 1   -- flat +1 for qualifying instances

HCP.WeeklyPoolDefault = 10

-- ═══════════════════════════════════════════
--  Violation Thresholds
-- ═══════════════════════════════════════════

HCP.Violations = {
    GRACE_MINUTES       = 15,       -- Minutes before addon gap becomes a violation
    MINOR_WEEKLY_MAX    = 5,        -- Minor violations per week before escalation
}

-- ═══════════════════════════════════════════
--  Freshness Check Thresholds (Phase 1.5)
-- ═══════════════════════════════════════════

HCP.Freshness = {
    MAX_LEVEL       = 5,
    MAX_GOLD        = 5000,     -- 50 silver in copper
    MAX_PLAYED      = 7200,     -- 2 hours in seconds
}

-- ═══════════════════════════════════════════
--  Soft Reset
-- ═══════════════════════════════════════════

-- NOTE: Named SoftResetConfig (not SoftReset) because Systems/SoftReset.lua
-- assigns HCP.SoftReset to the module table. This avoids the collision.
HCP.SoftResetConfig = {
    MAX_GOLD            = 10000,    -- 1g in copper
    COMPLETION_WINDOW   = 7200,     -- 2 hours /played in seconds
}

-- ═══════════════════════════════════════════
--  UI Constants
-- ═══════════════════════════════════════════

HCP.UI = {
    PANEL_WIDTH     = 520,
    PANEL_HEIGHT    = 480,
    BORDER_SIZE     = 1,
    PADDING         = 12,
    HEADER_HEIGHT   = 36,
    TAB_HEIGHT      = 28,
}

-- ═══════════════════════════════════════════
--  Network Protocol
-- ═══════════════════════════════════════════

HCP.Net = {
    PREFIX              = "HCPlus",
    HEARTBEAT_INTERVAL  = 60,       -- seconds
    HASH_INTERVAL       = 300,      -- 5 minutes
    PEER_TIMEOUT        = 300,      -- 5 minutes before peer considered offline
    PENDING_AUTO_TIMEOUT = 300,     -- 5 min: auto-promote PENDING → UNVERIFIED if no peers
}

-- ═══════════════════════════════════════════
--  Debug / Tester Mode (Alpha)
--  Toggle individual systems on/off for testing.
--  Always available in alpha builds.
-- ═══════════════════════════════════════════

HCP.DebugDefaults = {
    enabled         = true,     -- master debug mode (always on in alpha)
    verbose         = false,    -- print detailed debug messages to chat
    -- Core system toggles (true = active, false = disabled for testing)
    deathTracking   = true,     -- death detection + recording
    uptimeTracking  = true,     -- /played gap detection
    soiTracking     = true,     -- Soul of Iron buff scanning
    verification    = true,     -- status state machine
    network         = true,     -- heartbeat, peer comm, hash broadcast
    instanceLives   = true,     -- instance life pool
    checkpoint      = true,     -- checkpoint token generation/claim
    softReset       = true,     -- soft reset system
    -- Tracker plugins (toggleable data collectors)
    goldTracking        = true, -- gold change snapshots
    killTracking        = true, -- mob kill counter
    tradeTracking       = true, -- trade logging
    mailTracking        = true, -- mail sent/received
    ahTracking          = true, -- auction house visits
    distanceTracking    = true, -- zone traversal tracking
    professionTracking  = true, -- profession skill snapshots
    equipmentTracking   = true, -- gear change logging
    lootTracking        = true, -- loot collection logging
}

-- ═══════════════════════════════════════════
--  Instance Data — +1 Bonus Life Instances (Phase 5)
--  Only these instances grant +1 bonus life per attempt.
--  All other dungeons/raids = 0 bonus lives (death = permadeath).
-- ═══════════════════════════════════════════

-- 7 hardest heroic dungeons (each grants +1 life)
HCP.BonusLifeHeroics = {
    ["The Shattered Halls"]         = true,
    ["Magisters' Terrace"]          = true,
    ["Shadow Labyrinth"]            = true,     -- Shadow Lab
    ["The Arcatraz"]                = true,
    ["Opening of the Dark Portal"]  = true,     -- Black Morass
    ["The Steamvault"]              = true,
    ["Sethekk Halls"]               = true,
}

-- 7 hardest raids (each grants +1 life)
HCP.BonusLifeRaids = {
    ["Serpentshrine Cavern"]    = true,
    ["Tempest Keep"]            = true,     -- The Eye
    ["Hyjal Summit"]            = true,
    ["Black Temple"]            = true,
    ["Sunwell Plateau"]         = true,
    ["Zul'Aman"]                = true,
    ["Gruul's Lair"]            = true,
}

-- ═══════════════════════════════════════════
--  Challenge Modes (Future Feature)
--  Weapon/playstyle restriction challenges with tiered rewards.
-- ═══════════════════════════════════════════

HCP.ChallengeMode = {
    ONLYFISTS   = "onlyfists",
    WANDSLINGER = "wandslinger",
    PETLESS     = "petless",
    NAKED       = "naked",
}

HCP.ChallengeTiers = {
    [HCP.ChallengeMode.ONLYFISTS] = {
        name = "Onlyfists",
        desc = "Fist weapons only",
        tiers = {
            { name = "Bronze", level = 40, points = 300 },
            { name = "Silver", level = 60, points = 750 },
            { name = "Gold",   level = 70, points = 1500 },
        },
        chickenPenalty = -100,
        -- Validation: check INVSLOT_MAINHAND and INVSLOT_OFFHAND for fist weapon subclass
        weaponSubclass = "Fist Weapons",  -- GetItemInfo subtype
    },
    [HCP.ChallengeMode.PETLESS] = {
        name = "Petless Hunter",
        desc = "Hunter with no pet — ever",
        tiers = {
            { name = "Bronze", level = 40, points = 500 },
            { name = "Silver", level = 60, points = 1000 },
            { name = "Gold",   level = 70, points = 2000 },
        },
        chickenPenalty = -150,
        classRestriction = "HUNTER",
    },
}

HCP.ChallengeStatus = {
    INACTIVE  = "inactive",
    ACTIVE    = "active",
    COMPLETED = "completed",
    FORFEITED = "forfeited",  -- "Chicken"
}

-- ═══════════════════════════════════════════
--  Flex Raiding — Dynamic Life Scaling (Future Feature)
-- ═══════════════════════════════════════════

HCP.FlexRaiding = {
    -- Scale factor: bonus = floor((max - actual) / factor)
    SCALE_FACTOR_25 = 5,
    SCALE_FACTOR_10 = 3,
    -- Hard caps
    MAX_BONUS_25 = 3,
    MAX_BONUS_10 = 2,
    -- Minimum group size to qualify for flex scaling
    MIN_GROUP_SIZE = 5,
}

-- ═══════════════════════════════════════════
--  Mixed Group / Disconnect Rules
-- ═══════════════════════════════════════════

HCP.MixedGroup = {
    -- Instance lives disabled when group contains non-addon players
    LIVES_DISABLED_IN_MIXED = true,
    -- Grace period (seconds) before disconnected player's status becomes contested
    DISCONNECT_GRACE = 300,  -- 5 minutes
}

-- Quick lookup: does this instance grant a bonus life?
-- Heroic dungeons require heroic difficulty (GetInstanceDifficulty() == 2 in TBC).
-- Raids are always eligible by name (all listed raids are inherently hard content).
function HCP.GetBonusLives(instanceName, isHeroic)
    if HCP.BonusLifeHeroics[instanceName] then
        -- Heroic dungeons only grant bonus life on HEROIC difficulty.
        -- Normal mode of the same dungeon = 0 lives (permadeath).
        if isHeroic then
            return HCP.INSTANCE_BONUS_LIFE
        end
        return 0
    end
    if HCP.BonusLifeRaids[instanceName] then
        return HCP.INSTANCE_BONUS_LIFE
    end
    return 0
end
