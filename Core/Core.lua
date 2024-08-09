---@type string
local AddonName = ...
---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.version = 2

---@class CUF.widgets
CUF.widgets = {}
---@class CUF.uFuncs
CUF.uFuncs = {}
CUF.unitButtons = {}

---@class CUF.vars
---@field selectedLayout string
---@field selectedUnit Unit
---@field selectedWidget WIDGET_KIND
---@field selectedLayoutTable LayoutTable
---@field selectedWidgetTable WidgetTables
---@field testMode boolean
CUF.vars = {}

-------------------------------------------------
-- MARK: OnAddonLoaded
-------------------------------------------------

---@param owner number
---@param loadedAddonName string
---@return boolean
local function OnAddonLoaded(owner, loadedAddonName)
    if loadedAddonName == AddonName then
        -- Load our DB
        CUF_DB = CUF_DB or {}

        -- Load Cell and type it
        CUF.Cell = Cell
        CellDB = CellDB --[[@as CellDB]]
        Cell.vars.currentLayout = Cell.vars.currentLayout --[[@as string]]
        Cell.vars.currentLayoutTable = Cell.vars.currentLayoutTable --[[@as LayoutTable]]

        -- Verify DB
        for _layoutName, layout in pairs(CellDB["layouts"]) do
            for unit, unitLayout in pairs(CUF.Defaults.Layouts) do
                if type(layout[unit]) ~= "table" then
                    layout[unit] = Cell.funcs:Copy(unitLayout)
                else
                    --layout[unit].widgets["nameText"] = layout[unit].widgets.name
                    CUF.Util:AddMissingProps(layout[unit], unitLayout)
                end
            end
        end

        CUF_DB.version = CUF.version

        return true
    end

    return false
end
CUF:AddEventListener("ADDON_LOADED", OnAddonLoaded)

-------------------------------------------------
-- MARK: OnPlayerLogin
-------------------------------------------------

---@param playerLoginOwnerId number
---@return boolean
local function OnPlayerLogin(playerLoginOwnerId)
    -- Load vars
    CUF.vars.isMenuOpen = false
    CUF.vars.testMode = true

    CUF.vars.selectedUnit = CUF.constants.UNIT.PLAYER
    CUF.vars.selectedWidget = CUF.constants.WIDGET_KIND.NAME_TEXT
    CUF.vars.selectedLayout = Cell.vars.currentLayout
    CUF.vars.selectedLayoutTable = Cell.vars.currentLayoutTable
    CUF.vars.selectedWidgetTable = CUF.vars.selectedLayoutTable[CUF.vars.selectedUnit].widgets

    -- Hide Blizzard Unit Frames
    for _, unit in pairs(CUF.constants.UNIT) do
        if CUF.vars.selectedLayoutTable[unit].enabled then
            CUF:HideBlizzardUnitFrame(unit)
        end
    end

    -- Init Unit Buttons
    CUF.uFuncs:InitUnitButtons()
    CUF:Fire("UpdateUnitButtons")

    -- Register callbacks
    Cell:RegisterCallback("UpdateIndicators", "CUF_UpdateIndicators",
        function(layout) CUF:Fire("UpdateWidget", layout) end)

    -- Init widgets
    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout)

    return true
end
CUF:AddEventListener("PLAYER_LOGIN", OnPlayerLogin)
