--[[
    HardcorePlus — Main Panel
    Central UI frame with status header, tab navigation, and content area.
    Uses raw WoW frames (not AceGUI) for full visual control matching HC website palette.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local MainPanel = {}
HCP.MainPanel = MainPanel

local PANEL_WIDTH = HCP.UI.PANEL_WIDTH
local PANEL_HEIGHT = HCP.UI.PANEL_HEIGHT
local PADDING = HCP.UI.PADDING
local HEADER_H = HCP.UI.HEADER_HEIGHT
local TAB_H = HCP.UI.TAB_HEIGHT

-- ═══════════════════════════════════════════
--  Backdrop Templates
-- ═══════════════════════════════════════════

local BACKDROP_MAIN = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local BACKDROP_CARD = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

-- ═══════════════════════════════════════════
--  Frame Creation
-- ═══════════════════════════════════════════

local frame = nil
local tabs = {}
local contentFrames = {}
local activeTab = nil

local function ApplyColors(f, bgColor, borderColor)
    local bg = bgColor or HCP.Colors.BG_DARK
    local border = borderColor or HCP.Colors.BORDER
    f:SetBackdropColor(bg.r, bg.g, bg.b, bg.a or 0.95)
    f:SetBackdropBorderColor(border.r, border.g, border.b, 1)
end

local function CreateStatusHeader(parent)
    local header = CreateFrame("Frame", nil, parent)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING, -PADDING)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PADDING, -PADDING)
    header:SetHeight(HEADER_H + 40)

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    title:SetText(HCP.CC.GOLD .. "HARDCOREPLUS" .. HCP.CC.CLOSE)
    title:SetFont(title:GetFont(), 18, "OUTLINE")

    -- Version
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("LEFT", title, "RIGHT", 8, 0)
    version:SetText(HCP.CC.DIM .. "v" .. HCP.VERSION .. HCP.CC.CLOSE)

    -- Status line
    local statusLine = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    header.statusLine = statusLine

    -- Character info line
    local charLine = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    charLine:SetPoint("TOPLEFT", statusLine, "BOTTOMLEFT", 0, -4)
    header.charLine = charLine

    -- Gold accent line under header
    local accentLine = header:CreateTexture(nil, "ARTWORK")
    accentLine:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    accentLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    accentLine:SetHeight(1)
    accentLine:SetColorTexture(HCP.Colors.ACCENT.r, HCP.Colors.ACCENT.g, HCP.Colors.ACCENT.b, 0.6)

    return header
end

local function UpdateHeader(header)
    local data = HCP.db and HCP.db.char or {}
    local c = HCP.CC
    local statusColor = HCP.StatusColors[data.status] or c.DIM
    local statusLabel = HCP.StatusLabels[data.status] or (data.status or "Unknown")
    local titleStr = data.title and (" " .. c.GOLD .. "[" .. data.title .. "]" .. c.CLOSE) or ""

    header.statusLine:SetText("Status: " .. statusColor .. statusLabel .. c.CLOSE .. titleStr)

    local name = UnitName("player") or "?"
    local level = HCP.Utils.GetLevel()
    local _, class = UnitClass("player")
    local deaths = (data.openWorldDeaths or 0)
    local soiStr = data.soulOfIron and (c.GREEN .. "SoI" .. c.CLOSE) or ""

    header.charLine:SetText(
        c.WHITE .. name .. c.CLOSE ..
        " — " .. c.DIM .. "Level " .. level .. " " .. (class or "") .. c.CLOSE ..
        " — " .. c.RED .. deaths .. " death(s)" .. c.CLOSE ..
        (soiStr ~= "" and (" — " .. soiStr) or "")
    )
end

-- ═══════════════════════════════════════════
--  Tab System
-- ═══════════════════════════════════════════

local TAB_DEFS = {
    { id = "overview",  label = "Overview" },
    { id = "deaths",    label = "Deaths" },
    { id = "lives",     label = "Lives" },
    { id = "network",   label = "Network" },
    { id = "flags",     label = "Flags" },
}

local function CreateTabButton(parent, tabDef, index, totalTabs)
    local tabWidth = (PANEL_WIDTH - PADDING * 2) / totalTabs
    local btn = HCP.Compat.CreateBackdropFrame("Button", nil, parent)
    btn:SetSize(tabWidth, TAB_H)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", (index - 1) * tabWidth, 0)

    -- Background
    btn:SetBackdrop(BACKDROP_CARD)
    ApplyColors(btn, HCP.Colors.BG_CARD, HCP.Colors.BORDER)

    -- Label
    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    label:SetText(HCP.CC.DIM .. tabDef.label .. HCP.CC.CLOSE)
    btn.label = label
    btn.tabId = tabDef.id

    btn:SetScript("OnClick", function()
        MainPanel:SwitchTab(tabDef.id)
    end)

    btn:SetScript("OnEnter", function(self)
        if activeTab ~= self.tabId then
            ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.BORDER)
        end
    end)

    btn:SetScript("OnLeave", function(self)
        if activeTab ~= self.tabId then
            ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.BORDER)
        end
    end)

    return btn
