--[[
    LibDBIcon-1.0 — Minimal implementation for HardcorePlus
    Creates a minimap button from a LibDataBroker launcher object.
    Replace with full LibDBIcon from wowace.com for production.
]]

local MAJOR, MINOR = "LibDBIcon-1.0", 11
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.objects = lib.objects or {}
lib.callbackRegistered = lib.callbackRegistered or {}
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.notCreated = lib.notCreated or {}

local ICON_SIZE = 32
local MINIMAP_RADIUS = 80

local function GetPosition(angle)
    return math.cos(angle) * MINIMAP_RADIUS, math.sin(angle) * MINIMAP_RADIUS
end

local function UpdatePosition(button, angle)
    local x, y = GetPosition(angle)
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateButton(name, obj, db)
    local button = CreateFrame("Button", "LibDBIcon10_" .. name, Minimap)
    button:SetFrameStrata("MEDIUM")
    button:SetSize(ICON_SIZE, ICON_SIZE)
    button:SetFrameLevel(8)
    button:SetHighlightTexture(136477) -- Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight
    button:SetMovable(true)
    button:RegisterForClicks("anyUp")

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture(136430) -- Interface\\Minimap\\MiniMap-TrackingBorder
    overlay:SetPoint("TOPLEFT")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture(136467) -- Interface\\Minimap\\UI-Minimap-Background
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture(obj.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    icon:SetPoint("TOPLEFT", 7, -6)
    button.icon = icon

    button:SetScript("OnClick", function(self, btn)
        if obj.OnClick then
            obj.OnClick(self, btn)
        end
    end)

    button:SetScript("OnEnter", function(self)
        if obj.OnTooltipShow then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            obj.OnTooltipShow(GameTooltip)
            GameTooltip:Show()
        end
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Dragging
    local isDragging = false
    button:SetScript("OnMouseDown", function(self, btn)
        if btn == "LeftButton" and IsShiftKeyDown() then
            isDragging = true
            self:StartMoving()
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        if isDragging then
            isDragging = false
            self:StopMovingOrSizing()
            -- Calculate angle from minimap center
            local mx, my = Minimap:GetCenter()
            local bx, by = self:GetCenter()
            local angle = math.atan2(by - my, bx - mx)
            db.minimapPos = math.deg(angle)
            UpdatePosition(self, angle)
        end
    end)

    -- Initial position
    local angle = math.rad(db.minimapPos or 220)
    UpdatePosition(button, angle)

    if db.hide then
        button:Hide()
    else
        button:Show()
    end

    return button
end

function lib:Register(name, obj, db)
    if not db then db = {} end
    if not db.minimapPos then db.minimapPos = 220 end

    local button = CreateButton(name, obj, db)
    lib.objects[name] = button
    lib.objects[name].db = db
end

function lib:Show(name)
    local button = lib.objects[name]
    if button then
        button:Show()
        button.db.hide = false
    end
end

function lib:Hide(name)
    local button = lib.objects[name]
    if button then
        button:Hide()
        button.db.hide = true
    end
end

function lib:IsRegistered(name)
    return lib.objects[name] ~= nil
end

function lib:GetMinimapButton(name)
    return lib.objects[name]
end
