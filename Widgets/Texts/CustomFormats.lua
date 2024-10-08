---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

local Util = CUF.Util

---@class CUF.widgets
local W = CUF.widgets

local L = CUF.L

-------------------------------------------------
-- MARK: Tags
-------------------------------------------------

-- Formats a percent value with decimals
---@param max number
---@param cur number
---@return string
local function FormatPercent(max, cur)
    if not cur or cur == 0 then return "0.00%" end

    return string.format("%.2f%%", (cur / max * 100))
end

-- Formats a percent value with decimals
--
-- Returns an empty string if cur is 0 or nil
---@param max number
---@param cur number
---@return string
local function FormatPercentNoZeroes(max, cur)
    if not cur or cur == 0 then return "" end

    return string.format("%.2f%%", (cur / max * 100))
end

-- Formats a percent value without decimals
---@param max number
---@param cur number
---@return string
local function FormatPercentShort(max, cur)
    if not cur or cur == 0 then return "0%" end

    return string.format("%d%%", (cur / max * 100))
end

-- Formats a percent value without decimals
--
-- Returns an empty string if cur is 0 or nil
---@param max number
---@param cur number
---@return string
local function FormatPercentShortNoZeroes(max, cur)
    if not cur or cur == 0 then return "" end

    return string.format("%d%%", (cur / max * 100))
end

-- Format a number using tostring
---@param num number
---@return string
local function FormatNumber(num)
    return tostring(num)
end

-- Format a number using tostring
--
-- Returns an empty string if the number is 0
---@param num number
---@return string
local function FormatNumberNoZeroes(num)
    if not num or num == 0 then return "" end
    return FormatNumber(num)
end

-- Formats a number using F:FormatNumber
--
-- eg. 12.3k, 12.3M or 12.3B
---@param num number
---@return string
local function FormatNumberShort(num)
    return F:FormatNumber(num)
end

-- Formats a number using F:FormatNumber
--
-- eg. 12.3k, 12.3M or 12.3B
--
-- Returns an empty string if the number is 0 or nil
local function FormatNumberShortNoZeroes(num)
    if not num or num == 0 then return "" end
    return FormatNumberShort(num)
end

-- Formats two formats together with a separator
--
-- Will return the first format if the second is empty
---@param format1 string
---@param format2 string
---@param seperator? string Default: "+"
---@return string
local function CombineFormats(format1, format2, seperator)
    if format2 == "" then return format1 end

    return string.format("%s" .. (seperator or "+") .. "%s", format1, format2)
end

