---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local P = Cell.pixelPerfectFuncs
local Util = CUF.Util

local menuWindow = CUF.MenuWindow

---@class CUF.Menu
local menu = {}
menu = {}
menu.window = menuWindow
menu.unitsToAdd = {}
menu.widgetsToAdd = {}
menu.selectedLayout = Cell.vars.currentLayout
---@type LayoutTable
menu.selectedLayoutTable = Cell.vars.currentLayoutTable
menu.selectedUnit = "player"
menu.selectedWidget = "name"
menu.selectedWidgetTable = {}
menu.init = false
menu.hookInit = false

CUF.Menu = menu

---@param unit function
function menu:AddUnit(unit)
    CUF:Debug("Menu - AddUnit")
    table.insert(self.unitsToAdd, unit)
end

---@param widget function
function menu:AddWidget(widget)
    CUF:Debug("Menu - AddWidget")
    table.insert(self.widgetsToAdd, widget)
end

---@param unit string|nil
---@param widget string|nil
function menu:UpdateSelected(unit, widget)
    if unit then
        self.selectedUnit = unit
        self.selectedWidgetTable = self.selectedLayoutTable[unit].widgets
    end

    if widget then
        self.selectedWidget = widget
    end

    CUF:Debug("UpdateSelected:", unit, widget)
    CUF:Fire("LoadPageDB", unit, widget)
end

-- Load layout from DB
---@param layout string
local function LoadLayoutDB(layout)
    menu.selectedLayout = layout
    menu.selectedLayoutTable = CellDB["layouts"][layout]
    menu.selectedWidgetTable = menu.selectedLayoutTable[menu.selectedUnit].widgets

    CUF:Debug("LoadLayoutDB:", menu.selectedUnit, menu.selectedWidget)
    CUF:Fire("LoadPageDB", menu.selectedUnit, menu.selectedWidget)
    CUF:Fire("UpdateVisibility")
end

-- MARK: Callbacks

---@param tab string
local function ShowTab(tab)
    if tab == "layouts" then
        LoadLayoutDB(Cell.vars.currentLayout)

        menuWindow:ShowMenu()

        if not menu.init then
            menu.init = true
        end
    else
        menuWindow:HideMenu()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "CellUnitFrames_ShowTab", ShowTab)

-- This is hacky, but it works
-- This is needed to get access to current layout, since this
-- is the only place where this info is outside of local scope
local function UpdatePreview()
    if not menu.init or menu.hookInit then return end

    local layoutsTab = Util.findChildByName(Cell.frames.optionsFrame, "CellOptionsFrame_LayoutsTab")
    local layoutPane = Util.findChildByName(layoutsTab, "Layout")
    local layoutDropdown = Util.findChildByProp(layoutPane, "items")

    hooksecurefunc(layoutDropdown, "SetSelected", function(self)
        LoadLayoutDB(self:GetSelected())
    end)
    hooksecurefunc(layoutDropdown, "SetSelectedValue", function(self)
        LoadLayoutDB(self:GetSelected())
    end)

    LoadLayoutDB(layoutDropdown:GetSelected())
    Cell:UnregisterCallback("UpdatePreview", "CellUnitFrames_UpdatePreview")

    menu.hookInit = true
end
Cell:RegisterCallback("UpdatePreview", "CellUnitFrames_UpdatePreview", UpdatePreview)
