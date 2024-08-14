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
---@field testMode boolean
CUF.vars = {}

-------------------------------------------------
-- MARK: OnPlayerEnteringWorld
-------------------------------------------------

---@param _layout string
local function OnCellInitialUpdateLayout(_layout)
    -- Load vars
    CUF.vars.isMenuOpen = false
    CUF.vars.testMode = true

    CUF.vars.selectedUnit = CUF.constants.UNIT.PLAYER
    CUF.vars.selectedWidget = CUF.constants.WIDGET_KIND.NAME_TEXT
    CUF.vars.selectedLayout = Cell.vars.currentLayout

    -- Hide Blizzard Unit Frames
    for _, unit in pairs(CUF.constants.UNIT) do
        if CUF.DB.SelectedLayoutTable()[unit].enabled then
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

    Cell:UnregisterCallback("UpdateLayout", "CUFInitial_UpdateLayout")
end

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

        CUF.DB.VerifyDB()

        CUF_DB.version = CUF.version

        Cell:RegisterCallback("UpdateLayout", "CUFInitial_UpdateLayout", OnCellInitialUpdateLayout)

        return true
    end

    return false
end
CUF:AddEventListener("ADDON_LOADED", OnAddonLoaded)
