---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.Cell = Cell

CUF.version = 2
CUF.debug = true
CUF.debugDB = true
CUF.units = { "player", "target", "focus" }

local F = Cell.funcs
local Util = CUF.Util

-- MARK: Overrides
-------------------------------------------------------
-- local Cell functions

local IterateAllUnitButtons = F.IterateAllUnitButtons

function F:IterateAllUnitButtons(...)
    IterateAllUnitButtons(self, ...)

    -- We need this to get clickCasting properly set up
    local func, updateCurrentGroupOnly, updateQuickAssist = ...
    if func and type(func) == "function" and not updateCurrentGroupOnly and updateQuickAssist then
        -- player
        func(Cell.unitButtons.player["player"])

        -- Target
        func(Cell.unitButtons.target["target"])

        -- Focus
        func(Cell.unitButtons.focus["focus"])
    end
end

for _, unit in pairs(CUF.units) do
    -- Load layout defaults (Layout_Defaults.lua)
    Cell.defaults.layout[unit] = CUF.defaults.unitFrame
    -- Insert unit buttons (MainFrame.lua)
    Cell.unitButtons[unit] = {}
end

-- MARK: Verify DB
-------------------------------------------------------

if type(CUFDB) ~= "table" then CUFDB = {} end

for _, layout in pairs(CellDB["layouts"]) do
    for _, unit in pairs(CUF.units) do
        if type(layout[unit]) ~= "table" then
            layout[unit] = F:Copy(Cell.defaults.layout[unit])
        else
            Util:AddMissingProps(layout[unit], CUF.defaults.unitFrame)
        end
    end
end

CUFDB.version = CUF.version
