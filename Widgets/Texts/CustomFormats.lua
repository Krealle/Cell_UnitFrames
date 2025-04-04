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

local nameLengths = {
    veryshort = 5,
    short = 10,
    medium = 15,
    long = 20,
}

local FormatText = Util.FormatText
local GetTranslitCellNickname = Util.GetTranslitCellNickname

local format = string.format

local UnitName = UnitName
local UnitPower = UnitPower
local UnitIsAFK = UnitIsAFK
local UnitHealth = UnitHealth
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs

-------------------------------------------------
-- MARK: Formatting Functions
-------------------------------------------------

-- Formats a percent value with decimals
---@param max number
---@param cur number
---@return string
local function FormatPercent(max, cur)
    if not cur or cur == 0 then return "0.00%" end

    return format("%.2f%%", (cur / max * 100))
end

-- Formats a percent value with decimals
--
-- Returns an nil if cur is 0 or nil
---@param max number
---@param cur number
---@return string?
local function FormatPercentNoZeroes(max, cur)
    if not cur or cur == 0 then return end

    return format("%.2f%%", (cur / max * 100))
end

-- Formats a percent value without decimals
---@param max number
---@param cur number
---@return string
local function FormatPercentShort(max, cur)
    if not cur or cur == 0 then return "0%" end

    return format("%d%%", (cur / max * 100))
end

-- Formats a percent value without decimals
--
-- Returns an nil if cur is 0 or nil
---@param max number
---@param cur number
---@return string?
local function FormatPercentShortNoZeroes(max, cur)
    if not cur or cur == 0 then return end

    return format("%d%%", (cur / max * 100))
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

-- Formats a number using F.FormatNumber
--
-- eg. 12.3k, 12.3M or 12.3B
---@param num number
---@return string
local function FormatNumberShort(num)
    return F.FormatNumber(num)
end

-- Formats a number using F.FormatNumber
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
---@param separator? string Default: "+"
---@return string
local function CombineFormats(format1, format2, separator)
    if not format2 then return format1 end

    return format("%s" .. (separator or "+") .. "%s", format1, format2)
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
                table.insert(allTooltips, "")
            end

            -- Color category titles
            local catTitle = Util.ColorWrap(cat, "WARLOCK")
            table.insert(allTooltips, catTitle)

            for _, tooltip in ipairs(tooltips) do
                table.insert(allTooltips, tooltip)
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

        local closeBtn = Cell.CreateButton(tooltipFrame, "×", "red", { 18, 18 }, false, false, "CELL_FONT_SPECIAL",
            "CELL_FONT_SPECIAL")
        closeBtn:SetPoint("TOPRIGHT", -5, -1)
        closeBtn:SetScript("OnClick", function() tooltipFrame:Hide() end)

        ---@class TooltipFrame.settingsFrame: Frame
        ---@field scrollFrame CellScrollFrame
        local settingsFrame = CUF:CreateFrame("CUF_Menu_UnitFrame_Widget", tooltipFrame,
            tooltipFrame:GetWidth() - 10, 450, true, true)
        settingsFrame:SetPoint("TOPLEFT", tooltipFrame, "TOPLEFT", 0, -40)

        Cell.CreateScrollFrame(settingsFrame)
        settingsFrame.scrollFrame:SetScrollStep(50)

        local tagText = settingsFrame.scrollFrame.content:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
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

    local tooltip = format(Util.ColorWrap("[", "gold") .. "%s" .. Util.ColorWrap("]", "gold") .. " - %s",
        Util.ColorWrap(tagName, "orange"),
        L["tag_" .. tagName])

    if example then
        tooltip = tooltip .. " " .. Util.ColorWrap(example, "orange")
    end

    if not self.TagTooltips[category] then
        self.TagTooltips[category] = {}
    end
    table.insert(self.TagTooltips[category], tooltip)
end

