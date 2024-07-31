---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.Cell = Cell

---@class CUF.constants
local const = {}
CUF.constants = const

--[[ ---@enum Units
const.UNITS = {
    ["player"] = "player",
    ["target"] = "target",
    ["focus"] = "focus",
} ]]

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
