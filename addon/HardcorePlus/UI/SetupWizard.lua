--[[
    HardcorePlus — Setup Wizard UI (Phase 1.5)
    Full-screen first-run wizard: freshness check → rule config → confirm.
    Uses raw frames with HC website color palette.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local Wizard = {}
HCP.SetupWizard = Wizard

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local frame = nil
local currentStep = 1
local freshnessResult = nil
local freshnessChecks = nil

-- Selected options (defaults)
local selectedTradeMode = HCP.TradeMode.OPEN
local selectedInstanceLives = true
local selectedCheckpoint = true

-- ═══════════════════════════════════════════
--  Helpers
-- ═══════════════════════════════════════════

local function ApplyColors(f, bgColor, borderColor)
    local bg = bgColor or HCP.Colors.BG_DARK
    local border = borderColor or HCP.Colors.BORDER
    f:SetBackdropColor(bg.r, bg.g, bg.b, bg.a or 0.95)
    f:SetBackdropBorderColor(border.r, border.g, border.b, 1)
end

local function CreateButton(parent, text, width, onClick)
    local btn = HCP.Compat.CreateBackdropFrame("Button", nil, parent)
    btn:SetSize(width or 160, 32)
    btn:SetBackdrop(BACKDROP)
    ApplyColors(btn, HCP.Colors.BG_CARD, HCP.Colors.ACCENT)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    btn.label = label

    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function(self)
        ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.ACCENT_GLOW)
    end)
    btn:SetScript("OnLeave", function(self)
        ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.ACCENT)
    end)
    return btn
end

-- ═══════════════════════════════════════════
--  Step 1: Welcome
-- ═══════════════════════════════════════════

local function ShowStep1(contentArea)
    local c = HCP.CC
    local yOff = -20

    local function Line(text, fontSize)
        local fs = contentArea:CreateFontString(nil, "OVERLAY", fontSize or "GameFontNormal")
        fs:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 20, yOff)
        fs:SetPoint("RIGHT", contentArea, "RIGHT", -20, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        fs:SetWordWrap(true)
        yOff = yOff - (fs:GetStringHeight() + 6)
        return fs
    end

    Line(c.GOLD .. "Register for TBC Hybrid Hardcore" .. c.CLOSE, "GameFontNormalLarge")
    yOff = yOff - 8
    Line(c.TEXT .. "Character: " .. c.WHITE .. (UnitName("player") or "?") .. c.CLOSE ..
        "  |  Level " .. HCP.Utils.GetLevel() ..
        "  |  " .. (UnitClass("player") or "") ..
        "  |  " .. (UnitRace("player") or ""), nil)
    yOff = yOff - 12
    Line(c.TEXT .. "TBC Hybrid Hardcore tracks your deaths, verifies your deathless state, " ..
        "and enables instance lives, checkpoints, and soft resets." .. c.CLOSE, nil)
    yOff = yOff - 4
    Line(c.TEXT .. "Once registered, your rule settings are " ..
        c.RED .. "permanently locked" .. c.CLOSE ..
        c.TEXT .. " for this character." .. c.CLOSE, nil)
    yOff = yOff - 16

    -- Next button
    local nextBtn = CreateButton(contentArea, c.GOLD .. "Begin Freshness Check  >" .. c.CLOSE, 220, function()
        Wizard:ShowStep(2)
    end)
    nextBtn:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -20, 20)
end

-- ═══════════════════════════════════════════
--  Step 2: Freshness Check
-- ═══════════════════════════════════════════

