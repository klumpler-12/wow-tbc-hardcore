--[[
    HardcorePlus — Death Monitor Widget (Phase 2)
    Small, moveable, semi-transparent frame showing:
    - Current status (color-coded)
    - Death count
    - Current zone + instance indicator
    - Addon active indicator (green dot)
    Togglable via /hcp monitor or minimap right-click.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local DeathMonitor = {}
HCP.DeathMonitor = DeathMonitor

local monitorFrame = nil
local MONITOR_WIDTH = 180
local MONITOR_HEIGHT = 72

-- ═══════════════════════════════════════════
--  Create Monitor Frame
-- ═══════════════════════════════════════════

local function CreateMonitor()
    if monitorFrame then return monitorFrame end

    local col = HCP.Colors

    local f = HCP.Compat.CreateBackdropFrame("Frame", "HCPDeathMonitor", UIParent)
    f:SetSize(MONITOR_WIDTH, MONITOR_HEIGHT)
    f:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -20)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(5)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    f:SetBackdropColor(col.BG_DARK.r, col.BG_DARK.g, col.BG_DARK.b, 0.85)
    f:SetBackdropBorderColor(col.BORDER.r, col.BORDER.g, col.BORDER.b, 0.6)

    -- Active indicator (small colored dot, top-left)
    local dot = f:CreateTexture(nil, "OVERLAY")
    dot:SetSize(8, 8)
    dot:SetPoint("TOPLEFT", f, "TOPLEFT", 6, -6)
    dot:SetTexture("Interface\\Buttons\\WHITE8x8")
    dot:SetVertexColor(col.GREEN.r, col.GREEN.g, col.GREEN.b, 1)
    f.dot = dot

    -- Status text (top line, right of dot)
    local statusText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("TOPLEFT", dot, "TOPRIGHT", 4, 1)
    statusText:SetPoint("RIGHT", f, "RIGHT", -6, 0)
    statusText:SetJustifyH("LEFT")
    statusText:SetText(HCP.CC.GREEN .. "ALIVE" .. HCP.CC.CLOSE)
    f.statusText = statusText

    -- Death count (middle line)
    local deathText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    deathText:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -22)
    deathText:SetPoint("RIGHT", f, "RIGHT", -6, 0)
    deathText:SetJustifyH("LEFT")
    deathText:SetText(HCP.CC.DIM .. "Deaths: " .. HCP.CC.WHITE .. "0" .. HCP.CC.CLOSE)
    f.deathText = deathText

    -- Zone text (bottom line)
    local zoneText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zoneText:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -38)
    zoneText:SetPoint("RIGHT", f, "RIGHT", -6, 0)
    zoneText:SetJustifyH("LEFT")
    zoneText:SetText(HCP.CC.DIM .. "Zone: ..." .. HCP.CC.CLOSE)
    f.zoneText = zoneText

    -- Flags indicator (bottom-right, small)
    local flagText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    flagText:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 4)
    flagText:SetJustifyH("RIGHT")
    flagText:SetText("")
    f.flagText = flagText

    -- Right-click to minimize, shift-click to hide
    f:SetScript("OnMouseUp", function(self, btn)
        if btn == "RightButton" then
            DeathMonitor:ToggleMinimized()
        end
    end)

    -- Tooltip
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("HardcorePlus Monitor", 0.91, 0.65, 0.14)
        GameTooltip:AddLine("Drag to move | Right-click to minimize", 0.54, 0.53, 0.50)
        GameTooltip:AddLine("/hcp monitor to toggle", 0.54, 0.53, 0.50)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    monitorFrame = f
    return f
end

-- ═══════════════════════════════════════════
--  Update Monitor Display
-- ═══════════════════════════════════════════