--- Generic for getting a tag function to the given tag
---
--- Functions an easy way to create wrapper functions that can be used with the tag system
--- eg. for adding prefixes or wrapping string tags (non valid tag functions)
---@param tag string|CustomTagFunc
---@param prefix string? if present will create a wrapper function that prepends the prefix to the tag
---@param suffix string? if present will create a wrapper function that appends the suffix to the tag
---@return CustomTagFunc
function W:WrapTagFunction(tag, prefix, suffix)
    if type(tag) ~= "function" then
        return function(_) return tag end
    end

    -- Wrap the tag function to include the prefix if the tag function
    -- returns a string
    -- [{op:color}>abs:healabs:merge:short]
    if prefix then
        local positiveColor, negativeColor
        for bracketed in prefix:gmatch("%b{}") do
            local operator, color = string.split(":", bracketed:sub(2, -2))
            if operator == "neg" or operator == "pos" then
                if (const.FormatColors[color] or Util.GetClassColorCode(color)) then
                    if operator == "neg" then
                        negativeColor = color
                    else
                        positiveColor = color
                    end
                    prefix = prefix:gsub("%b" .. bracketed, "")
                end
            end
        end

        -- Check if we also have a suffix to append
        if suffix then
            if positiveColor or negativeColor then
                return function(unit)
                    local result, isPositive = tag(unit)
                    if result then
                        if positiveColor and isPositive then
                            return Util.ColorWrap((prefix .. result .. suffix), positiveColor)
                        elseif negativeColor and not isPositive then
                            return Util.ColorWrap((prefix .. result .. suffix), negativeColor)
                        end

                        return prefix .. result .. suffix
                    end
                end
            end

            return function(unit)
                local result = tag(unit)
                if result then
                    return prefix .. result .. suffix
                end
            end
        end

        if positiveColor or negativeColor then
            return function(unit)
                local result, isPositive = tag(unit)
                if result then
                    if positiveColor and isPositive then
                        return Util.ColorWrap((prefix .. result), positiveColor)
                    elseif negativeColor and not isPositive then
                        return Util.ColorWrap((prefix .. result), negativeColor)
                    end

                    return prefix .. result
                end
            end
        end

        return function(unit)
            local result = tag(unit)
            if result then
                return prefix .. result
            end
        end
    elseif suffix then
        return function(unit)
            local result = tag(unit)
            if result then
                return result .. suffix
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

    -- For some reason "|" inputs are being interpreted as "||"
    -- This breaks color codes, so we need to strip away the extra "|" for them
    textFormat = textFormat:gsub("||([cr])", "|%1")

    -- Process the text format and find all bracketed tags
    for bracketed in textFormat:gmatch("%b[]") do
        local startPos, endPos = textFormat:find("%b[]", lastEnd)
        if startPos > lastEnd then
            table.insert(tagFuncs, W:WrapTagFunction(textFormat:sub(lastEnd, startPos - 1)))
        end

        local tagContent = bracketed:sub(2, -2)

        ---@type string?, string
        local prefix, tag = string.split(">", tagContent)
        if not tag then
            tag = tagContent
            prefix = nil
        end

        ---@type string, string
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
    return FormatText(UnitHealth(unit))
end, "Health", "35000")
W:AddTag("curhp:short", "UNIT_HEALTH", function(unit)
    return FormatText(UnitHealth(unit), nil, false, true)
end, "Health", "35K")
W:AddTag("perhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatText(UnitHealthMax(unit), UnitHealth(unit), true)
end, "Health", "75.20%")
W:AddTag("perhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    return FormatText(UnitHealthMax(unit), UnitHealth(unit), true, true)
end, "Health", "75%")

W:AddTag("maxhp", "UNIT_MAXHEALTH", function(unit)
    return FormatText(UnitHealthMax(unit))
end, "Health", "50000")
W:AddTag("maxhp:short", "UNIT_MAXHEALTH", function(unit)
    return FormatText(UnitHealthMax(unit), nil, false, true)
end, "Health", "50K")

