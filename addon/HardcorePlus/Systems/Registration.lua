--[[
    HardcorePlus — Registration System (Phase 1.5)
    Character freshness verification and HC enrollment.
    Shows setup wizard on first load for unregistered characters.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local Registration = {}
HCP.Registration = Registration

-- ═══════════════════════════════════════════
--  Freshness Check
-- ═══════════════════════════════════════════

function Registration:RunFreshnessChecks()
    local checks = {}
    local allPass = true

    -- Level check
    local level = HCP.Utils.GetLevel()
    local levelPass = level <= HCP.Freshness.MAX_LEVEL
    table.insert(checks, {
        name = "Level",
        pass = levelPass,
        detail = "Level " .. level .. (levelPass and " (max " .. HCP.Freshness.MAX_LEVEL .. ")" or " — too high"),
    })
    if not levelPass then allPass = false end

    -- Gold check
    local gold = HCP.Utils.GetGold()
    local goldPass = gold <= HCP.Freshness.MAX_GOLD
    table.insert(checks, {
        name = "Gold",
        pass = goldPass,
        detail = HCP.Utils.FormatGold(gold) .. (goldPass and "" or " — too much"),
    })
    if not goldPass then allPass = false end

    -- Professions
    local profCount = HCP.Utils.GetProfessionCount()
    local profPass = profCount == 0
    table.insert(checks, {
        name = "Professions",
        pass = profPass,
        detail = profCount .. " learned" .. (profPass and "" or " — must be 0"),
    })
    if not profPass then allPass = false end

    -- Talent points
    local talents = HCP.Utils.GetSpentTalentPoints()
    local talentPass = talents == 0
    table.insert(checks, {
        name = "Talents",
        pass = talentPass,
        detail = talents .. " points spent" .. (talentPass and "" or " — must be 0"),
    })
    if not talentPass then allPass = false end

    -- Gear quality
    local gearPass = HCP.Utils.HasOnlyStartingGear()
    table.insert(checks, {
        name = "Equipment",
        pass = gearPass,
        detail = gearPass and "Starting gear only" or "Has green+ gear",
    })
    if not gearPass then allPass = false end

    -- Bag items (rough check — starting chars have ~4 items)
    local bagItems = HCP.Utils.CountBagItems()
    local bagPass = bagItems <= 8
    table.insert(checks, {
        name = "Inventory",
        pass = bagPass,
        detail = bagItems .. " items" .. (bagPass and "" or " — too many for a fresh character"),
    })
    if not bagPass then allPass = false end

    return allPass, checks
end

-- ═══════════════════════════════════════════
--  Registration Logic
-- ═══════════════════════════════════════════

function Registration:Register(tradeMode, instanceLivesEnabled, checkpointEnabled)
    local data = HCP.db.char

    data.registered = true
    data.registeredAt = HCP.Utils.GetTimestamp()
    data.tradeMode = tradeMode or HCP.TradeMode.OPEN
    data.instanceLivesEnabled = instanceLivesEnabled
    data.checkpointEnabled = checkpointEnabled
    data.status = HCP.Status.PENDING  -- Awaiting peer validation

    -- Determine achievement title
    if not checkpointEnabled and not instanceLivesEnabled then
        data.title = HCP.Titles.JUGGERNAUT
    end
    -- True-HC requires maintaining SoI — set later when SoI is detected + above conditions

    -- Snapshot baseline state
    data.lastLevel = HCP.Utils.GetLevel()
    data.lastGold = HCP.Utils.GetGold()
    data.lastInventoryHash = HCP.Utils.GetInventoryHash()
    data.lastProfCount = HCP.Utils.GetProfessionCount()

    HardcorePlus:Print(HCP.CC.GOLD .. "Registered for Hardcore!" .. HCP.CC.CLOSE ..
        " Status: " .. HCP.CC.DIM .. "Awaiting Peer Validation" .. HCP.CC.CLOSE)

    if data.title then
        HardcorePlus:Print("Title earned: " .. HCP.CC.GOLD .. data.title .. HCP.CC.CLOSE)
    end

    -- Notify other modules
    -- Signature: (newStatus, oldStatus, reason) — matches VerificationTracker:TransitionStatus
    HardcorePlus:SendMessage("HCP_REGISTERED")
    HardcorePlus:SendMessage("HCP_STATUS_CHANGED", data.status, nil, "HC Registration")
end

function Registration:RegisterLate(tradeMode)
    local data = HCP.db.char

    data.registered = true
    data.registeredAt = HCP.Utils.GetTimestamp()
    data.tradeMode = tradeMode or HCP.TradeMode.OPEN
    data.instanceLivesEnabled = true
    data.checkpointEnabled = true
    data.status = HCP.Status.LATE_REG

    data.lastLevel = HCP.Utils.GetLevel()
    data.lastGold = HCP.Utils.GetGold()
    data.lastInventoryHash = HCP.Utils.GetInventoryHash()
    data.lastProfCount = HCP.Utils.GetProfessionCount()

    HardcorePlus:Print(HCP.CC.GOLD .. "Late Registration complete." .. HCP.CC.CLOSE ..
        " Status: " .. HCP.CC.DIM .. "Non-Verified Start" .. HCP.CC.CLOSE)

    HardcorePlus:SendMessage("HCP_REGISTERED")
    HardcorePlus:SendMessage("HCP_STATUS_CHANGED", data.status, nil, "Late Registration")
end

-- ═══════════════════════════════════════════
--  Auto-show wizard on first load
-- ═══════════════════════════════════════════

-- Show wizard after UI is ready (fires after all HCP_ADDON_READY handlers)
HardcorePlus:RegisterMessage("HCP_UI_READY", function()
    HardcorePlus:ScheduleTimer(function()
        if not HCP.db.char.registered then
            HardcorePlus:SendMessage("HCP_SHOW_SETUP_WIZARD")
        end
    end, 1)
end)
