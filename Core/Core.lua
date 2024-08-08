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
---@field selectedWidgetTable UnitFrameWidgetsTable
---@field testMode boolean
CUF.vars = {}

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

        -- Load layout defaults (Layout_Defaults.lua)
        for _, unit in pairs(CUF.constants.UNIT) do
            Cell.defaults.layout[unit] = CUF.defaults.unitFrame
        end

        -- Verify DB
        for _, layout in pairs(CellDB["layouts"]) do
            for _, unit in pairs(CUF.constants.UNIT) do
                --layout[unit].widgets.debuffs = nil

                if type(layout[unit]) ~= "table" then
                    layout[unit] = Cell.funcs:Copy(Cell.defaults.layout[unit])
                else
                    --layout[unit].widgets["nameText"] = layout[unit].widgets.name
                    CUF.Util:AddMissingProps(layout[unit], CUF.defaults.unitFrame)
                end
            end
        end

        CUF_DB.version = CUF.version

        return true
    end

    return false
end
CUF:AddEventListener("ADDON_LOADED", OnAddonLoaded)

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

    -- Register callbacks
    Cell:RegisterCallback("UpdateIndicators", "CUF_UpdateIndicators",
        function(layout) CUF:Fire("UpdateWidget", layout) end)

    -- Init widgets
    CUF:Fire("UpdateWidget", Cell.vars.currentLayout)

    return true
end
CUF:AddEventListener("PLAYER_LOGIN", OnPlayerLogin)
