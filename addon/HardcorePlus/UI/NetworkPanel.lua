--[[
    HardcorePlus — Network Panel (Phase 4)
    Populates the "Network" tab in MainPanel with peer list and status.
    Shows online peers, their HC status, and network health.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local NetworkPanel = {}
HCP.NetworkPanel = NetworkPanel

-- ═══════════════════════════════════════════
--  Populate Network Tab
-- ═══════════════════════════════════════════

function NetworkPanel:PopulateNetworkTab(contentFrame)
    -- Clear existing
    local children = { contentFrame:GetChildren() }
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
    local regions = { contentFrame:GetRegions() }
    for _, region in ipairs(regions) do
        if region.SetText then region:SetText("") end
    end
    if contentFrame.placeholder then contentFrame.placeholder:Hide() end

    local c = HCP.CC
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

    -- Header
    Line(c.GOLD .. "Peer Network" .. c.CLOSE)
    yOff = yOff - 4

    -- Check if we're in a guild
    if not IsInGuild() then
        Line(c.DIM .. "Not in a guild. Network requires guild membership." .. c.CLOSE)
        Line(c.DIM .. "Join a guild to connect with other HC players." .. c.CLOSE)
        return
    end

    if not HCP.Heartbeat then
        Line(c.DIM .. "Network module not loaded." .. c.CLOSE)
        return
    end

    -- ═══ Network Status ═══
    local onlineCount = HCP.Heartbeat:GetOnlinePeerCount()
    local registryCount = 0
    local registry = HCP.Heartbeat:GetPeerRegistry()
    for _ in pairs(registry) do registryCount = registryCount + 1 end

    Line(c.DIM .. "Online peers: " .. c.CLOSE ..
        (onlineCount > 0 and (c.GREEN .. onlineCount .. c.CLOSE) or (c.RED .. "0" .. c.CLOSE)))
    Line(c.DIM .. "Known peers: " .. c.CLOSE .. c.WHITE .. registryCount .. c.CLOSE)
    Line(c.DIM .. "Heartbeat: " .. c.CLOSE ..
        c.GREEN .. "every " .. HCP.Net.HEARTBEAT_INTERVAL .. "s" .. c.CLOSE ..
        c.DIM .. " | Hash: every " .. HCP.Net.HASH_INTERVAL .. "s" .. c.CLOSE)

    Spacer()

    -- ═══ Online Peers ═══
    local onlinePeers = HCP.Heartbeat:GetOnlinePeers()

    if onlineCount == 0 then
        Line(c.DIM .. "No HC peers online. Waiting for heartbeats..." .. c.CLOSE)
    else
        Line(c.GOLD .. "Online Peers" .. c.CLOSE)
        yOff = yOff - 4

        -- Sort by name
        local sorted = {}
        for key, peer in pairs(onlinePeers) do
            table.insert(sorted, { key = key, peer = peer })
        end
        table.sort(sorted, function(a, b)
            return a.key < b.key
        end)

        for _, entry in ipairs(sorted) do
            local peer = entry.peer
            local statusColor = HCP.StatusColors[peer.status] or c.DIM
            local statusLabel = HCP.StatusLabels[peer.status] or (peer.status or "?")

            -- Player line
            local peerLine = c.WHITE .. entry.key .. c.CLOSE ..
                "  " .. statusColor .. statusLabel .. c.CLOSE
            if peer.title then
                peerLine = peerLine .. " " .. c.GOLD .. "[" .. peer.title .. "]" .. c.CLOSE
            end
            if peer.soi then
                peerLine = peerLine .. " " .. c.GREEN .. "SoI" .. c.CLOSE
            end
            Line(peerLine)

            -- Details line
            local detailParts = {}
            table.insert(detailParts, "Lvl " .. (peer.level or "?"))
            if peer.owDeaths > 0 then
                table.insert(detailParts, c.RED .. peer.owDeaths .. " OW death(s)" .. c.CLOSE)
            end
            if peer.flags > 0 then
                table.insert(detailParts, c.RED .. peer.flags .. " flag(s)" .. c.CLOSE)
            end

            local timeSince = HCP.Utils.GetTimestamp() - peer.lastHeartbeat
            table.insert(detailParts, c.DIM .. HCP.Utils.FormatTime(timeSince) .. " ago" .. c.CLOSE)

            Line("  " .. c.DIM .. table.concat(detailParts, " | ") .. c.CLOSE)
            yOff = yOff - 2
        end
    end

    Spacer()

    -- ═══ Known Peers (offline) ═══
    local offlinePeers = {}
    for key, reg in pairs(registry) do
        if not onlinePeers[key] and reg.registered then
            table.insert(offlinePeers, { key = key, reg = reg })
        end
    end

    if #offlinePeers > 0 then
        Line(c.DIM .. "Known Offline Peers" .. c.CLOSE)
        yOff = yOff - 4

        -- Sort by last seen (most recent first)
        table.sort(offlinePeers, function(a, b)
            return (a.reg.lastSeen or 0) > (b.reg.lastSeen or 0)
        end)

        -- Show at most 10
        for i = 1, math.min(#offlinePeers, 10) do
            local entry = offlinePeers[i]
            local reg = entry.reg
            local statusColor = HCP.StatusColors[reg.status] or c.DIM

            local lastSeenStr = reg.lastSeen and
                HCP.Utils.FormatDate(reg.lastSeen) or "Never"

            Line(c.DIM .. entry.key .. c.CLOSE ..
                "  " .. statusColor .. (HCP.StatusLabels[reg.status] or "?") .. c.CLOSE ..
                c.DIM .. " — Lvl " .. (reg.level or "?") ..
                " — Last: " .. lastSeenStr .. c.CLOSE)
        end

        if #offlinePeers > 10 then
            Line(c.DIM .. "  +" .. (#offlinePeers - 10) .. " more..." .. c.CLOSE)
        end
    end
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

-- Populate network tab when selected
HardcorePlus:RegisterMessage("HCP_TAB_SELECTED", function(_, tabId)
    if tabId == "network" and HCP.MainPanel then
        local cf = HCP.MainPanel:GetContentFrame("network")
        if cf then
            NetworkPanel:PopulateNetworkTab(cf)
        end
    end
end)

-- Refresh network tab when peers change (if tab is active)
local function RefreshNetworkIfActive()
    if HCP.MainPanel and HCP.MainPanel.activeTab == "network" then
        local cf = HCP.MainPanel:GetContentFrame("network")
        if cf then
            NetworkPanel:PopulateNetworkTab(cf)
        end
    end
end

HardcorePlus:RegisterMessage("HCP_PEER_UPDATED", function() RefreshNetworkIfActive() end)
HardcorePlus:RegisterMessage("HCP_PEER_OFFLINE", function() RefreshNetworkIfActive() end)
HardcorePlus:RegisterMessage("HCP_PEER_REGISTERED", function() RefreshNetworkIfActive() end)
