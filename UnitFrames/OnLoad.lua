---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

---@class CUF.uFuncs
local U = CUF.uFuncs
local I = Cell.iFuncs

local W = CUF.widgets
local const = CUF.constants

local GetUnitName = GetUnitName
local UnitGUID = UnitGUID

local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local ForEachAura = AuraUtil.ForEachAura

-------------------------------------------------
-- MARK: Aura tables
-------------------------------------------------

---@param self CUFUnitButton
local function ResetAuraTables(self)
    wipe(self._auraBuffCache)
    wipe(self._auraDebuffCache)

    if not self:HasWidget(const.WIDGET_KIND.BUFFS) then return end
    wipe(self.widgets.buffs._auraCache)
    wipe(self.widgets.debuffs._auraCache)
end

-------------------------------------------------
-- MARK: Update InRange
-------------------------------------------------

local DEFAULT_HARM_SPELLS = {
    ["WARLOCK"] = 234153, -- Drain Life
    ["EVOKER"] = 361469,  -- Living Flame
}

---@param self CUFUnitButton
---@param ir boolean?
---@param forceUpdate boolean?
local function UnitFrame_UpdateInRange(self, ir, forceUpdate)
    local unit = self.states.displayedUnit
    if not unit then return end

    local inRange = F:IsInRange(unit)

    -- Hack to circumvent override issue with C_Spell.IsSpellInRange and override spells
    if not inRange and UnitCanAttack("player", unit) then
        local overrideSpell = DEFAULT_HARM_SPELLS[UnitClassBase("player")]
        if overrideSpell then
            inRange = C_Spell.IsSpellInRange(overrideSpell, unit) or false
        end
    end

    self.states.inRange = inRange
    if Cell.loaded then
        if self.states.inRange ~= self.states.wasInRange or forceUpdate then
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
-- MARK: Auras
-------------------------------------------------

--- Processes an aura and returns the type of aura
--- Returns None if the aura shoulbe be ignored
---@param aura AuraData
---@param ignoreBuffs boolean
---@param ignoreDebuffs boolean
---@return AuraUtil.AuraUpdateChangedType
local function ProcessAura(aura, ignoreBuffs, ignoreDebuffs)
    if aura == nil then
        return AuraUtil.AuraUpdateChangedType.None;
    end

    if aura.isNameplateOnly then
        return AuraUtil.AuraUpdateChangedType.None;
    end

    if aura.isHarmful and not ignoreDebuffs then
        aura.dispelName = I.CheckDebuffType(aura.dispelName, aura.spellId)
        if aura.dispelName ~= "" then
            return AuraUtil.AuraUpdateChangedType.Dispel
        end

        return AuraUtil.AuraUpdateChangedType.Debuff
    elseif aura.isHelpful and not ignoreBuffs then
        return AuraUtil.AuraUpdateChangedType.Buff
    end

    return AuraUtil.AuraUpdateChangedType.None;
end

--- Perform a full aura update for a unit
---@param self CUFUnitButton
---@param ignoreBuffs boolean
---@param ignoreDebuffs boolean
local function ParseAllAuras(self, ignoreBuffs, ignoreDebuffs)
    wipe(self._auraBuffCache)
    wipe(self._auraDebuffCache)

    local batchCount = nil
    local usePackedAura = true
    ---@param aura AuraData
    local function HandleAura(aura)
        local type = ProcessAura(aura, ignoreBuffs, ignoreDebuffs)
        if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
            self._auraDebuffCache[aura.auraInstanceID] = aura
        elseif type == AuraUtil.AuraUpdateChangedType.Buff then
            self._auraBuffCache[aura.auraInstanceID] = aura
        end
    end

    if not ignoreDebuffs then
        ForEachAura(self.states.unit, AuraUtil.AuraFilters.Harmful, batchCount,
            HandleAura,
            usePackedAura)
    end
    if not ignoreBuffs then
        ForEachAura(self.states.unit, AuraUtil.AuraFilters.Helpful, batchCount,
            HandleAura,
            usePackedAura)
    end
end

