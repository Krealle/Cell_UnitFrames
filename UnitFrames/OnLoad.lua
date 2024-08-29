---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

---@class CUF.uFuncs
local U = CUF.uFuncs

local W = CUF.widgets
local const = CUF.constants

local GetUnitName = GetUnitName
local UnitGUID = UnitGUID

-------------------------------------------------
-- MARK: Aura tables
-------------------------------------------------

---@param self CUFUnitButton
local function ResetAuraTables(self)
    if not self:HasWidget(const.WIDGET_KIND.BUFFS) then return end
    wipe(self.widgets.buffs._auraCache)
    wipe(self.widgets.debuffs._auraCache)
end

-------------------------------------------------
-- MARK: Update InRange
-------------------------------------------------

---@param self CUFUnitButton
---@param ir boolean?
local function UnitFrame_UpdateInRange(self, ir)
    local unit = self.states.displayedUnit
    if not unit then return end

    local inRange = F:IsInRange(unit)

    self.states.inRange = inRange
    if Cell.loaded then
        if self.states.inRange ~= self.states.wasInRange then
            if inRange then
                if CELL_FADE_OUT_HEALTH_PERCENT then
                    if not self.states.healthPercent or self.states.healthPercent < CELL_FADE_OUT_HEALTH_PERCENT then
                        A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                    else
                        A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB.appearance.outOfRangeAlpha)
                    end
                else
                    A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                end
            else
                A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB.appearance.outOfRangeAlpha)
            end
        end
        self.states.wasInRange = inRange
    end
end

-------------------------------------------------
-- MARK: Update All
-------------------------------------------------

---@param button CUFUnitButton
local function UnitFrame_UpdateAll(button)
    if not button:IsVisible() then return end

    U:UnitFrame_UpdateHealthMax(button)
    U:UnitFrame_UpdateHealth(button)
    U:UnitFrame_UpdateHealthColor(button)
    --UnitFrame_UpdateTarget(self)
    UnitFrame_UpdateInRange(button)
    U:UnitFrame_UpdateAuras(button)
    U:UnitFrame_UpdateCastBar(button)

    button:UpdateWidgets()
end
U.UpdateAll = UnitFrame_UpdateAll

-------------------------------------------------
-- MARK: Helpers
-------------------------------------------------

---@param button CUFUnitButton
local function UnitFrame_ShouldShowAuras(button)
    if not button:HasWidget(const.WIDGET_KIND.BUFFS) then return end
    return button.widgets.buffs.enabled or button.widgets.debuffs.enabled
end

-- Register/Unregister UNIT_AURA event
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleAuras(button, show)
    if not button:IsShown() then return end
    if UnitFrame_ShouldShowAuras(button) or show then
        button:RegisterEvent("UNIT_AURA")
    else
        button:UnregisterEvent("UNIT_AURA")
    end
end

