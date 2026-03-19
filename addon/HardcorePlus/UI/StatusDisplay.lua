--[[
    HardcorePlus — Status Display (Phase 3)
    Populates the Overview tab with verification status, SoI info,
    session info, and character summary. Updates dynamically.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local StatusDisplay = {}
HCP.StatusDisplay = StatusDisplay

-- ═══════════════════════════════════════════
--  Populate Overview Tab
-- ═══════════════════════════════════════════

function StatusDisplay:PopulateOverview(contentFrame)
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

    local function Spacer()
        yOff = yOff - 6
    end

    local function SectionHeader(text)
        Spacer()
        local fs = Line(c.GOLD .. text .. c.CLOSE)
        -- Gold underline
        local line = contentFrame:CreateTexture(nil, "ARTWORK")
        line:SetSize(contentFrame:GetWidth() - 16, 1)
        line:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, yOff + 2)
        line:SetTexture("Interface\\Buttons\\WHITE8x8")
        local col = HCP.Colors.ACCENT
        line:SetVertexColor(col.r, col.g, col.b, 0.4)
        yOff = yOff - 4
    end

    -- ═══ Character Info ═══
    if not data.registered then
        Line(c.DIM .. "Character not registered for HC mode." .. c.CLOSE)
        Line(c.DIM .. "Use the setup wizard or /hcp to get started." .. c.CLOSE)
        return
    end

    -- Status badge
    local statusColor = HCP.StatusColors[data.status] or c.DIM
    local statusLabel = HCP.StatusLabels[data.status] or data.status
    Line(c.DIM .. "Status: " .. c.CLOSE .. statusColor .. statusLabel .. c.CLOSE)

    -- Title
    if data.title then
        Line(c.DIM .. "Title: " .. c.CLOSE .. c.GOLD .. data.title .. c.CLOSE)
    end

    -- Character basics
    Line(c.DIM .. "Level: " .. c.CLOSE .. c.WHITE .. HCP.Utils.GetLevel() .. c.CLOSE ..
        c.DIM .. "  |  Class: " .. c.CLOSE .. c.WHITE .. (HCP.Utils.GetClass() or "?") .. c.CLOSE)

    -- Trade mode
    local tradeModeLabel = HCP.TradeModeLabels[data.tradeMode] or data.tradeMode
    Line(c.DIM .. "Trade Mode: " .. c.CLOSE .. c.WHITE .. tradeModeLabel .. c.CLOSE)

    -- ═══ Soul of Iron ═══
    SectionHeader("Soul of Iron")

    if HCP.VerificationTracker then
        local soiStatus = HCP.VerificationTracker:GetSoIStatus()
        local soiColor = c.DIM
        if data.soulOfIron then
            soiColor = c.GREEN
        elseif data.soulOfIronLost then
            soiColor = c.RED
        end
        Line(c.DIM .. "SoI Status: " .. c.CLOSE .. soiColor .. soiStatus .. c.CLOSE)

        if not HCP.VerificationTracker:IsSoIReliable() then
            Line(c.DIM .. "Note: SoI unreliable at Lvl 58+ (instance content)" .. c.CLOSE)
        end
    else
        Line(c.DIM .. "SoI: Not tracked" .. c.CLOSE)
    end

    -- ═══ Death Summary ═══
    SectionHeader("Deaths")

    Line(c.DIM .. "Open World: " .. c.CLOSE .. c.RED .. data.openWorldDeaths .. c.CLOSE ..
        c.DIM .. "  |  Instance: " .. c.CLOSE .. c.BLUE .. data.instanceDeaths .. c.CLOSE)

    if #data.deaths > 0 then
        local last = data.deaths[#data.deaths]
        Line(c.DIM .. "Last death: " .. c.CLOSE .. c.WHITE .. (last.killer or "?") .. c.CLOSE ..
            c.DIM .. " in " .. (last.zone or "?") ..
            " — " .. HCP.Utils.FormatDate(last.timestamp) .. c.CLOSE)
    else
        Line(c.GREEN .. "No deaths — stay alive!" .. c.CLOSE)
    end

    -- ═══ Instance Lives ═══
    SectionHeader("Instance Lives")

    if data.instanceLivesEnabled then
        local pool = data.weeklyPool
        local poolTotal = pool.max + pool.bonus
        local poolRemaining = math.max(0, poolTotal - pool.used)
        Line(c.DIM .. "Weekly Pool: " .. c.CLOSE ..
            c.BLUE .. poolRemaining .. "/" .. poolTotal .. c.CLOSE ..
            (pool.bonus > 0 and
                (c.GREEN .. " (+" .. pool.bonus .. " bonus)" .. c.CLOSE) or ""))
    else
        Line(c.DIM .. "Instance Lives: Disabled (Juggernaut mode)" .. c.CLOSE)
    end

    -- ═══ Integrity ═══
    SectionHeader("Integrity")

    local flagCount = #data.suspiciousFlags
    if flagCount == 0 then
        Line(c.GREEN .. "Clean record — no violations" .. c.CLOSE)
    else
        local majorCount = 0
        local minorCount = 0
        for _, flag in ipairs(data.suspiciousFlags) do
            if flag.severity == "major" or flag.severity == "high" then
                majorCount = majorCount + 1
            else
                minorCount = minorCount + 1
            end
        end
        Line(c.RED .. flagCount .. " violation" .. (flagCount > 1 and "s" or "") .. c.CLOSE ..
            c.DIM .. " (" .. majorCount .. " major, " .. minorCount .. " minor)" .. c.CLOSE)
    end

    Line(c.DIM .. "Minor violations this week: " ..
        data.minorViolations .. "/" .. HCP.Violations.MINOR_WEEKLY_MAX .. c.CLOSE)

    -- ═══ Session Info ═══
    SectionHeader("Session")

    if HCP.UptimeTracker then
        local info = HCP.UptimeTracker:GetSessionInfo()
        Line(c.DIM .. "Current session: " .. c.CLOSE ..
            c.WHITE .. HCP.Utils.FormatTime(info.currentUptime) .. c.CLOSE)
        Line(c.DIM .. "Total /played: " .. c.CLOSE ..
            c.WHITE .. HCP.Utils.FormatTime(info.totalPlayed) .. c.CLOSE)
        Line(c.DIM .. "Sessions tracked: " .. c.CLOSE ..
            c.WHITE .. info.sessionCount .. c.CLOSE)
    end

    -- ═══ Soft Reset ═══
    if data.softResets > 0 then
        SectionHeader("Soft Reset")
        Line(c.PURPLE .. "Soft Reset x" .. data.softResets .. c.CLOSE ..
            c.DIM .. " — permanent tag" .. c.CLOSE)
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

-- Populate overview when tab selected
HardcorePlus:RegisterMessage("HCP_TAB_SELECTED", function(_, tabId)
    if tabId == "overview" and HCP.MainPanel then
        local cf = HCP.MainPanel:GetContentFrame("overview")
        if cf then
            StatusDisplay:PopulateOverview(cf)
        end
    end
end)

-- Refresh overview on status changes
HardcorePlus:RegisterMessage("HCP_STATUS_CHANGED", function()
    if HCP.MainPanel and HCP.MainPanel.activeTab == "overview" then
        local cf = HCP.MainPanel:GetContentFrame("overview")
        if cf then
            StatusDisplay:PopulateOverview(cf)
        end
    end
end)
