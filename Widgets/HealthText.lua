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

local menu = CUF.Menu

-------------------------------------------------
-- MARK: UpdateHealthText
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateHealthText(button)
    if button.states.displayedUnit then
        W:UpdateUnitHealthState(button)

        button.widgets.healthText:UpdateTextColor()
        button.widgets.healthText:UpdateValue()
    end
end

-------------------------------------------------
-- MARK: Format
-------------------------------------------------

-- TODO: make generic

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", current / max * 100)
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Absorbs(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetFormattedText("%d%%", current / max * 100)
    else
        self:SetFormattedText("%d%%+%d%%", current / max * 100, totalAbsorbs / max * 100)
    end
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Absorbs_Merged(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", (current + totalAbsorbs) / max * 100)
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Deficit(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", (current - max) / max * 100)
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number(self, current, max, totalAbsorbs)
    self:SetText(tostring(current))
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Short(self, current, max, totalAbsorbs)
    self:SetText(F:FormatNumber(current))
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Absorbs_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText(F:FormatNumber(current))
    else
        self:SetFormattedText("%s+%s", F:FormatNumber(current), F:FormatNumber(totalAbsorbs))
    end
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Absorbs_Merged_Short(self, current, max, totalAbsorbs)
    self:SetText(F:FormatNumber(current + totalAbsorbs))
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Deficit(self, current, max, totalAbsorbs)
    self:SetText(tostring(current - max))
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Deficit_Short(self, current, max, totalAbsorbs)
    self:SetText(F:FormatNumber(current - max))
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Current_Short_Percentage(self, current, max, totalAbsorbs)
    self:SetFormattedText("%s %d%%", F:FormatNumber(current), (current / max * 100))
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetText(tostring(totalAbsorbs))
    end
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetText(F:FormatNumber(totalAbsorbs))
    end
    self:SetWidth(self:GetStringWidth())
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only_Percentage(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetFormattedText("%d%%", totalAbsorbs / max * 100)
    end
    self:SetWidth(self:GetStringWidth())
end

---@class HealthTextWidget
---@param self HealthTextWidget
---@param format HealthTextFormat
local function HealthText_SetFormat(self, format)
    if format == "percentage" then
        self.SetValue = SetHealth_Percentage
    elseif format == "percentage-absorbs" then
        self.SetValue = SetHealth_Percentage_Absorbs
    elseif format == "percentage-absorbs-merged" then
        self.SetValue = SetHealth_Percentage_Absorbs_Merged
    elseif format == "percentage-deficit" then
        self.SetValue = SetHealth_Percentage_Deficit
    elseif format == "number" then
        self.SetValue = SetHealth_Number
    elseif format == "number-short" then
        self.SetValue = SetHealth_Number_Short
    elseif format == "number-absorbs-short" then
        self.SetValue = SetHealth_Number_Absorbs_Short
    elseif format == "number-absorbs-merged-short" then
        self.SetValue = SetHealth_Number_Absorbs_Merged_Short
    elseif format == "number-deficit" then
        self.SetValue = SetHealth_Number_Deficit
    elseif format == "number-deficit-short" then
        self.SetValue = SetHealth_Number_Deficit_Short
    elseif format == "current-short-percentage" then
        self.SetValue = SetHealth_Current_Short_Percentage
    elseif format == "absorbs-only" then
        self.SetValue = SetHealth_Absorbs_Only
    elseif format == "absorbs-only-short" then
        self.SetValue = SetHealth_Absorbs_Only_Short
    elseif format == "absorbs-only-percentage" then
        self.SetValue = SetHealth_Absorbs_Only_Percentage
    end
end

-------------------------------------------------
-- MARK: CreateHealthText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateHealthText(button)
    ---@class HealthTextWidget: FontString
    local healthText = button.widgets.healthBar:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    button.widgets.healthText = healthText
    healthText:ClearAllPoints()
    healthText:SetPoint("CENTER", 0, 0)
    healthText:SetFont("Cell Default", 12, "Outline")
    healthText.enabled = false
    healthText.id = "healthText"

    healthText.SetFormat = HealthText_SetFormat
    healthText.SetValue = SetHealth_Percentage
    healthText.SetEnabled = W.SetEnabled
    healthText.SetPosition = W.SetPosition
    healthText.SetFontStyle = W.SetFontStyle

    function healthText:UpdateValue()
        if button.widgets.healthText.enabled and button.states.healthMax ~= 0 then
            button.widgets.healthText:SetValue(button.states.health, button.states.healthMax, button.states.totalAbsorbs)
            button.widgets.healthText:Show()
        else
            button.widgets.healthText:Hide()
        end
    end

    function healthText:UpdateTextColor()
        if not Cell.vars.currentLayoutTable[button.states.unit] then
            button.widgets.healthText:SetTextColor(1, 1, 1)
            return
        end

        if Cell.vars.currentLayoutTable[button.states.unit].widgets.healthText.color.type == "class_color" then
            button.widgets.healthText:SetTextColor(F:GetClassColor(button.states.class))
        else
            button.widgets.healthText:SetTextColor(unpack(Cell.vars.currentLayoutTable[button.states.unit].widgets
                .healthText
                .color.rgb))
        end
    end
end

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget("healthText", 250, "Health", Builder.MenuOptions.TextColor,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font)

---@param button CUFUnitButton
---@param unit Units
---@param setting string
---@param subSetting string
function W.UpdateHealthTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.healthText

    if not setting or setting == "healthFormat" then
        widget:SetFormat(CUF.vars.selectedLayoutTable[unit].widgets.healthText.format)
    end

    U:UnitFrame_UpdateHealthText(button)
end

Handler:RegisterWidget(W.UpdateHealthTextWidget, "healthText")
