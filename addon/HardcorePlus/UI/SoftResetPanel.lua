--[[
    HardcorePlus — Soft Reset Panel (Phase 7)
    Step-by-step wizard for soft reset with real-time verification scan.
    Accessed via /hcp reset.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local SoftResetPanel = {}
HCP.SoftResetPanel = SoftResetPanel

local BACKDROP_PANEL = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local frame = nil
local scanTimer = nil

local function ApplyColors(f, bgColor, borderColor)
    local bg = bgColor or HCP.Colors.BG_DARK
    local border = borderColor or HCP.Colors.BORDER
    f:SetBackdropColor(bg.r, bg.g, bg.b, bg.a or 0.95)
    f:SetBackdropBorderColor(border.r, border.g, border.b, 1)
end

-- ═══════════════════════════════════════════
--  Panel Creation
-- ═══════════════════════════════════════════

function SoftResetPanel:Show()
    if frame then
        frame:Show()
        self:Refresh()
        return
    end

    local c = HCP.CC

    frame = HCP.Compat.CreateBackdropFrame("Frame", "HCPSoftResetPanel", UIParent)
    frame:SetSize(440, 420)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)

    frame:SetBackdrop(BACKDROP_PANEL)
    ApplyColors(frame, HCP.Colors.BG_DARK, HCP.Colors.ACCENT_DIM)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
        if scanTimer then
            HardcorePlus:CancelTimer(scanTimer)
            scanTimer = nil
        end
    end)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(c.PURPLE .. "Soft Reset" .. c.CLOSE)

    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 12, -40)
    content:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.content = content

    tinsert(UISpecialFrames, "HCPSoftResetPanel")

    self:Refresh()
    frame:Show()
end

-- ═══════════════════════════════════════════
--  Refresh Content
-- ═══════════════════════════════════════════

function SoftResetPanel:Refresh()
    if not frame or not frame.content then return end

    local content = frame.content
    -- Clear
    local regions = { content:GetRegions() }
    for _, r in ipairs(regions) do
        if r.SetText then r:SetText("") end
        r:Hide()
    end
    local children = { content:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end

    local c = HCP.CC
    local yOff = 0

    local function Line(text)
        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
        fs:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        fs:SetWordWrap(true)
        fs:Show()
        yOff = yOff - 16
        return fs
    end

    local function CreateButton(text, width, onClick)
        local btn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
        btn:SetSize(width, 28)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
        btn:SetBackdrop(BACKDROP_PANEL)
        ApplyColors(btn, HCP.Colors.BG_CARD, HCP.Colors.BORDER)
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("CENTER")
        label:SetText(text)
        btn:SetScript("OnClick", onClick)
        btn:SetScript("OnEnter", function(self) ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.BORDER) end)
        btn:SetScript("OnLeave", function(self) ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.BORDER) end)
        yOff = yOff - 34
        return btn
    end

    local inProgress = HCP.SoftReset:IsInProgress()

    if not inProgress then
        -- ═══ Eligibility Check ═══
        Line(c.GOLD .. "Step 1: Eligibility" .. c.CLOSE)
        yOff = yOff - 4

        local eligible, eligChecks = HCP.SoftReset:CheckEligibility()
        for _, check in ipairs(eligChecks) do
            local icon = check.pass and (c.GREEN .. "✓" .. c.CLOSE) or (c.RED .. "✗" .. c.CLOSE)
            Line(icon .. " " .. c.DIM .. check.name .. ": " .. c.CLOSE .. check.detail)
        end

        yOff = yOff - 8

        if eligible then
            Line(c.GREEN .. "Eligible for soft reset." .. c.CLOSE)
            yOff = yOff - 4
            Line(c.DIM .. "This will:" .. c.CLOSE)
            Line(c.DIM .. "  • Start a 2-hour /played timer" .. c.CLOSE)
            Line(c.DIM .. "  • Require stripping ALL progress" .. c.CLOSE)
            Line(c.DIM .. "  • Permanently tag you as Soft Reset x" ..
                (HCP.db.char.softResets + 1) .. c.CLOSE)
            Line(c.DIM .. "  • Reputation stays (TBC limitation)" .. c.CLOSE)
            yOff = yOff - 8

            CreateButton(c.PURPLE .. "Begin Soft Reset" .. c.CLOSE, 200, function()
                HCP.SoftReset:Initiate()
                SoftResetPanel:Refresh()
                -- Start live scan timer
                SoftResetPanel:StartLiveScan()
            end)
        else
            Line(c.RED .. "Not eligible. Fix the above requirements." .. c.CLOSE)
        end
    else
        -- ═══ In Progress — Strip Verification ═══
        Line(c.PURPLE .. "Soft Reset In Progress" .. c.CLOSE)
        yOff = yOff - 4

        -- Timer
        local remaining, elapsed = HCP.SoftReset:GetWindowRemaining()
        if remaining then
            local timerColor = remaining > 1800 and c.GREEN or (remaining > 600 and c.GOLD or c.RED)
            Line(c.DIM .. "Time remaining: " .. c.CLOSE ..
                timerColor .. HCP.Utils.FormatTime(remaining) .. c.CLOSE ..
                c.DIM .. " (elapsed: " .. HCP.Utils.FormatTime(elapsed) .. ")" .. c.CLOSE)
        end

        yOff = yOff - 8
        Line(c.GOLD .. "Step 2: Strip All Progress" .. c.CLOSE)
        yOff = yOff - 4

        local allPass, stripChecks = HCP.SoftReset:RunStripVerification()
        for _, check in ipairs(stripChecks) do
            local icon = check.pass and (c.GREEN .. "✓" .. c.CLOSE) or (c.RED .. "✗" .. c.CLOSE)
            Line(icon .. " " .. c.DIM .. check.name .. ": " .. c.CLOSE .. check.detail)
        end

        yOff = yOff - 8

        if allPass then
            Line(c.GREEN .. "All requirements met!" .. c.CLOSE)
            yOff = yOff - 4
            CreateButton(c.GOLD .. "★ Confirm Soft Reset ★" .. c.CLOSE, 240, function()
                local success = HCP.SoftReset:Complete()
                if success then
                    if scanTimer then
                        HardcorePlus:CancelTimer(scanTimer)
                        scanTimer = nil
                    end
                    frame:Hide()
                else
                    SoftResetPanel:Refresh()
                end
            end)
        else
            Line(c.RED .. "Strip your character to proceed." .. c.CLOSE)
            Line(c.DIM .. "Destroy items, unequip gear, unlearn professions," .. c.CLOSE)
            Line(c.DIM .. "reset talents, abandon quests, spend/drop gold." .. c.CLOSE)
        end
    end
end

-- ═══════════════════════════════════════════
--  Live Scan (auto-refresh while panel open)
-- ═══════════════════════════════════════════

function SoftResetPanel:StartLiveScan()
    if scanTimer then
        HardcorePlus:CancelTimer(scanTimer)
    end
    scanTimer = HardcorePlus:ScheduleRepeatingTimer(function()
        if frame and frame:IsShown() and HCP.SoftReset:IsInProgress() then
            SoftResetPanel:Refresh()
        else
            HardcorePlus:CancelTimer(scanTimer)
            scanTimer = nil
        end
    end, 3)  -- refresh every 3 seconds
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_SHOW_SOFT_RESET", function()
    SoftResetPanel:Show()
end)
