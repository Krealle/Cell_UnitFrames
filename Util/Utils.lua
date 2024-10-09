---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local DB = CUF.DB
local L = CUF.L

---@class CUF.Util
local Util = CUF.Util

local const = CUF.constants

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

        if childName == name or childName == L[name] then
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
        if child[prop] or child[L[prop]] then
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
            tableA[key] = Util:CopyDeep(bVal)
        elseif type(tableA[key]) ~= type(bVal) then
            tableA[key] = Util:CopyDeep(bVal)
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

---@param table table
---@param seen table?
---@return table
function Util:CopyDeep(table, seen)
    -- Handle non-tables and previously-seen tables.
    if type(table) ~= 'table' then return table end
    if seen and seen[table] then return seen[table] end

    -- New table; mark it as seen an copy recursively.
    local s = seen or {}
    local res = {}
    s[table] = res
    for k, v in next, table do res[self:CopyDeep(k, s)] = self:CopyDeep(v, s) end
    return setmetatable(res, getmetatable(table))
end

--- Check if a table is a valid copy of another table, used for import checks
---
--- This function will check if a table is a valid copy of another table.
--- It will check if the table has the same structure as the template table.
--- @param table table The table to check
--- @param template table The template table to check against
--- @param allowMissing boolean? Whether to allow missing keys
--- @return boolean
function Util:IsValidCopy(table, template, allowMissing)
    if type(table) ~= "table" or type(template) ~= "table" then
        return false
    end

    for k, v in pairs(template) do
        if (not table[k] and not allowMissing)
            or (not self:IsPropSameType(table[k], v)) then
            return false
        end

        if type(v) == "table" then
            if not Util:IsValidCopy(table[k], v, allowMissing) then
                return false
            end
        end
    end

    -- TODO: Maybe check if table has keys not present in template?
    -- right now that is dealt with in SafeImport so for now w/e

    return true
end

--- Safely perform an import
---
--- This does not overwrite the current table.
--- It instead iterates over the imported table and copies the valid props to the current table.
---@param imported table
---@param current table
function Util:SafeImport(imported, current)
    for k, v in pairs(imported) do
        if current[k] and self:IsPropSameType(current[k], v) then
            current[k] = self:CopyDeep(v)
        end
    end
end

-------------------------------------------------
-- MARK: IterateAllUnitButtons
-------------------------------------------------

---@param func fun(button: CUFUnitButton, unit: string, ...)
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
        return unpack(DB.GetColors().reaction.friendly)
    end

    -- Hostile
    if selectionType == 0 then
        return unpack(DB.GetColors().reaction.hostile)
    end

    -- Pet
    if selectionType == 4 then
        if UnitIsEnemy(unit, "player") then
            return unpack(DB.GetColors().reaction.hostile)
        end

        if unit == "pet" and DB.GetColors().reaction.useClassColorForPet then
            return F:GetClassColor(select(2, UnitClass("player")))
        end

        return unpack(DB.GetColors().reaction.pet)
    end

    -- Neutral
    return unpack(DB.GetColors().reaction.neutral)
end

--- Converts a dictionary table to an array eg.
---
--- { ["key"] = "value", ["key2"] = "value2" }
---
--- becomes { "value", "value2" }
---@param dictionary table
---@return table array
function Util.DictionaryToArray(dictionary)
    local array = {}
    for _, value in pairs(dictionary) do
        table.insert(array, value)
    end
    return array
end

---@return string[]
function Util:GetAllLayoutNames()
    local layoutNames = {}
    for layoutName, _ in pairs(CellDB.layouts) do
        tinsert(layoutNames, layoutName)
    end

    return layoutNames
end

---@param formatted boolean?
---@return string
function Util:GetAllLayoutNamesAsString(formatted)
    local layoutNames = {}

    for layoutName, _ in pairs(CellDB.layouts) do
        tinsert(layoutNames, Util:FormatLayoutName(layoutName, formatted))
    end

    return table.concat(layoutNames, ", ")
end

--- Check if two values have the same type
---@param a any
---@param b any
---@return boolean
function Util:IsPropSameType(a, b)
    return type(a) == type(b)
end

---@param unit Unit
function Util:ButtonIsAnchoredToParent(unit)
    return DB.CurrentLayoutTable()[unit].anchorToParent
end

---@param unit Unit
function Util:ButtonIsMirrored(unit)
    return DB.CurrentLayoutTable()[unit].mirrorPlayer
end

-------------------------------------------------
-- MARK: Unit Info
-------------------------------------------------

---@param unit UnitToken
---@return string name
---@return string? nameWithServer
function Util:GetUnitName(unit)
    local name, server = UnitName(unit)

    local nameWithServer
    if server and server ~= "" then
        nameWithServer = name .. "-" .. server
    end

    return name, nameWithServer
