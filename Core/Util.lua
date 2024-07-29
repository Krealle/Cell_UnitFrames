---@class CUF
local CUF = select(2, ...)

---@class CUF.Util
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

---@param func function
---@param unitToIterate string?
function CUF.Util:IterateAllUnitButtons(func, unitToIterate, ...)
    for _, unit in pairs(CUF.units) do
        if not unitToIterate or unitToIterate == unit then
            func(Cell.unitButtons[unit], unit, ...)
        end
    end
end

---@param fs FontString
---@param text string
---@param widthTable FontWidth
---@param relativeTo Frame
function CUF.Util:UpdateTextWidth(fs, text, widthTable, relativeTo)
    if not text or not widthTable then return end

    if widthTable.type == "unlimited" then
        fs:SetText(text)
    elseif widthTable.type == "percentage" then
        local percent = widthTable.value or 0.75
        local width = relativeTo:GetWidth() - 2
        for i = string.utf8len(text), 0, -1 do
            fs:SetText(string.utf8sub(text, 1, i))
            if fs:GetWidth() / width <= percent then
                break
            end
        end
    elseif widthTable.type == "length" then
        if string.len(text) == string.utf8len(text) then -- en
            fs:SetText(string.utf8sub(text, 1, widthTable.value))
        else                                             -- non-en
            fs:SetText(string.utf8sub(text, 1, widthTable.auxValue))
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

function CUF:Debug(...)
    if not CUF.debug then return end
    print(...)
end

function CUF:DevAdd(data, name)
    if not CUF.debugDB or not DevTool then return end

    DevTool:AddData(data, name)
end
