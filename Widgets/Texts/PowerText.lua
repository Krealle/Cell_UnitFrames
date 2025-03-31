---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
---@type LibGroupInfo
local LGI = LibStub:GetLibrary("LibGroupInfo", true)

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
local P = CUF.PixelPerfect

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.POWER_TEXT,
    Builder.MenuOptions.TextColorWithPowerType,
    Builder.MenuOptions.PowerFormat,
    Builder.MenuOptions.PowerTextAnchorOptions,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdatePowerTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.powerText
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.POWER_TEXT, unit) --[[@as PowerTextWidgetTable]]

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
    if not setting or setting == const.OPTION_KIND.ANCHOR_TO_POWER_BAR then
        widget:SetPosition(styleTable)
    end
    if not setting or setting == const.OPTION_KIND.POWER_FILTER then
        widget.powerFilter = styleTable.powerFilter
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
local function GetRole(button)
    local role
    local info = LGI and LGI:GetCachedInfo(button.states.guid)

    if button.states.unit == "player" then
        local classID = select(2, UnitClassBase("player"))
        if classID then
            role = select(5, GetSpecializationInfoForClassID(classID, GetSpecialization()))
        end
    elseif info then
        role = info.role
    else
        role = UnitGroupRolesAssigned(button.states.unit)
    end

    return role
end

---@param self PowerTextWidget
local function PowerFilterCheck(self)
    local owner = self._owner
    local guid = owner.states.guid or UnitGUID(owner.states.unit)
    if not guid then return end

    local class, role
    if owner.states.inVehicle then
        class = "VEHICLE"
    elseif F.IsPlayer(guid) then
        class = UnitClassBase(owner.states.unit)
        role = GetRole(owner)
    elseif F.IsPet(guid) then
        class = "PET"
    elseif F.IsNPC(guid) then
        if UnitInPartyIsAI(owner.states.unit) then
            class = UnitClassBase(owner.states.unit)
            role = GetRole(owner)
        else
            class = "NPC"
        end
    elseif F.IsVehicle(guid) then
        class = "VEHICLE"
    end

    if not Cell.vars.currentLayoutTable then return end

    if class then
        if type(Cell.vars.currentLayoutTable["powerFilters"][class]) == "boolean" then
            return Cell.vars.currentLayoutTable["powerFilters"][class]
        else
            if role then
                if role == "NONE" then
                    return true
                end
                return Cell.vars.currentLayoutTable["powerFilters"][class][role]
            else
                return
            end
        end
    end

    return true
end

---@param self PowerTextWidget
local function UpdateVisibility(self)
    if self.powerFilter then
        local powerFilterCheck = PowerFilterCheck(self)

        if powerFilterCheck == nil then
            C_Timer.After(0.1, function()
                self:UpdateVisibility()
            end)
            return
        elseif not powerFilterCheck then
            self:HidePowerText()
            return
        end
    end

    self:ShowPowerText()
end

---@param self PowerTextWidget
local function HidePowerText(self)
    if not self.active then return end

    self.active = false

    self._owner:RemoveEventListener("UNIT_POWER_FREQUENT", self.UpdateFrequent)
    self._owner:RemoveEventListener("UNIT_MAXPOWER", self.Update)

    self:Hide()
end

---@param self PowerTextWidget
local function ShowPowerText(self)
    if self.active then return end

    self.active = true

    self._owner:AddEventListener("UNIT_POWER_FREQUENT", self.UpdateFrequent, self.unitLess)
    self._owner:AddEventListener("UNIT_MAXPOWER", self.Update, self.unitLess)

    self:Show()
end

---@param button CUFUnitButton
local function UpdateFrequent(button)
    if button.states.displayedUnit then
        button.widgets.powerText:UpdateValue()
    end
end

---@param button CUFUnitButton
local function Update(button)
    local powerText = button.widgets.powerText
    if not powerText.enabled then return end

    powerText:UpdateVisibility()
    if not powerText.active then return end

    powerText:UpdateTextColor()
    powerText:UpdateValue()
end

---@param self PowerTextWidget
local function Enable(self)
    self.Update(self._owner)
    self.unitLess = self._owner.states.unit == CUF.constants.UNIT.TARGET_TARGET

    self._owner:AddEventListener("UNIT_DISPLAYPOWER", Update, self.unitLess)
    if F.IsPlayer(UnitGUID(self._owner.states.unit)) then
        self._owner:AddEventListener("PLAYER_SPECIALIZATION_CHANGED", self.Update)
    end

    return true
end

---@param self PowerTextWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_DISPLAYPOWER", Update)
    self._owner:RemoveEventListener("PLAYER_SPECIALIZATION_CHANGED", self.Update)

    self:HidePowerText()
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
    self:SetText(F.FormatNumber(current))
end

-------------------------------------------------
-- MARK: Custom Format
-------------------------------------------------

---@param self PowerTextWidget
local function SetPower_Custom(self)
    local formatFn = W.GetTagFunction(self.textFormat, "Power")
    self.SetValue = function(_, current, max)
        self:SetText(formatFn(nil, self._owner.states.unit))
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
    powerText.active = false
    powerText.unitLess = false
    powerText.powerFilter = false

    powerText.SetFormat = PowerText_SetFormat
    powerText.SetTextFormat = PowerText_SetTextFormat
    powerText.SetValue = SetPower_Percentage

    function powerText:UpdateValue()
        if not self.enabled then
            self:Hide()
            return
        end

        local unit = button.states.unit
        local powerMax = UnitPowerMax(unit)
        local power = UnitPower(unit)

        if UnitIsDeadOrGhost(unit) then
            self:Hide()
            return
        end

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

    powerText._SetPosition = powerText.SetPosition
    ---@param styleTable PowerTextWidgetTable
    function powerText:SetPosition(styleTable)
        if styleTable.anchorToPowerBar then
            P.ClearPoints(self.text)
            P.Point(self.text, styleTable.position.point, button.widgets.powerBar,
                styleTable.position.relativePoint,
                styleTable.position.offsetX, styleTable.position.offsetY)
        else
            powerText:_SetPosition(styleTable)
        end
    end

    function powerText:UpdateTextColor()
        local unit = button.states.displayedUnit
        if not unit then return end

        if self.colorType == const.PowerColorType.CLASS_COLOR then
            self:SetTextColor(F.GetClassColor(button.states.class))
        elseif self.colorType == const.PowerColorType.POWER_COLOR then
            self:SetTextColor(Util:GetPowerColor(unit))
        else
            self:SetTextColor(unpack(self.rgb))
        end
    end

    powerText.UpdateVisibility = UpdateVisibility
    powerText.HidePowerText = HidePowerText
    powerText.ShowPowerText = ShowPowerText

    powerText.Update = Update
    powerText.UpdateFrequent = UpdateFrequent
    powerText.Enable = Enable
    powerText.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.POWER_TEXT, W.CreatePowerText)