end

---@param unit UnitToken
---@return number? subgroup
function Util:GetUnitSubgroup(unit)
    local name, nameWithServer = self:GetUnitName(unit)
    for i = 1, GetNumGroupMembers() do
        local rName, rank, subgroup = GetRaidRosterInfo(i)
        if rName == name or rName == nameWithServer then
            return subgroup
        end
    end
end

local classifications = {
    rare = L["Rare"],
    rareelite = L["Rare Elite"],
    elite = L["Elite"],
    worldboss = L["Boss"],
    --minus = L["Affix"],
    --trivial = L["Trivial"],
}
function Util:GetUnitClassification(unit, localized)
    local classification = UnitClassification(unit)
    if localized then
        return classifications[classification]
    end
    return classification
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

---@param parent Frame
---@param width number
---@param text string
---@param onAccept function?
---@param onReject function?
---@param mask boolean?
---@param hasEditBox boolean?
---@param dropdowns boolean?
function CUF:CreateConfirmPopup(parent, width, text, onAccept, onReject, mask, hasEditBox, dropdowns)
    return Cell:CreateConfirmPopup(parent, width, text, onAccept, onReject, mask, hasEditBox, dropdowns)
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
-- MARK: Pixel Perfect
-------------------------------------------------

---@return number
function Util.GetPixelScale()
    local width, height = GetPhysicalScreenSize()
    if height then
        return 768 / height
    else
        return 1
    end
end

---@param frame Frame
function Util.SetPixelScale(frame)
    frame:SetScale(Util.GetPixelScale())
end

--- Calculates the nearest pixel size of a number
---@param number number
---@return number
function Util.GetNearestPixelSize(number)
    return PixelUtil.GetNearestPixelSize(number, 1)
end

--- Calculates the relative position of a frame to the center of the UIParent
---@param frame Frame
---@return number, number
function Util.GetPositionRelativeToScreenCenter(frame)
    local frameX, frameY = frame:GetCenter()
    local width, height = GetPhysicalScreenSize()

    local relativeX = Util.GetNearestPixelSize(frameX - (width / 2))
    local relativeY = Util.GetNearestPixelSize(frameY - (height / 2))

    return relativeX, relativeY
end

-------------------------------------------------
-- MARK: Glow
-------------------------------------------------

local LCG = LibStub("LibCustomGlow-1.0")
---@class GlowFrame: Frame
---@field __glowing string?

---@param frame GlowFrame|CellAuraIcon
---@param color RGBAOpt?
---@param N number?
---@param frequency number?
---@param length number?
---@param thickness number?
---@param xOffset number?
---@param yOffset number?
---@param border boolean?
---@param key string?
---@param frameLevel number?
function Util.GlowStart_Pixel(frame, color, N, frequency, length, thickness, xOffset, yOffset, border, key, frameLevel)
    if frame.__glowing ~= "Pixel" then
        Util.GlowStop(frame, key)
    end

    LCG.PixelGlow_Start(frame, color, N, frequency, length, thickness, xOffset, yOffset, border, key, frameLevel)
    frame.__glowing = "Pixel"
end

---@param frame GlowFrame|CellAuraIcon
---@param color RGBAOpt?
---@param N number?
---@param frequency number?
---@param scale number?
---@param xOffset number?
---@param yOffset number?
---@param key string?
---@param frameLevel number?
function Util.GlowStart_Shine(frame, color, N, frequency, scale, xOffset, yOffset, key, frameLevel)
    if frame.__glowing ~= "Shine" then
        Util.GlowStop(frame, key)
    end

    LCG.AutoCastGlow_Start(frame, color, N, frequency, scale, xOffset, yOffset, key, frameLevel)
    frame.__glowing = "Shine"
end

---@param frame GlowFrame|CellAuraIcon
---@param color RGBAOpt?
---@param duration number?
---@param startAnim boolean?
---@param xOffset number?
---@param yOffset number?
---@param key string?
---@param frameLevel number?
function Util.GlowStart_Proc(frame, color, duration, startAnim, xOffset, yOffset, key, frameLevel)
    if frame.__glowing ~= "Proc" then
        Util.GlowStop(frame, key)
    end

    LCG.ProcGlow_Start(frame, color, duration, startAnim, xOffset, yOffset, key, frameLevel)
    frame.__glowing = "Proc"
end

---@param frame GlowFrame|CellAuraIcon
---@param color RGBAOpt?
---@param frequency number?
---@param frameLevel number?
function Util.GlowStart_Normal(frame, color, frequency, frameLevel)
    if frame.__glowing ~= "Normal" then
        Util.GlowStop(frame)
    end

    LCG.ButtonGlow_Start(frame, color, frequency, frameLevel)
    frame.__glowing = "Normal"
end

