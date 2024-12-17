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
local DB = CUF.DB

local maxLevel = CUF.Defaults.Values.maxLevel

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.RESTING_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.HideAtMaxLevel,
    Builder.MenuOptions.IconTexture,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateRestingIconWidget(button, unit, setting, subSetting)
    local restingIcon = button.widgets.restingIcon
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.RESTING_ICON, unit)
    if not setting or setting == const.OPTION_KIND.HIDE_AT_MAX_LEVEL then
        restingIcon.hideAtMaxLevel = styleTable.hideAtMaxLevel
        restingIcon:UpdateEventListeners()
    end
    if not setting or setting == const.OPTION_KIND.ICON_TEXTURE then
        restingIcon:SetTexture(styleTable.iconTexture)
    end

    restingIcon.Update(button)
end

Handler:RegisterWidget(W.UpdateRestingIconWidget, const.WIDGET_KIND.RESTING_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button, event, ...)
    local unit = button.states.displayedUnit
    if not unit then return end

    local status = IsResting()
    button.states.isResting = status

    local restingIcon = button.widgets.restingIcon

    if restingIcon.enabled and (status or restingIcon._isSelected) then
        if restingIcon.hideAtMaxLevel then
            local level = UnitEffectiveLevel(unit)

            -- UnitLevel can return outdated value, so if we have a value from the event
            -- We use that instead
            if event == "PLAYER_LEVEL_UP" then
                local newLevel = ...
                if newLevel and newLevel > level then
                    level = newLevel
                end
            elseif event == "PLAYER_LEVEL_CHANGED" then
                local _, newLevel = ...
                if newLevel and newLevel > level then
                    level = newLevel
                end
            end

            if level == maxLevel then
                restingIcon:Hide()
                restingIcon:UpdateEventListeners()
                return
            end
        end

        restingIcon:Show()
    else
        restingIcon:Hide()
    end
end

---@param self RestingIconWidget
local function Enable(self)
    self:UpdateEventListeners()

    return true
end

---@param self RestingIconWidget
local function Disable(self)
    self._owner:RemoveEventListener("PLAYER_UPDATE_RESTING", Update)
    self._owner:RemoveEventListener("PLAYER_LEVEL_CHANGED", Update)
    self._owner:RemoveEventListener("PLAYER_LEVEL_UP", Update)
end

---@param self RestingIconWidget
local function UpdateEventListeners(self)
    if self.hideAtMaxLevel then
        if UnitEffectiveLevel(self._owner.states.unit) < maxLevel then
            self._owner:AddEventListener("PLAYER_UPDATE_RESTING", Update, true)
            self._owner:AddEventListener("PLAYER_LEVEL_CHANGED", Update, true)
            self._owner:AddEventListener("PLAYER_LEVEL_UP", Update, true)
        else
            self._owner:RemoveEventListener("PLAYER_UPDATE_RESTING", Update)
            self._owner:RemoveEventListener("PLAYER_LEVEL_CHANGED", Update)
            self._owner:RemoveEventListener("PLAYER_LEVEL_UP", Update)
        end
    else
        self._owner:AddEventListener("PLAYER_UPDATE_RESTING", Update, true)

        self._owner:RemoveEventListener("PLAYER_LEVEL_CHANGED", Update)
        self._owner:RemoveEventListener("PLAYER_LEVEL_UP", Update)
    end
end

---@param self RestingIconWidget
---@param texture string
local function SetTexture(self, texture)
    if texture == "" then
        self.tex:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        self.tex:SetTexCoord(0, .5, 0, .421875)
    else
        self.tex:SetTexture(texture)
        self.tex:SetTexCoord(0, 1, 0, 1)
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
    restingIcon._owner = button
    restingIcon.hideAtMaxLevel = false

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

    restingIcon.UpdateEventListeners = UpdateEventListeners

    restingIcon.SetTexture = SetTexture

    restingIcon.SetEnabled = W.SetEnabled
    restingIcon.SetPosition = W.SetPosition
    restingIcon._SetIsSelected = W.SetIsSelected
    restingIcon.SetWidgetSize = W.SetWidgetSize
    restingIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.RESTING_ICON, W.CreateRestingIcon)
