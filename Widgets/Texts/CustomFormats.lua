---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

local Util = CUF.Util

---@class CUF.widgets
local W = CUF.widgets

local L = CUF.L
local const = CUF.constants

---@class Tag
---@field events string|number
---@field func CustomTagFunc
---@field category TagCategory

---@type table<string, Tag>
W.Tags = {}
W.TagTooltips = {}

---@alias TagCategory "Health"|"Miscellaneous"|"Group"|"Classification"|"Target"|"Power"|"Color"|"Name"|"Status"
---@alias CustomTagFunc fun(unit: UnitToken): string?

local nameLenghts = {
    veryshort = 5,
    short = 10,
    medium = 15,
    long = 20,
}

local UnitName = UnitName
local UnitPower = UnitPower
local UnitIsAFK = UnitIsAFK
local UnitHealth = UnitHealth
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs -- Function is still not present in classic cata, orgiginally made available in mists.
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs -- Function is still not present in classic cata, orgiginally made available in mists.

-------------------------------------------------
-- MARK: Formatting Functions
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
-- Returns an nil if cur is 0 or nil
---@param max number
---@param cur number
---@return string?
local function FormatPercentNoZeroes(max, cur)
    if not cur or cur == 0 then return end

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
-- Returns an nil if cur is 0 or nil
---@param max number
---@param cur number
---@return string?
local function FormatPercentShortNoZeroes(max, cur)
    if not cur or cur == 0 then return end

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
-- Returns nil if the number is 0 or nil
---@param num number
---@return string?
local function FormatNumberNoZeroes(num)
    if not num or num == 0 then return end
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
-- Returns nil if the number is 0 or nil
---@param num number
---@return string?
local function FormatNumberShortNoZeroes(num)
    if not num or num == 0 then return end
    return FormatNumberShort(num)
end

-- Formats two formats together with a separator
--
-- Will return the first format if the second is empty
---@param format1 string
---@param format2 string?
---@param seperator? string Default: "+"
---@return string
local function CombineFormats(format1, format2, seperator)
    if not format2 then return format1 end

    return string.format("%s" .. (seperator or "+") .. "%s", format1, format2)
end

-------------------------------------------------
-- MARK: Tooltips
-------------------------------------------------

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
            local catTitle = Util.ColorWrap(cat, "WARLOCK")
            tinsert(allTooltips, catTitle)

            for _, tooltip in ipairs(tooltips) do
                tinsert(allTooltips, tooltip)
            end
        end
    end

    return allTooltips
end

