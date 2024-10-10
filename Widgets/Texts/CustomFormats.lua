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

W.Tags = {}
W.TagTooltips = {}

---@alias TagCategory "Health"|"Miscellaneous"|"Group"|"Classification"|"Target"|"Power"

---@param tagName string
---@param events string
---@param func fun(unit: UnitToken): string
---@param category TagCategory?
function W:AddTag(tagName, events, func, category)
    self.Tags[tagName] = { events = events, func = func, category = category }

    local tooltip = string.format("[%s] - %s", tagName, L[tagName])
    category = category or "Miscellaneous"
    if not self.TagTooltips[category] then
        self.TagTooltips[category] = {}
    end
    tinsert(self.TagTooltips[category], tooltip)
end

--- Creates a wrapper function that returns the input string
---
--- Used for non tag inputs
---@param str string
---@return fun(unit: UnitToken): string
function W:CreateStringWrapFunction(str)
    return function(unit) return str end
end

local allTooltips
---@param category TagCategory?
---@return string[]
function W:GetTagTooltips(category)
    if category then
        return self.TagTooltips[category]
    end

    if not allTooltips then
        allTooltips = {}
        for cat, tooltips in pairs(self.TagTooltips) do
            -- Add buffer between categories
            if #allTooltips > 0 then
                tinsert(allTooltips, "")
            end

            -- Color category titles
            local catTitle = Util.ColorWrap(cat, "orange")
            tinsert(allTooltips, catTitle)

            for _, tooltip in ipairs(tooltips) do
                tinsert(allTooltips, tooltip)
            end
        end
    end

    return allTooltips
end

-- Health
W:AddTag("curhp", "UNIT_HEALTH", function(unit)
    return FormatNumber(UnitHealth(unit))
end, "Health")
W:AddTag("curhp:short", "UNIT_HEALTH", function(unit)
    return FormatNumberShort(UnitHealth(unit))
end, "Health")
W:AddTag("perhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatPercent(UnitHealthMax(unit), UnitHealth(unit))
end, "Health")
W:AddTag("perhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatPercentShort(UnitHealthMax(unit), UnitHealth(unit))
end, "Health")

W:AddTag("maxhp", "UNIT_MAXHEALTH", function(unit)
    return FormatNumber(UnitHealthMax(unit))
end, "Health")
W:AddTag("maxhp:short", "UNIT_MAXHEALTH", function(unit)
    return FormatNumberShort(UnitHealthMax(unit))
end, "Health")

W:AddTag("defhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatNumberNoZeroes(UnitHealthMax(unit) - UnitHealth(unit))
end, "Health")
W:AddTag("defhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatNumberShortNoZeroes(UnitHealthMax(unit) - UnitHealth(unit))
end, "Health")
W:AddTag("perdefhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local current = UnitHealth(unit)
    return FormatPercentNoZeroes(maxhp, (current - maxhp))
end, "Health")
W:AddTag("perdefhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local current = UnitHealth(unit)
    return FormatPercentShortNoZeroes(maxhp, (current - maxhp))
end, "Health")

-- Absorbs
W:AddTag("abs", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    return FormatNumber(UnitGetTotalAbsorbs(unit))
end, "Health")
W:AddTag("abs:short", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    return FormatNumberShortNoZeroes(UnitGetTotalAbsorbs(unit))
end, "Health")
W:AddTag("perabs", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    return FormatPercentNoZeroes(maxhp, totalAbsorbs)
end, "Health")
W:AddTag("perabs:short", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    return FormatPercentShortNoZeroes(maxhp, totalAbsorbs)
end, "Health")

-- Combine
W:AddTag("curhp:abs", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return CombineFormats(FormatNumber(curhp), FormatNumberNoZeroes(totalAbsorbs))
end, "Health")
W:AddTag("curhp:abs:short", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return CombineFormats(FormatNumberShort(curhp), FormatNumberShortNoZeroes(totalAbsorbs))
end, "Health")
W:AddTag("perhp:perabs", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return CombineFormats(FormatPercent(maxhp, curhp), FormatPercentNoZeroes(maxhp, totalAbsorbs))
end, "Health")
W:AddTag("perhp:perabs:short", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return CombineFormats(FormatPercentShort(maxhp, curhp), FormatPercentShortNoZeroes(maxhp, totalAbsorbs))
end, "Health")

