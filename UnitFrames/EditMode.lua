---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local Util = CUF.Util
local L = CUF.L

-------------------------------------------------
-- MARK: Positioning Popup
-------------------------------------------------

---@type CUFPositioningPopup
local positioningPopup

local function CreatePositioningPopup()
    ---@class CUFPositioningPopup: Frame
    positioningPopup = CUF:CreateFrame("CUFPositioningPopup", UIParent, 200, 160)
    positioningPopup:SetPoint("CENTER")
    positioningPopup:Hide()

    positioningPopup:SetMovable(true)
    positioningPopup:EnableMouse(true)
    positioningPopup:RegisterForDrag("LeftButton")
    positioningPopup:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    positioningPopup:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local closeBtn = Cell:CreateButton(positioningPopup, "×", "red", { 18, 18 }, false, false, "CELL_FONT_SPECIAL",
        "CELL_FONT_SPECIAL")
    closeBtn:SetPoint("TOPRIGHT", P:Scale(-5), P:Scale(-1))
    closeBtn:SetScript("OnClick", function() positioningPopup:Hide() end)

    local title = positioningPopup:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)
    positioningPopup.title = title

    local xVal = GetScreenWidth() / 2
    local yVal = GetScreenHeight() / 2

    positioningPopup.xPosSlider = Cell:CreateSlider(L["X Offset"], positioningPopup, -xVal, xVal, 150, 1)
    positioningPopup.xPosSlider:SetPoint("TOP", 0, -45)

    positioningPopup.yPosSlider = Cell:CreateSlider(L["Y Offset"], positioningPopup, -yVal, yVal, 150, 1)
    positioningPopup.yPosSlider:SetPoint("TOPLEFT", positioningPopup.xPosSlider, "BOTTOMLEFT", 0, -40)

    ---@type CheckButton
    local mirrorCB = Cell:CreateCheckButton(positioningPopup, L["MirrorPlayer"], function(checked)
        CUF.DB.CurrentLayoutTable()[const.UNIT.TARGET].mirrorPlayer = checked
        U:UpdateUnitButtonPosition("target", CUF.unitButtons.target)
        positioningPopup.xPosSlider:SetEnabled(not checked)
        positioningPopup.yPosSlider:SetEnabled(not checked)
    end)
    mirrorCB:SetPoint("TOPLEFT", positioningPopup.yPosSlider, "BOTTOMLEFT", 0, -30)
    positioningPopup.mirrorCB = mirrorCB
end

---@param unit Unit
---@param button CUFUnitButton
local function ShowPositioningPopup(unit, button)
    if not positioningPopup then
        CreatePositioningPopup()
    end
    positioningPopup:Show()
    positioningPopup.title:SetText(L["Positioning"] .. ": " .. CUF.constants.TITLE_CASED_UNITS[unit])

    positioningPopup.xPosSlider:SetValue(CUF.DB.CurrentLayoutTable()[unit].position[1])
    positioningPopup.yPosSlider:SetValue(CUF.DB.CurrentLayoutTable()[unit].position[2])

    positioningPopup.xPosSlider.onValueChangedFn = function(value)
        CUF.DB.CurrentLayoutTable()[unit].position[1] = value
        U:UpdateUnitButtonPosition(unit, button)

        if unit == const.UNIT.PLAYER then
            CUF:Fire("UpdateLayout", nil, "position", const.UNIT.TARGET)
        end
    end
    positioningPopup.yPosSlider.onValueChangedFn = function(value)
        CUF.DB.CurrentLayoutTable()[unit].position[2] = value
        U:UpdateUnitButtonPosition(unit, button)

        if unit == const.UNIT.PLAYER then
            CUF:Fire("UpdateLayout", nil, "position", const.UNIT.TARGET)
        end
    end

    local isMirrored = CUF.DB.CurrentLayoutTable()[unit].mirrorPlayer or false

    if unit == const.UNIT.TARGET then
        positioningPopup.mirrorCB:SetChecked(isMirrored)
        positioningPopup.mirrorCB:Show()
    else
        positioningPopup.mirrorCB:Hide()
    end

    positioningPopup.xPosSlider:SetEnabled(not isMirrored)
    positioningPopup.yPosSlider:SetEnabled(not isMirrored)
