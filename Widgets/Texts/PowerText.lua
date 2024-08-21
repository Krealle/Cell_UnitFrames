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

    if not setting or setting == "enabled" then
        U:TogglePowerEvents(button)
    end
    if not setting or setting == const.OPTION_KIND.FORMAT then
        widget:SetFormat(styleTable.format)
    end
    if not setting or setting == const.OPTION_KIND.TEXT_FORMAT then
        widget:SetTextFormat(styleTable.textFormat)
        widget:SetFormat(styleTable.format)
    end

    U:UnitFrame_UpdatePowerText(button)
    U:UnitFrame_UpdatePowerTextColor(button)
end

Handler:RegisterWidget(W.UpdatePowerTextWidget, const.WIDGET_KIND.POWER_TEXT)

-------------------------------------------------
-- MARK: Update Power Text
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerText(button)
    if button.states.displayedUnit then
        button.widgets.powerText:UpdateValue()
    end
end

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerTextColor(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    button.widgets.powerText:UpdateTextColor()
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

    powerText.SetFormat = PowerText_SetFormat
    powerText.SetTextFormat = PowerText_SetTextFormat
    powerText.SetValue = SetPower_Percentage

    function powerText:UpdateValue()
        if button.widgets.powerText.enabled and button.states.powerMax ~= 0 and button.states.power then
            button.widgets.powerText:SetValue(button.states.power, button.states.powerMax)
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
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.POWER_TEXT, W.CreatePowerText)
