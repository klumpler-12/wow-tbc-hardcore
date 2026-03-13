-- TBC Hardcore POC — Core.lua
-- Proof of Concept: A functional frame with an HC Status toggle button.

-- SavedVariables defaults
TBCHardcoreDB = TBCHardcoreDB or {}

local addonName = "TBCHardcore"
local isHCActive = false

-- ==========================================
-- Main Frame (draggable, with status button)
-- ==========================================
local frame = CreateFrame("Frame", "TBCHardcoreFrame", UIParent)
frame:SetWidth(220)
frame:SetHeight(120)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Background
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0.05, 0.05, 0.1, 0.9)

-- Title text
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -10)
title:SetText("|cff9b59f0TBC Hardcore|r")

-- Status text
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusText:SetPoint("CENTER", frame, "CENTER", 0, 10)
statusText:SetText("|cffff4444HC Mode: INACTIVE|r")

-- ==========================================
-- HC Status Toggle Button
-- ==========================================
local btn = CreateFrame("Button", "TBCHardcoreToggleBtn", frame, "UIPanelButtonTemplate")
btn:SetWidth(140)
btn:SetHeight(28)
btn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
btn:SetText("Activate HC Mode")

btn:SetScript("OnClick", function()
    isHCActive = not isHCActive
    if isHCActive then
        statusText:SetText("|cff4caf50HC Mode: ACTIVE|r")
        btn:SetText("Deactivate HC Mode")
        DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r HC Mode |cff4caf50ACTIVATED|r. Deaths will be tracked.")
        TBCHardcoreDB.active = true
    else
        statusText:SetText("|cffff4444HC Mode: INACTIVE|r")
        btn:SetText("Activate HC Mode")
        DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r HC Mode |cffff4444DEACTIVATED|r.")
        TBCHardcoreDB.active = false
    end
end)

-- ==========================================
-- Slash Command
-- ==========================================
SLASH_TBCHARDCORE1 = "/tbchc"
SLASH_TBCHARDCORE2 = "/hardcore"
SlashCmdList["TBCHARDCORE"] = function(msg)
    if msg == "toggle" then
        btn:Click()
    elseif msg == "status" then
        local state = isHCActive and "|cff4caf50ACTIVE|r" or "|cffff4444INACTIVE|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r Status: " .. state)
    else
        -- Toggle frame visibility
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r Commands: /tbchc toggle | /tbchc status")
    end
end

-- ==========================================
-- Event Hooks (Foundation for death tracking)
-- ==========================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            -- Restore saved state
            if TBCHardcoreDB.active then
                isHCActive = true
                statusText:SetText("|cff4caf50HC Mode: ACTIVE|r")
                btn:SetText("Deactivate HC Mode")
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r v0.1.0-poc loaded. Type /tbchc for options.")
        end
    elseif event == "PLAYER_DEAD" then
        if isHCActive then
            DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r |cffff4444YOU DIED!|r Death has been recorded.")
            -- TODO: Implement death hash, penalty execution, and data export
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if isHCActive then
            local newLevel = ...
            DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r Level up! Now level |cff4caf50" .. (newLevel or "?") .. "|r. Keep going!")
            -- TODO: Generate level-up hash for anti-cheat verification
        end
    end
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff9b59f0[TBC Hardcore]|r POC addon file loaded.")
