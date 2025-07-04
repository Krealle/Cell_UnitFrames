---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = CUF.PixelPerfect

---@class CUF.uFuncs
local U = CUF.uFuncs

local W = CUF.widgets
local const = CUF.constants
local Util = CUF.Util

local UnitGUID = UnitGUID

local wipe = table.wipe

-------------------------------------------------
-- MARK: Update All
-------------------------------------------------

---@param button CUFUnitButton
local function UnitFrame_UpdateAll(button)
    -- This function may be called from various sources, so we reset the update flag
    -- to prevent it from running too much
    button._updateRequired = nil

    if not button:IsVisible() then return end

    U:UnitFrame_UpdateHealthColor(button)
    --UnitFrame_UpdateTarget(self)

    button:UpdateWidgets()

    -- Aura widgets will queue an update, but we want it to happen immediately
    button:UpdateAurasInternal()
end
U.UpdateAll = UnitFrame_UpdateAll

-------------------------------------------------
-- MARK: RegisterEvents
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_RegisterEvents(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_CONNECTION") -- offline

    --self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

    --self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    --self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    --self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    --self:RegisterEvent("UNIT_EXITED_VEHICLE")

    --self:RegisterEvent("PLAYER_FLAGS_CHANGED")  -- afk
    --self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

    if self._baseUnit == const.UNIT.TARGET or self._baseUnit == const.UNIT.TARGET_TARGET then
        self:AddEventListener("PLAYER_TARGET_CHANGED", UnitFrame_UpdateAll, true)
    end
    if self._baseUnit == const.UNIT.FOCUS then
        self:AddEventListener("PLAYER_FOCUS_CHANGED", UnitFrame_UpdateAll, true)
    end
    if self._baseUnit == const.UNIT.PET then
        self:AddEventListener("UNIT_PET", function(button, event, unit)
            if unit ~= const.UNIT.PLAYER then return end
            UnitFrame_UpdateAll(button)
        end, true)
    end
    if self._baseUnit == const.UNIT.TARGET_TARGET then
        self:AddEventListener("UNIT_TARGET", function(button, event, unit, ...)
            if unit == "target" then
                UnitFrame_UpdateAll(button)
            end
        end, true)
    end

    if self._baseUnit ~= const.UNIT.PLAYER then
        self:AddEventListener("INSTANCE_ENCOUNTER_ENGAGE_UNIT", UnitFrame_UpdateAll, true)
        self:AddEventListener("UNIT_TARGETABLE_CHANGED", UnitFrame_UpdateAll)
        self:AddEventListener("UNIT_FACTION", UnitFrame_UpdateAll)
    end

    local success, result = pcall(UnitFrame_UpdateAll, self)
    if not success then
        F.Debug("UnitFrame_UpdateAll |cffff0000FAILED:|r", self:GetName(), result)
    end
end

-------------------------------------------------
-- MARK: UnregisterEvents
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_UnregisterEvents(self)
    self:UnregisterAllEvents()
    wipe(self.eventHandlers)
end

-------------------------------------------------
-- MARK: OnEvents
-------------------------------------------------

---@param self CUFUnitButton
---@param event WowEvent
---@param unit string
---@param ... any
local function UnitFrame_OnEvent(self, event, unit, ...)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if event == "UNIT_CONNECTION" then
            self._updateRequired = true
            return
        end
    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = true
            return
        end
    end

    self:_OnEvent(event, unit, ...)
end

-------------------------------------------------
-- MARK: OnShow
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnShow(self)
    --CUF:Log(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent UnitFrame_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    self._powerBarUpdateRequired = true
    UnitFrame_RegisterEvents(self)

    self:EnableWidgets()
end

-------------------------------------------------
-- MARK: OnHide
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnHide(self)
    --CUF:Log(GetTime(), "OnHide", self:GetName())
    UnitFrame_UnregisterEvents(self)
    self:ResetAuraTables()

    if self.__unitGuid then
        self.__unitGuid = nil
    end
    if self.__unitName then
        self.__unitName = nil
    end
    self.__displayedGuid = nil
    F.RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")

    self:DisableWidgets()
end

-------------------------------------------------
-- MARK: OnEnter
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnEnter(self)
    --if not IsEncounterInProgress() then UnitButton_UpdateStatusText(self) end

    --if highlightEnabled then self.widgets.mouseoverHighlight:Show() end

    local unit = self.states.displayedUnit
    if not unit then return end

    F.ShowTooltips(self, "unit", unit)
end

-------------------------------------------------
-- MARK: OnLeave
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnLeave(self)
    self.widgets.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

local UNKNOWN = _G["UNKNOWN"]
local UNKNOWNOBJECT = _G["UNKNOWNOBJECT"]

-------------------------------------------------
-- MARK: OnTick
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnTick(self)
    -- CUF:Log(GetTime(), "OnTick", self._updateRequired, self:GetAttribute("refreshOnUpdate"), self:GetName())
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0

        if self.states.unit and self.states.displayedUnit then
            local displayedGuid = UnitGUID(self.states.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                F.RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                self._powerBarUpdateRequired = true
                self._updateRequired = true
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- CUF:Log("guidChanged:", self:GetName(), self.states.unit, guid)
                -- NOTE: unit entity changed
                self.__unitGuid = guid

                -- NOTE: only save players' names
                if UnitIsPlayer(self.states.unit) then
                    local name = Util:GetUnitNameWithServer(self.states.unit)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        self.__nameRetries = nil
                    else
                        -- NOTE: update on next tick
                        self.__nameRetries = (self.__nameRetries or 0) + 1
                        self.__unitGuid = nil
                    end
                end
            end
        end
    end

    self.__tickCount = e

    if self._updateRequired or self.alwaysUpdate then
        UnitFrame_UpdateAll(self)
    end

    if self._auraUpdateRequired then
        self:UpdateAurasInternal()
    end
end

-------------------------------------------------
-- MARK: OnUpdate
-------------------------------------------------

---@param self CUFUnitButton
---@param elapsed number
local function UnitFrame_OnUpdate(self, elapsed)
    local e = (self.__updateElapsed or 0) + elapsed
    if e > 0.25 then
        UnitFrame_OnTick(self)
        e = 0
    end
    self.__updateElapsed = e
end

-------------------------------------------------
-- MARK: OnAttributeChanged
-------------------------------------------------

---@param self CUFUnitButton
---@param name string
---@param value string?
local function UnitFrame_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if not value or value ~= self.states.unit then
            -- NOTE: when unitId for this button changes
            if self.__unitGuid then -- self.__unitGuid is deleted when hide
                self.__unitGuid = nil
            end
            if self.__unitName then
                self.__unitName = nil
            end
            wipe(self.states)
        end

        if type(value) == "string" then
            self.states.unit = value
            self.states.displayedUnit = value

            if not self.__widgetsInit then
                W:AssignWidgets(self, self._baseUnit)
                self.__widgetsInit = true
            end
            self:ResetAuraTables()

            self._updateRequired = true
            self._auraUpdateRequired = true
        end
    end
end

-------------------------------------------------
-- MARK: OnLoad
-------------------------------------------------

---@param button CUFUnitButton
function CUFUnitButton_OnLoad(button)
    --CUF:Log(buttonName, "OnLoad")

    ---@class CUFUnitButton
    button = button

    ---@diagnostic disable-next-line: missing-fields
    button.widgets = {}
    ---@diagnostic disable-next-line: missing-fields
    button.states = {}

    button.__widgetsInit = false
    button.healthBarColorType = const.UnitButtonColorType.CELL
    button.healthLossColorType = const.UnitButtonColorType.CELL

    -- ping system
    Mixin(button, PingableType_UnitFrameMixin)
    button:SetAttribute("ping-receiver", true)

    function button:GetTargetPingGUID()
        return button.__unitGuid
    end

    ---@param widget WIDGET_KIND
    function button:HasWidget(widget)
        return button.widgets[widget] ~= nil
    end

    -- backdrop
    if CELL_BORDER_SIZE > 0 then
        button:SetBackdrop({
            bgFile = Cell.vars.whiteTexture,
            edgeFile = Cell.vars.whiteTexture,
            edgeSize = P.Scale(CELL_BORDER_SIZE)
        })
        button:SetBackdropColor(0, 0, 0, 1)
        button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))
    end

    -- Widgets
    W:CreateHealthBar(button)
    --W:CreatePowerBar(button)

    -- targetHighlight
    ---@class HighlightWidget: BackdropTemplate, Frame
    local targetHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.widgets.targetHighlight = targetHighlight
    targetHighlight:SetIgnoreParentAlpha(true)
    targetHighlight:SetFrameLevel(button:GetFrameLevel() + 2)
    targetHighlight:Hide()

    -- mouseoverHighlight
    local mouseoverHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate") --[[@as HighlightWidget]]
    button.widgets.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetIgnoreParentAlpha(true)
    mouseoverHighlight:SetFrameLevel(button:GetFrameLevel() + 3)
    mouseoverHighlight:Hide()

    -- Event Handlers

    function button:EnableWidgets()
        for id, widget in pairs(self.widgets) do
            --CUF:Print(id, widget.enabled, self:GetName())
            if widget.Enable and widget.enabled then
                self:EnableWidget(widget)
            end
        end
    end

    function button:DisableWidgets()
        for _, widget in pairs(self.widgets) do
            if widget.Disable then
                self:DisableWidget(widget)
            end
        end
    end

    function button:UpdateWidgets()
        for _, widget in pairs(self.widgets) do
            if widget.Update and widget.enabled then
                widget.Update(self)
            end
        end
    end

    ---@param widget Widget|PowerBarWidget
    function button:EnableWidget(widget)
        if not self:ShouldEnableWidget(widget) then return end
        if widget:Enable() then
            widget._isEnabled = true
        end
    end

    ---@param widget Widget|PowerBarWidget
    function button:DisableWidget(widget)
        widget._isEnabled = false
        if not widget:Disable() then
            widget:Hide()
        end
    end

    ---@param widget Widget|PowerBarWidget
    function button:ShouldEnableWidget(widget)
        return self:IsVisible()
            and self.states.unit
            and widget.enabled
            and not widget._isEnabled
    end

    ---@param unit UnitToken
    function button:SetUnit(unit)
        self:SetAttribute("unit", unit)
        CUF:Fire("UpdateVisibility", unit)
    end

    Util:Mixin(button, CUF.Mixin.EventMixin)
    Util:Mixin(button, CUF.Mixin.AurasMixin)

    -- script
    button:SetScript("OnAttributeChanged", UnitFrame_OnAttributeChanged) -- init
    button:HookScript("OnShow", UnitFrame_OnShow)
    button:HookScript("OnHide", UnitFrame_OnHide)                        -- click-castings: _onhide
    button:HookScript("OnEnter", UnitFrame_OnEnter)                      -- click-castings: _onenter
    button:HookScript("OnLeave", UnitFrame_OnLeave)                      -- click-castings: _onleave
    button:SetScript("OnUpdate", UnitFrame_OnUpdate)
    --[[ button:SetScript("OnSizeChanged", UnitFrame_OnSizeChanged) ]]
    button:SetScript("OnEvent", UnitFrame_OnEvent)
    button:RegisterForClicks("AnyDown")
    --CUF:Log(button:GetName(), "OnLoad end")
end

---@class CUFUnitButton: Button, BackdropTemplate
---@field widgets CUFUnitButton.Widgets
---@field states CUFUnitButton.States
---@field GetTargetPingGUID function
---@field __unitGuid string
---@field class string
---@field powerSize number
---@field _powerBarUpdateRequired boolean
---@field _updateRequired boolean
---@field _auraUpdateRequired boolean
---@field __tickCount number
---@field __updateElapsed number
---@field __displayedGuid string?
---@field __unitName string
---@field __nameRetries number
---@field orientation "horizontal" | "vertical_health" | "vertical"
---@field _casts table
---@field _timers table
---@field _isSelected boolean
---@field name string
---@field __customPositioning boolean
---@field __customSize boolean
---@field _auraBuffCache table<number, AuraData>
---@field _auraDebuffCache table<number, AuraData>
---@field _auraBuffCallbacks UnitAuraCallbackFn[]
---@field _auraDebuffCallbacks UnitAuraCallbackFn[]
---@field _ignoreBuffs boolean
---@field _ignoreDebuffs boolean
---@field _baseUnit Unit Base unit without N eg. 'boss'
---@field _unit UnitToken Unit with N eg. 'boss1'
---@field _previewUnit UnitToken
---@field alwaysUpdate boolean

---@class CUFUnitButton.States
---@field unit Unit
---@field displayedUnit Unit
---@field name string
---@field fullName string
---@field class string
---@field guid string?
---@field isPlayer boolean
---@field health number
---@field healthMax number
---@field healthPercent number
---@field healthPercentOld number
---@field totalAbsorbs number
---@field wasDead boolean
---@field isDead boolean
---@field wasDeadOrGhost boolean
---@field isDeadOrGhost boolean
---@field hasSoulstone boolean
---@field inVehicle boolean
---@field role string
---@field powerType number
---@field powerMax number
---@field power number
---@field isLeader boolean
---@field isAssistant boolean
---@field readyCheckStatus ("ready" | "waiting" | "notready")?
---@field isResting boolean