local tooltipFrame
function W.ShowTooltipFrame()
    if not tooltipFrame then
        tooltipFrame = CUF:CreateFrame("CUF_CustomTags_Tooltip", CUF.mainFrame, 900, 500)
        tooltipFrame:SetFrameStrata("HIGH")

        tooltipFrame:SetMovable(true)
        tooltipFrame:RegisterForDrag("LeftButton")

        tooltipFrame:SetScript("OnDragStart", function()
            tooltipFrame:StartMoving()
        end)
        tooltipFrame:SetScript("OnDragStop", function()
            tooltipFrame:StopMovingOrSizing()
        end)

        local title = tooltipFrame:CreateFontString(nil, "OVERLAY", const.FONTS.CLASS_TITLE)
        title:SetPoint("TOP", 0, -10)
        title:SetText(L.TagTooltipsTitle)
        title:SetTextScale(1.5)

        local closeBtn = Cell:CreateButton(tooltipFrame, "×", "red", { 18, 18 }, false, false, "CELL_FONT_SPECIAL",
            "CELL_FONT_SPECIAL")
        closeBtn:SetPoint("TOPRIGHT", -5, -1)
        closeBtn:SetScript("OnClick", function() tooltipFrame:Hide() end)

        ---@class TooltipFrame.settingsFrame: Frame
        ---@field scrollFrame CellScrollFrame
        local settingsFrame = CUF:CreateFrame("CUF_Menu_UnitFrame_Widget", tooltipFrame,
            tooltipFrame:GetWidth() - 10, 450, true, true)
        settingsFrame:SetPoint("TOPLEFT", tooltipFrame, "TOPLEFT", 0, -40)

        Cell:CreateScrollFrame(settingsFrame)
        settingsFrame.scrollFrame:SetScrollStep(50)

        local tagText = settingsFrame.scrollFrame.content:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
        tagText:SetPoint("TOPLEFT", 5, -5)
        tagText:SetJustifyH("LEFT")
        tagText:SetSpacing(5)

        local text
        for _, tip in ipairs(W:GetTagTooltips()) do
            if not text then
                text = tip
            else
                text = text .. "\n" .. tip
            end
        end
        tagText:SetText(text)

        tooltipFrame:SetWidth(tagText:GetStringWidth() + 25)
        settingsFrame:SetWidth(tooltipFrame:GetWidth() - 10)

        C_Timer.After(0.1, function()
            settingsFrame.scrollFrame:SetContentHeight(tagText:GetStringHeight() + 10)
            settingsFrame.scrollFrame:ResetScroll()
        end)

        tooltipFrame:SetScript("OnShow", function() tooltipFrame:RegisterEvent("PLAYER_REGEN_DISABLED") end)
        tooltipFrame:SetScript("OnHide", function() tooltipFrame:UnregisterEvent("PLAYER_REGEN_DISABLED") end)
        tooltipFrame:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_DISABLED" then self:Hide() end
        end)
    end

    tooltipFrame:ClearAllPoints()
    tooltipFrame:SetPoint("CENTER", UIParent)
    tooltipFrame:Show()
end

-------------------------------------------------
-- MARK: Main Functions
-------------------------------------------------

---@param tagName string
---@param events string|number
---@param func CustomTagFunc
---@param category TagCategory?
---@param example string?
function W:AddTag(tagName, events, func, category, example)
    category = category or "Miscellaneous"
    self.Tags[tagName] = { events = events, func = func, category = category }

    local tooltip = string.format(Util.ColorWrap("[", "gold") .. "%s" .. Util.ColorWrap("]", "gold") .. " - %s",
        Util.ColorWrap(tagName, "orange"),
        L["tag_" .. tagName])

    if example then
        tooltip = tooltip .. " " .. Util.ColorWrap(example, "orange")
    end

    if not self.TagTooltips[category] then
        self.TagTooltips[category] = {}
    end
    tinsert(self.TagTooltips[category], tooltip)
end

--- Generic for getting a tag function to the given tag
---
--- Functions an easy way to create wrapper functions that can be used with the tag system
--- eg. for adding prefixes or wrapping string tags (non valid tag functions)
---@param tag string|function
---@param prefix string? if present will create a wrapper function that prepends the prefix to the tag
---@param suffix string? if present will create a wrapper function that appends the suffix to the tag
---@return CustomTagFunc
function W:WrapTagFunction(tag, prefix, suffix)
    if type(tag) ~= "function" then
        return function(_) return tag end
    end

    -- Wrap the tag function to include the prefix if the tag function
    -- returns a string
    if prefix then
        -- Check if we also have a suffix to append
        if suffix then
            return function(unit)
                local result = tag(unit)
                if result then
                    return prefix .. tag(unit) .. suffix
                end
            end
        end

        return function(unit)
            local result = tag(unit)
            if result then
                return prefix .. tag(unit)
            end
        end
    elseif suffix then
        return function(unit)
            local result = tag(unit)
            if result then
                return tag(unit) .. suffix
            end
        end
    end

    return tag
