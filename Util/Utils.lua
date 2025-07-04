---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local DB = CUF.DB
local L = CUF.L
local P = CUF.PixelPerfect

---@class CUF.Util
local Util = CUF.Util

local const = CUF.constants

local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetClassColor = GetClassColor

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

---@generic T: table
---@param table T
---@param seen table?
---@return T
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

--- Deep copies mixins into an existing object
---@param object table
---@param ... table[]
function Util:Mixin(object, ...)
    for i = 1, select("#", ...) do
        Mixin(object, Util:CopyDeep(select(i, ...)))
    end
end

-------------------------------------------------
-- MARK: IterateAllUnitButtons
-------------------------------------------------

---@param func fun(button: CUFUnitButton, unit: string, ...)
---@param unitToIterate string?
function Util:IterateAllUnitButtons(func, unitToIterate, ...)
    for _, unit in pairs(CUF.constants.UNIT) do
        if unit == "boss" then
            for _, button in pairs(CUF.unitButtons.boss) do
                func(button, unit, ...)
            end
        else
            if not unitToIterate or unitToIterate == unit then
                func(CUF.unitButtons[unit], unit, ...)
            end
        end
    end
end

---@param func fun(layout: UnitLayout, unit: Unit)
function Util.IterateAllUnitLayouts(func)
    for _, layoutTable in pairs(CellDB.layouts) do
        if layoutTable.CUFUnits then
            for unit, unitLayout in pairs(layoutTable.CUFUnits) do
                func(unitLayout, unit)
            end
        end
    end
end

-------------------------------------------------
-- MARK: Compat
-------------------------------------------------

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- Below are compatted versions of some of the uft8 fns from Cell that will fail more gracefully

-- ABNF from RFC 3629
--
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator (this part is compatted to return 1 instead of erroring)
---@param s string
---@param i number
---@return number
local function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    end

    local c = s:byte(i)

    -- determine bytes needed for character, based on RFC 3629
    -- validate byte 1
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1
    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = s:byte(i + 1)
        if not c2 or c2 < 128 or c2 > 191 then
            -- Invalid UTF-8 sequence, skip 1 byte
            return 1
        end
        return 2
    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)

        if not c2 or not c3 then
            -- UTF-8 string terminated early, skip 1 byte
            return 1
        end

        -- validate byte 2 and byte 3 based on c
        if (c == 224 and (c2 < 160 or c2 > 191)) or
            (c == 237 and (c2 < 128 or c2 > 159)) or
            (c2 < 128 or c2 > 191) or
            (c3 < 128 or c3 > 191) then
            -- Invalid UTF-8 sequence, skip 1 byte
            return 1
        end

        return 3
    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)

        if not c2 or not c3 or not c4 then
            -- UTF-8 string terminated early, skip 1 byte
            return 1
        end

        -- validate byte 2, byte 3, and byte 4
        if (c == 240 and (c2 < 144 or c2 > 191)) or
            (c == 244 and (c2 < 128 or c2 > 143)) or
            (c2 < 128 or c2 > 191) or
            (c3 < 128 or c3 > 191) or
            (c4 < 128 or c4 > 191) then
            -- Invalid UTF-8 sequence, skip 1 byte
            return 1
        end

        return 4
    else
        -- Invalid first byte, skip 1 byte
        return 1
    end
end

-- returns the number of characters in a UTF-8 string
---@param s string
---@return number
local function utf8len(s)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8len' (string expected, got " .. type(s) .. ")")
    end

    local pos = 1
    local bytes = s:len()
    local len = 0

    while pos <= bytes do
        len = len + 1
        pos = pos + utf8charbytes(s, pos)
    end

    return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub(s, i, j)
    -- argument defaults
    j = j or -1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8sub' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8sub' (number expected, got " .. type(i) .. ")")
    end
    if type(j) ~= "number" then
        error("bad argument #3 to 'utf8sub' (number expected, got " .. type(j) .. ")")
    end

    local pos       = 1
    local bytes     = s:len()
    local len       = 0

    -- only set l if i or j is negative
    local l         = (i >= 0 and j >= 0) or s:utf8len()
    local startChar = (i >= 0) and i or l + i + 1
    local endChar   = (j >= 0) and j or l + j + 1

    -- can't have start before end!
    if startChar > endChar then
        return ""
    end

    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes

    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end

    return s:sub(startByte, endByte)
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
        for i = utf8len(text), 0, -1 do
            fs:SetText(utf8sub(text, 1, i))
            if fs:GetWidth() / width <= percent then
                break
            end
        end
    elseif widthTable.type == "length" then
        if string.len(text) == utf8len(text) then -- en
            fs:SetText(utf8sub(text, 1, widthTable.value))
        else                                      -- non-en
            fs:SetText(utf8sub(text, 1, widthTable.auxValue))
        end
    end
