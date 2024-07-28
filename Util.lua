---@class CUF
local CUF = select(2, ...)

function CUF.findChildByName(frame, name)
    for _, child in pairs({ frame:GetChildren() }) do
        local childName = child:GetName() or (child.title and child.title:GetText()) or ""

        if childName == name then
            return child
        end
    end
end

function CUF.findChildByProp(frame, prop)
    for _, child in pairs({ frame:GetChildren() }) do
        if child[prop] then
            return child
        end
    end
end

-- Callbacks
local callbacks = {}

function CUF:RegisterCallback(eventName, onEventFuncName, onEventFunc)
    if not callbacks[eventName] then callbacks[eventName] = {} end
    callbacks[eventName][onEventFuncName] = onEventFunc
end

function CUF:UnregisterCallback(eventName, onEventFuncName)
    if not callbacks[eventName] then return end
    callbacks[eventName][onEventFuncName] = nil
end

function CUF:UnregisterAllCallbacks(eventName)
    if not callbacks[eventName] then return end
    callbacks[eventName] = nil
end

function CUF:Fire(eventName, ...)
    if not callbacks[eventName] then return end

    for onEventFuncName, onEventFunc in pairs(callbacks[eventName]) do
        onEventFunc(...)
    end
end