local valid_health_tags = {
    -- Current
    ["cur"] = function(current, max, totalAbsorbs)
        return FormatNumber(current)
    end,
    ["cur:short"] = function(current, max, totalAbsorbs)
        return FormatNumberShort(current)
    end,
    ["cur:per"] = function(current, max, totalAbsorbs)
        return FormatPercent(max, current)
    end,
    ["cur:per-short"] = function(current, max, totalAbsorbs)
        return FormatPercentShort(max, current)
    end,
    -- Max
    ["max"] = function(current, max, totalAbsorbs)
        return FormatNumber(max)
    end,
    ["max:short"] = function(current, max, totalAbsorbs)
        return FormatNumberShort(max)
    end,
    -- Absorbs
    ["abs"] = function(current, max, totalAbsorbs)
        return FormatNumberNoZeroes(totalAbsorbs)
    end,
    ["abs:short"] = function(current, max, totalAbsorbs)
        return FormatNumberShortNoZeroes(totalAbsorbs)
    end,
    ["abs:per"] = function(current, max, totalAbsorbs)
        return FormatPercentNoZeroes(max, totalAbsorbs)
    end,
    ["abs:per-short"] = function(current, max, totalAbsorbs)
        return FormatPercentShortNoZeroes(max, totalAbsorbs)
    end,
    -- Current + Absorbs
    ["cur:abs"] = function(current, max, totalAbsorbs)
        return CombineFormats(FormatNumber(current), FormatNumberNoZeroes(totalAbsorbs))
    end,
    ["cur:abs-short"] = function(current, max, totalAbsorbs)
        return CombineFormats(FormatNumberShort(current), FormatNumberShortNoZeroes(totalAbsorbs))
    end,
    ["cur:abs:per"] = function(current, max, totalAbsorbs)
        return CombineFormats(FormatPercent(max, current), FormatPercentNoZeroes(max, totalAbsorbs))
    end,
    ["cur:abs:per-short"] = function(current, max, totalAbsorbs)
        return CombineFormats(FormatPercentShort(max, current), FormatPercentShortNoZeroes(max, totalAbsorbs))
    end,
    -- Current:Absorbs merge
    ["cur:abs:merge"] = function(current, max, totalAbsorbs)
        return FormatNumber(current + totalAbsorbs)
    end,
    ["cur:abs:merge:short"] = function(current, max, totalAbsorbs)
        return FormatNumberShort(current + totalAbsorbs)
    end,
    ["cur:abs:merge:per"] = function(current, max, totalAbsorbs)
        return FormatPercent(max, (current + totalAbsorbs))
    end,
    ["cur:abs:merge:per-short"] = function(current, max, totalAbsorbs)
        return FormatPercentShort(max, (current + totalAbsorbs))
    end,
    -- Deficit
    ["def"] = function(current, max, totalAbsorbs)
        return FormatNumberNoZeroes(current - max)
    end,
    ["def:short"] = function(current, max, totalAbsorbs)
        return FormatNumberShortNoZeroes(current - max)
    end,
    ["def:per"] = function(current, max, totalAbsorbs)
        return FormatPercentNoZeroes(max, (current - max))
    end,
    ["def:per-short"] = function(current, max, totalAbsorbs)
        return FormatPercentShortNoZeroes(max, (current - max))
    end,
    -- Heal Absorbs
    ["healabs"] = function(current, max, totalAbsorbs, healAbsorbs)
        return FormatNumberNoZeroes(healAbsorbs)
    end,
    ["healabs:short"] = function(current, max, totalAbsorbs, healAbsorbs)
        return FormatNumberShortNoZeroes(healAbsorbs)
    end,
    ["healabs:per"] = function(current, max, totalAbsorbs, healAbsorbs)
        return FormatPercentNoZeroes(max, healAbsorbs)
    end,
    ["healabs:per-short"] = function(current, max, totalAbsorbs, healAbsorbs)
        return FormatPercentShortNoZeroes(max, healAbsorbs)
    end,
}

W.CustomHealtFormatsTooltip = {
    "[cur] - " .. L["cur"],
    "[cur:short] - " .. L["cur:short"],
    "[cur:per] - " .. L["cur:per"],
    "[cur:per-short] - " .. L["cur:per-short"],
    "",
    "[max] - " .. L["max"],
    "[max:short] - " .. L["max:short"],
    "",
    "[abs] - " .. L["abs"],
    "[abs:short] - " .. L["abs:short"],
    "[abs:per] - " .. L["abs:per"],
    "[abs:per-short] - " .. L["abs:per-short"],
    "",
    "[cur:abs] - " .. L["cur:abs"],
    "[cur:abs-short] - " .. L["cur:abs-short"],
    "[cur:abs:per] - " .. L["cur:abs:per"],
    "[cur:abs:per-short] - " .. L["cur:abs:per-short"],
    "",
    "[cur:abs:merge] - " .. L["cur:abs:merge"],
    "[cur:abs:merge:short] - " .. L["cur:abs:merge:short"],
    "[cur:abs:merge:per] - " .. L["cur:abs:merge:per"],
    "[cur:abs:merge:per-short] - " .. L["cur:abs:merge:per-short"],
    "",
    "[def] - " .. L["def"],
    "[def:short] - " .. L["def:short"],
    "[def:per] - " .. L["def:per"],
    "[def:per-short] - " .. L["def:per-short"],
    "",
    "[healabs] - " .. L["healabs"],
    "[healabs:short] - " .. L["healabs:short"],
    "[healabs:per] - " .. L["healabs:per"],
    "[healabs:per-short] - " .. L["healabs:per-short"],
}

