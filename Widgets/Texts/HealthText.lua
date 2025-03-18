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
local L = CUF.L

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.HEALTH_TEXT,
    Builder.MenuOptions.TextColor,
    Builder.MenuOptions.HealthFormat,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateHealthTextWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.healthText
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.HEALTH_TEXT, unit) --[[@as HealthTextWidgetTable]]

    if not setting or setting == const.OPTION_KIND.FORMAT then
        widget:SetFormat(styleTable.format)
    end
    if not setting or setting == const.OPTION_KIND.TEXT_FORMAT then
        widget:SetTextFormat(styleTable.textFormat)
        widget:SetFormat(styleTable.format)
    end
    if not setting or setting == const.OPTION_KIND.HIDE_IF_FULL then
        widget.hideIfFull = styleTable.hideIfFull
    end
    if not setting or setting == const.OPTION_KIND.HIDE_IF_EMPTY then
        widget.hideIfEmpty = styleTable.hideIfEmpty
    end
    if not setting or setting == const.OPTION_KIND.SHOW_DEAD_STATUS then
        widget.showDeadStatus = styleTable.showDeadStatus
    end

    if widget.enabled and button:IsVisible() then
        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdateHealthTextWidget, const.WIDGET_KIND.HEALTH_TEXT)

-------------------------------------------------
-- MARK: UpdateHealthText
-------------------------------------------------

---@param button CUFUnitButton
local function UpdateFrequent(button)
    if not button:IsVisible() then return end
    button.widgets.healthText:UpdateValue()
end

-- Called on full updates
---@param button CUFUnitButton
local function Update(button)
    if not button:IsVisible() then return end

    local healthText = button.widgets.healthText
    if not healthText.enabled then return end

    healthText:UpdateTextColor()
    healthText:UpdateValue()
end

---@param self HealthTextWidget
local function Enable(self)
    local unitLess
    if self._owner.states.unit == CUF.constants.UNIT.TARGET_TARGET then
        unitLess = true
    end

    self._owner:AddEventListener("UNIT_HEALTH", UpdateFrequent, unitLess)
    self._owner:AddEventListener("UNIT_MAXHEALTH", UpdateFrequent, unitLess)

    if self._showingAbsorbs then
        self._owner:AddEventListener("UNIT_ABSORB_AMOUNT_CHANGED", UpdateFrequent, unitLess)
    else
        self._owner:RemoveEventListener("UNIT_ABSORB_AMOUNT_CHANGED", UpdateFrequent)
    end

    if self._showingHealAbsorbs then
        self._owner:AddEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", UpdateFrequent, unitLess)
    else
        self._owner:RemoveEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", UpdateFrequent)
    end

    -- Full update
    self.Update(self._owner)
    self:Show()

    return true
end

---@param self HealthTextWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_HEALTH", UpdateFrequent)
    self._owner:RemoveEventListener("UNIT_MAXHEALTH", UpdateFrequent)
    self._owner:RemoveEventListener("UNIT_ABSORB_AMOUNT_CHANGED", UpdateFrequent)
    self._owner:RemoveEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", UpdateFrequent)
end

-------------------------------------------------
-- MARK: Format
-------------------------------------------------

