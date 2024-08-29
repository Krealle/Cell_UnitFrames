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
local DB = CUF.DB
local Util = CUF.Util

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.POWER_TEXT,
    Builder.MenuOptions.TextColorWithPowerType,
    Builder.MenuOptions.PowerFormat,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdatePowerTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.powerText
    local styleTable = DB.GetWidgetTable(const.WIDGET_KIND.POWER_TEXT, unit) --[[@as PowerTextWidgetTable]]

    if not setting or setting == const.OPTION_KIND.FORMAT then
        widget:SetFormat(styleTable.format)
    end
    if not setting or setting == const.OPTION_KIND.TEXT_FORMAT then
        widget:SetTextFormat(styleTable.textFormat)
        widget:SetFormat(styleTable.format)
    end
    if not setting or setting == const.OPTION_KIND.HIDE_IF_EMPTY_OR_FULL then
        widget.hideIfEmptyOrFull = styleTable.hideIfEmptyOrFull
    end

    if widget.enabled and button:IsVisible() then
        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdatePowerTextWidget, const.WIDGET_KIND.POWER_TEXT)

-------------------------------------------------
-- MARK: Update Power Text
-------------------------------------------------

---@param button CUFUnitButton
local function UpdateFrequent(button)
    if button.states.displayedUnit then
        button.widgets.powerText:UpdateValue()
    end
end

---@param button CUFUnitButton
local function Update(button)
    button.widgets.powerText:UpdateTextColor()
    button.widgets.powerText:UpdateValue()
end

---@param self PowerTextWidget
local function Enable(self)
    local unitLess
    if self._owner.states.unit == CUF.constants.UNIT.TARGET_TARGET then
        unitLess = true
    end

    self._owner:AddEventListener("UNIT_POWER_FREQUENT", UpdateFrequent, unitLess)
    self._owner:AddEventListener("UNIT_DISPLAYPOWER", Update, unitLess)
    self:Show()

    return true
end

---@param self PowerTextWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_POWER_FREQUENT", UpdateFrequent)
    self._owner:RemoveEventListener("UNIT_DISPLAYPOWER", Update)
end

-------------------------------------------------
-- MARK: Format
-------------------------------------------------

-- TODO: make generic

---@param self PowerTextWidget
---@param current number
---@param max number
local function SetPower_Percentage(self, current, max)
    self:SetFormattedText("%d%%", current / max * 100)
end

---@param self PowerTextWidget
---@param current number
---@param max number
local function SetPower_Number(self, current, max)
    self:SetText(tostring(current))
end

---@param self PowerTextWidget
---@param current number
---@param max number
local function SetPower_Number_Short(self, current, max)
    self:SetText(F:FormatNumber(current))
end

-------------------------------------------------
-- MARK: Custom Format
-------------------------------------------------

---@param self PowerTextWidget
local function SetPower_Custom(self)
    local formatFn = W.ProcessCustomTextFormat(self.textFormat, "power")
    self.SetValue = function(_, current, max)
        self:SetText(formatFn(current, max))
    end
    self:UpdateValue() -- Fixes annoying race condition
end

-------------------------------------------------
-- MARK: Setters
-------------------------------------------------

---@class PowerTextWidget
---@param self PowerTextWidget
---@param format PowerTextFormat
local function PowerText_SetFormat(self, format)
    if format == const.PowerTextFormat.PERCENTAGE then
        self.SetValue = SetPower_Percentage
    elseif format == const.PowerTextFormat.NUMBER then
        self.SetValue = SetPower_Number
    elseif format == const.PowerTextFormat.NUMBER_SHORT then
        self.SetValue = SetPower_Number_Short
    elseif format == const.PowerTextFormat.CUSTOM then
        self.SetValue = SetPower_Custom
    end
end

---@class PowerTextWidget
---@param self PowerTextWidget
---@param format string
local function PowerText_SetTextFormat(self, format)
    self.textFormat = format
end

-------------------------------------------------
-- MARK: CreatePowerText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreatePowerText(button)
    ---@class PowerTextWidget: TextWidget
    local powerText = W.CreateBaseTextWidget(button, const.WIDGET_KIND.HEALTH_TEXT)
    button.widgets.powerText = powerText

    powerText.textFormat = ""
    powerText.hideIfEmptyOrFull = false

    powerText.SetFormat = PowerText_SetFormat
    powerText.SetTextFormat = PowerText_SetTextFormat
    powerText.SetValue = SetPower_Percentage

    function powerText:UpdateValue()
        local powerMax = UnitPowerMax(button.states.unit)
        local power = UnitPower(button.states.unit)

        if self.hideIfEmptyOrFull and (power == 0 or power == powerMax) then
            self:Hide()
            return
        end

        if powerMax > 0 and power then
            button.widgets.powerText:SetValue(power, powerMax)
            button.widgets.powerText:Show()
        else
            button.widgets.powerText:Hide()
        end
    end

    function powerText:UpdateTextColor()
        local unit = button.states.displayedUnit
        if not unit then return end

        if self.colorType == const.PowerColorType.CLASS_COLOR then
            self:SetTextColor(F:GetClassColor(button.states.class))
        elseif self.colorType == const.PowerColorType.POWER_COLOR then
            self:SetTextColor(Util:GetPowerColor(unit))
        else
            self:SetTextColor(unpack(self.rgb))
        end
    end

    powerText.Update = Update
    powerText.UpdateFrequent = UpdateFrequent
    powerText.Enable = Enable
    powerText.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.POWER_TEXT, W.CreatePowerText)
