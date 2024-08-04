---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.Cell = Cell

---@class CUF.constants
local const = {}
CUF.constants = const

---@alias Unit "player" | "target" | "focus"
const.UNIT = {
    PLAYER = "player",
    TARGET = "target",
    FOCUS = "focus",
}

---@enum PowerColorType
const.PowerColorType = {
    CLASS_COLOR = "class_color",
    CUSTOM = "custom",
    POWER_COLOR = "power_color",
}

---@enum ColorType
const.ColorType = {
    CLASS_COLOR = "class_color",
    CUSTOM = "custom",
}

---@alias PowerTextFormat
---| "percentage"
---| "number"
---| "number-short"
const.PowerTextFormat = {
    PERCENTAGE = "percentage",
    NUMBER = "number",
    NUMBER_SHORT = "number-short",
}

---@alias HealthTextFormat
---| PowerTextFormat
---| "percentage-absorbs"
---| "percentage-absorbs-merged"
---| "percentage-deficit"
---| "number-absorbs-short"
---| "number-absorbs-merged-short"
---| "number-deficit"
---| "number-deficit-short"
---| "current-short-percentage"
---| "absorbs-only"
---| "absorbs-only-short"
---| "absorbs-only-percentage"
const.HealthTextFormat = {
    PERCENTAGE = "percentage",
    NUMBER = "number",
    NUMBER_SHORT = "number-short",
    PERCENTAGE_ABSORBS = "percentage-absorbs",
    PERCENTAGE_ABSORBS_MERGED = "percentage-absorbs-merged",
    PERCENTAGE_DEFICIT = "percentage-deficit",
    NUMBER_ABSORBS_SHORT = "number-absorbs-short",
    NUMBER_ABSORBS_MERGED_SHORT = "number-absorbs-merged-short",
    NUMBER_DEFICIT = "number-deficit",
    NUMBER_DEFICIT_SHORT = "number-deficit-short",
    CURRENT_SHORT_PERCENTAGE = "current-short-percentage",
    ABSORBS_ONLY = "absorbs-only",
    ABSORBS_ONLY_SHORT = "absorbs-only-short",
    ABSORBS_ONLY_PERCENTAGE = "absorbs-only-percentage",
}

---@alias WIDGET_KIND "nameText" | "healthText" | "powerText" | "buffs" | "debuffs"
const.WIDGET_KIND = {
    NAME_TEXT = "nameText",
    HEALTH_TEXT = "healthText",
    POWER_TEXT = "powerText",
    BUFFS = "buffs",
    DEBUFFS = "debuffs",
}

---@alias OPTION_KIND
---| "enabled"
---| "position"
---| "font"
---| "width"
---| "textWidth"
---| "textColor"
---| "healthFormat"
---| "powerFormat"
---| "format"
---| "height"
---| "outline"
---| "style"
---| "shadow"
---| "anchor"
---| "offsetX"
---| "offsetY"
---| "color"
---| "type"
---| "extraAnchor"
const.OPTION_KIND = {
    ENABLED = "enabled",
    POSITION = "position",
    FONT = "font",
    WIDTH = "width",
    TEXT_WIDTH = "textWidth",
    TEXT_COLOR = "textColor",
    HEALTH_FORMAT = "healthFormat",
    POWER_FORMAT = "powerFormat",
    ORIENTATION = "orientation",
    FORMAT = "format",
    OUTLINE = "outline",
    STYLE = "style",
    SHADOW = "shadow",
    COLOR = "color",
}

---@alias AURA_OPTION_KIND
---| "size"
---| "font"
---| "orientation"
---| "position"
---| "showDuration"
---| "showAnimation"
---| "showStack"
---| "showTooltip"
---| "spacing"
---| "numPerLine"
---| "filter"
---| "maxIcons"
---| "minDuration"
---| "maxDuration"
---| "hidePersonal"
---| "hideExternal"
---| "horizontal"
---| "vertical"
---| "hideNoDuration"
---| "useBlacklist"
---| "useWhitelist"
---| "duration"
---| "stacks"
const.AURA_OPTION_KIND = {
    SIZE = "size",
    FONT = "font",
    ORIENTATION = "orientation",
    POSITION = "position",
    SHOW_DURATION = "showDuration",
    SHOW_ANIMATION = "showAnimation",
    SHOW_STACK = "showStack",
    SHOW_TOOLTIP = "showTooltip",
    SPACING = "spacing",
    NUM_PER_LINE = "numPerLine",
    FILTER = "filter",
    MAX_ICONS = "maxIcons"
}

---@alias AuraOrientation "right-to-left" | "left-to-right" | "top-to-bottom" | "bottom-to-top"
const.AURA_ORIENTATION = {
    RIGHT_TO_LEFT = "right-to-left",
    LEFT_TO_RIGHT = "left-to-right",
    TOP_TO_BOTTOM = "top-to-bottom",
    BOTTOM_TO_TOP = "bottom-to-top",
}

---@enum FontKind
const.FONTS = {
    CELL_WIGET = "CELL_FONT_WIDGET",
    CELL_SPECIAL = "CELL_FONT_SPECIAL",
}
