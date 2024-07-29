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
menu.selectedLayoutTable = Cell.vars.currentLayoutTable
menu.selectedUnit = "player"
menu.init = false
menu.hookInit = false

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