end

function MainPanel:SwitchTab(tabId)
    activeTab = tabId
    self.activeTab = tabId  -- expose for external modules
    for i, btn in ipairs(tabs) do
        if btn.tabId == tabId then
            ApplyColors(btn, HCP.Colors.BG_DARK, HCP.Colors.ACCENT)
            btn.label:SetText(HCP.CC.GOLD .. TAB_DEFS[i].label .. HCP.CC.CLOSE)
        else
            ApplyColors(btn, HCP.Colors.BG_CARD, HCP.Colors.BORDER)
            btn.label:SetText(HCP.CC.DIM .. TAB_DEFS[i].label .. HCP.CC.CLOSE)
        end
    end

    for id, cf in pairs(contentFrames) do
        if id == tabId then
            cf:Show()
        else
            cf:Hide()
        end
    end

    -- Fire event for modules to populate content
    HardcorePlus:SendMessage("HCP_TAB_SELECTED", tabId)
end

-- ═══════════════════════════════════════════
--  Content Areas (placeholder)
-- ═══════════════════════════════════════════

local function CreateContentFrame(parent, tabId)
    local cf = CreateFrame("Frame", nil, parent)
    cf:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    cf:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    cf:Hide()

    -- Placeholder text
    local placeholder = cf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholder:SetPoint("CENTER")
    placeholder:SetText(HCP.CC.DIM .. tabId:upper() .. " — Coming in next phase" .. HCP.CC.CLOSE)
    cf.placeholder = placeholder

    -- Scrollable text area for modules to populate
    cf.lines = {}

    return cf
end

-- Overview tab content is populated by UI/StatusDisplay.lua via HCP_TAB_SELECTED event.
-- No local PopulateOverview needed here.

-- ═══════════════════════════════════════════
--  Build Main Frame
-- ═══════════════════════════════════════════

function MainPanel:Create()
    if frame then return frame end

    frame = HCP.Compat.CreateBackdropFrame("Frame", "HardcorePlusMainFrame", UIParent)
    frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)

    -- Main backdrop
    frame:SetBackdrop(BACKDROP_MAIN)
    ApplyColors(frame, HCP.Colors.BG_DARK, HCP.Colors.ACCENT_DIM)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Status header
    frame.header = CreateStatusHeader(frame)

    -- Tab bar
    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -8)
    tabBar:SetPoint("TOPRIGHT", frame.header, "BOTTOMRIGHT", 0, -8)
    tabBar:SetHeight(TAB_H)

    for i, tabDef in ipairs(TAB_DEFS) do
        tabs[i] = CreateTabButton(tabBar, tabDef, i, #TAB_DEFS)
    end

    -- Content area
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -4)
    contentArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)

    for _, tabDef in ipairs(TAB_DEFS) do
        contentFrames[tabDef.id] = CreateContentFrame(contentArea, tabDef.id)
    end

    -- Default to overview tab
    MainPanel:SwitchTab("overview")

    -- ESC to close
    tinsert(UISpecialFrames, "HardcorePlusMainFrame")

    frame:Hide()
    return frame
end

function MainPanel:Toggle()
    if not frame then
        self:Create()
    end

    if frame:IsShown() then
        frame:Hide()
    else
        -- Refresh header then show — tab content populated via HCP_TAB_SELECTED
        if frame.header then
            UpdateHeader(frame.header)
        end
        frame:Show()
        -- Re-fire tab selection to populate active tab content
        HardcorePlus:SendMessage("HCP_TAB_SELECTED", activeTab or "overview")
    end
end

function MainPanel:Refresh()
    if frame and frame:IsShown() then
        if frame.header then
            UpdateHeader(frame.header)
        end
        -- Re-populate active tab via event
        HardcorePlus:SendMessage("HCP_TAB_SELECTED", activeTab or "overview")
    end
end

-- Get content frame for a tab (modules use this to populate)
function MainPanel:GetContentFrame(tabId)
    return contentFrames[tabId]
end

-- ═══════════════════════════════════════════
--  Message Handlers
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_TOGGLE_PANEL", function()
    MainPanel:Toggle()
end)

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    MainPanel:Create()
end)
