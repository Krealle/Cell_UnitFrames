---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.Util
local Util = CUF.Util

-------------------------------------------------
-- MARK: Prop Hunting
-------------------------------------------------

---@param frame Frame
---@param name string
---@return Frame|CellUnknowFrame? child
function Util.findChildByName(frame, name)
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
function Util.findChildByProp(frame, prop)
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
---@param propsToIgnore? table<string, boolean>
function Util:AddMissingProps(tableA, tableB, propsToIgnore)
    if type(tableA) ~= "table" or type(tableB) ~= "table" then return end
    propsToIgnore = propsToIgnore or {}

    for key, bVal in pairs(tableB) do
        if tableA[key] == nil then
            tableA[key] = bVal
        elseif type(tableA[key]) ~= type(bVal) then
            tableA[key] = bVal
        elseif type(bVal) == "table" and not propsToIgnore[key] then
            self:AddMissingProps(tableA[key], bVal, propsToIgnore)
        end
    end
end

---@param table table
---@param oldKey string
---@param newKey string
function Util:RenameProp(table, oldKey, newKey)
    if type(table) ~= "table" then return end

    for curKey, entry in pairs(table) do
        if type(entry) == "table" then
            self:RenameProp(entry, oldKey, newKey)
        elseif curKey == oldKey then
            table[newKey] = entry
            table[oldKey] = nil
        end
    end
end

-------------------------------------------------
-- MARK: IterateAllUnitButtons
-------------------------------------------------

---@param func function
---@param unitToIterate string?
function Util:IterateAllUnitButtons(func, unitToIterate, ...)
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
---@param text string?
---@param widthTable FontWidthOpt
---@param relativeTo Frame
function Util.UpdateTextWidth(fs, text, widthTable, relativeTo)
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
function Util:GetFontItems()
    local items, fonts, defaultFontName, defaultFont = F:GetFontItems()

    local newItems = {}
    for idx, item in pairs(items) do
        newItems[idx] = item.text
    end

    return newItems
end

-- Convert a value to a boolean
---@param value any
---@return boolean
function Util:ToBool(value)
    if value == nil or type(value) ~= "boolean" then return false end
    return value
end

-- Convert a value to a number
---@param value any
---@return number
function Util:ToNumber(value)
    if value == nil or type(value) ~= "number" then return 0 end
    return value
end

-- Convert a value to a string
---@param value any
---@return string
function Util:ToString(value)
    if value == nil or type(value) ~= "string" then
        if type(value) == "number" then return tostring(value) end
        return ""
    end

    return value
end

-- Returns rgb values for a unit's power color
--
-- Doesn't return type prop from F:GetPowerColor
---@param unit Unit
---@return number, number, number
function Util:GetPowerColor(unit)
    local r, g, b, type = F:GetPowerColor(unit)

    return r, g, b
end

---@param unit UnitToken
---@param class? string
---@param guid? string
---@return number, number, number
function Util:GetUnitClassColor(unit, class, guid)
    class = class or select(2, UnitClass(unit))
    guid = guid or UnitGUID(unit)

    -- Player
    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
        return F:GetClassColor(class)
    end

    local selectionType = UnitSelectionType(unit)

    -- Friendly
    if selectionType == 3 then
        return unpack(CUF.constants.COLORS.FRIENDLY)
    end

    -- Hostile
    if selectionType == 0 then
        return unpack(CUF.constants.COLORS.HOSTILE)
    end

    -- Pet
    if selectionType == 4 then
        if UnitIsEnemy(unit, "player") then
            return unpack(CUF.constants.COLORS.HOSTILE)
        end

        return unpack(CUF.constants.COLORS.FRIENDLY)
    end

    -- Neutral
    return unpack(CUF.constants.COLORS.NEUTRAL)
end

--- Converts a dictionary table to an array eg.
---
--- { ["key"] = "value", ["key2"] = "value2" }
---
--- becomes { "value", "value2" }
---@param dictionary table
---@return table array
function Util:DictionaryToArray(dictionary)
    local array = {}
    for _, value in pairs(dictionary) do
        table.insert(array, value)
    end
    return array
end

-------------------------------------------------
-- MARK: Frames
-------------------------------------------------

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
---@return CellButton
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
        local label = editBox:CreateFontString(nil, "OVERLAY", CUF.constants.FONTS.CELL_WIGET)
        label:SetText(text)
        label:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 0, 2)
    end

    return editBox
end

---@param frame Frame
---@param anchor "ANCHOR_TOP" | "ANCHOR_BOTTOM" | "ANCHOR_LEFT" | "ANCHOR_RIGHT" | "ANCHOR_TOPLEFT" | "ANCHOR_TOPRIGHT" | "ANCHOR_BOTTOMLEFT" | "ANCHOR_BOTTOMRIGHT" | "ANCHOR_CURSOR"
---@param x number
---@param y number
---@param ... any
function CUF:SetTooltips(frame, anchor, x, y, ...)
    Cell:SetTooltips(frame, anchor, x, y, ...)
end

---@param frame Frame
function CUF:ClearTooltips(frame)
    Cell:ClearTooltips(frame)
end

---@param icon Texture
---@param zoomLevel number
function Util.SetIconZoom(icon, zoomLevel)
    zoomLevel = math.max(0, math.min(zoomLevel, 100))

    local scale = 1 - (zoomLevel / 100) -- scale ranges from 1 (no zoom) to 0 (full zoom)
    -- Calculate offset to center the zoomed portion
    local offset = (1 - scale) / 2

    icon:SetTexCoord(offset, offset + scale, offset, offset + scale)
end

-------------------------------------------------
-- MARK: Formatting
-------------------------------------------------

-- Function to capitalize the first letter to a series of strings
---@param ... string
---@return string
function Util:ToTitleCase(...)
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
function Util:trim(string)
    return string:match '^()%s*$' and '' or string:match '^%s*(.*%S)'
end

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

function CUF:Print(...)
    print("|cffffa500[CUF]|r", ...)
end

function CUF:Warn(...)
    CUF:Print("|cFFFF3030[WARN]|r", ...)
end

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