-- Merge
W:AddTag("curhp:abs:merge", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return FormatNumber(curhp + totalAbsorbs)
end, "Health")
W:AddTag("curhp:abs:merge:short", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return FormatNumberShort(curhp + totalAbsorbs)
end, "Health")
W:AddTag("perhp:perabs:merge", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return FormatPercent(maxhp, (curhp + totalAbsorbs))
end, "Health")
W:AddTag("perhp:perabs:merge:short", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return FormatPercentShort(maxhp, (curhp + totalAbsorbs))
end, "Health")

-- Heal Absorbs
W:AddTag("healabs", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
    return FormatNumber(UnitGetTotalHealAbsorbs(unit))
end, "Health")
W:AddTag("healabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
    return FormatNumberShortNoZeroes(UnitGetTotalHealAbsorbs(unit))
end, "Health")
W:AddTag("perhealabs", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return FormatPercentNoZeroes(maxhp, totalHealAbsorbs)
end, "Health")
W:AddTag("perhealabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    return FormatPercentShortNoZeroes(maxhp, totalHealAbsorbs)
end, "Health")

-- Power
W:AddTag("curpp", "UNIT_POWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    return FormatNumber(power)
end, "Power")
W:AddTag("curpp:short", "UNIT_POWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    return FormatNumberShort(power)
end, "Power")
W:AddTag("perpp", "UNIT_POWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercent(maxPower, power)
end, "Power")
W:AddTag("perpp:short", "UNIT_POWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercentShort(maxPower, power)
end, "Power")

W:AddTag("maxpp", "UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumber(maxPower)
end, "Power")
W:AddTag("maxpp:short", "UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumberShort(maxPower)
end, "Power")

W:AddTag("defpp", "UNIT_POWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumber(maxPower - power)
end, "Power")
W:AddTag("defpp:short", "UNIT_POWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumberShort(maxPower - power)
end, "Power")
W:AddTag("perdefpp", "UNIT_POWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercent(maxPower, (maxPower - power))
end, "Power")
W:AddTag("perdefpp:short", "UNIT_POWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercentShort(maxPower, (maxPower - power))
end, "Power")

-- Group
W:AddTag("group", "GROUP_ROSTER_UPDATE", function(unit)
    local subgroup = Util:GetUnitSubgroup(unit)
    if subgroup then
        return FormatNumber(subgroup)
    end
    return ""
end, "Group")

W:AddTag("group:raid", "GROUP_ROSTER_UPDATE", function(unit)
    if not IsInRaid() then return "" end
    local subgroup = Util:GetUnitSubgroup(unit)
    if subgroup then
        return FormatNumber(subgroup)
    end
    return ""
end, "Group")

-- Classification

W:AddTag("classification", "UNIT_CLASSIFICATION_CHANGED", function(unit)
    return Util:GetUnitClassification(unit, true)
end, "Classification")


-- This function takes a text format string and returns a function that can be called with a UnitToken
--
-- Valid tags will be replaced with the corresponding function
--
-- Example usage:
--
-- local preBuiltFunction = W.GetTagFunction("[cur:per-short] | [cur:short]")
--
-- local finalString = preBuiltFunction(self, unit)
--
-- print(finalString) -- Output: 100% | 12.6k
---@param textFormat string
---@param categoryFilter TagCategory?
function W.GetTagFunction(textFormat, categoryFilter)
    local elements = {}
    local events = {}
    local lastEnd = 1

    -- Process the text format and find all bracketed tags
    for bracketed in textFormat:gmatch("%b[]") do
        local startPos, endPos = textFormat:find("%b[]", lastEnd)
        if startPos > lastEnd then
            table.insert(elements, W:CreateStringWrapFunction(textFormat:sub(lastEnd, startPos - 1)))
        end

        local tag = bracketed:sub(2, -2)
        local maybeTag = W.Tags[tag]

        if maybeTag and (not categoryFilter or maybeTag.category == categoryFilter) then
            for _, event in pairs(strsplittable(" ", maybeTag.events)) do
                events[event] = true
            end

            table.insert(elements, maybeTag.func)
        else
            table.insert(elements, W:CreateStringWrapFunction(bracketed))
        end

        lastEnd = endPos + 1
    end

    -- Add any remaining text after the last tag
    if lastEnd <= #textFormat then
        table.insert(elements, W:CreateStringWrapFunction(textFormat:sub(lastEnd)))
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
