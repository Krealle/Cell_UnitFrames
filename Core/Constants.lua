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

---@alias WIDGET_KIND "nameText" | "healthText" | "powerText"
const.WIDGET_KIND = {
    NAME_TEXT = "nameText",
    HEALTH_TEXT = "healthText",
    POWER_TEXT = "powerText",
}