-------------------------------------------------
-- MARK: RegisterEvents
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_RegisterEvents(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")

    --self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    --self:RegisterEvent("UNIT_HEAL_PREDICTION")
    --self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

    --self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    --self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    --self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    --self:RegisterEvent("UNIT_EXITED_VEHICLE")

    self:RegisterEvent("UNIT_CONNECTION")  -- offline
    --self:RegisterEvent("PLAYER_FLAGS_CHANGED")  -- afk
    self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
    --self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

    if self.states.unit == const.UNIT.TARGET then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
    if self.states.unit == const.UNIT.FOCUS then
        self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end
    if self.states.unit == const.UNIT.PET then
        self:RegisterEvent("UNIT_PET")
    end
    U:ToggleAuras(self)
    U:ToggleCastEvents(self)

    self:RegisterEvent("UNIT_NAME_UPDATE")

    local success, result = pcall(UnitFrame_UpdateAll, self)
    if not success then
        F:Debug("UnitFrame_UpdateAll |cffff0000FAILED:|r", self:GetName(), result)
    end
end

-------------------------------------------------
-- MARK: UnregisterEvents
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

-------------------------------------------------
-- MARK: OnEvents
-------------------------------------------------

---@param self CUFUnitButton
---@param event WowEvent
---@param unit string
---@param ... any
local function UnitFrame_OnEvent(self, event, unit, ...)
    self:_OnEvent(event, unit, ...)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if event == "UNIT_AURA" then
            U:UnitFrame_UpdateAuras(self, ...)
        elseif event == "UNIT_HEALTH" then
            U:UnitFrame_UpdateHealth(self)
        elseif event == "UNIT_MAXHEALTH" then
            U:UnitFrame_UpdateHealthMax(self)
            U:UnitFrame_UpdateHealth(self)
        elseif event == "UNIT_CONNECTION" then
            self._updateRequired = true
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            UnitFrame_UpdateInRange(self, ...)
        elseif event == "UNIT_SPELLCAST_START"
            or event == "UNIT_SPELLCAST_CHANNEL_START"
            or event == "UNIT_SPELLCAST_EMPOWER_START" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastStart(self, event, unit, ...)
        elseif event == "UNIT_SPELLCAST_STOP"
            or event == "UNIT_SPELLCAST_CHANNEL_STOP"
            or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastStop(self, event, unit, ...)
        elseif event == "UNIT_SPELLCAST_DELAYED"
            or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
            or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastUpdate(self, event, unit, ...)
        elseif event == "UNIT_SPELLCAST_FAILED"
            or event == "UNIT_SPELLCAST_INTERRUPTED" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastFail(self, event, unit, ...)
        end
    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = true
        elseif event == "PLAYER_TARGET_CHANGED" then
            --[[  UnitButton_UpdateTarget(self)
            UnitButton_UpdateThreatBar(self) ]]
            UnitFrame_UpdateAll(self)
        elseif event == "PLAYER_FOCUS_CHANGED" then
            UnitFrame_UpdateAll(self)
        elseif event == "UNIT_PET" and unit == const.UNIT.PLAYER then
            UnitFrame_UpdateAll(self)
        end
    end
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
    ResetAuraTables(self)

    -- NOTE: update Cell.vars.guids
    -- CUF:Log("hide", self.states.unit, self.__unitGuid, self.__unitName)
    if self.__unitGuid then
        Cell.vars.guids[self.__unitGuid] = nil
        self.__unitGuid = nil
    end
    if self.__unitName then
        Cell.vars.names[self.__unitName] = nil
        self.__unitName = nil
    end
    self.__displayedGuid = nil
    F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")

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

    F:ShowTooltips(self, "unit", unit)
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
                F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                self._updateRequired = true
                self._powerBarUpdateRequired = true
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- CUF:Log("guidChanged:", self:GetName(), self.states.unit, guid)
                -- NOTE: unit entity changed
                -- update Cell.vars.guids
                self.__unitGuid = guid
                Cell.vars.guids[guid] = self.states.unit

                -- NOTE: only save players' names
                if UnitIsPlayer(self.states.unit) then
                    -- update Cell.vars.names
                    local name = GetUnitName(self.states.unit, true)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        Cell.vars.names[name] = self.states.unit
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

    UnitFrame_UpdateInRange(self)

    if self._updateRequired then
        self._updateRequired = nil
        UnitFrame_UpdateAll(self)
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
                Cell.vars.guids[self.__unitGuid] = nil
                self.__unitGuid = nil
            end
            if self.__unitName then
                Cell.vars.names[self.__unitName] = nil
                self.__unitName = nil
            end
            wipe(self.states)
        end

        if type(value) == "string" then
            self.states.unit = value
            self.states.displayedUnit = value

            W:AssignWidgets(self, value)
            ResetAuraTables(self)
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
    button:SetBackdrop({
        bgFile = Cell.vars.whiteTexture,
        edgeFile = Cell.vars.whiteTexture,
        edgeSize = P:Scale(
            CELL_BORDER_SIZE)
    })
    button:SetBackdropColor(0, 0, 0, 1)
    button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))

    -- Widgets
    W:CreateHealthBar(button)
    W:CreatePowerBar(button)

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

    ---@type table<WowEvent, CUFUnitButton.EventHandler[]>
    button.eventHandlers = {}

    --- Handles the event dispatching for a button with registered event listeners.
    --- Filters events based on whether they are unit-specific or unit-less.
    ---@param event WowEvent
    ---@param unit UnitToken
    ---@param ... any
    function button:_OnEvent(event, unit, ...)
        local handlers = self.eventHandlers[event]

        if not handlers then
            if event ~= "UNIT_AURA" then
                CUF:Warn("No event handlers registered for event", event, "in", self:GetName())
            end
            return
        end

        -- Using a numeric `for` loop instead of `ipairs` for performance reasons:
        -- 1. `ipairs` has a slight overhead due to its function call in each iteration.
        -- 2. A numeric `for` loop directly accesses elements by their index, which is faster.
        for i = 1, #handlers do
            local handler = handlers[i]

            -- Perform unit filtering before calling the callback:
            -- Centralizing this logic here is more efficient than repeating it in every callback.
            -- This avoids redundant evaluations and unnecessary function calls.
            if handler.unitLess or unit == self.states.unit then
                handler.callback(self, event, unit, ...)
            end
        end
    end

    --- Register an event listener for the button.
    ---@param event WowEvent
    ---@param callback EventCallbackFn
    ---@param unitLess boolean? Indicates if the callback should ignore unit filtering
    function button:AddEventListener(event, callback, unitLess)
        if not self.eventHandlers[event] then
            self.eventHandlers[event] = {}
            self:RegisterEvent(event)
        else
            -- Check if the callback is already registered to prevent duplicates
            for i = 1, #self.eventHandlers[event] do
                local handler = self.eventHandlers[event][i]
                if handler.callback == callback then
                    --CUF:Warn("Callback is already registered for event", event, "in", self:GetName())
                    return
                end
            end
        end

        tinsert(self.eventHandlers[event], { callback = callback, unitLess = unitLess })
    end

    --- Remove an event listener for the button.
    --- Unregisters the event if no listeners remain.
    ---@param event WowEvent
    ---@param callback EventCallbackFn
    function button:RemoveEventListener(event, callback)
        local handlers = self.eventHandlers[event]
        if not handlers then return end

        for i = 1, #handlers do
            local handler = handlers[i]
            if handler.callback == callback then
                tremove(handlers, i)
                break
            end
        end

        -- Unregister the event if there are no more handlers left.
        if #handlers == 0 then
            self:UnregisterEvent(event)
            self.eventHandlers[event] = nil
        end
    end

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

    ---@param widget Widget
    function button:EnableWidget(widget)
        if not self:ShouldEnableWidget(widget) then return end
        if widget:Enable() then
            widget._isEnabled = true
        end
    end

    ---@param widget Widget
    function button:DisableWidget(widget)
        widget:Disable()
        widget._isEnabled = false
        widget:Hide()
    end

    ---@param widget Widget
    function button:ShouldEnableWidget(widget)
        return self:IsVisible()
            and self.states.unit
            and widget.enabled
            and not widget._isEnabled
    end

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
---@field inRange boolean
---@field wasInRange boolean
---@field isLeader boolean
---@field isAssistant boolean
---@field readyCheckStatus ("ready" | "waiting" | "notready")?
---@field isResting boolean

---@class CUFUnitButton.EventHandler
---@field callback EventCallbackFn
---@field unitLess boolean

---@alias EventCallbackFn fun(self: CUFUnitButton, event: WowEvent, unit: UnitToken, ...: any)