local valid_power_tags = {
    -- Current
    ["cur"] = function(current, max)
        return FormatNumber(current)
    end,
    ["cur:short"] = function(current, max)
        return FormatNumberShort(current)
    end,
    ["cur:per"] = function(current, max)
        return FormatPercent(max, current)
    end,
    ["cur:per-short"] = function(current, max)
        return FormatPercentShort(max, current)
    end,
    -- Max
    ["max"] = function(current, max)
        return FormatNumber(max)
    end,
    ["max:short"] = function(current, max)
        return FormatNumberShort(max)
    end,
    -- Deficit
    ["def"] = function(current, max)
        return FormatNumberNoZeroes(current - max)
    end,
    ["def:short"] = function(current, max)
        return FormatNumberShortNoZeroes(current - max)
    end,
    ["def:per"] = function(current, max)
        return FormatPercent(max, (current - max))
    end,
    ["def:per-short"] = function(current, max)
        return FormatPercentShort(max, (current - max))
    end,
}

W.CustomPowerFormatsTooltip = {
    "[cur] - " .. L["cur"],
    "[cur:short] - " .. L["cur:short"],
    "[cur:per] - " .. L["cur:per"],
    "[cur:per-short] - " .. L["cur:per-short"],
    "",
    "[max] - " .. L["max"],
    "[max:short] - " .. L["max:short"],
    "",
    "[def] - " .. L["def"],
    "[def:short] - " .. L["def:short"],
    "[def:per] - " .. L["def:per"],
    "[def:per-short] - " .. L["def:per-short"],
}

---@param textFormat string
---@param which "health" | "power"
---@return function?
local function findTagFunction(textFormat, which)
    if which == "power" then
        return valid_power_tags[textFormat]
    end

    return valid_health_tags[textFormat]
end

-------------------------------------------------
-- MARK: Processer
-------------------------------------------------

-- This function takes a text format string and returns a function that can be called with current, max, totalAbsorbs
--
-- Valid tags will be replaced with the corresponding function
--
-- Example usage:
--
-- local preBuiltFunction = W.ProcessCustomTextFormat("[cur:per-short] | [cur:short]")
--
-- local finalString = preBuiltFunction(100, 12600, 0)
--
-- print(finalString) -- Output: 100% | 12.6k
---@param textFormat string
---@param which "health" | "power"
function W.ProcessCustomTextFormat(textFormat, which)
    local elements = {}
    local lastEnd = 1
    local hasAbsorb = false
    local hasHealth = false
    local hasHealAbsorb = false

    -- Process the text format and find all bracketed tags
    for bracketed in textFormat:gmatch("%b[]") do
        local startPos, endPos = textFormat:find("%b[]", lastEnd)
        if startPos > lastEnd then
            table.insert(elements, textFormat:sub(lastEnd, startPos - 1))
        end

        local tag = bracketed:sub(2, -2)
        local maybeFunc = findTagFunction(tag, which)

        if maybeFunc then
            if tag:find("healabs") ~= nil then
                hasHealAbsorb = true
            elseif tag:find("abs") ~= nil then
                hasAbsorb = true
            else
                hasHealth = true
            end
            table.insert(elements, maybeFunc)
        else
            table.insert(elements, bracketed)
        end

        lastEnd = endPos + 1
    end

    -- Add any remaining text after the last tag
    if lastEnd <= #textFormat then
        table.insert(elements, textFormat:sub(lastEnd))
    end

    ---@param current number
    ---@param max number
    ---@param totalAbsorbs? number
    ---@param healAbsorbs? number
    ---@return string
    return function(current, max, totalAbsorbs, healAbsorbs)
        local result = {}

        for i, element in ipairs(elements) do
            if type(element) == "function" then
                local success, output = pcall(element, current, max, totalAbsorbs, healAbsorbs)
                if success then
                    result[i] = output
                else
                    result[i] = "n/a"
                end
            else
                result[i] = element
            end
        end

        return Util:trim(table.concat(result))
    end, hasAbsorb, hasHealth, hasHealAbsorb