end

-- Returns a table of all fonts.
---@return string[]
function Util:GetFontItems()
    local items, fonts, defaultFontName, defaultFont = F.GetFontItems()

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
-- Doesn't return type prop from F.GetPowerColor
---@param unit Unit
---@return number, number, number
function Util:GetPowerColor(unit)
    local r, g, b, type = F.GetPowerColor(unit)

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
        return F.GetClassColor(class)
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
            return F.GetClassColor(select(2, UnitClass("player")))
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
        table.insert(layoutNames, layoutName)
    end

    return layoutNames
end

---@param formatted boolean?
---@return string
function Util:GetAllLayoutNamesAsString(formatted)
    local layoutNames = {}

    for layoutName, _ in pairs(CellDB.layouts) do
        table.insert(layoutNames, Util:FormatLayoutName(layoutName, formatted))
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

---@param healthBarColorType UnitButtonColorType
---@param healthLossColorType UnitButtonColorType
---@param percent number
---@param isDeadOrGhost boolean
---@param r number
---@param g number
---@param b number
---@return number barR
---@return number barG
---@return number barB
---@return number lossR
---@return number lossG
---@return number lossB
function Util:GetHealthBarColor(healthBarColorType, healthLossColorType, percent, isDeadOrGhost, r, g, b)
    if healthBarColorType == const.UnitButtonColorType.CELL then
        return F.GetHealthBarColor(percent, isDeadOrGhost, r, g, b)
    end

    local barR, barG, barB, lossR, lossG, lossB
    percent = percent or 1

    local colors = DB.GetColors().unitFrames

    -- bar
    if percent == 1 and colors.useFullColor then
        barR, barG, barB = unpack(colors.fullColor)
    else
        if healthBarColorType == const.UnitButtonColorType.CLASS_COLOR then
            barR, barG, barB = r, g, b
        elseif healthBarColorType == const.UnitButtonColorType.CLASS_COLOR_DARK then
            barR, barG, barB = r * 0.2, g * 0.2, b * 0.2
        else
            barR, barG, barB = unpack(colors.barColor)
        end
    end

    -- loss
    if isDeadOrGhost and colors.useDeathColor then
        lossR, lossG, lossB = unpack(colors.deathColor)
    else
        if healthLossColorType == const.UnitButtonColorType.CLASS_COLOR then
            lossR, lossG, lossB = r, g, b
        elseif healthLossColorType == const.UnitButtonColorType.CLASS_COLOR_DARK then
            lossR, lossG, lossB = r * 0.2, g * 0.2, b * 0.2
        else
            lossR, lossG, lossB = unpack(colors.lossColor)
        end
    end

    return barR, barG, barB, lossR, lossG, lossB
end

---@class WeaponEnchantInfo
---@field hasMainHandEnchant boolean
---@field mainHandExpiration number?
---@field mainHandCharges number?
---@field mainHandEnchantID number?
---@field hasOffHandEnchant boolean?
---@field offHandExpiration number?
---@field offHandCharges number?
---@field offHandEnchantID number?
---@field hasRangedEnchant boolean?
---@field rangedExpiration number?
---@field rangedCharges number?
---@field rangedEnchantID number?

