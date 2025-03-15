---@class CUF
local CUF = select(2, ...)

---@class CUF.Mixin
local Mixin = CUF.Mixin

---@class CUFUnitButton
local EventMixin = {}
Mixin.EventMixin = EventMixin

---@class EventMixin.EventHandler
---@field callback EventCallbackFn
---@field unitLess boolean

---@alias EventCallbackFn fun(self: CUFUnitButton, event: WowEvent, unit: UnitToken, ...: any)

---@type table<WowEvent, EventMixin.EventHandler[]>
EventMixin.eventHandlers = {}

local brokenUnitMap = CUF.constants.BROKEN_UNIT_MAP

--- Handles the event dispatching for a button with registered event listeners.
--- Filters events based on whether they are unit-specific or unit-less.
---@param event WowEvent
---@param unit UnitToken
---@param ... any
function EventMixin:_OnEvent(event, unit, ...)
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
        if not handler then return end

        -- WORKAROUND https://github.com/Stanzilla/WoWUIBugs/issues/708
        -- The game fires events for arenaX when it actually should be sending for boss(X+5)
        if brokenUnitMap[unit] == self._unit and not UnitExists(unit) then
            unit = brokenUnitMap[unit]
        end

        -- Perform unit filtering before calling the callback:
        -- Centralizing this logic here is more efficient than repeating it in every callback.
        -- This avoids redundant evaluations and unnecessary function calls.
        if handler.unitLess or unit == self.states.unit then
            handler.callback(self, event, unit, ...)
        end
    end
end

-- Simple cache for unit-less events, to prevent trying to register them multiple times.
local unitLessEvents = {}

--- Register an event listener for the button.
---@param event WowEvent
---@param callback EventCallbackFn
---@param unitLess boolean? Indicates if the callback should ignore unit filtering
function EventMixin:AddEventListener(event, callback, unitLess)
    if not self.eventHandlers[event] then
        self.eventHandlers[event] = {}

        unitLess = unitLess or unitLessEvents[event]
        if unitLess then
            self:RegisterEvent(event)
        else
            -- WORKAROUND https://github.com/Stanzilla/WoWUIBugs/issues/708
            -- The game fires events for arenaX when it actually should be sending for boss(X+5)
            local unit = self._unit
            if brokenUnitMap[unit] and not UnitExists(unit) then
                unit = brokenUnitMap[unit]
            end
            -- In case we try to register a non-unit event we need to catch the error
            if not pcall(self.RegisterUnitEvent, self, event, unit) then
                CUF:Log("Failed to RegisterUnitEvent:", event, "for:", unit)

                unitLessEvents[event] = true

                self:RegisterEvent(event)
            end
        end
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

    table.insert(self.eventHandlers[event], { callback = callback, unitLess = unitLess })
end

--- Remove an event listener for the button.
--- Unregister the event if no listeners remain.
---@param event WowEvent
---@param callback EventCallbackFn
function EventMixin:RemoveEventListener(event, callback)
    local handlers = self.eventHandlers[event]
    if not handlers then return end

    for i = 1, #handlers do
        local handler = handlers[i]
        if handler.callback == callback then
            table.remove(handlers, i)
            break
        end
    end

    -- Unregister the event if there are no more handlers left.
    if #handlers == 0 then
        self:UnregisterEvent(event)
        self.eventHandlers[event] = nil
    end
end
