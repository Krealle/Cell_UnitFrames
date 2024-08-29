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
    button.widgets.restingIcon.Update(button)
end

Handler:RegisterWidget(W.UpdateRestingIconWidget, const.WIDGET_KIND.RESTING_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
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

---@param self RestingIconWidget
local function Enable(self)
    if not self._owner:IsVisible() then return end
    self._owner:AddEventListener("PLAYER_UPDATE_RESTING", Update, true)
end

---@param self RestingIconWidget
local function Disable(self)
    self._owner:RemoveEventListener("PLAYER_UPDATE_RESTING", Update)
    self:Hide()
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
    restingIcon._owner = button

    restingIcon.tex = restingIcon:CreateTexture(nil, "ARTWORK")
    restingIcon.tex:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    restingIcon.tex:SetAllPoints(restingIcon)
    restingIcon.tex:SetTexCoord(0, .5, 0, .421875)

    function restingIcon:_OnIsSelected()
        self.Update(self._owner)
    end

    restingIcon.Enable = Enable
    restingIcon.Disable = Disable
    restingIcon.Update = Update

    restingIcon.SetEnabled = W.SetEnabled
    restingIcon.SetPosition = W.SetPosition
    restingIcon._SetIsSelected = W.SetIsSelected
    restingIcon.SetWidgetSize = W.SetWidgetSize
    restingIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.RESTING_ICON, W.CreateRestingIcon)