end

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
    ---@type CustomTagFunc[]
    local tagFuncs = {}
    local events = {}
    local lastEnd = 1
    local onUpdateTimer

    -- Process the text format and find all bracketed tags
    for bracketed in textFormat:gmatch("%b[]") do
        local startPos, endPos = textFormat:find("%b[]", lastEnd)
        if startPos > lastEnd then
            table.insert(tagFuncs, W:WrapTagFunction(textFormat:sub(lastEnd, startPos - 1)))
        end

        local tagContent = bracketed:sub(2, -2)

        local prefix, tag = string.split(">", tagContent)
        if not tag then
            tag = tagContent
            prefix = nil
        end

        local maybeSuffixedTag, suffix = string.split("<", tag)
        if suffix then
            tag = maybeSuffixedTag
        end

        local maybeTag = W.Tags[tag]

        if maybeTag and (not categoryFilter or maybeTag.category == categoryFilter) then
            local maybeEvents = maybeTag.events
            if type(maybeEvents) == "string" then
                for _, event in pairs(strsplittable(" ", maybeEvents)) do
                    events[event] = true
                end
            else
                onUpdateTimer = maybeEvents
            end

            table.insert(tagFuncs, W:WrapTagFunction(maybeTag.func, prefix, suffix))
        else
            table.insert(tagFuncs, W:WrapTagFunction(bracketed))
        end

        lastEnd = endPos + 1
    end

    -- Add any remaining text after the last tag
    if lastEnd <= #textFormat then
        table.insert(tagFuncs, W:WrapTagFunction(textFormat:sub(lastEnd)))
    end

    ---@param unit UnitToken
    ---@return string
    return function(_, unit)
        local result = ""

        for i = 1, #tagFuncs do
            local output = tagFuncs[i](unit)

            if output and output ~= "" then
                result = result .. output
            end
        end

        return result
    end, events, onUpdateTimer
end

-------------------------------------------------
-- MARK: Tags
-------------------------------------------------

-- MARK: Health
W:AddTag("curhp", "UNIT_HEALTH", function(unit)
    return FormatNumber(UnitHealth(unit))
end, "Health", "35000")
W:AddTag("curhp:short", "UNIT_HEALTH", function(unit)
    return FormatNumberShort(UnitHealth(unit))
end, "Health", "35K")
W:AddTag("perhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatPercent(UnitHealthMax(unit), UnitHealth(unit))
end, "Health", "75.20%")
W:AddTag("perhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatPercentShort(UnitHealthMax(unit), UnitHealth(unit))
end, "Health", "75%")

W:AddTag("maxhp", "UNIT_MAXHEALTH", function(unit)
    return FormatNumber(UnitHealthMax(unit))
end, "Health", "50000")
W:AddTag("maxhp:short", "UNIT_MAXHEALTH", function(unit)
    return FormatNumberShort(UnitHealthMax(unit))
end, "Health", "50K")

W:AddTag("defhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatNumberNoZeroes(UnitHealth(unit) - UnitHealthMax(unit))
end, "Health", "-10000")
W:AddTag("defhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatNumberShortNoZeroes(UnitHealth(unit) - UnitHealthMax(unit))
end, "Health", "-10K")
W:AddTag("perdefhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local current = UnitHealth(unit)
    return FormatPercentNoZeroes(maxhp, (current - maxhp))
end, "Health", "-20.20%")
W:AddTag("perdefhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local current = UnitHealth(unit)
    return FormatPercentShortNoZeroes(maxhp, (current - maxhp))
end, "Health", "-20%")