---@param frame GlowFrame|CellAuraIcon
---@param key string?
function Util.GlowStop(frame, key)
    if not frame.__glowing then return end

    LCG.ButtonGlow_Stop(frame, key)
    LCG.PixelGlow_Stop(frame, key)
    LCG.AutoCastGlow_Stop(frame, key)
    LCG.ProcGlow_Stop(frame, key)

    frame.__glowing = nil
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

--- Returns a formatted timestamp "15:30:10:350"
---@param showSec boolean?
---@param showMillisec boolean?
---@return string
function Util:GetFormattedTimeStamp(showSec, showMillisec)
    local time = date("*t")

    if showMillisec then
        local millisec = math.floor(GetTime() * 1000) % 1000
        return string.format("%02d:%02d:%02d:%03d", time.hour, time.min, time.sec, millisec)
    end
    if showSec then
        return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
    end

    return string.format("%02d:%02d", time.hour, time.min)
end

--- Returns a formatted date "January 1"
---@return string
function Util:GetFormattedDate()
    local d = C_DateAndTime.GetCurrentCalendarTime()
    local month = CALENDAR_FULLDATE_MONTH_NAMES[d.month]

    if d.monthDay == 0 or month == nil then
        return tostring(date("%b %d"))
    end

    return string.format("%s %d", month, d.monthDay)
end

-- Trims whitespace from the start and end of a string
--
-- https://snippets.bentasker.co.uk/page-1706031030-Trim-whitespace-from-string-LUA.html
---@param string string
---@return string
function Util:trim(string)
    return string:match '^()%s*$' and '' or string:match '^%s*(.*%S)'
end

--- Splits a full name string into the specified format.
--- @param fullName string The full name (e.g., "Lars Erik Olsen Larsen")
--- @param format NameFormat
--- @return string
function Util.FormatName(fullName, format)
    if not fullName then return "Unknown" end

    local nameParts = {}
    for name in fullName:gmatch("%S+") do
        table.insert(nameParts, name)
    end

    if #nameParts == 1 then
        return fullName
    end

    local firstName = nameParts[1] or ""
    local lastName = nameParts[#nameParts] or ""
    if lastName == "" then return fullName end

    if format == CUF.constants.NameFormat.FULL_NAME then
        return fullName
    elseif format == CUF.constants.NameFormat.LAST_NAME then
        return lastName
    elseif format == CUF.constants.NameFormat.FIRST_NAME then
        return firstName
    elseif format == CUF.constants.NameFormat.FIRST_NAME_LAST_INITIAL then
        return string.format("%s %s.", firstName, lastName:sub(1, 1))
    elseif format == CUF.constants.NameFormat.FIRST_INITIAL_LAST_NAME then
        return string.format("%s. %s", firstName:sub(1, 1), lastName)
    end

    return fullName
end

--- Replaces "default" with _G.DEFAULT
---@param layoutName string
---@param color boolean? whether to color the name gold
---@return string
function Util:FormatLayoutName(layoutName, color)
    ---@diagnostic disable-next-line: undefined-field
    local normalizedLayoutName = layoutName == "default" and _G.DEFAULT or layoutName
    if color then
        return "|cFFFFD700" .. normalizedLayoutName .. "|r"
    end

    return normalizedLayoutName
end

--- Formats a duration in seconds to a string
---
--- Format is 1w, 2d, 3h, 4m, 5
---@param duration number
---@return string
function Util.FormatDuration(duration)
    if duration >= 604800 then
        return math.floor(duration / 604800) .. "w"
    elseif duration >= 86400 then
        return math.floor(duration / 86400) .. "d"
    elseif duration >= 3600 then
        return math.floor(duration / 3600) .. "h"
    elseif duration >= 60 then
        return math.floor(duration / 60) .. "m"
    else
        return tostring(duration)
    end
end

--- Function to fetch Blizzard's class color string
--- @param className string
--- @return string?
function Util.GetClassColorCode(className)
    local classColor = RAID_CLASS_COLORS[className:upper()]
    if classColor then
        return classColor.colorStr
    end
    return nil
end

--- Wrap a string with a predefined color code
---@param string string
---@param color FormatColorType
---@return string
function Util.ColorWrap(string, color)
    ---@type string?
    local colorCode = const.FormatColors[color]
    if not colorCode then
        colorCode = Util.GetClassColorCode(color)
    end
    if not colorCode then
        return string
    end

    return string.format("|c%s%s|r", colorCode, string)
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
    print("[" .. Util:GetFormattedTimeStamp(true, true) .. "]", "|cffffa500[CUF]|r", ...)
end

---@param data any
---@param name string|number
function CUF:DevAdd(data, name)
    if not CUF.IsInDebugMode() or not DevTool then return end

    DevTool:AddData(data, name)
end
