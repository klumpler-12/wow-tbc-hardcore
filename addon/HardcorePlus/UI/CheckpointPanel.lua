--[[
    HardcorePlus — Checkpoint Panel (Phase 6)
    Shows checkpoint status and claim button in the main panel.
    Accessed via /hcp checkpoint or a section in the Overview tab.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local CheckpointPanel = {}
HCP.CheckpointPanel = CheckpointPanel

local BACKDROP_BTN = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

-- ═══════════════════════════════════════════
--  Checkpoint Dialog
-- ═══════════════════════════════════════════

local dialogFrame = nil

local function ApplyColors(f, bgColor, borderColor)
    local bg = bgColor or HCP.Colors.BG_DARK
    local border = borderColor or HCP.Colors.BORDER
    f:SetBackdropColor(bg.r, bg.g, bg.b, bg.a or 0.95)
    f:SetBackdropBorderColor(border.r, border.g, border.b, 1)
end

function CheckpointPanel:ShowCheckpointDialog()
    if dialogFrame then
        dialogFrame:Show()
        self:RefreshDialog()
        return
    end

    local c = HCP.CC
    local data = HCP.db.char

    dialogFrame = HCP.Compat.CreateBackdropFrame("Frame", "HCPCheckpointDialog", UIParent)
    dialogFrame:SetSize(400, 300)
    dialogFrame:SetPoint("CENTER")
    dialogFrame:SetMovable(true)
    dialogFrame:EnableMouse(true)
    dialogFrame:RegisterForDrag("LeftButton")
    dialogFrame:SetScript("OnDragStart", dialogFrame.StartMoving)
    dialogFrame:SetScript("OnDragStop", dialogFrame.StopMovingOrSizing)
    dialogFrame:SetFrameStrata("DIALOG")
    dialogFrame:SetClampedToScreen(true)

    dialogFrame:SetBackdrop(BACKDROP_BTN)
    ApplyColors(dialogFrame, HCP.Colors.BG_DARK, HCP.Colors.ACCENT_DIM)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, dialogFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() dialogFrame:Hide() end)

    -- Title
    local title = dialogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(c.GOLD .. "Checkpoint System" .. c.CLOSE)

    -- Content area
    local content = CreateFrame("Frame", nil, dialogFrame)
    content:SetPoint("TOPLEFT", 12, -40)
    content:SetPoint("BOTTOMRIGHT", -12, 12)
    dialogFrame.content = content

    tinsert(UISpecialFrames, "HCPCheckpointDialog")

    self:RefreshDialog()
    dialogFrame:Show()
end

function CheckpointPanel:RefreshDialog()
    if not dialogFrame or not dialogFrame.content then return end

    local content = dialogFrame.content
    -- Clear
    local regions = { content:GetRegions() }
    for _, r in ipairs(regions) do
        if r.SetText then r:SetText("") end
        r:Hide()
    end
    local children = { content:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end

    local c = HCP.CC
    local data = HCP.db.char
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

    -- Current character status
    if data.registered then
        Line(c.DIM .. "Character: " .. c.CLOSE ..
            c.WHITE .. HCP.Utils.GetPlayerKey() .. c.CLOSE ..
            c.DIM .. " (Level " .. HCP.Utils.GetLevel() .. ")" .. c.CLOSE)

        local statusColor = HCP.StatusColors[data.status] or c.DIM
        local statusLabel = HCP.StatusLabels[data.status] or data.status
        Line(c.DIM .. "Status: " .. c.CLOSE .. statusColor .. statusLabel .. c.CLOSE)

        if data.checkpoint.sourceChar then
            Line(c.DIM .. "Checkpoint from: " .. c.CLOSE ..
                c.GOLD .. data.checkpoint.sourceChar .. c.CLOSE)
        end

        yOff = yOff - 8

        if data.checkpointEnabled then
            if data.checkpoint.unlocked then
                Line(c.GREEN .. "✓ Checkpoint unlocked (Level 58+)" .. c.CLOSE)
            else
                Line(c.DIM .. "Checkpoint unlocks at Level 58." .. c.CLOSE)
                Line(c.DIM .. "Current level: " .. HCP.Utils.GetLevel() .. c.CLOSE)
            end
        else
            Line(c.DIM .. "Checkpoints disabled for this character." .. c.CLOSE)
        end

        -- If dead, show token info
        if data.status == HCP.Status.DEAD then
            yOff = yOff - 8
            local status = HCP.Checkpoint:GetStatus()
            if status.tokenAvailable then
                Line(c.GOLD .. "Token available!" .. c.CLOSE)
                Line(c.DIM .. "Claim on a new Level 58+ character with:" .. c.CLOSE)
                Line(c.NEON .. "/hcp checkpoint claim" .. c.CLOSE)
                if status.tokenExpires then
                    local remaining = status.tokenExpires - HCP.Utils.GetTimestamp()
                    Line(c.DIM .. "Expires in: " ..
                        HCP.Utils.FormatTime(math.max(0, remaining)) .. c.CLOSE)
                end
            else
                Line(c.DIM .. "No checkpoint token (level < 58 or checkpoints disabled)." .. c.CLOSE)
            end
        end
    else
        -- Unregistered character — check for claimable tokens
        Line(c.DIM .. "Character not registered for HC." .. c.CLOSE)
        yOff = yOff - 8

        local token = HCP.Checkpoint:FindValidToken()
        if token then
            Line(c.GOLD .. "Checkpoint token available!" .. c.CLOSE)
            Line(c.DIM .. "From: " .. token.sourceChar ..
                " (Level " .. token.sourceLevel .. " " .. token.sourceClass .. ")" .. c.CLOSE)
            if token.expiresAt then
                local remaining = token.expiresAt - HCP.Utils.GetTimestamp()
                Line(c.DIM .. "Expires in: " ..
                    HCP.Utils.FormatTime(math.max(0, remaining)) .. c.CLOSE)
            end
            yOff = yOff - 8

            local level = HCP.Utils.GetLevel()
            if level >= 58 then
                -- Claim button
                local claimBtn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
                claimBtn:SetSize(220, 32)
                claimBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
                claimBtn:SetBackdrop(BACKDROP_BTN)
                ApplyColors(claimBtn, HCP.Colors.BG_CARD, HCP.Colors.ACCENT_GLOW)

                local label = claimBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                label:SetPoint("CENTER")
                label:SetText(c.GOLD .. "Claim Checkpoint" .. c.CLOSE)

                claimBtn:SetScript("OnClick", function()
                    HCP.Checkpoint:ClaimToken()
                    dialogFrame:Hide()
                end)
                claimBtn:SetScript("OnEnter", function(self)
                    ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.ACCENT_GLOW)
                end)
                claimBtn:SetScript("OnLeave", function(self)
                    ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.ACCENT_GLOW)
                end)
            else
                Line(c.RED .. "Must be Level 58+ to claim. Current: " .. level .. c.CLOSE)
            end
        else
            Line(c.DIM .. "No checkpoint tokens available." .. c.CLOSE)
            Line(c.DIM .. "Tokens are generated when a Level 58+ HC character dies." .. c.CLOSE)
        end
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_SHOW_CHECKPOINT", function()
    CheckpointPanel:ShowCheckpointDialog()
end)
