---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.RESTING_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateRestingIconWidget(button, unit, setting, subSetting)
    if not setting or setting == const.OPTION_KIND.ENABLED then
        U:ToggleRestingEvents(button)
    end

    U:UnitFrame_UpdateRestingIcon(button)
end

Handler:RegisterWidget(W.UpdateRestingIconWidget, const.WIDGET_KIND.RESTING_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateRestingIcon(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local status = IsResting()
    button.states.isResting = status

    local restingIcon = button.widgets.restingIcon

    if restingIcon.enabled and (status or restingIcon._isSelected) then
        restingIcon:Show()
    else
        restingIcon:Hide()
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateRestingIcon(button)
    ---@class RestingIconWidget: Frame, BaseWidget
    local restingIcon = CreateFrame("Frame", button:GetName() .. "_RestingIcon", button)
    button.widgets.restingIcon = restingIcon

    restingIcon:SetPoint("TOPLEFT", 0, 0)
    restingIcon.enabled = false
    restingIcon.id = const.WIDGET_KIND.RESTING_ICON
    restingIcon._isSelected = false

    restingIcon.tex = restingIcon:CreateTexture(nil, "ARTWORK")
    restingIcon.tex:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    restingIcon.tex:SetAllPoints(restingIcon)
    restingIcon.tex:SetTexCoord(0, .5, 0, .421875)

    function restingIcon:_OnIsSelected()
        U:UnitFrame_UpdateRestingIcon(button)
    end

    restingIcon.SetEnabled = W.SetEnabled
    restingIcon.SetPosition = W.SetPosition
    restingIcon._SetIsSelected = W.SetIsSelected
    restingIcon.SetWidgetSize = W.SetWidgetSize
    restingIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end