local function ShowStep2(contentArea)
    local c = HCP.CC
    local yOff = -20

    local function Line(text)
        local fs = contentArea:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 20, yOff)
        fs:SetPoint("RIGHT", contentArea, "RIGHT", -20, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        yOff = yOff - 20
        return fs
    end

    -- Run checks
    freshnessResult, freshnessChecks = HCP.Registration:RunFreshnessChecks()

    Line(c.GOLD .. "Character Freshness Check" .. c.CLOSE)
    yOff = yOff - 8

    for _, check in ipairs(freshnessChecks) do
        local icon = check.pass and (c.GREEN .. "✓" .. c.CLOSE) or (c.RED .. "✗" .. c.CLOSE)
        Line(icon .. "  " .. c.TEXT .. check.name .. ": " .. c.CLOSE ..
            (check.pass and c.GREEN or c.RED) .. check.detail .. c.CLOSE)
    end

    yOff = yOff - 12

    if freshnessResult then
        Line(c.GREEN .. "All checks passed! This character qualifies for full HC registration." .. c.CLOSE)
    else
        Line(c.RED .. "Some checks failed." .. c.CLOSE ..
            c.TEXT .. " This character has existing progress." .. c.CLOSE)
        yOff = yOff - 4
        Line(c.DIM .. "You can still register as 'Late Registration' with reduced trust, " ..
            "or create a new character (level 1-5) for full verification." .. c.CLOSE)
    end

    -- Buttons
    if freshnessResult then
        local nextBtn = CreateButton(contentArea, c.GOLD .. "Configure Rules  >" .. c.CLOSE, 200, function()
            Wizard:ShowStep(3)
        end)
        nextBtn:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -20, 20)
    else
        local lateBtn = CreateButton(contentArea, c.DIM .. "Late Registration" .. c.CLOSE, 180, function()
            Wizard:ShowStep(4) -- Skip to confirm with late registration
        end)
        lateBtn:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -20, 20)

        local cancelBtn = CreateButton(contentArea, c.RED .. "Cancel" .. c.CLOSE, 120, function()
            frame:Hide()
        end)
        cancelBtn:SetPoint("RIGHT", lateBtn, "LEFT", -10, 0)
    end

    local backBtn = CreateButton(contentArea, c.DIM .. "< Back" .. c.CLOSE, 100, function()
        Wizard:ShowStep(1)
    end)
    backBtn:SetPoint("BOTTOMLEFT", contentArea, "BOTTOMLEFT", 20, 20)
end

-- ═══════════════════════════════════════════
--  Step 3: Rule Configuration
-- ═══════════════════════════════════════════

