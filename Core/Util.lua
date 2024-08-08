---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

local const = CUF.constants

---@class CUF.Util
CUF.Util = {}

-------------------------------------------------
-- MARK: Prop Hunting
-------------------------------------------------

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

-------------------------------------------------
-- MARK: Table Functions
-------------------------------------------------

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

-------------------------------------------------
-- MARK: IterateAllUnitButtons
-------------------------------------------------

---@param func function
---@param unitToIterate string?
function CUF.Util:IterateAllUnitButtons(func, unitToIterate, ...)
    for _, unit in pairs(CUF.constants.UNIT) do
        if not unitToIterate or unitToIterate == unit then
            func(CUF.unitButtons[unit], unit, ...)
        end
    end
end

-------------------------------------------------
-- MARK: Util
-------------------------------------------------

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

---@param name? string
---@param parent Frame
---@param width number
---@param height number
---@param isTransparent? boolean
---@param isShown? boolean
---@param template? string
---@return Frame
function CUF:CreateFrame(name, parent, width, height, isTransparent, isShown, template)
    local f = Cell:CreateFrame(name, parent, width, height, isTransparent, template)
    if isShown then f:Show() end
    return f
end

---@param parent Frame
---@param text string
---@param size { [1]: number, [2]: number }
---@param onClick? function
---@param buttonColor? "red"|"red-hover"|"green"|"green-hover"|"blue"|"blue-hover"|"yellow"|"yellow-hover"|"accent"|"accent-hover"|"chartreuse"|"magenta"|"transparent"|"transparent-white"|"transparent-light"|"transparent-accent"|"none"
---@param noBorder? boolean
---@param noBackground? boolean
---@param fontNormal? string
---@param fontDisable? string
---@param template? Template
---@param ... any
---@return Button
function CUF:CreateButton(parent, text, size, onClick, buttonColor, noBorder, noBackground, fontNormal, fontDisable,
                          template, ...)
    local b = Cell:CreateButton(parent, text, (buttonColor or "accent-hover"), size or 16, noBorder, noBackground,
        fontNormal,
        fontDisable,
        template,
        ...)

    if onClick then
        b:SetScript("OnClick", onClick)
    end

    return b
end

---@param parent Frame
---@param width number
---@param height number
---@param text? string
---@param isTransparent? boolean
---@param isMultiLine? boolean
---@param isNumeric? boolean
---@param font? string
---@return EditBox
function CUF:CreateEditBox(parent, width, height, text, isTransparent, isMultiLine, isNumeric, font)
    local editBox = Cell:CreateEditBox(parent, width, height, isTransparent, isMultiLine, isNumeric, font)

    if text then
        local label = editBox:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
        label:SetText(text)
        label:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 0, 2)
    end

    return editBox
end

-- Returns rgb values for a unit's power color
--
-- Doesn't return type prop from F:GetPowerColor
---@param unit Unit
---@return number, number, number
function CUF.Util:GetPowerColor(unit)
    local r, g, b, type = F:GetPowerColor(unit)

    return r, g, b
end

function CUF:Print(...)
    print("|cffffa500[CUF]|r", ...)
end

function CUF:Warn(...)
    CUF:Print("|cFFFF3030[WARN]|r", ...)
end

-------------------------------------------------
-- MARK: Formatting
-------------------------------------------------

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

local function GetFormattedTimestamp()
    local time = date("*t")
    local millisec = math.floor(GetTime() * 1000) % 1000
    return string.format("[%02d:%02d:%02d:%03d]", time.hour, time.min, time.sec, millisec)
end

-- Trims whitespace from the start and end of a string
--
-- https://snippets.bentasker.co.uk/page-1706031030-Trim-whitespace-from-string-LUA.html
---@param string string
---@return string
function CUF.Util:trim(string)
    return string:match '^()%s*$' and '' or string:match '^%s*(.*%S)'
end

-------------------------------------------------
-- MARK: Callbacks
-------------------------------------------------

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

-------------------------------------------------
-- MARK: Debug
-------------------------------------------------

---@param ... any
function CUF:Log(...)
    if not CUF.IsInDebugMode() then return end
    print(GetFormattedTimestamp(), "|cffffa500[CUF]|r", ...)
end

---@param data any
---@param name string|number
function CUF:DevAdd(data, name)
    if not CUF.IsInDebugMode() or not DevTool then return end

    DevTool:AddData(data, name)
end
