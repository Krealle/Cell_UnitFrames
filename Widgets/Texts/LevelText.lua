---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

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
menu:AddWidget(const.WIDGET_KIND.LEVEL_TEXT,
    Builder.MenuOptions.TextColor,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateLevelTextWidget(button, unit, setting, subSetting)
    button.widgets.levelText.Update(button)
end

Handler:RegisterWidget(W.UpdateLevelTextWidget, const.WIDGET_KIND.LEVEL_TEXT)

-------------------------------------------------
-- MARK: Button Update Level
-------------------------------------------------

---@param button CUFUnitButton
---@param event WowEvent?
local function Update(button, event, ...)
    local unit = button.states.unit
    if not unit then return end

    local levelText = button.widgets.levelText
    if not levelText.enabled then return end

    local level = UnitEffectiveLevel(unit) ---@type number|string

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

    level = tostring(UnitLevel(unit))
    if level == "-1" then
        level = "??"
    end

    levelText:SetText(level)
    levelText:UpdateTextColor()
end

---@param self LevelTextWidget
local function Enable(self)
    self:Show()

    -- Unsure which event is most accurate, so we listen to both
    if self._owner._baseUnit == "player" then
        self._owner:AddEventListener("PLAYER_LEVEL_CHANGED", Update, true)
        self._owner:AddEventListener("PLAYER_LEVEL_UP", Update, true)
    else
        self._owner:AddEventListener("UNIT_LEVEL", Update)
    end

    return true
end

---@param self LevelTextWidget
local function Disable(self)
    self._owner:RemoveEventListener("PLAYER_LEVEL_CHANGED", Update)
    self._owner:RemoveEventListener("PLAYER_LEVEL_UP", Update)
    self._owner:RemoveEventListener("UNIT_LEVEL", Update)
end

-------------------------------------------------
-- MARK: CreateLevelText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateLevelText(button)
    ---@class LevelTextWidget: TextWidget
    local levelText = W.CreateBaseTextWidget(button, const.WIDGET_KIND.LEVEL_TEXT)
    button.widgets.levelText = levelText

    levelText.Update = Update
    levelText.Enable = Enable
    levelText.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.LEVEL_TEXT, W.CreateLevelText)