--- Process UNIT_AURA events and update aura caches
--- This function is called either on UNIT_AURA event or from UnitFrame_UpdateAll
--- Will only trigger if auras are not ignored
---@param self CUFUnitButton
---@param event "UNIT_AURA"?
---@param unit UnitToken?
---@param unitAuraUpdateInfo UnitAuraUpdateInfo?
local function UpdateAurasInternal(self, event, unit, unitAuraUpdateInfo)
    if self._ignoreBuffs and self._ignoreDebuffs then return end

    local debuffsChanged = false
    local buffsChanged = false
    local dispelsChanged = false
    local fullUpdate = false

    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
        self:ParseAllAuras(self._ignoreBuffs, self._ignoreDebuffs)
        debuffsChanged = true
        buffsChanged = true
        dispelsChanged = true
        fullUpdate = true
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                local type = ProcessAura(aura, self._ignoreBuffs, self._ignoreDebuffs)

                if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
                    self._auraDebuffCache[aura.auraInstanceID] = aura
                    debuffsChanged = true
                    dispelsChanged = type == AuraUtil.AuraUpdateChangedType.Dispel
                elseif type == AuraUtil.AuraUpdateChangedType.Buff then
                    self._auraBuffCache[aura.auraInstanceID] = aura
                    buffsChanged = true
                end
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self._auraDebuffCache[auraInstanceID] ~= nil then
                    local newAura = GetAuraDataByAuraInstanceID(self.states.unit, auraInstanceID) --[[@as AuraData]]
                    newAura.dispelName = I.CheckDebuffType(newAura.dispelName, newAura.spellId)
                    self._auraDebuffCache[auraInstanceID] = newAura
                    debuffsChanged = true
                    dispelsChanged = newAura.dispelName ~= nil
                elseif self._auraBuffCache[auraInstanceID] ~= nil then
                    local newAura = GetAuraDataByAuraInstanceID(self.states.unit, auraInstanceID)
                    self._auraBuffCache[auraInstanceID] = newAura
                    buffsChanged = true
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self._auraDebuffCache[auraInstanceID] ~= nil then
                    dispelsChanged = self._auraDebuffCache[auraInstanceID].dispelName ~= nil
                    self._auraDebuffCache[auraInstanceID] = nil
                    debuffsChanged = true
                elseif self._auraBuffCache[auraInstanceID] ~= nil then
                    self._auraBuffCache[auraInstanceID] = nil
                    buffsChanged = true
                end
            end
        end
    end

    self:TriggerAuraCallbacks(buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
end

--- Queues an aura update
--- Used to prevent aura update spam
--- Mostly relevant when full updating widgets since they will all ask for aura update
---@param self CUFUnitButton
local function QueueAuraUpdate(self)
    if not self:IsVisible() then return end
    if self._ignoreBuffs and self._ignoreDebuffs then return end
    self._auraUpdateRequired = true
end

--- Triggers aura callbacks
---@param self CUFUnitButton
---@param buffsChanged boolean
---@param debuffsChanged boolean
---@param dispelsChanged boolean
---@param fullUpdate boolean
local function TriggerAuraCallbacks(self, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
    --CUF:Log("TriggerAuraCallbacks", self.states.unit, buffsChanged, debuffsChanged, fullUpdate)
    if not buffsChanged and not debuffsChanged and not fullUpdate then
        return
    end

    if buffsChanged then
        for _, callback in pairs(self._auraBuffCallbacks) do
            callback(self, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
        end
    end
    if debuffsChanged then
        for _, callback in pairs(self._auraDebuffCallbacks) do
            callback(self, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
        end
    end
end

--- Iterates over all auras of a specific type
---@param self CUFUnitButton
---@param type "buffs" | "debuffs"
---@param fn fun(aura: AuraData, ...)
local function IterateAuras(self, type, fn, ...)
    if type == "buffs" then
        for _, aura in pairs(self._auraBuffCache) do
            fn(aura, ...)
        end
    elseif type == "debuffs" then
        for _, aura in pairs(self._auraDebuffCache) do
            fn(aura, ...)
        end
    end
end

--- Registers a callback for auras of a specific type
--- This function will automatically add UNIT_AURA event listener if it is not already added
---@param self CUFUnitButton
---@param type "buffs" | "debuffs"
---@param callback UnitAuraCallbackFn
local function RegisterAuraCallback(self, type, callback)
    local listenerActive = #self._auraBuffCallbacks > 0 or #self._auraDebuffCallbacks > 0
    if not listenerActive then
        self:AddEventListener("UNIT_AURA", self.UpdateAurasInternal)
    end

    if type == "buffs" then
        tinsert(self._auraBuffCallbacks, callback)
        self._ignoreBuffs = false
    elseif type == "debuffs" then
        tinsert(self._auraDebuffCallbacks, callback)
        self._ignoreDebuffs = false
    end

    self:UpdateAurasInternal()
end

--- Unregisters a callback for auras of a specific type
--- This function will automatically remove UNIT_AURA event listener if no more callbacks are registered
---@param self CUFUnitButton
---@param type "buffs" | "debuffs"
---@param callback function
local function UnregisterAuraCallback(self, type, callback)
    if type == "buffs" then
        if #self._auraBuffCallbacks == 1 then
            wipe(self._auraBuffCallbacks)
        else
            for i, cb in ipairs(self._auraBuffCallbacks) do
                if cb == callback then
                    tremove(self._auraBuffCallbacks, i)
                    break
                end
            end
        end
    elseif type == "debuffs" then
        if #self._auraDebuffCallbacks == 1 then
            wipe(self._auraDebuffCallbacks)
        else
            for i, cb in ipairs(self._auraDebuffCallbacks) do
                if cb == callback then
                    tremove(self._auraDebuffCallbacks, i)
                    break
                end
            end
        end
    end

    self._ignoreBuffs = #self._auraBuffCallbacks == 0
    self._ignoreDebuffs = #self._auraDebuffCallbacks == 0

    if self._ignoreBuffs then
        wipe(self._auraBuffCache)
    end
    if self._ignoreDebuffs then
        wipe(self._auraDebuffCache)
    end

    -- If no more callbacks are registered, remove the event listener
    if self._ignoreBuffs and self._ignoreDebuffs then
        self:RemoveEventListener("UNIT_AURA", self.UpdateAurasInternal)
    end
end

-------------------------------------------------
-- MARK: Update All
-------------------------------------------------

---@param button CUFUnitButton
local function UnitFrame_UpdateAll(button)
    if not button:IsVisible() then return end

    U:UnitFrame_UpdateHealthColor(button)
    --UnitFrame_UpdateTarget(self)
    UnitFrame_UpdateInRange(button)

    button:UpdateWidgets()
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

    if self.states.unit == const.UNIT.TARGET then
        self:AddEventListener("PLAYER_TARGET_CHANGED", UnitFrame_UpdateAll, true)
    end
    if self.states.unit == const.UNIT.FOCUS then
        self:AddEventListener("PLAYER_FOCUS_CHANGED", UnitFrame_UpdateAll, true)
    end
    if self.states.unit == const.UNIT.PET then
        self:AddEventListener("UNIT_PET", function(button, event, unit)
            if unit ~= const.UNIT.PLAYER then return end
            UnitFrame_UpdateAll(button)
        end, true)
    end

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

    if self._auraUpdateRequired then
        self._auraUpdateRequired = nil
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
        --CUF:Print(event, self:GetName(), unit, handlers and #handlers)

        if not handlers then
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
        widget._isEnabled = false
        if not widget:Disable() then
            widget:Hide()
        end
    end

    ---@param widget Widget
    function button:ShouldEnableWidget(widget)
        return self:IsVisible()
            and self.states.unit
            and widget.enabled
            and not widget._isEnabled
    end

    button.UpdateInRange = UnitFrame_UpdateInRange

    -- Auras

    button.IterateAuras = IterateAuras
    button.ParseAllAuras = ParseAllAuras
    button.QueueAuraUpdate = QueueAuraUpdate
    button.UpdateAurasInternal = UpdateAurasInternal
    button.TriggerAuraCallbacks = TriggerAuraCallbacks
    button.RegisterAuraCallback = RegisterAuraCallback
    button.UnregisterAuraCallback = UnregisterAuraCallback

    button._auraBuffCache = {}
    button._auraDebuffCache = {}
    button._auraBuffCallbacks = {}
    button._auraDebuffCallbacks = {}

    button._ignoreBuffs = true
    button._ignoreDebuffs = true

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
---@alias UnitAuraCallbackFn fun(self: CUFUnitButton, buffsChanged: boolean, debuffsChanged: boolean, dispelsChanged: boolean, fullUpdate: boolean)
