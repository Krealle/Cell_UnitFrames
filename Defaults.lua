---@class CUF
local CUF = select(2, ...)

CUF.defaults = {}

---@class CUF.defaults.color
---@field type "class_color" | "custom"
---@field rgb table<number>
local colorOpt = {
    ["type"] = "class_color",
    ["rgb"] = { 1, 1, 1 },
}

---@class CUF.defaults.font
---@field size number
---@field outline "outline" | "none"
---@field shadow boolean
---@field style string
local fontOpt = {
    ["size"] = 12,
    ["outline"] = "outline",
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

---@class CUF.defaults.unitFrame.widgets
local unitFrameWidgets = {
    ["name"] = {
        ["enabled"] = true,
        ["color"] = colorOpt,
        ["font"] = fontOpt,
        ["position"] = positionOpt,
        ["width"] = { ["type"] = "percent", ["value"] = 0.75 },
    },
}

---@class CUF.defaults.unitFrame
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