-- MARK: Absorbs
if CUF.vars.isRetail then
    W:AddTag("abs", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        return FormatNumberNoZeroes(UnitGetTotalAbsorbs(unit))
    end, "Health", "25000")
    W:AddTag("abs:short", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        return FormatNumberShortNoZeroes(UnitGetTotalAbsorbs(unit))
    end, "Health", "25K")
    W:AddTag("perabs", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
        local maxhp = UnitHealthMax(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatPercentNoZeroes(maxhp, totalAbsorbs)
    end, "Health", "50.20%")
    W:AddTag("perabs:short", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
        local maxhp = UnitHealthMax(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatPercentShortNoZeroes(maxhp, totalAbsorbs)
    end, "Health", "50%")

    -- MARK: Combine
    W:AddTag("curhp:abs", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return CombineFormats(FormatNumber(curhp), FormatNumberNoZeroes(totalAbsorbs))
    end, "Health", "35000 + 5000")
    W:AddTag("curhp:abs:short", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return CombineFormats(FormatNumberShort(curhp), FormatNumberShortNoZeroes(totalAbsorbs))
    end, "Health", "35K + 5K")
    W:AddTag("perhp:perabs", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local maxhp = UnitHealthMax(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return CombineFormats(FormatPercent(maxhp, curhp), FormatPercentNoZeroes(maxhp, totalAbsorbs))
    end, "Health", "75.20% + 15%")
    W:AddTag("perhp:perabs:short", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local maxhp = UnitHealthMax(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return CombineFormats(FormatPercentShort(maxhp, curhp), FormatPercentShortNoZeroes(maxhp, totalAbsorbs))
    end, "Health", "75% + 15%")

    -- MARK: Merge
    W:AddTag("curhp:abs:merge", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatNumber(curhp + totalAbsorbs)
    end, "Health", "40000")
    W:AddTag("curhp:abs:merge:short", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatNumberShort(curhp + totalAbsorbs)
    end, "Health", "40K")
    W:AddTag("perhp:perabs:merge", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local maxhp = UnitHealthMax(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatPercent(maxhp, (curhp + totalAbsorbs))
    end, "Health", "90.20%")
    W:AddTag("perhp:perabs:merge:short", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local curhp = UnitHealth(unit)
        local maxhp = UnitHealthMax(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatPercentShort(maxhp, (curhp + totalAbsorbs))
    end, "Health", "90%")
    W:AddTag("abs:healabs:merge", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatNumberNoZeroes(totalAbsorbs - totalHealAbsorbs)
    end, "Health", "40000")
    W:AddTag("abs:healabs:merge:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
        local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
        local totalAbsorbs = UnitGetTotalAbsorbs(unit)
        return FormatNumberShortNoZeroes(totalAbsorbs - totalHealAbsorbs)
    end, "Health", "-40k")

-- MARK: Heal Absorbs
    W:AddTag("healabs", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
        return FormatNumberNoZeroes(UnitGetTotalHealAbsorbs(unit))
    end, "Health", "20000")
    W:AddTag("healabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
        return FormatNumberShortNoZeroes(UnitGetTotalHealAbsorbs(unit))
    end, "Health", "20K")
    W:AddTag("perhealabs", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
        local maxhp = UnitHealthMax(unit)
        local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
        return FormatPercentNoZeroes(maxhp, totalHealAbsorbs)
    end, "Health", "40.20%")
    W:AddTag("perhealabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
        local maxhp = UnitHealthMax(unit)
        local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
        return FormatPercentShortNoZeroes(maxhp, totalHealAbsorbs)
    end, "Health", "40%")
end

-- MARK: Power
W:AddTag("curpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    return FormatNumber(power)
end, "Power", "12000")
W:AddTag("curpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    return FormatNumberShort(power)
end, "Power", "12K")
W:AddTag("perpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercent(maxPower, power)
end, "Power", "80.20%")
W:AddTag("perpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercentShort(maxPower, power)
end, "Power", "80%")

W:AddTag("maxpp", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumber(maxPower)
end, "Power", "15000")
W:AddTag("maxpp:short", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumberShort(maxPower)
end, "Power", "15K")

W:AddTag("defpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumberNoZeroes(power - maxPower)
end, "Power", "-3000")
W:AddTag("defpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatNumberShortNoZeroes(power - maxPower)
end, "Power", "-3K")
W:AddTag("perdefpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercentNoZeroes(maxPower, (power - maxPower))
end, "Power", "-20.20%")
W:AddTag("perdefpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local powerType = UnitPowerType(unit)
    local power = UnitPower(unit, powerType)
    local maxPower = UnitPowerMax(unit, powerType)
    return FormatPercentShortNoZeroes(maxPower, (power - maxPower))
end, "Power", "-20%")

-- MARK: Group
W:AddTag("group", "GROUP_ROSTER_UPDATE", function(unit)
    local subgroup = Util:GetUnitSubgroup(unit)
    if subgroup then
        return FormatNumber(subgroup)
    end
end, "Group", "1-8")

W:AddTag("group:raid", "GROUP_ROSTER_UPDATE", function(unit)
    if not IsInRaid() then return "" end
    local subgroup = Util:GetUnitSubgroup(unit)
    if subgroup then
        return FormatNumber(subgroup)
    end
end, "Group", "1-8")

-- MARK: Classification
W:AddTag("classification", "UNIT_CLASSIFICATION_CHANGED", function(unit)
    return Util:GetUnitClassification(unit, true)
end, "Classification", (L.rare .. ", " .. L.rareelite .. ", " .. L.elite .. ", " .. L.worldboss))

-- MARK: Name
for type, lenght in pairs(nameLenghts) do
    local normalExample = Util.ShortenString("Sylvanas Windrunner", lenght)
    local abbrevExample = Util.ShortenString("S. Windrunner", lenght)

    W:AddTag("name:" .. type, "UNIT_NAME_UPDATE", function(unit)
        local unitName = UnitName(unit)
        if unitName then
            return Util.ShortenString(unitName, lenght)
        end
    end, "Name", normalExample)

    W:AddTag("name:abbrev:" .. type, "UNIT_NAME_UPDATE", function(unit)
        local unitName = UnitName(unit)
        if unitName then
            local abbreveated = Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
            return Util.ShortenString(abbreveated, lenght)
        end
    end, "Name", abbrevExample)

    W:AddTag("target:" .. type, "UNIT_TARGET", function(unit)
        local unitName = UnitName(unit .. "target")
        if unitName then
            return Util.ShortenString(unitName, lenght)
        end
    end, "Target", normalExample)

    W:AddTag("target:abbrev:" .. type, "UNIT_TARGET", function(unit)
        local unitName = UnitName(unit .. "target")
        if unitName then
            local abbreveated = Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
            return Util.ShortenString(abbreveated, lenght)
        end
    end, "Target", abbrevExample)
end

W:AddTag("name", "UNIT_NAME_UPDATE", function(unit)
    local unitName = UnitName(unit)
    if unitName then
        return unitName
    end
end, "Name", "Sylvanas Windrunner")
W:AddTag("name:abbrev", "UNIT_NAME_UPDATE", function(unit)
    local unitName = UnitName(unit)
    if unitName then
        return Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
    end
end, "Name", "S. Windrunner")

-- MARK: Target
W:AddTag("target", "UNIT_TARGET", function(unit)
    local targetName = UnitName(unit .. "target")
    if targetName then
        return targetName
    end
end, "Target", "Sylvanas Windrunner")
W:AddTag("target:abbrev", "UNIT_TARGET", function(unit)
    local unitName = UnitName(unit .. "target")
    if unitName then
        return Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
    end
end, "Target", "S. Windrunner")

-- MARK: Colors
W:AddTag("classcolor", "UNIT_NAME_UPDATE UNIT_FACTION", function(unit)
    local r, g, b = Util:GetUnitClassColor(unit)
    return Util.RGBToOpenColorCode(r, g, b)
end, "Color")
W:AddTag("classcolor:target", "UNIT_TARGET", function(unit)
    local r, g, b = Util:GetUnitClassColor(unit .. "target")
    return Util.RGBToOpenColorCode(r, g, b)
end, "Color")

-- MARK: Status
W:AddTag("afk", "PLAYER_FLAGS_CHANGED", function(unit)
    if UnitIsAFK(unit) then
        return L.AFK
    end
end, "Status")
W:AddTag("dead", "PLAYER_FLAGS_CHANGED UNIT_FLAGS", function(unit)
    if UnitIsDead(unit) then
        return L["Dead"]
    end
end, "Status")