local function ShowStep3(contentArea)
    local c = HCP.CC
    local yOff = -20

    local function Label(text)
        local fs = contentArea:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 20, yOff)
        fs:SetPoint("RIGHT", contentArea, "RIGHT", -20, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        yOff = yOff - 22
        return fs
    end

    Label(c.GOLD .. "Rule Configuration" .. c.CLOSE)
    yOff = yOff - 4
    Label(c.RED .. "These settings are PERMANENT for this character." .. c.CLOSE)
    yOff = yOff - 12

    -- Trade Mode selection (3 radio-style buttons)
    Label(c.TEXT .. "Trade Mode:" .. c.CLOSE)
    local tradeModes = {
        { key = HCP.TradeMode.SSF, label = "SSF (Solo Self-Found)", desc = "No trading at all" },
        { key = HCP.TradeMode.GUILDFOUND, label = "Guildfound", desc = "Guild trading only — enables Soft Reset" },
        { key = HCP.TradeMode.OPEN, label = "Open Trading", desc = "No restrictions" },
    }

    local tradeButtons = {}
    for _, mode in ipairs(tradeModes) do
        local btn = HCP.Compat.CreateBackdropFrame("Button", nil, contentArea)
        btn:SetSize(420, 24)
        btn:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 30, yOff)
        btn:SetBackdrop(BACKDROP)

        local isSelected = selectedTradeMode == mode.key
        ApplyColors(btn, isSelected and HCP.Colors.BG_CARD_HOVER or HCP.Colors.BG_CARD,
            isSelected and HCP.Colors.ACCENT or HCP.Colors.BORDER)

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT", btn, "LEFT", 8, 0)
        local prefix = isSelected and (c.NEON .. "● " .. c.CLOSE) or (c.DIM .. "○ " .. c.CLOSE)
        lbl:SetText(prefix .. (isSelected and c.WHITE or c.DIM) .. mode.label ..
            c.DIM .. " — " .. mode.desc .. c.CLOSE)
        btn.label = lbl
        btn.modeKey = mode.key

        btn:SetScript("OnClick", function()
            selectedTradeMode = mode.key
            Wizard:ShowStep(3) -- Refresh
        end)

        table.insert(tradeButtons, btn)
        yOff = yOff - 28
    end

    yOff = yOff - 12

    -- Instance Lives toggle
    Label(c.TEXT .. "Instance Lives:" .. c.CLOSE)
    local ilvBtn = HCP.Compat.CreateBackdropFrame("Button", nil, contentArea)
    ilvBtn:SetSize(420, 24)
    ilvBtn:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 30, yOff)
    ilvBtn:SetBackdrop(BACKDROP)
    ApplyColors(ilvBtn, HCP.Colors.BG_CARD, selectedInstanceLives and HCP.Colors.GREEN or HCP.Colors.BORDER)

    local ilvLbl = ilvBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ilvLbl:SetPoint("LEFT", ilvBtn, "LEFT", 8, 0)
    ilvLbl:SetText((selectedInstanceLives and (c.GREEN .. "✓ Enabled") or (c.RED .. "✗ Disabled")) .. c.CLOSE ..
        c.DIM .. " — Extra lives in heroic dungeons and raids" .. c.CLOSE)
    ilvBtn:SetScript("OnClick", function()
        selectedInstanceLives = not selectedInstanceLives
        Wizard:ShowStep(3)
    end)
    yOff = yOff - 32

    -- Checkpoint toggle
    Label(c.TEXT .. "Checkpoint (Level 58):" .. c.CLOSE)
    local cpBtn = HCP.Compat.CreateBackdropFrame("Button", nil, contentArea)
    cpBtn:SetSize(420, 24)
    cpBtn:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 30, yOff)
    cpBtn:SetBackdrop(BACKDROP)
    ApplyColors(cpBtn, HCP.Colors.BG_CARD, selectedCheckpoint and HCP.Colors.GREEN or HCP.Colors.BORDER)

    local cpLbl = cpBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cpLbl:SetPoint("LEFT", cpBtn, "LEFT", 8, 0)
    cpLbl:SetText((selectedCheckpoint and (c.GREEN .. "✓ Enabled") or (c.RED .. "✗ Disabled")) .. c.CLOSE ..
        c.DIM .. " — Register a new char after death at 58+" .. c.CLOSE)
    cpBtn:SetScript("OnClick", function()
        selectedCheckpoint = not selectedCheckpoint
        Wizard:ShowStep(3)
    end)
    yOff = yOff - 36

    -- Title preview
    if not selectedCheckpoint and not selectedInstanceLives then
        Label(c.GOLD .. "★ Title earned: JUGGERNAUT" .. c.CLOSE ..
            c.DIM .. " — No checkpoints, no instance lives. Pure skill." .. c.CLOSE)
    end

    -- Buttons
    local nextBtn = CreateButton(contentArea, c.GOLD .. "Review & Confirm  >" .. c.CLOSE, 220, function()
        Wizard:ShowStep(4)
    end)
    nextBtn:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -20, 20)

    local backBtn = CreateButton(contentArea, c.DIM .. "< Back" .. c.CLOSE, 100, function()
        Wizard:ShowStep(2)
    end)
    backBtn:SetPoint("BOTTOMLEFT", contentArea, "BOTTOMLEFT", 20, 20)
end

-- ═══════════════════════════════════════════
--  Step 4: Confirmation
-- ═══════════════════════════════════════════

