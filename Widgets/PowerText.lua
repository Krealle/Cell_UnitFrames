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

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.POWER_TEXT, 230, "Power", Builder.MenuOptions.TextColorWithPowerType,
    Builder.MenuOptions.PowerFormat,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdatePowerTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.powerText

    if not setting or setting == const.OPTION_KIND.POWER_FORMAT then
        widget:SetFormat(DB.GetAllWidgetTables(unit).powerText.format)
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
    if format == const.PowerTextFormat.PERCENTAGE then
        self.SetValue = SetPower_Percentage
    elseif format == const.PowerTextFormat.NUMBER then
        self.SetValue = SetPower_Number
    elseif format == const.PowerTextFormat.NUMBER_SHORT then
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
    powerText._SetIsSelected = W.SetIsSelected

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
