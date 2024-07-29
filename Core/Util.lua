---@class CUF
local CUF = select(2, ...)
CUF.Util = {}

function CUF.Util.findChildByName(frame, name)
    for _, child in pairs({ frame:GetChildren() }) do
        local childName = child:GetName() or (child.title and child.title:GetText()) or ""

        if childName == name then
            return child
        end
    end
end

function CUF.Util.findChildByProp(frame, prop)
    for _, child in pairs({ frame:GetChildren() }) do
        if child[prop] then
            return child
        end
    end
end

function CUF.Util:SafeTableMerge(tableA, tableB, overwrite)
    if type(tableA) ~= "table" or type(tableB) ~= "table" then return end

    for key, bVal in pairs(tableB) do
        local aVal = tableA[key]

        if not aVal or type(aVal) ~= type(bVal) then
            tableA[key] = bVal
        elseif type(bVal) == "table" then
            if not overwrite then
                self:SafeTableMerge(aVal, bVal, overwrite)
            else
                tableA[key] = bVal
            end
        elseif overwrite then
            tableA[key] = bVal
        end
    end
end

function CUF.Util:AddMissingProps(tableA, tableB)
    if type(tableA) ~= "table" or type(tableB) ~= "table" then return end

    for key, bVal in pairs(tableB) do
        if tableA[key] == nil then
            tableA[key] = bVal
        elseif type(tableA[key]) ~= type(bVal) then
            tableA[key] = bVal
        elseif type(bVal) == "table" then
            self:AddMissingProps(tableA[key], bVal)
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
