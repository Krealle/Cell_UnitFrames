---@class CUF
local CUF = select(2, ...)

---@class CUF.constants
local const = CUF.constants

CUF.defaults = {}

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
    frameLevel = 10
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
    textFormat = "",
    frameLevel = 10
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
    textFormat = "",
    frameLevel = 10
}

---@class AuraFilterOpt
---@field useBlacklist boolean
---@field blacklist table<number>
---@field useWhitelist boolean
---@field whitelist table<number>
---@field minDuration number
---@field maxDuration number
---@field hidePersonal boolean
---@field hideExternal boolean
---@field hideNoDuration boolean
local auraFilterOpt = {
    ["useBlacklist"] = false,
    ["blacklist"] = {},
    ["useWhitelist"] = false,
    ["whitelist"] = {},
    ["minDuration"] = 0,
    ["maxDuration"] = 0,
    ["hidePersonal"] = false,
    ["hideExternal"] = false,
    ["hideNoDuration"] = false,
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
---@field maxIcons number
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
    numPerLine = 5,
    maxIcons = 10
}

---@class RaidIconWidgetTable
---@field enabled boolean
---@field size SizeOpt
---@field position PositionOpt
local raidIconWidget = {
    enabled = false,
    size = sizeOpt,
    position = positionOpt,
    frameLevel = 10
}

---@class RoleIconWidgetTable
---@field enabled boolean
---@field size SizeOpt
---@field position PositionOpt
local roleIconWidget = {
    enabled = false,
    size = sizeOpt,
    position = positionOpt,
    frameLevel = 10
}

---@class LeaderIconWidgetTable
---@field enabled boolean
---@field size SizeOpt
---@field position PositionOpt
local leaderIconWidget = {
    enabled = false,
    size = sizeOpt,
    position = positionOpt,
    frameLevel = 10
}

---@class CombatIconWidgetTable: BaseWidgetTable
local combatIconWidget = {
    enabled = false,
    size = sizeOpt,
    position = positionOpt,
    frameLevel = 10
}

---@class ShieldBarWidgetTable: BaseWidgetTable
local shieldBarWidget = {
    enabled = false,
    size = sizeOpt,
    position = positionOpt,
    rgba = { 1, 1, 0, 0.25 },
    frameLevel = 10,
}

---@class UnitFrameWidgetsTable
local unitFrameWidgets = {
    nameText = nameWidget,
    healthText = healthTextWidget,
    powerText = powerTextWidget,
    buffs = auraWidget,
    debuffs = auraWidget,
    raidIcon = raidIconWidget,
    roleIcon = roleIconWidget,
    leaderIcon = leaderIconWidget,
    combatIcon = combatIconWidget,
    shieldBar = shieldBarWidget,
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