---@param unit Unit
---@param absorbs boolean
---@param healAbsorbs boolean
---@return number health
---@return number healthMax
---@return number totalAbsorbs
---@return number totalHealAbsorbs
local function GetHealthInfo(unit, absorbs, healAbsorbs)
    local health = UnitHealth(unit) or 0
    local healthMax = UnitHealthMax(unit) or 0
    local totalAbsorbs = absorbs and UnitGetTotalAbsorbs(unit) or 0
    local healAborbs = healAbsorbs and UnitGetTotalHealAbsorbs(unit) or 0
    return health, healthMax, totalAbsorbs, healAborbs
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", current / max * 100)
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
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Absorbs_Merged(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", (current + totalAbsorbs) / max * 100)
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Deficit(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", (current - max) / max * 100)
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number(self, current, max, totalAbsorbs)
    self:SetText(tostring(current))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Short(self, current, max, totalAbsorbs)
    self:SetText(F.FormatNumber(current))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Absorbs_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText(F.FormatNumber(current))
    else
        self:SetFormattedText("%s+%s", F.FormatNumber(current), F.FormatNumber(totalAbsorbs))
    end
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Absorbs_Merged_Short(self, current, max, totalAbsorbs)
    self:SetText(F.FormatNumber(current + totalAbsorbs))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Deficit(self, current, max, totalAbsorbs)
    self:SetText(tostring(current - max))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Deficit_Short(self, current, max, totalAbsorbs)
    self:SetText(F.FormatNumber(current - max))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Current_Short_Percentage(self, current, max, totalAbsorbs)
    self:SetFormattedText("%s %d%%", F.FormatNumber(current), (current / max * 100))
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
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetText(F.FormatNumber(totalAbsorbs))
    end
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
end

-------------------------------------------------
-- MARK: Custom Format
-------------------------------------------------

---@param self HealthTextWidget
local function SetHealth_Custom(self)
    local formatFn, events = W.GetTagFunction(self.textFormat, "Health")

    local hasAbsorb, hasHealAbsorb = false, false
    for event, _ in pairs(events) do
        if event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            hasAbsorb = true
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            hasHealAbsorb = true
        end
    end

    self._showingAbsorbs = hasAbsorb
    self._showingHealAbsorbs = hasHealAbsorb

    self.SetValue = function()
        self:SetText(formatFn(nil, self._owner.states.unit))
    end
end

-------------------------------------------------
-- MARK: Setters
-------------------------------------------------

---@class HealthTextWidget
---@param self HealthTextWidget
---@param format HealthTextFormat
local function HealthText_SetFormat(self, format)
    if format == const.HealthTextFormat.PERCENTAGE then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Percentage
    elseif format == const.HealthTextFormat.PERCENTAGE_ABSORBS then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Percentage_Absorbs
    elseif format == const.HealthTextFormat.PERCENTAGE_ABSORBS_MERGED then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Percentage_Absorbs_Merged
    elseif format == const.HealthTextFormat.PERCENTAGE_DEFICIT then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Percentage_Deficit
    elseif format == const.HealthTextFormat.NUMBER then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Number
    elseif format == const.HealthTextFormat.NUMBER_SHORT then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Number_Short
    elseif format == const.HealthTextFormat.NUMBER_ABSORBS_SHORT then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Number_Absorbs_Short
    elseif format == const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Number_Absorbs_Merged_Short
    elseif format == const.HealthTextFormat.NUMBER_DEFICIT then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Number_Deficit
    elseif format == const.HealthTextFormat.NUMBER_DEFICIT_SHORT then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Number_Deficit_Short
    elseif format == const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE then
        self._showingAbsorbs = false
        self.SetValue = SetHealth_Current_Short_Percentage
    elseif format == const.HealthTextFormat.ABSORBS_ONLY then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Absorbs_Only
    elseif format == const.HealthTextFormat.ABSORBS_ONLY_SHORT then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Absorbs_Only_Short
    elseif format == const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE then
        self._showingAbsorbs = true
        self.SetValue = SetHealth_Absorbs_Only_Percentage
    elseif format == const.HealthTextFormat.CUSTOM then
        self:SetHealth_Custom()
    end

    if not self.enabled then return end
    self:Enable()
end

---@class HealthTextWidget
---@param self HealthTextWidget
---@param format string
local function HealthText_SetTextFormat(self, format)
    self.textFormat = format
end

-------------------------------------------------
-- MARK: CreateHealthText
-------------------------------------------------

---@param button CUFUnitButton
---@param custom boolean?
function W:CreateHealthText(button, custom)
    ---@class HealthTextWidget: TextWidget
    local healthText = W.CreateBaseTextWidget(button, const.WIDGET_KIND.HEALTH_TEXT)
    if not custom then
        button.widgets.healthText = healthText
    end

    healthText.textFormat = ""
    healthText._showingAbsorbs = false
    healthText._showingHealth = true
    healthText._showingHealAbsorbs = false
    healthText.hideIfEmptyOrFull = false
    healthText.hideIfFull = false
    healthText.hideIfEmpty = false
    healthText.showDeadStatus = false

    healthText.SetFormat = HealthText_SetFormat
    healthText.SetTextFormat = HealthText_SetTextFormat
    ---@type fun(self: HealthTextWidget, current: number, max: number, totalAbsorbs: number, healAbsorbs: number)
    healthText.SetValue = SetHealth_Percentage

    healthText.SetHealth_Custom = SetHealth_Custom

    ---@param unit UnitToken
    healthText.FormatFunc = function(_self, unit) end

    function healthText:UpdateValue()
        if not self.enabled then return end

        local unit = self._owner.states.displayedUnit
        local health, healthMax, totalAbsorbs, healAbsorbs = GetHealthInfo(unit,
            self._showingAbsorbs,
            self._showingHealAbsorbs)

        if healthMax == 0 then return end

        if self.hideIfFull and health == healthMax then
            self:Hide()
            return
        end

        if health == 0 then
            if self.hideIfEmpty then
                self:Hide()
                return
            end

            if self.showDeadStatus and UnitIsDeadOrGhost(unit) then
                self:SetText(L["Dead"])
                self:Show()
                return
            end
        end

        self:SetValue(health, healthMax, totalAbsorbs, healAbsorbs)
        self:Show()
    end

    healthText.Update = Update
    healthText.Enable = Enable
    healthText.Disable = Disable

    if custom then
        return healthText
    end
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.HEALTH_TEXT, W.CreateHealthText)
