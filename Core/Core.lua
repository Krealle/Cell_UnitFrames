---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.Cell = Cell

CellDB = CellDB --[[@as CellDB]]
Cell.vars.currentLayout = Cell.vars.currentLayout --[[@as string]]
Cell.vars.currentLayoutTable = Cell.vars.currentLayoutTable --[[@as LayoutTable]]

CUF.version = 2

---@class CUF.widgets
CUF.widgets = {}
---@class CUF.uFuncs
CUF.uFuncs = {}
---@class CUF.constants
local const = CUF.constants

---@class CUF.vars
---@field selectedLayout string
---@field selectedUnit Unit
---@field selectedWidget WIDGET_KIND
---@field selectedLayoutTable LayoutTable
---@field selectedWidgetTable UnitFrameWidgetsTable
---@field units table<number, Unit>
CUF.vars = {}
CUF.vars.units = { const.UNIT.PLAYER, const.UNIT.TARGET, const.UNIT.FOCUS }
CUF.vars.isMenuOpen = false
CUF.vars.testMode = true
CUF.vars.debug = false
CUF.vars.debugDB = false

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
        func(Cell.unitButtons.player)

        -- Target
        func(Cell.unitButtons.target)

        -- Focus
        func(Cell.unitButtons.focus)
    end
end

for _, unit in pairs(CUF.vars.units) do
    -- Load layout defaults (Layout_Defaults.lua)
    Cell.defaults.layout[unit] = CUF.defaults.unitFrame
    -- Insert unit buttons (MainFrame.lua)
    Cell.unitButtons[unit] = {}
end

-- MARK: Verify DB
-------------------------------------------------------

if type(CUFDB) ~= "table" then CUFDB = {} end

for _, layout in pairs(CellDB["layouts"]) do
    for _, unit in pairs(CUF.vars.units) do
        --layout[unit].widgets.debuffs = nil

        if type(layout[unit]) ~= "table" then
            layout[unit] = F:Copy(Cell.defaults.layout[unit])
        else
            --layout[unit].widgets["nameText"] = layout[unit].widgets.name
            Util:AddMissingProps(layout[unit], CUF.defaults.unitFrame)
        end
    end
end

CUFDB.version = CUF.version

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    CUF.vars.selectedUnit = const.UNIT.PLAYER
    CUF.vars.selectedWidget = const.WIDGET_KIND.NAME_TEXT
    CUF.vars.selectedLayout = Cell.vars.currentLayout
    CUF.vars.selectedLayoutTable = Cell.vars.currentLayoutTable
    CUF.vars.selectedWidgetTable = CUF.vars.selectedLayoutTable[CUF.vars.selectedUnit].widgets

    for _, unit in pairs(CUF.vars.units) do
        if CUF.vars.selectedLayoutTable[unit].enabled then
            CUF:HideBlizzardUnitFrame(unit)
        end
    end

    Cell:RegisterCallback("UpdateIndicators", "CUF_UpdateIndicators",
        function(layout) CUF:Fire("UpdateWidget", layout) end)

    CUF:Fire("UpdateWidget", Cell.vars.currentLayout)
end)