W:AddTag("defhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local deficit = UnitHealth(unit) - UnitHealthMax(unit)
    if not deficit or deficit == 0 then return end
    return FormatText(deficit)
end, "Health", "-10000")
W:AddTag("defhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local deficit = UnitHealth(unit) - UnitHealthMax(unit)
    if not deficit or deficit == 0 then return end
    return FormatText(deficit, nil, false, true)
end, "Health", "-10K")
W:AddTag("perdefhp", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local current = UnitHealth(unit)
    local deficit = current - maxhp
    if not deficit or deficit == 0 then return end
    return FormatText(maxhp, deficit, true)
end, "Health", "-20.20%")
W:AddTag("perdefhp:short", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
    local maxhp = UnitHealthMax(unit)
    local current = UnitHealth(unit)
    local deficit = current - maxhp
    if not deficit or deficit == 0 then return end
    return FormatText(maxhp, deficit, true, true)
end, "Health", "-20%")

-- MARK: Absorbs
W:AddTag("abs", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs == 0 then return end
    return FormatText(totalAbsorbs)
end, "Health", "25000")
W:AddTag("abs:short", "UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs == 0 then return end
    return FormatText(totalAbsorbs, nil, false, true)
end, "Health", "25K")
W:AddTag("perabs", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs == 0 then return end
    local maxhp = UnitHealthMax(unit)
    return FormatText(maxhp, totalAbsorbs, true)
end, "Health", "50.20%")
W:AddTag("perabs:short", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs == 0 then return end
    local maxhp = UnitHealthMax(unit)
    return FormatText(maxhp, totalAbsorbs, true, true)
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
    return FormatText(curhp + totalAbsorbs)
end, "Health", "40000")
W:AddTag("curhp:abs:merge:short", "UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    return FormatText(curhp + totalAbsorbs, nil, false, true)
end, "Health", "40K")
W:AddTag("perhp:perabs:merge", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    return FormatText(maxhp, (curhp + totalAbsorbs), true)
end, "Health", "90.20%")
W:AddTag("perhp:perabs:merge:short", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local curhp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    return FormatText(maxhp, (curhp + totalAbsorbs), true, true)
end, "Health", "90%")
W:AddTag("abs:healabs:merge", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    local tot = totalAbsorbs - totalHealAbsorbs
    if tot == 0 then return end
    return FormatText(tot)
end, "Health", "40000")
W:AddTag("abs:healabs:merge:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_ABSORB_AMOUNT_CHANGED", function(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    local tot = totalAbsorbs - totalHealAbsorbs
    if tot == 0 then return end
    return FormatText(tot, nil, false, true)
end, "Health", "-40k")

-- MARK: Heal Absorbs
W:AddTag("healabs", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    if totalHealAbsorbs == 0 then return end
    return FormatText(totalHealAbsorbs)
end, "Health", "20000")
W:AddTag("healabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", function(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    if totalHealAbsorbs == 0 then return end
    return FormatText(totalHealAbsorbs, nil, false, true)
end, "Health", "20K")
W:AddTag("perhealabs", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    if totalHealAbsorbs == 0 then return end
    local maxhp = UnitHealthMax(unit)
    return FormatText(maxhp, totalHealAbsorbs, true)
end, "Health", "40.20%")
W:AddTag("perhealabs:short", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit)
    local totalHealAbsorbs = UnitGetTotalHealAbsorbs(unit)
    if totalHealAbsorbs == 0 then return end
    local maxhp = UnitHealthMax(unit)
    return FormatText(maxhp, totalHealAbsorbs, true, true)
end, "Health", "40%")

-- MARK: Power
W:AddTag("curpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    return FormatText(UnitPower(unit))
end, "Power", "12000")
W:AddTag("curpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    return FormatText(UnitPower(unit), nil, false, true)
end, "Power", "12K")
W:AddTag("perpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    return FormatText(UnitPowerMax(unit), UnitPower(unit), true)
end, "Power", "80.20%")
W:AddTag("perpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    return FormatText(UnitPowerMax(unit), UnitPower(unit), true, true)
end, "Power", "80%")

W:AddTag("maxpp", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    return FormatText(UnitPowerMax(unit))
end, "Power", "15000")
W:AddTag("maxpp:short", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    return FormatText(UnitPowerMax(unit), nil, false, true)
end, "Power", "15K")

W:AddTag("defpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local deficit = UnitPower(unit) - UnitPowerMax(unit)
    if not deficit or deficit == 0 then return end
    return FormatText(deficit)
end, "Power", "-3000")
W:AddTag("defpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local deficit = UnitPower(unit) - UnitPowerMax(unit)
    if not deficit or deficit == 0 then return end
    return FormatText(deficit, nil, false, true)
end, "Power", "-3K")
W:AddTag("perdefpp", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit)
    local deficit = UnitPower(unit) - max
    if not deficit or deficit == 0 then return end
    return FormatText(max, deficit, true)
end, "Power", "-20.20%")
W:AddTag("perdefpp:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit)
    local deficit = UnitPower(unit) - max
    if not deficit or deficit == 0 then return end
    return FormatText(max, deficit, true, true)
end, "Power", "-20%")

