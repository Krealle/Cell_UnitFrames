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

-------------------------------------------------
-- MARK: Overlay
-------------------------------------------------

---@param button CUFUnitButton
---@param unit Unit
local function CreateOverlayBox(button, unit)
    ---@class CUFOverlayBox: Button, BackdropTemplate
    local overlay = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    overlay:SetAllPoints(button)
    overlay:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    overlay:SetBackdropColor(0, 1, 1, 0.5)

    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(overlay:GetFrameLevel() + 100)

    local overlayText = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    overlayText:SetPoint("BOTTOM", overlay, "TOP", 0, 5)
    overlayText:SetText(L[unit])
    overlayText:SetTextColor(0, 1, 1, 1)

    overlay:RegisterForDrag("LeftButton")
    overlay:RegisterForClicks("LeftButtonUp")
    overlay:SetMovable(true)
    button:SetMovable(true)

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

    overlay:HookScript("OnShow", function()
        button:SetMovable(true)
    end)
    overlay:HookScript("OnHide", function()
        button:SetMovable(false)
    end)

    return overlay
end

---@type table<Unit, Frame>
local overlays = {}

---@param show boolean?
function U:EditMode(show)
    if show ~= nil then
        CUF.vars.inEditMode = show
    else
        CUF.vars.inEditMode = not CUF.vars.inEditMode
    end

    if CUF.vars.inEditMode then
        for _, unit in pairs(CUF.constants.UNIT) do
            if overlays[unit] then
                overlays[unit]:Show()
            else
                overlays[unit] = CreateOverlayBox(CUF.unitButtons[unit], unit)
            end
        end
    else
        for _, unit in pairs(CUF.constants.UNIT) do
            if overlays[unit] then
                overlays[unit]:Hide()
            end
        end

        if positioningPopup then
            positioningPopup:Hide()
        end
    end
end
