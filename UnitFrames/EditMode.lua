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

---@type table<Unit, Frame>
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

    overlay.border = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    overlay.border:SetAllPoints()
    overlay.border:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    overlay.border:SetBackdropBorderColor(0, 0, 0, 1)

    overlay.tex = overlay:CreateTexture(nil, "ARTWORK")
    overlay.tex:SetTexture(Cell.vars.whiteTexture)
    overlay.tex:SetAllPoints()

    local r, g, b = unpack(colors[unit])
    overlay.tex:SetVertexColor(r, g, b, 0.5)

    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(overlay:GetFrameLevel() + 100)

    local overlayText = overlay:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    overlayText:SetPoint("BOTTOM", overlay, "TOP", 0, 5)
    overlayText:SetText(L[unit])
    overlayText:SetScale(1.5)

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
        overlay:RegisterEvent("PLAYER_REGEN_DISABLED")
    end)
    overlay:HookScript("OnHide", function()
        button:SetMovable(false)
        overlay:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end)

    return overlay
end

local function HideOverlays()
    for _, overlay in pairs(overlays) do
        overlay:Hide()
    end
end

local function ShowOverlays()
    for _, unit in pairs(CUF.constants.UNIT) do
        if overlays[unit] then
            overlays[unit]:Show()
        else
            overlays[unit] = CreateOverlayBox(CUF.unitButtons[unit], unit)
        end
    end
end

-------------------------------------------------
-- MARK: Edit Mode
-------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
    CUF.vars.inEditMode = false
    HideOverlays()
    HidePositioningPopup()
end)

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