end

-------------------------------------------------
-- MARK: CustomText
-------------------------------------------------

W.Formats = {}
W.FormatsTooltips = {}

---@param formatName string
---@param events string
---@param func fun(unit: UnitToken): string
---@param category ("Health"|"Miscellaneous")?
function W:AddFormat(formatName, events, func, category)
    self.Formats[formatName] = { events = events, func = func }

    local tooltip = string.format("[%s] - %s", formatName, L[formatName])
    category = category or "Miscellaneous"
    if not self.FormatsTooltips[category] then
        self.FormatsTooltips[category] = {}
    end
    tinsert(self.FormatsTooltips[category], tooltip)
end

local allTooltips
---@param category ("Health"|"Miscellaneous")?
---@return string[]
function W:GetFormatTooltips(category)
    if category then
        return self.FormatsTooltips[category]
    end

    if not allTooltips then
        allTooltips = {}
        for cat, tooltips in pairs(self.FormatsTooltips) do
            tinsert(allTooltips, cat)
            for _, tooltip in ipairs(tooltips) do
                tinsert(allTooltips, tooltip)
            end
        end
    end

    return allTooltips
end

-- Health
W:AddFormat("curhp", "UNIT_HEALTH", function(unit)
    return FormatNumber(UnitHealth(unit))
end, "Health")
W:AddFormat("curhp:short", "UNIT_HEALTH", function(unit)
    return FormatNumberShort(UnitHealth(unit))
end, "Health")
W:AddFormat("perhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatPercent(UnitHealthMax(unit), UnitHealth(unit))
end, "Health")
W:AddFormat("maxhp", "UNIT_MAXHEALTH", function(unit)
    return FormatNumber(UnitHealthMax(unit))
end, "Health")
W:AddFormat("defhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatNumberNoZeroes(UnitHealthMax(unit) - UnitHealth(unit))
end, "Health")

-- Absorbs
W:AddFormat("abs:short", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    return FormatNumberShortNoZeroes(UnitGetTotalAbsorbs(unit))
end, "Health")

-- Heal Absorbs
W:AddFormat("healabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
    return FormatNumberShortNoZeroes(UnitGetTotalHealAbsorbs(unit))
end, "Health")

-- This function takes a text format string and returns a function that can be called with current, max, totalAbsorbs
--
-- Valid tags will be replaced with the corresponding function
--
-- Example usage:
--
-- local preBuiltFunction = W.GetCustomTextFormat("[cur:per-short] | [cur:short]")
--
-- local finalString = preBuiltFunction(100, 12600, 0)
--
-- print(finalString) -- Output: 100% | 12.6k
---@param textFormat string
function W.GetCustomTextFormat(textFormat)
    local elements = {}
    local events = {}
    local lastEnd = 1

    -- Process the text format and find all bracketed tags
    for bracketed in textFormat:gmatch("%b[]") do
        local startPos, endPos = textFormat:find("%b[]", lastEnd)
        if startPos > lastEnd then
            table.insert(elements, textFormat:sub(lastEnd, startPos - 1))
        end

        local tag = bracketed:sub(2, -2)
        local maybeFormat = W.Formats[tag]

        if maybeFormat then
            --CUF:DevAdd(maybeFormat, tag)

            for _, event in pairs(strsplittable(" ", maybeFormat.events)) do
                events[event] = true
            end

            table.insert(elements, maybeFormat.func)
        else
            table.insert(elements, function() return bracketed end)
        end

        lastEnd = endPos + 1
    end

    -- Add any remaining text after the last tag
    if lastEnd <= #textFormat then
        table.insert(elements, textFormat:sub(lastEnd))
    end

    ---@param unit UnitToken
    ---@return string
    return function(_, unit)
        local result = {}

        for i, element in ipairs(elements) do
            local success, output = pcall(element, unit)
            if success then
                result[i] = output
            else
                result[i] = "n/a"
            end
        end

        return Util:trim(table.concat(result))
    end, events
end
