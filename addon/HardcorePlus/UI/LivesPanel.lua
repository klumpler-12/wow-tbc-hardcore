--[[
    HardcorePlus — Lives Panel (Phase 5)
    1. Populates the "Lives" tab in MainPanel with instance life data.
    2. Creates a small moveable in-instance widget showing lives remaining.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local LivesPanel = {}
HCP.LivesPanel = LivesPanel

-- ═══════════════════════════════════════════
--  Lives Tab Content (MainPanel)
-- ═══════════════════════════════════════════

function LivesPanel:PopulateLivesTab(contentFrame)
    -- Clear existing
    local children = { contentFrame:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
    local regions = { contentFrame:GetRegions() }
    for _, region in ipairs(regions) do
        if region.SetText then region:SetText("") end
    end
    if contentFrame.placeholder then contentFrame.placeholder:Hide() end

    local c = HCP.CC
    local data = HCP.db.char
    local yOff = -8

    local function Line(text)
        local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, yOff)
        fs:SetPoint("RIGHT", contentFrame, "RIGHT", -8, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        fs:SetWordWrap(true)
        yOff = yOff - 16
        return fs
    end

    -- Instance lives disabled check
    if not data.instanceLivesEnabled then
        Line(c.DIM .. "Instance Lives: Disabled (Juggernaut/True-HC mode)" .. c.CLOSE)
        Line("")
        Line(c.DIM .. "All instance deaths are treated as permadeath." .. c.CLOSE)
        return
    end

    -- Header
    Line(c.GOLD .. "Instance Lives" .. c.CLOSE)
    yOff = yOff - 4

    -- Weekly Pool
    local pool = data.weeklyPool
    local poolRemaining = HCP.InstanceTracker and HCP.InstanceTracker:GetWeeklyPoolRemaining() or
        math.max(0, (pool.max + pool.bonus) - pool.used)
    local poolTotal = pool.max + pool.bonus
    local poolColor = poolRemaining > 0 and c.BLUE or c.RED

    Line(c.WHITE .. "Weekly Pool: " .. c.CLOSE ..
        poolColor .. poolRemaining .. "/" .. poolTotal .. c.CLOSE ..
        c.DIM .. " remaining" .. c.CLOSE)
    if pool.bonus > 0 then
        Line(c.DIM .. "  (includes +" .. pool.bonus .. " deathless bonus)" .. c.CLOSE)
    end
    Line(c.DIM .. "  Resets: " .. HCP.Utils.FormatDate(pool.resetTime, "%m/%d %H:%M") .. c.CLOSE)
    yOff = yOff - 8

    -- Current instance (if in one)
    local currentInst = HCP.InstanceTracker and HCP.InstanceTracker:GetCurrentInstance()
    if currentInst then
        Line(c.BLUE .. "═══ Currently In ═══" .. c.CLOSE)
        local bonusLives = HCP.GetBonusLives(currentInst.name, currentInst.isHeroic)
        if bonusLives > 0 then
            local remaining = HCP.InstanceTracker:GetInstanceLivesRemaining(currentInst.name, currentInst.isHeroic)
            local lifeColor = remaining > 0 and c.GREEN or c.RED
            Line(c.WHITE .. currentInst.name ..
                (currentInst.isHeroic and " (Heroic)" or "") .. c.CLOSE)
            Line("  Lives: " .. lifeColor .. remaining .. "/" .. bonusLives .. c.CLOSE)
        else
            Line(c.RED .. currentInst.name ..
                (currentInst.isHeroic and " (Heroic)" or "") .. c.CLOSE)
            Line("  " .. c.RED .. "NO bonus lives — death is permanent" .. c.CLOSE)
        end
        yOff = yOff - 8
    end

    -- Instance history
    local hasData = false
    Line(c.GOLD .. "Instance History" .. c.CLOSE)
    yOff = yOff - 4

    -- Sort by most recently entered
    local sorted = {}
    for key, lifeData in pairs(data.instanceLives) do
        table.insert(sorted, { key = key, data = lifeData })
    end
    table.sort(sorted, function(a, b)
        return (a.data.lastEntry or 0) > (b.data.lastEntry or 0)
    end)

    for _, entry in ipairs(sorted) do
        hasData = true
        local lifeData = entry.data
        local remaining = lifeData.livesMax - lifeData.livesUsed
        local lifeColor = remaining > 0 and c.GREEN or c.RED
        local deathCount = #lifeData.deaths

        Line(c.WHITE .. entry.key .. c.CLOSE)
        if lifeData.livesMax > 0 then
            Line("  Lives: " .. lifeColor .. remaining .. "/" .. lifeData.livesMax .. c.CLOSE ..
                (deathCount > 0 and (c.DIM .. " (" .. deathCount .. " death" ..
                    (deathCount > 1 and "s" or "") .. ")" .. c.CLOSE) or ""))
        else
            Line("  " .. c.DIM .. "No bonus lives" .. c.CLOSE)
        end

        -- Show last entry time
        if lifeData.lastEntry > 0 then
            Line("  " .. c.DIM .. "Last entered: " ..
                HCP.Utils.FormatDate(lifeData.lastEntry) .. c.CLOSE)
        end
        yOff = yOff - 4
    end

    if not hasData then
        Line(c.DIM .. "  No instance data yet. Enter an instance to begin tracking." .. c.CLOSE)
    end
end

-- ═══════════════════════════════════════════
--  In-Instance Lives Widget (floating)
-- ═══════════════════════════════════════════

local BACKDROP_WIDGET = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local widgetFrame = nil

local function CreateInstanceWidget()
    if widgetFrame then return widgetFrame end

    widgetFrame = HCP.Compat.CreateBackdropFrame("Frame", "HCPInstanceLivesWidget", UIParent)
    widgetFrame:SetSize(200, 60)
    widgetFrame:SetPoint("TOP", UIParent, "TOP", 0, -120)
    widgetFrame:SetMovable(true)
    widgetFrame:EnableMouse(true)
    widgetFrame:RegisterForDrag("LeftButton")
    widgetFrame:SetScript("OnDragStart", widgetFrame.StartMoving)
    widgetFrame:SetScript("OnDragStop", widgetFrame.StopMovingOrSizing)
    widgetFrame:SetFrameStrata("HIGH")
    widgetFrame:SetClampedToScreen(true)

    widgetFrame:SetBackdrop(BACKDROP_WIDGET)
    widgetFrame:SetBackdropColor(
        HCP.Colors.BG_DARK.r, HCP.Colors.BG_DARK.g, HCP.Colors.BG_DARK.b, 0.85)
    widgetFrame:SetBackdropBorderColor(
        HCP.Colors.BORDER.r, HCP.Colors.BORDER.g, HCP.Colors.BORDER.b, 1)

    -- Instance name
    local nameText = widgetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", 8, -6)
    nameText:SetPoint("TOPRIGHT", -8, -6)
    nameText:SetJustifyH("LEFT")
    widgetFrame.nameText = nameText

    -- Lives line
    local livesText = widgetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    livesText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -4)
    livesText:SetPoint("RIGHT", widgetFrame, "RIGHT", -8, 0)
    widgetFrame.livesText = livesText

    -- Weekly pool line
    local poolText = widgetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    poolText:SetPoint("TOPLEFT", livesText, "BOTTOMLEFT", 0, -2)
    widgetFrame.poolText = poolText

    widgetFrame:Hide()
    return widgetFrame
end

function LivesPanel:UpdateWidget()
    if not HCP.db.char.instanceLivesEnabled then
        if widgetFrame then widgetFrame:Hide() end
        return
    end

    local currentInst = HCP.InstanceTracker and HCP.InstanceTracker:GetCurrentInstance()
    if not currentInst then
        if widgetFrame then widgetFrame:Hide() end
        return
    end

    local widget = CreateInstanceWidget()
    local c = HCP.CC
    local bonusLives = HCP.GetBonusLives(currentInst.name, currentInst.isHeroic)
    local weeklyRemaining = HCP.InstanceTracker:GetWeeklyPoolRemaining()

    -- Instance name
    widget.nameText:SetText(c.BLUE .. currentInst.name ..
        (currentInst.isHeroic and " (H)" or "") .. c.CLOSE)

    if bonusLives > 0 then
        local remaining = HCP.InstanceTracker:GetInstanceLivesRemaining(currentInst.name, currentInst.isHeroic)
        local lifeColor = remaining > 0 and c.GREEN or c.RED
        widget.livesText:SetText("Lives: " .. lifeColor .. remaining .. "/" .. bonusLives .. c.CLOSE)
        widget:SetBackdropBorderColor(
            HCP.Colors.BLUE.r, HCP.Colors.BLUE.g, HCP.Colors.BLUE.b, 1)
    else
        widget.livesText:SetText(c.RED .. "NO bonus lives" .. c.CLOSE)
        widget:SetBackdropBorderColor(
            HCP.Colors.RED.r, HCP.Colors.RED.g, HCP.Colors.RED.b, 1)
    end

    widget.poolText:SetText(c.DIM .. "Weekly pool: " .. weeklyRemaining .. c.CLOSE)

    widget:Show()
end

function LivesPanel:HideWidget()
    if widgetFrame then widgetFrame:Hide() end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

-- Populate lives tab when selected
HardcorePlus:RegisterMessage("HCP_TAB_SELECTED", function(_, tabId)
    if tabId == "lives" and HCP.MainPanel then
        local cf = HCP.MainPanel:GetContentFrame("lives")
        if cf then
            LivesPanel:PopulateLivesTab(cf)
        end
    end
end)

-- Show/hide/update widget on instance events
HardcorePlus:RegisterMessage("HCP_INSTANCE_ENTERED", function()
    LivesPanel:UpdateWidget()
end)

HardcorePlus:RegisterMessage("HCP_INSTANCE_LEFT", function()
    LivesPanel:HideWidget()
end)

HardcorePlus:RegisterMessage("HCP_INSTANCE_LIFE_CONSUMED", function()
    LivesPanel:UpdateWidget()
    -- Also refresh main panel if open
    if HCP.MainPanel then
        HCP.MainPanel:Refresh()
    end
end)