end

local function HidePositioningPopup()
    if positioningPopup then
        positioningPopup:Hide()
    end
end

-------------------------------------------------
-- MARK: Overlay
-------------------------------------------------

---@type table<Unit, CUFOverlayBox>
local overlays = {}

local colors = {
    [const.UNIT.PLAYER] = { 1, 0, 0 },
    [const.UNIT.TARGET] = { 1, 0.5, 0 },
    [const.UNIT.TARGET_TARGET] = { 1, 1, 0 },
    [const.UNIT.FOCUS] = { 0, 1, 0 },
    [const.UNIT.PET] = { 0, 0.5, 1 },
}

---@param button CUFUnitButton
---@param unit Unit
local function CreateOverlayBox(button, unit)
    ---@class CUFOverlayBox: Button, BackdropTemplate
    local overlay = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    overlay:SetAllPoints(button)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(overlay:GetFrameLevel() + 100)
    overlay:Hide()

    local border = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0, 0, 0, 1)

    local tex = overlay:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(Cell.vars.whiteTexture)
    tex:SetAllPoints()
    local r, g, b = unpack(colors[unit])
    tex:SetVertexColor(r, g, b, 0.5)

    local label = overlay:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    label:SetPoint("CENTER")
    label:SetText(L[unit])

    -- Register mouse and movable
    overlay:RegisterForDrag("LeftButton")
    overlay:RegisterForClicks("LeftButtonUp")
    overlay:SetMovable(true)
    button:SetMovable(true)

    -- Animation
    overlay.fadeIn = overlay:CreateAnimationGroup()
    local fadeIn = overlay.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetScript("OnPlay", function()
        overlay:Show()
    end)

    overlay.fadeOut = overlay:CreateAnimationGroup()
    local fadeOut = overlay.fadeOut:CreateAnimation("alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        overlay:Hide()
    end)

    -- Scripts
    overlay:SetScript("OnDragStart", function()
        button:StartMoving()
    end)
    overlay:SetScript("OnDragStop", function()
        button:StopMovingOrSizing()
        local x, y = Util.GetPositionRelativeToUIParentCenter(button)

        CUF.DB.CurrentLayoutTable()[unit].position = { x, y }
        U:UpdateUnitButtonPosition(unit, button)

        if unit == const.UNIT.PLAYER then
            CUF:Fire("UpdateLayout", nil, "position", const.UNIT.TARGET)
        end
    end)
    overlay:SetScript("OnClick", function()
        ShowPositioningPopup(unit, button)
    end)

    -- Hooks
    overlay:HookScript("OnShow", function()
        button:SetMovable(true)
    end)
    overlay:HookScript("OnHide", function()
        button:SetMovable(false)
    end)

    return overlay
end

--- Play the fade out animation and hide the overlays
---
--- If instant is true, the overlays will be hidden instantly
---@param instant boolean?
local function HideOverlays(instant)
    for _, overlay in pairs(overlays) do
        if instant then
            overlay:Hide()
        else
            overlay.fadeOut:Play()
        end
    end
end

--- Play the fade in animation and show the overlays
local function ShowOverlays()
    for _, unit in pairs(CUF.constants.UNIT) do
        if overlays[unit] then
            overlays[unit].fadeIn:Play()
        else
            overlays[unit] = CreateOverlayBox(CUF.unitButtons[unit], unit)
            overlays[unit].fadeIn:Play()
        end
    end
end

-------------------------------------------------
-- MARK: Edit Mode
-------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
    CUF.vars.inEditMode = false
    HideOverlays(true)
    HidePositioningPopup()
end)

--- Enable or disable edit mode
---
--- If show is nil then the current state will be toggled
---@param show boolean?
function U:EditMode(show)
    if show ~= nil then
        CUF.vars.inEditMode = show
    else
        CUF.vars.inEditMode = not CUF.vars.inEditMode
    end

    if CUF.vars.inEditMode then
        ShowOverlays()
        eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    else
        HideOverlays()
        HidePositioningPopup()
        eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end
end