-- MARK: Power Mana

local MANA_POWER_TYPE = Enum.PowerType.Mana

W:AddTag("curmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    if UnitPowerMax(unit, MANA_POWER_TYPE) == 0 then return end
    return FormatText(UnitPower(unit, MANA_POWER_TYPE))
end, "Power", "12000")
W:AddTag("curmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    if UnitPowerMax(unit, MANA_POWER_TYPE) == 0 then return end
    return FormatText(UnitPower(unit, MANA_POWER_TYPE), nil, false, true)
end, "Power", "12K")
W:AddTag("permana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max, UnitPower(unit, MANA_POWER_TYPE), true)
end, "Power", "80.20%")
W:AddTag("permana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max, UnitPower(unit, MANA_POWER_TYPE), true, true)
end, "Power", "80%")

W:AddTag("maxmana", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max)
end, "Power", "15000")
W:AddTag("maxmana:short", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max, nil, false, true)
end, "Power", "15K")

W:AddTag("defmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(deficit)
end, "Power", "-3000")
W:AddTag("defmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(deficit, nil, false, true)
end, "Power", "-3K")
W:AddTag("perdefmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(max, deficit, true)
end, "Power", "-20.20%")
W:AddTag("perdefmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(max, deficit, true, true)
end, "Power", "-20%")

-- MARK: Power Alt Mana

W:AddTag("curaltmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE
        or UnitPowerMax(unit, MANA_POWER_TYPE) == 0 then
        return
    end
    return FormatText(UnitPower(unit, MANA_POWER_TYPE))
end, "Power", "12000")
W:AddTag("curaltmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE
        or UnitPowerMax(unit, MANA_POWER_TYPE) == 0 then
        return
    end
    return FormatText(UnitPower(unit, MANA_POWER_TYPE), nil, false, true)
end, "Power", "12K")
W:AddTag("peraltmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max, UnitPower(unit, MANA_POWER_TYPE), true)
end, "Power", "80.20%")
W:AddTag("peraltmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max, UnitPower(unit, MANA_POWER_TYPE), true, true)
end, "Power", "80%")

W:AddTag("maxaltmana", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max)
end, "Power", "15000")
W:AddTag("maxaltmana:short", "UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    return FormatText(max, nil, false, true)
end, "Power", "15K")

W:AddTag("defaltmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(deficit)
end, "Power", "-3000")
W:AddTag("defaltmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(deficit, nil, false, true)
end, "Power", "-3K")
W:AddTag("perdefaltmana", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(max, deficit, true)
end, "Power", "-20.20%")
W:AddTag("perdefaltmana:short", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_MAXPOWER", function(unit)
    if UnitPowerType(unit) == MANA_POWER_TYPE then return end
    local max = UnitPowerMax(unit, MANA_POWER_TYPE)
    if max == 0 then return end
    local deficit = UnitPower(unit, MANA_POWER_TYPE) - max
    if not deficit or deficit == 0 then return end
    return FormatText(max, deficit, true, true)
end, "Power", "-20%")

-- MARK: Group
W:AddTag("group", "GROUP_ROSTER_UPDATE", function(unit)
    local subgroup = Util:GetUnitSubgroup(unit)
    if subgroup then
        return FormatNumber(subgroup)
    end
end, "Group", "1-8")

