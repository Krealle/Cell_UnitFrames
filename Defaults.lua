---@class CUF
local CUF = select(2, ...)

CUF.defaults = {}
CUF.anchorPoints = { "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT" }
CUF.outlines = { "None", "Outline", "Monochrome" }

---@class CUF.defaults.color
---@field type "class_color" | "custom"
---@field rgb table<number>
local colorOpt = {
    ["type"] = "class_color",
    ["rgb"] = { 1, 1, 1 },
}

---@class CUF.defaults.font
---@field size number
---@field outline "None" | "Outline" | "Monochrome"
---@field shadow boolean
---@field style string
local fontOpt = {
    ["size"] = 12,
    ["outline"] = "Outline",
    ["shadow"] = false,
    ["style"] = "Cell Default",
}

---@class CUF.defaults.position
---@field anchor AnchorPoint
---@field offsetX number
---@field offsetY number
local positionOpt = {
    ["anchor"] = "CENTER",
    ["offsetX"] = 0,
    ["offsetY"] = 0,
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

---@class CUF.defaults.width
---@field type "percentage" | "unlimited" | "length"
---@field value number
---@field auxValue number

---@class NameWidgetTable
---@field enabled boolean
---@field color CUF.defaults.color
---@field font CUF.defaults.font
---@field position CUF.defaults.position
---@field width CUF.defaults.width
local nameWidget = {
    ["enabled"] = true,
    ["color"] = colorOpt,
    ["font"] = fontOpt,
    ["position"] = positionOpt,
    ["width"] = { ["type"] = "percentage", ["value"] = 0.75, ["auxValue"] = 3 },
}

---@class UnitFrrameWidgetsTable
---@field name NameWidgetTable
local unitFrameWidgets = {
    ["name"] = nameWidget
}

---@class Layout
---@field enabled boolean
---@field sameSizeAsPlayer boolean
---@field size table<number, number>
---@field position table<string, number>
---@field tooltipPosition table<string, string>
---@field powerSize number
---@field anchor string
---@field widgets UnitFrrameWidgetsTable
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

---@alias LayoutTable table<string, Layout>
---@alias CellDB table<string, LayoutTable>
