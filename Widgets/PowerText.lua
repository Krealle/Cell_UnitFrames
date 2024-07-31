---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs
---@class CUF.Util
local Util = CUF.Util
---@class CUF.widgets.Handler
local Handler = CUF.widgetsHandler
---@class CUF.builder
local Builder = CUF.Builder

---@class CUF.Menu
local menu = CUF.Menu
---@class CUF.constants
local const = CUF.constants

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.POWER_TEXT, 250, "Power", Builder.MenuOptions.TextColorWithPowerType,
    Builder.MenuOptions.PowerFormat,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdatePowerTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.powerText

    if not setting or setting == "powerFormat" then
        widget:SetFormat(CUF.vars.selectedLayoutTable[unit].widgets.powerText.format)
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
    self:SetWidth(self:GetStringWidth())
end

---@param self PowerTextWidget
---@param current number
---@param max number
local function SetPower_Number(self, current, max)
    self:SetText(tostring(current))
    self:SetWidth(self:GetStringWidth())
end

---@param self PowerTextWidget
---@param current number
---@param max number
local function SetPower_Number_Short(self, current, max)
    self:SetText(F:FormatNumber(current))
    self:SetWidth(self:GetStringWidth())
end

---@class PowerTextWidget
---@param self PowerTextWidget
---@param format PowerTextFormat
local function PowerText_SetFormat(self, format)
    if format == "percentage" then
        self.SetValue = SetPower_Percentage
    elseif format == "number" then
        self.SetValue = SetPower_Number
    elseif format == "number-short" then
        self.SetValue = SetPower_Number_Short
    end
end

-------------------------------------------------
-- MARK: CreatePowerText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreatePowerText(button)
    ---@class PowerTextWidget: FontString
    local powerText = button.widgets.healthBar:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    button.widgets.powerText = powerText
    powerText:ClearAllPoints()
    powerText:SetPoint("CENTER", 0, 0)
    powerText:SetFont("Cell Default", 12, "Outline")
    powerText.enabled = false
    powerText.id = const.WIDGET_KIND.POWER_TEXT
    ---@type PowerColorType
    powerText.colorType = const.PowerColorType.CLASS_COLOR
    powerText.rgb = { 1, 1, 1 }

    powerText.SetFormat = PowerText_SetFormat
    powerText.SetValue = SetPower_Percentage
    powerText.SetEnabled = W.SetEnabled
    powerText.SetPosition = W.SetPosition
    powerText.SetFontStyle = W.SetFontStyle
    powerText.SetFontColor = W.SetFontColor

    function powerText:SetColor(r, g, b)
        self:SetTextColor(r, g, b)
    end

    function powerText:UpdateTextColor()
        local unit = button.states.displayedUnit
        if not unit then return end

        if self.colorType == const.PowerColorType.CLASS_COLOR then
            self:SetColor(F:GetClassColor(button.states.class))
        elseif self.colorType == const.PowerColorType.POWER_COLOR then
            self:SetColor(F:GetPowerColor(unit))
        else
            self:SetColor(unpack(self.rgb))
        end
    end

    function powerText:UpdateValue()
        if button.widgets.powerText.enabled and button.states.powerMax ~= 0 and button.states.power then
            button.widgets.powerText:SetValue(button.states.power, button.states.powerMax)
            button.widgets.powerText:Show()
        else
            button.widgets.powerText:Hide()
        end
    end
end