--- Returns weapon enchant info as a table
--- Returns nil if no weapon enchant info can be found
---@return WeaponEnchantInfo?
function Util:GetWeaponEnchantInfo()
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID,
    hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID,
    hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID =
        GetWeaponEnchantInfo()

    if hasMainHandEnchant ~= nil then
        return {
            hasMainHandEnchant = hasMainHandEnchant,
            mainHandExpiration = mainHandExpiration,
            mainHandCharges = mainHandCharges,
            mainHandEnchantID = mainHandEnchantID,
            hasOffHandEnchant = hasOffHandEnchant,
            offHandExpiration = offHandExpiration,
            offHandCharges = offHandCharges,
            offHandEnchantID = offHandEnchantID,
            hasRangedEnchant = hasRangedEnchant,
            rangedExpiration = rangedExpiration,
            rangedCharges = rangedCharges,
            rangedEnchantID = rangedEnchantID,
        }
    end
end

local LSM = LibStub("LibSharedMedia-3.0", true)
LSM:Register("statusbar", "Cell Shield", const.Textures.CELL_SHIELD)
LSM:Register("statusbar", "Cell Overshield", const.Textures.CELL_OVERSHIELD)
LSM:Register("statusbar", "Cell Overabsorb", const.Textures.CELL_OVERABSORB)
LSM:Register("statusbar", "Blizzard Shield Fill", const.Textures.BLIZZARD_SHIELD_FILL)
LSM:Register("statusbar", "Blizzard Shield Overlay", const.Textures.BLIZZARD_SHIELD_OVERLAY)
LSM:Register("statusbar", "Blizzard Overshield", const.Textures.BLIZZARD_OVERSHIELD)
LSM:Register("statusbar", "Blizzard Absorb Fill", const.Textures.BLIZZARD_ABSORB_FILL)
LSM:Register("statusbar", "Blizzard Overabsorb", const.Textures.BLIZZARD_OVERABSORB)

local textures
Util.textureToName = {}

---@return table<string,string>
function Util:GetTextures()
    if textures then return textures end

    textures = F.Copy(LSM:HashTable("statusbar"))
    for name, texture in pairs(textures) do
        self.textureToName[texture] = name
    end

    return textures
end

local LibTranslit = LibStub("LibTranslit-1.0")

--- Get potential translit nickname for a given name
---@param name string
---@param fullName string
---@return string
function Util.GetTranslitCellNickname(name, fullName)
    if CELL_NICKTAG_ENABLED and Cell.NickTag then
        -- GetNickname fun(self: Cell_NickTag, name: string, default: string?, silent: boolean?): string?
        name = Cell.NickTag:GetNickname(name, name, true)
    end
    name = F.GetNickname(name, fullName)

    if CellDB["general"]["translit"] then
        name = LibTranslit:Transliterate(name)
    end

    return name
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
---@return string unitName
function Util:GetUnitNameWithServer(unit)
    local name, nameWithServer = self:GetUnitName(unit)
    return nameWithServer or name
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

---@param unit UnitToken
---@param localized boolean
---@return string? classification
function Util:GetUnitClassification(unit, localized)
    local classification = UnitClassification(unit)
    if localized then
        return L[classification]
    end
    return classification
end

local gold, silver = "|A:nameplates-icon-elite-gold:16:16|a", "|A:nameplates-icon-elite-silver:16:16|a"
local typeIcon = { elite = gold, worldboss = gold, rareelite = silver, rare = silver }

---@param unit UnitToken
---@return string? icon
function Util:GetUnitClassificationIcon(unit)
    return typeIcon[UnitClassification(unit)]
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
    local f = Cell.CreateFrame(name, parent, width, height, isTransparent, template)
    P.Size(f, width, height)
    if isShown then f:Show() end
    return f
end

---@param parent Frame
---@param text string?
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
    local b = Cell.CreateButton(parent, text, (buttonColor or "accent-hover"), size or 16, noBorder, noBackground,
        fontNormal,
        fontDisable,
        template,
        ...)
    P.Size(b, size[1], size[2])

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
    local editBox = Cell.CreateEditBox(parent, width, height, isTransparent, isMultiLine, isNumeric, font)
    P.Size(editBox, width, height)

    if text then
        local label = editBox:CreateFontString(nil, "OVERLAY", CUF.constants.FONTS.CELL_WIDGET)
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
    return Cell.CreateConfirmPopup(parent, width, text, onAccept, onReject, mask, hasEditBox, dropdowns)
