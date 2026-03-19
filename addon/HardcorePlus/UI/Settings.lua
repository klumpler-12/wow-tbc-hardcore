--[[
    HardcorePlus — Settings
    AceConfig options panel. Shows current configuration (mostly read-only after registration).
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local function GetOptions()
    local c = HCP.CC
    local data = HCP.db and HCP.db.char or {}

    return {
        name = c.GOLD .. "HardcorePlus" .. c.CLOSE .. " Settings",
        type = "group",
        args = {
            -- Header
            headerDesc = {
                order = 1,
                type = "description",
                name = c.DIM .. "v" .. HCP.VERSION .. " — Hybrid Hardcore Mode" .. c.CLOSE .. "\n",
                fontSize = "medium",
            },

            -- Registration Status
            regGroup = {
                order = 10,
                type = "group",
                name = c.GOLD .. "Registration" .. c.CLOSE,
                inline = true,
                args = {
                    status = {
                        order = 1,
                        type = "description",
                        name = function()
                            if not data.registered then
                                return c.RED .. "Not registered. Open the main panel to register." .. c.CLOSE
                            end
                            local statusColor = HCP.StatusColors[data.status] or c.DIM
                            local statusLabel = HCP.StatusLabels[data.status] or data.status
                            return "Status: " .. statusColor .. statusLabel .. c.CLOSE ..
                                "\nRegistered: " .. HCP.Utils.FormatDate(data.registeredAt, "%Y-%m-%d %H:%M") ..
                                "\nTrade Mode: " .. (HCP.TradeModeLabels[data.tradeMode] or data.tradeMode) ..
                                (data.title and ("\nTitle: " .. c.GOLD .. data.title .. c.CLOSE) or "")
                        end,
                    },
                },
            },

            -- Rules (read-only after registration)
            rulesGroup = {
                order = 20,
                type = "group",
                name = c.GOLD .. "Rules (Locked)" .. c.CLOSE,
                inline = true,
                disabled = true,
                args = {
                    tradeMode = {
                        order = 1,
                        type = "description",
                        name = function()
                            return c.DIM .. "Trade Mode:" .. c.CLOSE .. " " ..
                                (HCP.TradeModeLabels[data.tradeMode] or data.tradeMode)
                        end,
                    },
                    instanceLives = {
                        order = 2,
                        type = "description",
                        name = function()
                            return c.DIM .. "Instance Lives:" .. c.CLOSE .. " " ..
                                (data.instanceLivesEnabled and (c.GREEN .. "Enabled" .. c.CLOSE) or (c.RED .. "Disabled" .. c.CLOSE))
                        end,
                    },
                    checkpoint = {
                        order = 3,
                        type = "description",
                        name = function()
                            return c.DIM .. "Checkpoint:" .. c.CLOSE .. " " ..
                                (data.checkpointEnabled and (c.GREEN .. "Enabled at 58" .. c.CLOSE) or (c.RED .. "Disabled" .. c.CLOSE))
                        end,
                    },
                    note = {
                        order = 10,
                        type = "description",
                        name = "\n" .. c.DIM .. "Rules are locked at registration and cannot be changed." .. c.CLOSE,
                    },
                },
            },

            -- Display Options (always changeable)
            displayGroup = {
                order = 30,
                type = "group",
                name = c.GOLD .. "Display" .. c.CLOSE,
                inline = true,
                args = {
                    minimapIcon = {
                        order = 1,
                        type = "toggle",
                        name = "Show Minimap Icon",
                        desc = "Show the HardcorePlus minimap button",
                        get = function()
                            return not (HCP.db.global.minimap and HCP.db.global.minimap.hide)
                        end,
                        set = function(_, val)
                            HCP.db.global.minimap.hide = not val
                            if val then
                                LibStub("LibDBIcon-1.0"):Show("HardcorePlus")
                            else
                                LibStub("LibDBIcon-1.0"):Hide("HardcorePlus")
                            end
                        end,
                    },
                },
            },

            -- Violation Info (read-only)
            violationGroup = {
                order = 40,
                type = "group",
                name = c.GOLD .. "Violation Tracking" .. c.CLOSE,
                inline = true,
                args = {
                    info = {
                        order = 1,
                        type = "description",
                        name = function()
                            local flagCount = data.suspiciousFlags and #data.suspiciousFlags or 0
                            local minorV = data.minorViolations or 0
                            return c.DIM .. "Grace Period:" .. c.CLOSE .. " " .. HCP.Violations.GRACE_MINUTES .. " minutes\n" ..
                                c.DIM .. "Minor Violations (this week):" .. c.CLOSE .. " " .. minorV .. "/" .. HCP.Violations.MINOR_WEEKLY_MAX .. "\n" ..
                                c.DIM .. "Suspicious Flags:" .. c.CLOSE .. " " .. (flagCount > 0 and (c.RED .. flagCount .. c.CLOSE) or "0")
                        end,
                    },
                },
            },
        },
    }
end

-- Register the options table
function HardcorePlus:SetupSettings()
    AceConfig:RegisterOptionsTable("HardcorePlus", GetOptions)
    AceConfigDialog:SetDefaultSize("HardcorePlus", 480, 520)
end

-- Show settings
function HardcorePlus:ShowSettings()
    AceConfigDialog:Open("HardcorePlus")
end

-- Message handlers
HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    HardcorePlus:SetupSettings()
end)

HardcorePlus:RegisterMessage("HCP_SHOW_SETTINGS", function()
    HardcorePlus:ShowSettings()
end)
