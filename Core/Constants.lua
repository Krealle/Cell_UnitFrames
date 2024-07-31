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

---@alias WIDGET_KIND "nameText" | "healthText" | "powerText"
const.WIDGET_KIND = {
    NAME_TEXT = "nameText",
    HEALTH_TEXT = "healthText",
    POWER_TEXT = "powerText",
}
