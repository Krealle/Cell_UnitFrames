---@class CUF
local CUF = select(2, ...)

---@class CUF.constants
local const = CUF.constants

CUF.defaults = {}
CUF.anchorPoints = { "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT" }
CUF.outlines = { "None", "Outline", "Monochrome" }

---@type ColorOpt
local colorOpt = {
    ["type"] = const.ColorType.CLASS_COLOR,
    ["rgb"] = { 1, 1, 1 },
}

---@type SmallFontOpt
local smallFontOpt = {
    ["size"] = 12,
    ["outline"] = "Outline",
    ["shadow"] = true,
    ["style"] = "Cell Default",
}

---@type BigFontOpt
local bigFontOpt = {
    ["size"] = 16,
    ["outline"] = "Outline",
    ["shadow"] = true,
    ["style"] = "Cell Default",
    ["anchor"] = "CENTER",
    ["offsetX"] = 0,
    ["offsetY"] = 0,
    ["rgb"] = { 1, 1, 1 },
}

---@type AuraFontOpt
local auraFontOpt = {
    ["stacks"] = bigFontOpt,
    ["duration"] = bigFontOpt,
}

---@type PositionOpt
local positionOpt = {
    ["anchor"] = "CENTER",
    ["extraAnchor"] = "CENTER",
    ["offsetX"] = 0,
    ["offsetY"] = 0,
}

---@type SizeOpt
local sizeOpt = {
    ["width"] = 20,
    ["height"] = 20,
}

---@class SpacingOpt
local spacingOpt = {
    horizontal = 0,
    vertical = 0,
}

local unitFrameIndicators = {
    ["buffs"] = {
        ["enabled"] = true,
        ["size"] = 4,
        ["spacing"] = 4,
        ["max"] = 16,
        ["blacklist"] = {
            ["enabled"] = false,
            ["list"] = {},
        },
        ["anchor"] = "TOPLEFT",
        ["offset"] = { 0, 0 },
        ["orientation"] = "right",
    },
}

---@type FontWidth
local defaultFontWidth = {
    ["type"] = "percentage",
    ["value"] = 0.75,
    ["auxValue"] = 3,
}
CUF.defaults.fontWidth = defaultFontWidth

---@type TextWidgetTable
local nameWidget = {
    ["enabled"] = true,
    ["color"] = colorOpt,
    ["font"] = smallFontOpt,
    ["position"] = positionOpt,
    ["width"] = defaultFontWidth,
}

---@type HealthTextWidgetTable
local healthTextWidget = {
    ["enabled"] = true,
    ["color"] = colorOpt,
    ["font"] = smallFontOpt,
    ["position"] = positionOpt,
    ["width"] = defaultFontWidth,
    ["format"] = "percentage",
    ["hideIfEmptyOrFull"] = false,
}

---@type PowerTextWidgetTable
local powerTextWidget = {
    ["enabled"] = true,
    ["color"] = colorOpt,
    ["font"] = smallFontOpt,
    ["position"] = positionOpt,
    ["width"] = defaultFontWidth,
    ["format"] = "percentage",
    ["hideIfEmptyOrFull"] = false,
}

---@class AuraFilterOpt
---@field useBlacklist boolean
---@field blacklist table<number, boolean>
---@field useWhitelist boolean
---@field whitelist table<number, boolean>
---@field minDuration number
---@field maxDuration number
---@field hidePersonal boolean
---@field hideExternal boolean
local auraFilterOpt = {
    ["useBlacklist"] = false,
    ["blacklist"] = {},
    ["useWhitelist"] = false,
    ["whitelist"] = {},
    ["minDuration"] = 0,
    ["maxDuration"] = 0,
    ["hidePersonal"] = false,
    ["hideExternal"] = false,
}

---@class AuraWidgetTable
---@field enabled boolean
---@field size SizeOpt
---@field font AuraFontOpt
---@field orientation AuraOrientation
---@field showStack boolean
---@field showDuration boolean|number
---@field showAnimation boolean
---@field filter AuraFilterOpt
---@field showTooltip boolean
---@field position PositionOpt
---@field spacing SpacingOpt
---@field numPerLine number
local auraWidget = {
    enabled = false,
    font = auraFontOpt,
    position = positionOpt,
    size = sizeOpt,
    orientation = const.AURA_ORIENTATION.RIGHT_TO_LEFT,
    showStack = true,
    showDuration = true,
    showAnimation = true,
    showTooltip = true,
    filter = auraFilterOpt,
    spacing = spacingOpt,
    numPerLine = 1,
}

---@class UnitFrameWidgetsTable
---@field nameText TextWidgetTable
---@field healthText HealthTextWidgetTable
---@field powerText PowerTextWidgetTable
---@field buffs AuraWidgetTable
local unitFrameWidgets = {
    nameText = nameWidget,
    healthText = healthTextWidget,
    powerText = powerTextWidget,
    buffs = auraWidget,
}

---@class Layout
CUF.defaults.unitFrame = {
    ["enabled"] = false,
    ["sameSizeAsPlayer"] = false,
    ["size"] = { 66, 46 },
    ["position"] = {},
    ["tooltipPosition"] = {},
    ["powerSize"] = 2,
    ["anchor"] = "TOPLEFT",
    ["widgets"] = unitFrameWidgets,
    --[[ ["indicators"] = unitFrameIndicators, ]]
}
