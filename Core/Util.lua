---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.Util
CUF.Util = {}

---@param frame Frame
---@param name string
---@return Frame|CellUnknowFrame? child
function CUF.Util.findChildByName(frame, name)
    for _, child in pairs({ frame:GetChildren() }) do
        ---@cast child CellUnknowFrame
        local childName = child:GetName() or (child.title and child.title:GetText()) or ""

        if childName == name then
            return child
        end
    end
end

---@param frame Frame
---@param prop string
---@return Frame|CellUnknowFrame? child
function CUF.Util.findChildByProp(frame, prop)
    for _, child in pairs({ frame:GetChildren() }) do
        ---@cast child CellUnknowFrame
        if child[prop] then
            return child
        end
    end
end

---@param tableA table
---@param tableB table
---@param overwrite boolean
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

---@param tableA table
---@param tableB table
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
    for _, unit in pairs(CUF.vars.units) do
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

-- Function to capitalize the first letter to a series of strings
---@param ... string
---@return string
function CUF.Util:ToTitleCase(...)
    local args = { ... }
    local function capitalizeFirst(word)
        return word:gsub("^%l", string.upper)
    end

    for i, str in ipairs(args) do
        args[i] = capitalizeFirst(str)
    end

    return table.concat(args)
end

-- Returns a table of all fonts.
---@return string[]
function CUF.Util:GetFontItems()
    local items, fonts, defaultFontName, defaultFont = F:GetFontItems()

    local newItems = {}
    for idx, item in pairs(items) do
        newItems[idx] = item.text
    end

    return newItems
end

-- Callbacks
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

local function GetFormattedTimestamp()
    local time = date("*t")
    local millisec = math.floor(GetTime() * 1000) % 1000
    return string.format("[%02d:%02d:%02d:%03d]", time.hour, time.min, time.sec, millisec)
end

---@param ... any
function CUF:Debug(...)
    if not CUF.debug then return end
    print(GetFormattedTimestamp(), "|cffffa500[CUF]|r", ...)
end

---@param data any
---@param name string|number
function CUF:DevAdd(data, name)
    if not CUF.debugDB or not DevTool then return end

    DevTool:AddData(data, name)
end
