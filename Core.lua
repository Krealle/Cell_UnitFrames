---@class CUF
local CUF = select(2, ...)

CUF.version = 1

local Cell = Cell
CUF.Cell = Cell

local F = Cell.funcs

-- MARK: Overrides
-------------------------------------------------------
-- local Cell functions

local IterateAllUnitButtons = F.IterateAllUnitButtons

function F:IterateAllUnitButtons(...)
    IterateAllUnitButtons(self, ...)

    local func = ...
    if func and type(func) == "function" then
        -- player
        func(Cell.unitButtons.player["player"])

        -- Target
        func(Cell.unitButtons.target["target"])

        -- Focus
        func(Cell.unitButtons.focus["focus"])
    end
end

-- MARK: Load layout defaults (Layout_Defaults.lua)
-------------------------------------------------------

local defaultLayout = {
    ["enabled"] = false,
    ["sameSizeAsPlayer"] = true,
    ["size"] = { 66, 46 },
    ["position"] = {},
    ["tooltipPosition"] = {},
    ["powerSize"] = 2,
    ["anchor"] = "TOPLEFT",
}
Cell.defaults.layout["player"] = defaultLayout
Cell.defaults.layout["target"] = defaultLayout
Cell.defaults.layout["focus"] = defaultLayout

-- MARK: Insert unit buttons (MainFrame.lua)
-------------------------------------------------------

Cell.unitButtons["player"] = {}
Cell.unitButtons["target"] = {}
Cell.unitButtons["focus"] = {}

-- MARK: Verify DB
-------------------------------------------------------

if type(CUFDB) ~= "table" then CUFDB = {} end

if not CUFDB["version"] or CUFDB["version"] ~= CUF.version then
    local units = { "player", "target", "focus" }

    for _, unit in pairs(units) do
        if type(CellDB["layouts"]["default"][unit]) ~= "table" then
            CellDB["layouts"]["default"][unit] = F:Copy(Cell.defaults.layout[unit])
        end
    end

    for _, layout in pairs(CellDB["layouts"]) do
        for _, unit in pairs(units) do
            if not layout[unit] then
                layout[unit] = F:Copy(Cell.defaults.layout[unit])
            end
        end
    end

    CUFDB["version"] = CUF.version
end
