---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local Util = CUF.Util

local menuWindow = CUF.MenuWindow
local DB = CUF.DB

---@class CUF.Menu
---@field selectedWidgetTable WidgetTable
---@field unitsToAdd table<number, function>
---@field widgetsToAdd table<number, WidgetsMenuPageArgs>
local menu = {}
menu.window = menuWindow
menu.unitsToAdd = {}
menu.widgetsToAdd = {}
menu.init = false
menu.hookInit = false

CUF.Menu = menu

---@param unit function
function menu:AddUnit(unit)
    --CUF:Log("Menu - AddUnit")
    table.insert(self.unitsToAdd, unit)
end

---@param widgetName WIDGET_KIND
---@param ... MenuOptions
function menu:AddWidget(widgetName, ...)
    --CUF:Log("Menu - AddWidget")
    table.insert(self.widgetsToAdd,
        { ["widgetName"] = widgetName, ["options"] = { ... } })
end

-------------------------------------------------
-- MARK: Update vars
-------------------------------------------------

-- Update the selected unit and widget vars fire `LoadPageDB` callback
---@param unit Unit|nil
---@param widget WIDGET_KIND|nil
function menu:UpdateSelectedPages(unit, widget)
    --CUF:Log("|cff00ff00menu:UpdateSelected:|r", unit, widget)

    if unit then
        CUF.vars.selectedUnit = unit
    end

    if widget then
        CUF.vars.selectedWidget = widget
    end

    -- Prevent excessive calls when initializing
    if not menu.window.init then return end

    CUF:Fire("LoadPageDB", unit, widget)
end

-- Load layout vars from DB
--
-- Hooked to `layoutDropdown` from Cell `layoutsTab`
--
-- Fires `LoadPageDB` and `UpdateVisibility` callbacks
---@param layout string
local function LoadLayoutDB(layout)
    CUF:Log("|cff00ff00LoadLayoutDB:|r", layout, CUF.vars.selectedUnit, CUF.vars.selectedWidget)

    CUF.vars.selectedLayout = layout

    menu.window:ShowMenu()
    CUF:Fire("LoadPageDB", CUF.vars.selectedUnit, CUF.vars.selectedWidget)
    CUF:Fire("UpdateVisibility")
end

-------------------------------------------------
-- MARK: Callbacks - Hooks
-------------------------------------------------

-- This is hacky, but it works
-- To make sure that we always have the correct layout selected
-- We need to hook on to Cell somehow, since the value in the dropdown
-- In the layout tab isn't exposed to us.
--
-- So here we hook on to the `SetSelectedValue` fn to grab the value
--
-- We can only hook once it's initialized, so we hook on to the `ShowOptionsTab` callback
-- Which we use to hook on to the `UpdatePreview` callback, since both are fired when the
-- `layouts` tab is selected.
--
-- We then unhook on to the `UpdatePreview` callback, since we no longer need it.
local function UpdatePreview()
    --CUF:Log("Cell_UpdatePreview")
    local layoutsTab = Util.findChildByName(Cell.frames.optionsFrame, "CellOptionsFrame_LayoutsTab")
    if not layoutsTab then return end

    local layoutPane = Util.findChildByName(layoutsTab, "Layout")
    if not layoutPane then return end

    local layoutDropdown = Util.findChildByProp(layoutPane, "items")
    if not layoutDropdown then return end

    hooksecurefunc(layoutDropdown, "SetSelectedValue", function(self)
        --CUF:Log("Cell_SetSelectedValue", self:GetSelected())
        LoadLayoutDB(self:GetSelected())
    end)

    -- Initial load
    LoadLayoutDB(layoutDropdown:GetSelected())

    -- Unhook
    Cell:UnregisterCallback("UpdatePreview", "CUF_UpdatePreview")
end

---@param tab string
local function ShowTab(tab)
    --CUF:Log("Cell_ShowTab", tab)
    if tab ~= "layouts" then
        menuWindow:HideMenu()
    elseif not menu.window.init then
        -- Inital hook
        Cell:RegisterCallback("UpdatePreview", "CUF_UpdatePreview", UpdatePreview)
    end
end
Cell:RegisterCallback("ShowOptionsTab", "CUFShowTab", ShowTab)