local function ShowStep4(contentArea)
    local c = HCP.CC
    local isLateReg = not freshnessResult
    local yOff = -20

    local function Line(text)
        local fs = contentArea:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 20, yOff)
        fs:SetPoint("RIGHT", contentArea, "RIGHT", -20, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        fs:SetWordWrap(true)
        yOff = yOff - (fs:GetStringHeight() + 6)
        return fs
    end

    Line(c.GOLD .. "Confirm Registration" .. c.CLOSE)
    yOff = yOff - 8

    Line(c.TEXT .. "Character: " .. c.WHITE .. (UnitName("player") or "?") .. c.CLOSE)
    Line(c.TEXT .. "Registration Type: " .. c.CLOSE ..
        (isLateReg and (c.RED .. "Late Registration (reduced trust)" .. c.CLOSE) or
        (c.GREEN .. "Full Registration" .. c.CLOSE)))
    yOff = yOff - 4

    if not isLateReg then
        Line(c.TEXT .. "Trade Mode: " .. c.WHITE ..
            (HCP.TradeModeLabels[selectedTradeMode] or selectedTradeMode) .. c.CLOSE)
        Line(c.TEXT .. "Instance Lives: " ..
            (selectedInstanceLives and (c.GREEN .. "Enabled" .. c.CLOSE) or (c.RED .. "Disabled" .. c.CLOSE)))
        Line(c.TEXT .. "Checkpoint: " ..
            (selectedCheckpoint and (c.GREEN .. "Enabled (Lvl 58)" .. c.CLOSE) or (c.RED .. "Disabled" .. c.CLOSE)))

        if not selectedCheckpoint and not selectedInstanceLives then
            Line(c.GOLD .. "Title: JUGGERNAUT" .. c.CLOSE)
        end
    else
        Line(c.DIM .. "Late Registration uses default rules (open trading, all features enabled)." .. c.CLOSE)
    end

    yOff = yOff - 12
    Line(c.RED .. "⚠ These settings cannot be changed after confirmation!" .. c.CLOSE)
    yOff = yOff - 4
    Line(c.TEXT .. "Your status will be " .. c.DIM .. "Awaiting Peer Validation" .. c.CLOSE ..
        c.TEXT .. " until another addon user validates you." .. c.CLOSE)

    -- Confirm button
    local confirmBtn = CreateButton(contentArea, c.GOLD .. "★ CONFIRM HC REGISTRATION ★" .. c.CLOSE, 300, function()
        if isLateReg then
            HCP.Registration:RegisterLate(selectedTradeMode)
        else
            HCP.Registration:Register(selectedTradeMode, selectedInstanceLives, selectedCheckpoint)
        end
        frame:Hide()
        -- Registration:Register/RegisterLate already fires HCP_STATUS_CHANGED
    end)
    confirmBtn:SetPoint("BOTTOM", contentArea, "BOTTOM", 0, 60)
    ApplyColors(confirmBtn, HCP.Colors.BG_CARD, HCP.Colors.ACCENT_GLOW)

    -- Back
    local backBtn = CreateButton(contentArea, c.DIM .. "< Back" .. c.CLOSE, 100, function()
        Wizard:ShowStep(isLateReg and 2 or 3)
    end)
    backBtn:SetPoint("BOTTOMLEFT", contentArea, "BOTTOMLEFT", 20, 20)

    local cancelBtn = CreateButton(contentArea, c.RED .. "Cancel" .. c.CLOSE, 100, function()
        frame:Hide()
    end)
    cancelBtn:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -20, 20)
end

-- ═══════════════════════════════════════════
--  Frame Management
-- ═══════════════════════════════════════════

local stepFuncs = { ShowStep1, ShowStep2, ShowStep3, ShowStep4 }
local contentArea = nil

function Wizard:ShowStep(step)
    currentStep = step

    -- Clear content area
    if contentArea then
        local children = { contentArea:GetChildren() }
        for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
        local regions = { contentArea:GetRegions() }
        for _, region in ipairs(regions) do
            if region.Hide then region:Hide() end
            if region.SetText then region:SetText("") end
        end
    end

    if stepFuncs[step] then
        stepFuncs[step](contentArea)
    end

    -- Update step indicator
    if frame and frame.stepText then
        frame.stepText:SetText(HCP.CC.DIM .. "Step " .. step .. " of 4" .. HCP.CC.CLOSE)
    end
end

function Wizard:Create()
    if frame then return frame end

    frame = HCP.Compat.CreateBackdropFrame("Frame", "HCPSetupWizard", UIParent)
    frame:SetSize(520, 440)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)

    frame:SetBackdrop(BACKDROP)
    ApplyColors(frame, HCP.Colors.BG_DARK, HCP.Colors.ACCENT_DIM)

    -- Title bar
    local titleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -12)
    titleBar:SetText(HCP.CC.GOLD .. "HARDCOREPLUS" .. HCP.CC.CLOSE ..
        HCP.CC.DIM .. " — Setup" .. HCP.CC.CLOSE)

    -- Step indicator
    frame.stepText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.stepText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, -16)

    -- Gold accent line
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -36)
    accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -36)
    accent:SetHeight(1)
    accent:SetColorTexture(HCP.Colors.ACCENT.r, HCP.Colors.ACCENT.g, HCP.Colors.ACCENT.b, 0.6)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Content area
    contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -40)
    contentArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    tinsert(UISpecialFrames, "HCPSetupWizard")

    frame:Hide()
    return frame
end

function Wizard:Show()
    if not frame then self:Create() end
    -- Reset selections
    selectedTradeMode = HCP.TradeMode.OPEN
    selectedInstanceLives = true
    selectedCheckpoint = true
    self:ShowStep(1)
    frame:Show()
end

-- Message handler
HardcorePlus:RegisterMessage("HCP_SHOW_SETUP_WIZARD", function()
    Wizard:Show()
end)