function DeathMonitor:Update()
    if not monitorFrame or not monitorFrame:IsShown() then return end
    if not HCP.db or not HCP.db.char then return end

    local data = HCP.db.char
    local c = HCP.CC
    local col = HCP.Colors

    -- Status
    local statusColor = HCP.StatusColors[data.status] or c.DIM
    local statusLabel = HCP.StatusLabels[data.status] or data.status
    monitorFrame.statusText:SetText(statusColor .. statusLabel .. c.CLOSE)

    -- Dot color: green = tracking OK, red = dead, gold = flagged
    if data.status == HCP.Status.DEAD then
        monitorFrame.dot:SetVertexColor(col.RED.r, col.RED.g, col.RED.b, 1)
    elseif #data.suspiciousFlags > 0 then
        monitorFrame.dot:SetVertexColor(col.ACCENT.r, col.ACCENT.g, col.ACCENT.b, 1)
    else
        monitorFrame.dot:SetVertexColor(col.GREEN.r, col.GREEN.g, col.GREEN.b, 1)
    end

    -- Deaths
    local owDeaths = data.openWorldDeaths or 0
    local instDeaths = data.instanceDeaths or 0
    local deathStr = c.DIM .. "Deaths: " .. c.RED .. owDeaths .. c.CLOSE
    if instDeaths > 0 then
        deathStr = deathStr .. c.DIM .. " | " .. c.BLUE .. instDeaths .. " inst" .. c.CLOSE
    end
    monitorFrame.deathText:SetText(deathStr)

    -- Zone
    local zoneInfo = HCP.Utils.GetZoneInfo()
    local inInstance, instanceType = HCP.Utils.IsInInstance()
    local zoneStr = c.DIM .. "Zone: " .. c.CLOSE
    if inInstance then
        zoneStr = zoneStr .. c.BLUE .. zoneInfo.zone .. c.CLOSE
    else
        zoneStr = zoneStr .. c.TEXT .. zoneInfo.zone .. c.CLOSE
    end
    monitorFrame.zoneText:SetText(zoneStr)

    -- Flags count
    local flagCount = #data.suspiciousFlags
    if flagCount > 0 then
        monitorFrame.flagText:SetText(c.RED .. flagCount .. " flag" ..
            (flagCount > 1 and "s" or "") .. c.CLOSE)
    else
        monitorFrame.flagText:SetText("")
    end
end

-- ═══════════════════════════════════════════
--  Minimize / Toggle
-- ═══════════════════════════════════════════

local minimized = false

function DeathMonitor:ToggleMinimized()
    if not monitorFrame then return end
    minimized = not minimized

    if minimized then
        monitorFrame:SetSize(MONITOR_WIDTH, 18)
        monitorFrame.deathText:Hide()
        monitorFrame.zoneText:Hide()
        monitorFrame.flagText:Hide()
    else
        monitorFrame:SetSize(MONITOR_WIDTH, MONITOR_HEIGHT)
        monitorFrame.deathText:Show()
        monitorFrame.zoneText:Show()
        monitorFrame.flagText:Show()
    end
end

function DeathMonitor:Toggle()
    if not monitorFrame then
        CreateMonitor()
    end
    if monitorFrame:IsShown() then
        monitorFrame:Hide()
    else
        monitorFrame:Show()
        self:Update()
    end
end

function DeathMonitor:Show()
    if not monitorFrame then CreateMonitor() end
    monitorFrame:Show()
    self:Update()
end

function DeathMonitor:Hide()
    if monitorFrame then monitorFrame:Hide() end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Auto-show if registered
    if HCP.db.char.registered then
        CreateMonitor()
        monitorFrame:Show()
        DeathMonitor:Update()
    end

    -- Periodic zone/status update
    HardcorePlus:ScheduleRepeatingTimer(function()
        DeathMonitor:Update()
    end, 5)

    -- Update on death
    HardcorePlus:RegisterMessage("HCP_PLAYER_DEATH", function()
        DeathMonitor:Update()
    end)

    -- Update on status change
    HardcorePlus:RegisterMessage("HCP_STATUS_CHANGED", function()
        DeathMonitor:Update()
    end)

    -- Update on violation
    HardcorePlus:RegisterMessage("HCP_VIOLATION", function()
        DeathMonitor:Update()
    end)

    -- Toggle via slash or message
    HardcorePlus:RegisterMessage("HCP_TOGGLE_MONITOR", function()
        DeathMonitor:Toggle()
    end)

    -- Show after registration
    HardcorePlus:RegisterMessage("HCP_REGISTERED", function()
        DeathMonitor:Show()
    end)
end)
