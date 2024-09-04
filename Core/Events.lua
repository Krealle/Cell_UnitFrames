---@class CUF
local CUF = select(2, ...)

-------------------------------------------------
-- MARK: Callbacks
-------------------------------------------------

---@alias Callbacks
---| "UpdateMenu"
---| "UpdateWidget"
---| "LoadPageDB"
---| "UpdateVisibility"
---| "UpdateUnitButtons"
---| "UpdateLayout"
---| "ShowOptionsTab"
---| "UpdatePixelPerfect"
---| "UpdateAppearance"
---| "AddonLoaded"
---| "UpdateClickCasting"
local callbacks = {}

---@param eventName Callbacks
---@param onEventFuncName string
---@param onEventFunc function
function CUF:RegisterCallback(eventName, onEventFuncName, onEventFunc)
    if not callbacks[eventName] then callbacks[eventName] = {} end
    callbacks[eventName][onEventFuncName] = onEventFunc
end

---@param eventName Callbacks
---@param onEventFuncName string
function CUF:UnregisterCallback(eventName, onEventFuncName)
    if not callbacks[eventName] then return end
    callbacks[eventName][onEventFuncName] = nil
end

---@param eventName Callbacks
function CUF:UnregisterAllCallbacks(eventName)
    if not callbacks[eventName] then return end
    callbacks[eventName] = nil
end

---@param eventName Callbacks
---@param ... any
function CUF:Fire(eventName, ...)
    if not callbacks[eventName] then return end

    for onEventFuncName, onEventFunc in pairs(callbacks[eventName]) do
        onEventFunc(...)
    end
end

-- Borrowed from XephCD
---@param event WowEvent
---@param callback fun(ownerId: number, ...: any): boolean
---@return number
function CUF:AddEventListener(event, callback)
    local function wrappedFn(...)
        local unregister = callback(...)

        if unregister then
            local id = select(1, ...)
            EventRegistry:UnregisterFrameEventAndCallback(event, id)
        end
    end

    return EventRegistry:RegisterFrameEventAndCallback(event, wrappedFn)
end
