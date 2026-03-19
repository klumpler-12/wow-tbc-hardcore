--[[
    HardcorePlus — Debug / Tester Panel (Alpha)
    Toggle individual systems on/off for isolated testing.
    Accessible via /hcp debug. Always available in alpha builds.

    Each toggle controls whether a system processes its events.
    Disabled systems still load but skip their logic, so you can
    test other systems in isolation.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local DebugPanel = {}
HCP.DebugPanel = DebugPanel

local BACKDROP_PANEL = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local frame = nil

local function ApplyColors(f, bgColor, borderColor)
    local bg = bgColor or HCP.Colors.BG_DARK
    local border = borderColor or HCP.Colors.BORDER
    f:SetBackdropColor(bg.r, bg.g, bg.b, bg.a or 0.95)
    f:SetBackdropBorderColor(border.r, border.g, border.b, 1)
end

-- System toggle definitions: { key, label, phase }
local SYSTEM_TOGGLES = {
    -- Core systems
    { key = "deathTracking",      label = "Death Tracking",       phase = "Core" },
    { key = "uptimeTracking",     label = "Uptime / Gap Detect",  phase = "Core" },
    { key = "soiTracking",        label = "Soul of Iron Scan",    phase = "Core" },
    { key = "verification",       label = "Status Verification",  phase = "Core" },
    { key = "network",            label = "Network / Peers",      phase = "Net" },
    { key = "instanceLives",      label = "Instance Lives",       phase = "Core" },
    { key = "checkpoint",         label = "Checkpoint System",    phase = "Core" },
    { key = "softReset",          label = "Soft Reset",           phase = "Core" },
    -- Tracker plugins
    { key = "goldTracking",       label = "Gold Tracking",        phase = "Trk" },
    { key = "killTracking",       label = "Kill Tracking",        phase = "Trk" },
    { key = "tradeTracking",      label = "Trade Logging",        phase = "Trk" },
    { key = "mailTracking",       label = "Mail Logging",         phase = "Trk" },
    { key = "ahTracking",         label = "Auction House",        phase = "Trk" },
    { key = "distanceTracking",   label = "Zone Traversal",       phase = "Trk" },
    { key = "professionTracking", label = "Profession Tracking",  phase = "Trk" },
    { key = "equipmentTracking",  label = "Equipment Changes",    phase = "Trk" },
    { key = "lootTracking",       label = "Loot Logging",         phase = "Trk" },
}

-- ═══════════════════════════════════════════
--  Panel Creation
-- ═══════════════════════════════════════════

function DebugPanel:Show()
    if frame then
        frame:Show()
        self:Refresh()
        return
    end

    local c = HCP.CC

    frame = HCP.Compat.CreateBackdropFrame("Frame", "HCPDebugPanel", UIParent)
    frame:SetSize(340, 520)
    frame:SetPoint("CENTER", 300, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)

    frame:SetBackdrop(BACKDROP_PANEL)
    ApplyColors(frame, HCP.Colors.BG_DARK, { r = 1, g = 0.4, b = 0.1 }) -- orange border = debug

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(c.GOLD .. "⚙ Tester Mode" .. c.CLOSE .. c.DIM .. " (Alpha)" .. c.CLOSE)

    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 12, -38)
    content:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.content = content

    tinsert(UISpecialFrames, "HCPDebugPanel")

    self:Refresh()
    frame:Show()
end

function DebugPanel:Hide()
    if frame then frame:Hide() end
end

-- ═══════════════════════════════════════════
--  Refresh Content
-- ═══════════════════════════════════════════

function DebugPanel:Refresh()
    if not frame or not frame.content then return end

    local content = frame.content
    -- Clear previous content
    local regions = { content:GetRegions() }
    for _, r in ipairs(regions) do
        if r.SetText then r:SetText("") end
        r:Hide()
    end
    local children = { content:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end

    local c = HCP.CC
    local debug = HCP.db.global.debug
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

    local function ToggleButton(key, label, phase)
        local isOn = debug[key] ~= false
        local btn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
        btn:SetSize(310, 24)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
        btn:SetBackdrop(BACKDROP_PANEL)

        local statusColor = isOn and HCP.Colors.BG_CARD or { r = 0.15, g = 0.05, b = 0.05, a = 0.95 }
        local borderColor = isOn and HCP.Colors.BORDER or { r = 0.4, g = 0.1, b = 0.1 }
        ApplyColors(btn, statusColor, borderColor)

        local icon = isOn and (c.GREEN .. "ON ") or (c.RED .. "OFF")
        local btnLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btnLabel:SetPoint("LEFT", 8, 0)
        btnLabel:SetText(icon .. c.CLOSE .. "  " .. c.DIM .. "[" .. phase .. "]" .. c.CLOSE .. " " .. label)

        btn:SetScript("OnClick", function()
            debug[key] = not isOn
            local state = debug[key] and "ON" or "OFF"
            local stateColor = debug[key] and c.GREEN or c.RED
            HardcorePlus:Print(c.GOLD .. "Debug:" .. c.CLOSE .. " " ..
                label .. " → " .. stateColor .. state .. c.CLOSE)
            HardcorePlus:SendMessage("HCP_DEBUG_TOGGLE", key, debug[key])
            DebugPanel:Refresh()
        end)
        btn:SetScript("OnEnter", function(self)
            ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.ACCENT_DIM)
        end)
        btn:SetScript("OnLeave", function(self)
            ApplyColors(self, statusColor, borderColor)
        end)

        yOff = yOff - 28
    end

    Line(c.DIM .. "Toggle systems on/off to test in isolation." .. c.CLOSE)
    Line(c.DIM .. "Disabled systems skip their logic but stay loaded." .. c.CLOSE)
    yOff = yOff - 4

    -- Verbose logging toggle
    local verboseOn = debug.verbose
    local verbBtn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
    verbBtn:SetSize(310, 24)
    verbBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
    verbBtn:SetBackdrop(BACKDROP_PANEL)
    local verbBg = verboseOn and HCP.Colors.BG_CARD or { r = 0.05, g = 0.05, b = 0.15, a = 0.95 }
    ApplyColors(verbBtn, verbBg, HCP.Colors.ACCENT_DIM)

    local verbIcon = verboseOn and (c.NEON .. "ON ") or (c.DIM .. "OFF")
    local verbLabel = verbBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    verbLabel:SetPoint("LEFT", 8, 0)
    verbLabel:SetText(verbIcon .. c.CLOSE .. "  " .. c.GOLD .. "Verbose Logging" .. c.CLOSE ..
        c.DIM .. " (prints debug messages to chat)" .. c.CLOSE)

    verbBtn:SetScript("OnClick", function()
        debug.verbose = not debug.verbose
        local state = debug.verbose and "ON" or "OFF"
        HardcorePlus:Print(c.GOLD .. "Debug:" .. c.CLOSE .. " Verbose logging → " ..
            (debug.verbose and c.NEON or c.DIM) .. state .. c.CLOSE)
        DebugPanel:Refresh()
    end)
    verbBtn:SetScript("OnEnter", function(self) ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.ACCENT_DIM) end)
    verbBtn:SetScript("OnLeave", function(self) ApplyColors(self, verbBg, HCP.Colors.ACCENT_DIM) end)
    yOff = yOff - 32

    Line(c.GOLD .. "System Toggles:" .. c.CLOSE)
    yOff = yOff - 4

    for _, toggle in ipairs(SYSTEM_TOGGLES) do
        ToggleButton(toggle.key, toggle.label, toggle.phase)
    end

    yOff = yOff - 8

    -- Quick actions
    Line(c.GOLD .. "Quick Actions:" .. c.CLOSE)
    yOff = yOff - 4

    -- All ON button
    local allOnBtn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
    allOnBtn:SetSize(148, 24)
    allOnBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
    allOnBtn:SetBackdrop(BACKDROP_PANEL)
    ApplyColors(allOnBtn, HCP.Colors.BG_CARD, HCP.Colors.BORDER)
    local allOnLabel = allOnBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    allOnLabel:SetPoint("CENTER")
    allOnLabel:SetText(c.GREEN .. "Enable All" .. c.CLOSE)
    allOnBtn:SetScript("OnClick", function()
        for _, toggle in ipairs(SYSTEM_TOGGLES) do debug[toggle.key] = true end
        HardcorePlus:Print(c.GOLD .. "Debug:" .. c.CLOSE .. c.GREEN .. " All systems enabled." .. c.CLOSE)
        DebugPanel:Refresh()
    end)
    allOnBtn:SetScript("OnEnter", function(self) ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.BORDER) end)
    allOnBtn:SetScript("OnLeave", function(self) ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.BORDER) end)

    -- All OFF button
    local allOffBtn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
    allOffBtn:SetSize(148, 24)
    allOffBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 160, yOff)
    allOffBtn:SetBackdrop(BACKDROP_PANEL)
    ApplyColors(allOffBtn, HCP.Colors.BG_CARD, HCP.Colors.BORDER)
    local allOffLabel = allOffBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    allOffLabel:SetPoint("CENTER")
    allOffLabel:SetText(c.RED .. "Disable All" .. c.CLOSE)
    allOffBtn:SetScript("OnClick", function()
        for _, toggle in ipairs(SYSTEM_TOGGLES) do debug[toggle.key] = false end
        HardcorePlus:Print(c.GOLD .. "Debug:" .. c.CLOSE .. c.RED .. " All systems disabled." .. c.CLOSE)
        DebugPanel:Refresh()
    end)
    allOffBtn:SetScript("OnEnter", function(self) ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.BORDER) end)
    allOffBtn:SetScript("OnLeave", function(self) ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.BORDER) end)

    yOff = yOff - 32

    -- ═══ Network Rate Monitor ═══
    Line(c.GOLD .. "Network Stats:" .. c.CLOSE)
    yOff = yOff - 4

    if HCP.Protocol and HCP.Protocol.Stats then
        local rates = HCP.Protocol:GetRates()
        Line(c.DIM .. "Sent: " .. c.CLOSE .. c.WHITE ..
            rates.totalSent .. c.CLOSE .. c.DIM .. " msgs (" ..
            string.format("%.1f", rates.sentPerMin) .. "/min, " ..
            string.format("%.0f", rates.bytesSentPerMin) .. " B/min)" .. c.CLOSE)
        Line(c.DIM .. "Recv: " .. c.CLOSE .. c.WHITE ..
            rates.totalRecv .. c.CLOSE .. c.DIM .. " msgs (" ..
            string.format("%.1f", rates.recvPerMin) .. "/min, " ..
            string.format("%.0f", rates.bytesRecvPerMin) .. " B/min)" .. c.CLOSE)

        -- Per-type breakdown
        local hasTypes = false
        for msgType, count in pairs(rates.sentByType) do
            if not hasTypes then
                Line(c.DIM .. "  By type (sent):" .. c.CLOSE)
                hasTypes = true
            end
            Line(c.DIM .. "    " .. msgType .. ": " .. c.CLOSE .. count)
        end

        -- Online peers
        local peerCount = HCP.Heartbeat and HCP.Heartbeat:GetOnlinePeerCount() or 0
        Line(c.DIM .. "Online peers: " .. c.CLOSE ..
            (peerCount > 0 and (c.GREEN .. peerCount) or (c.RED .. "0")) .. c.CLOSE)

        -- Active offline pings
        if HCP.Heartbeat then
            local pings = HCP.Heartbeat:GetActivePings()
            local pingCount = 0
            for _ in pairs(pings) do pingCount = pingCount + 1 end
            if pingCount > 0 then
                Line(c.GOLD .. "Active offline pings: " .. pingCount .. c.CLOSE)
                for key, ping in pairs(pings) do
                    Line(c.DIM .. "  " .. key .. ": attempt " ..
                        ping.attempts .. "/" .. ping.maxAttempts ..
                        " (next: " .. math.max(0, ping.nextPing - HCP.Utils.GetTimestamp()) .. "s)" .. c.CLOSE)
                end
            end
        end

        -- Reset stats button
        yOff = yOff - 4
        local resetBtn = HCP.Compat.CreateBackdropFrame("Button", nil, content)
        resetBtn:SetSize(148, 22)
        resetBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
        resetBtn:SetBackdrop(BACKDROP_PANEL)
        ApplyColors(resetBtn, HCP.Colors.BG_CARD, HCP.Colors.BORDER)
        local resetLabel = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        resetLabel:SetPoint("CENTER")
        resetLabel:SetText(c.DIM .. "Reset Stats" .. c.CLOSE)
        resetBtn:SetScript("OnClick", function()
            HCP.Protocol:ResetStats()
            HardcorePlus:Print(c.GOLD .. "Debug:" .. c.CLOSE .. " Network stats reset.")
            DebugPanel:Refresh()
        end)
        resetBtn:SetScript("OnEnter", function(self) ApplyColors(self, HCP.Colors.BG_CARD_HOVER, HCP.Colors.BORDER) end)
        resetBtn:SetScript("OnLeave", function(self) ApplyColors(self, HCP.Colors.BG_CARD, HCP.Colors.BORDER) end)
    else
        Line(c.DIM .. "Network not initialized yet." .. c.CLOSE)
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_SHOW_DEBUG", function()
    DebugPanel:Show()
end)