W:AddTag("group:raid", "GROUP_ROSTER_UPDATE", function(unit)
    if not IsInRaid() then return end
    local subgroup = Util:GetUnitSubgroup(unit)
    if subgroup then
        return FormatNumber(subgroup)
    end
end, "Group", "1-8")

-- MARK: Classification
W:AddTag("classification", "UNIT_CLASSIFICATION_CHANGED", function(unit)
    return Util:GetUnitClassification(unit, true)
end, "Classification", (L.rare .. ", " .. L.rareelite .. ", " .. L.elite .. ", " .. L.worldboss))
W:AddTag("classification:icon", "UNIT_CLASSIFICATION_CHANGED", function(unit)
    if UnitIsPlayer(unit) then return end
    return Util:GetUnitClassificationIcon(unit)
end, "Classification", "|A:nameplates-icon-elite-gold:16:16|a |A:nameplates-icon-elite-silver:16:16|a")

-- MARK: Name
for type, length in pairs(nameLengths) do
    local normalExample = Util.ShortenString("Sylvanas Windrunner", length)
    local abbrevExample = Util.ShortenString("S. Windrunner", length)

    W:AddTag("name:" .. type, "UNIT_NAME_UPDATE", function(unit)
        local unitName = UnitName(unit)
        if unitName then
            unitName = GetTranslitCellNickname(unitName, F.UnitFullName(unit))
            return Util.ShortenString(unitName, length)
        end
    end, "Name", normalExample)

    W:AddTag("name:abbrev:" .. type, "UNIT_NAME_UPDATE", function(unit)
        local unitName = UnitName(unit)
        if unitName then
            unitName = GetTranslitCellNickname(unitName, F.UnitFullName(unit))
            local abbreviated = Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
            return Util.ShortenString(abbreviated, length)
        end
    end, "Name", abbrevExample)

    W:AddTag("target:" .. type, "UNIT_TARGET", function(unit)
        local unitName = UnitName(unit .. "target")
        if unitName then
            unitName = GetTranslitCellNickname(unitName, F.UnitFullName(unit))
            return Util.ShortenString(unitName, length)
        end
    end, "Target", normalExample)

    W:AddTag("target:abbrev:" .. type, "UNIT_TARGET", function(unit)
        local unitName = UnitName(unit .. "target")
        if unitName then
            unitName = GetTranslitCellNickname(unitName, F.UnitFullName(unit))
            local abbreviated = Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
            return Util.ShortenString(abbreviated, length)
        end
    end, "Target", abbrevExample)
end

W:AddTag("name", "UNIT_NAME_UPDATE", function(unit)
    local unitName = UnitName(unit)
    if unitName then
        unitName = GetTranslitCellNickname(unitName, F.UnitFullName(unit))
        return unitName
    end
end, "Name", "Sylvanas Windrunner")
W:AddTag("name:abbrev", "UNIT_NAME_UPDATE", function(unit)
    local unitName = UnitName(unit)
    if unitName then
        unitName = GetTranslitCellNickname(unitName, F.UnitFullName(unit))
        return Util.FormatName(unitName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
    end
end, "Name", "S. Windrunner")

-- MARK: Target
W:AddTag("target", "UNIT_TARGET", function(unit)
    local targetName = UnitName(unit .. "target")
    if targetName then
        targetName = GetTranslitCellNickname(targetName, F.UnitFullName(unit .. "target"))
        return targetName
    end
end, "Target", "Sylvanas Windrunner")
W:AddTag("target:abbrev", "UNIT_TARGET", function(unit)
    local targetName = UnitName(unit .. "target")
    if targetName then
        targetName = GetTranslitCellNickname(targetName, F.UnitFullName(unit .. "target"))
        return Util.FormatName(targetName, const.NameFormat.FIRST_INITIAL_LAST_NAME)
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

W:AddTag("test", "UNIT_TARGET", function(unit)
    return "|cFFFF0000This is |cFFFFFFFFwhite|r red text"
end)
