---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local P = Cell.pixelPerfectFuncs

local menuWindow = CUF.MenuWindow

---@class CUF.Menu
local menu = {}
menu = {}
menu.window = menuWindow
menu.unitsToAdd = {}
menu.widgetsToAdd = {}
menu.selectedLayout = Cell.vars.currentLayout
menu.selectedLayoutTable = Cell.vars.currentLayoutTable
menu.selectedUnit = "player"

CUF.Menu = menu

---@param unit function
function menu:AddUnit(unit)
    CUF:Debug("Menu - AddUnit")
    table.insert(self.unitsToAdd, unit)
end

-- Load layout from DB
---@param layout string
local function LoadLayoutDB(layout)
    menu.selectedLayout = layout
    menu.selectedLayoutTable = CellDB["layouts"][layout]

    CUF:Fire("LoadPageDB", menu.selectedUnit)
    CUF:Fire("UpdateVisibility")
end

-- MARK: Callbacks

---@param tab string
local function ShowTab(tab)
    if tab == "layouts" then
        LoadLayoutDB(Cell.vars.currentLayout)

        menuWindow:ShowMenu()
    else
        menuWindow:HideMenu()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "CellUnitFrames_ShowTab", ShowTab)