end

--- Create a pop up frame with a header and a text area
---@param title string?
---@param width number
---@param ... string
function CUF:CreateInformationPopupFrame(title, width, ...)
    local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(1)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(0, 0, 20, 0)
    f:SetWidth(width)
    f:SetPoint("CENTER")
    f:Hide()
    Cell.StylizeFrame(f)

    -- header
    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.header = header
    header:EnableMouse(true)
    header:SetClampedToScreen(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        f:StartMoving()
    end)
    header:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    header:SetPoint("LEFT")
    header:SetPoint("RIGHT")
    header:SetPoint("BOTTOM", f, "TOP", 0, -1)
    header:SetHeight(20)
    Cell.StylizeFrame(header, { 0.115, 0.115, 0.115, 1 })

    header.text = header:CreateFontString(nil, "OVERLAY", const.FONTS.CLASS_TITLE)
    header.text:SetText("Cell UnitFrames - " .. (title or L.Info))
    header.text:SetPoint("CENTER", header)

    header.closeBtn = Cell.CreateButton(header, "×", "red", { 20, 20 }, false, false, "CELL_FONT_SPECIAL",
        "CELL_FONT_SPECIAL")
    header.closeBtn:SetPoint("TOPRIGHT")
    header.closeBtn:SetScript("OnClick", function() f:Hide() end)

    local content = f:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
    content:SetScale(1)
    content:SetPoint("TOP", header, "BOTTOM", 0, -10)
    content:SetWidth(f:GetWidth() - 30)
    content:SetJustifyH("CENTER")
    content:SetSpacing(5)

    local txt = ""
    for _, line in ipairs({ ... }) do
        txt = txt .. line .. "\n"
    end

    content:SetText(txt)

    -- update height
    f:SetHeight(content:GetStringHeight() + 20 + 5)

    return f
end

---@param frame Frame
---@param anchor "ANCHOR_TOP" | "ANCHOR_BOTTOM" | "ANCHOR_LEFT" | "ANCHOR_RIGHT" | "ANCHOR_TOPLEFT" | "ANCHOR_TOPRIGHT" | "ANCHOR_BOTTOMLEFT" | "ANCHOR_BOTTOMRIGHT" | "ANCHOR_CURSOR"
---@param x number
---@param y number
---@param ... any
function CUF:SetTooltips(frame, anchor, x, y, ...)
    Cell.SetTooltips(frame, anchor, x, y, ...)
end

---@param frame Frame
function CUF:ClearTooltips(frame)
    Cell.ClearTooltips(frame)
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
    local _, _, _, colorStr = GetClassColor(className:upper())
    if colorStr then
        return colorStr
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

--- Converts an RGB color to a hex color used for string formatting
---
--- Returns an open color code without "|r" suffix
---
--- eg. "|cffFFFFFF"
---@param r number|table
---@param g number?
---@param b number?
---@return string
function Util.RGBToOpenColorCode(r, g, b)
    if type(r) == "table" then
        r, g, b = unpack(r)
    end

    if not r then
        return "|cffFFFFFF"
    end

    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

--- Shortens a string to a given length
---@param str string
---@param maxLength number
function Util.ShortenString(str, maxLength)
    return utf8sub(str, 1, maxLength)
end

---@param max number
---@param min number?
---@param percent boolean?
---@param short boolean?
---@return string? result
---@return boolean? isPositive
function Util.FormatText(max, min, percent, short)
    local isPositive
    if percent then
        if not min then return end
        if not max or max == 0 then return end

        local val = min / max * 100
        isPositive = val > 0

        if short then
            return string.format("%d%%", val), isPositive
        end

        return string.format("%.2f%%", val), isPositive
    end

    isPositive = max >= 0
    if short then
        return F.FormatNumber(max), isPositive
    end

    return tostring(max), isPositive
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
