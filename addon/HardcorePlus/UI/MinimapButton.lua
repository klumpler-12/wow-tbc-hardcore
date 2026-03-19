--[[
    HardcorePlus — Minimap Button
    LibDBIcon integration. Left-click = toggle panel, right-click = settings.
    Tooltip shows status summary.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Create the data broker object
local dataBroker = LDB:NewDataObject("HardcorePlus", {
    type = "launcher",
    icon = "Interface\\Icons\\Spell_Shadow_SoulGem",  -- Skull icon, fits HC theme
    label = "HardcorePlus",

    OnClick = function(_, button)
        if button == "LeftButton" then
            HardcorePlus:SendMessage("HCP_TOGGLE_PANEL")
        elseif button == "RightButton" then
            HardcorePlus:SendMessage("HCP_SHOW_SETTINGS")
        end
    end,

    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end

        local c = HCP.CC
        local data = HCP.db and HCP.db.char or {}
        local statusColor = HCP.StatusColors[data.status] or c.DIM
        local statusLabel = HCP.StatusLabels[data.status] or (data.status or "Unknown")

        tooltip:AddLine(c.GOLD .. "HardcorePlus" .. c.CLOSE)
        tooltip:AddLine(" ")

        -- Status line
        tooltip:AddDoubleLine("Status:", statusColor .. statusLabel .. c.CLOSE, 1, 1, 1, 1, 1, 1)

        -- Level
        tooltip:AddDoubleLine("Level:", c.WHITE .. HCP.Utils.GetLevel() .. c.CLOSE, 1, 1, 1, 1, 1, 1)

        -- Deaths
        tooltip:AddDoubleLine("Deaths:", c.RED .. (data.openWorldDeaths or 0) .. c.CLOSE .. " OW / " ..
            c.BLUE .. (data.instanceDeaths or 0) .. c.CLOSE .. " Inst", 1, 1, 1, 1, 1, 1)

        -- Soul of Iron
        if data.soulOfIron then
            tooltip:AddDoubleLine("Soul of Iron:", c.GREEN .. "Active" .. c.CLOSE, 1, 1, 1, 1, 1, 1)
        end

        -- Title
        if data.title then
            tooltip:AddDoubleLine("Title:", c.GOLD .. data.title .. c.CLOSE, 1, 1, 1, 1, 1, 1)
        end

        -- Flags
        local flagCount = data.suspiciousFlags and #data.suspiciousFlags or 0
        if flagCount > 0 then
            tooltip:AddDoubleLine("Flags:", c.RED .. flagCount .. c.CLOSE, 1, 1, 1, 1, 1, 1)
        end

        tooltip:AddLine(" ")
        tooltip:AddLine(c.DIM .. "Left-click: Toggle panel" .. c.CLOSE)
        tooltip:AddLine(c.DIM .. "Right-click: Settings" .. c.CLOSE)
    end,
})

-- Register the minimap icon when addon initializes
function HardcorePlus:SetupMinimapButton()
    if not self.db.global.minimap then
        self.db.global.minimap = { hide = false }
    end
    LDBIcon:Register("HardcorePlus", dataBroker, self.db.global.minimap)
end

-- Hook into addon ready
HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    HardcorePlus:SetupMinimapButton()
end)
