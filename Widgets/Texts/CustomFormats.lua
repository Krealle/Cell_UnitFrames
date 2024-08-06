---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets

-------------------------------------------------
-- MARK: Tags
-------------------------------------------------

local valid_tags = {
    ["perhp"] = function(current, max, totalAbsorbs)
        return string.format("%d%%", current / max * 100)
    end,
    ["curhp"] = function(current, max, totalAbsorbs)
        return tostring(current)
    end,
    ["curhp-short"] = function(current, max, totalAbsorbs)
        return F:FormatNumber(current)
    end,
}

---@param textFormat string
---@return function?
local function findTagFunction(textFormat)
    return valid_tags[textFormat]
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
-- local preBuiltFunction = W.ProcessCustomTextFormat("[perhp] | [curhp-short]")
--
-- local finalString = preBuiltFunction(100, 12600, 0)
--
-- print(finalString) -- Output: 100% | 12.6k
---@param textFormat string
function W.ProcessCustomTextFormat(textFormat)
    local elements = {}
    local lastEnd = 1

    -- Process the text format and find all bracketed tags
    textFormat:gsub("%b[]", function(bracketed)
        local startPos, endPos = textFormat:find("%b[]", lastEnd)
        if startPos > lastEnd then
            table.insert(elements, textFormat:sub(lastEnd, startPos - 1))
        end

        local tag = bracketed:sub(2, -2)
        local maybeFunc = findTagFunction(tag)

        if maybeFunc then
            table.insert(elements, maybeFunc)
        else
            table.insert(elements, bracketed)
        end

        lastEnd = endPos + 1
    end)

    -- Add any remaining text after the last tag
    if lastEnd <= #textFormat then
        table.insert(elements, textFormat:sub(lastEnd))
    end

    ---@param current number
    ---@param max number
    ---@param totalAbsorbs number
    ---@return string
    return function(current, max, totalAbsorbs)
        local result = {}

        for i, element in ipairs(elements) do
            if type(element) == "function" then
                local success, output = pcall(element, current, max, totalAbsorbs)
                if success then
                    result[i] = output
                else
                    result[i] = "n/a"
                end
            else
                result[i] = element
            end
        end

        return table.concat(result)
    end
end
