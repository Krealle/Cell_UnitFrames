---@type string
local AddonName = ...
---@class CUF
local CUF = select(2, ...)

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

    Cell:RegisterCallback("UpdateLayout", "CUF_UpdateLayout",
        function(layout, kind) CUF:Fire("UpdateLayout", layout, kind) end)

    Cell:RegisterCallback("ShowOptionsTab", "CUF_ShowOptionsTab",
        function(tab) CUF:Fire("ShowOptionsTab", tab) end)

    Cell:RegisterCallback("UpdateMenu", "CUF_UpdateMenu",
        function(kind) CUF:Fire("UpdateMenu", kind) end)

    Cell:RegisterCallback("UpdatePixelPerfect", "CUF_UpdatePixelPerfect",
        function() CUF:Fire("UpdatePixelPerfect") end)

    Cell:RegisterCallback("UpdateVisibility", "CUF_UpdateVisibility",
        function(which) CUF:Fire("UpdateVisibility", which) end)

    Cell:RegisterCallback("UpdateAppearance", "CUF_UpdateAppearance",
        function(kind) CUF:Fire("UpdateAppearance", kind) end)

    -- Init widgets
    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout)

    Cell:UnregisterCallback("UpdateLayout", "CUF_Initial_UpdateLayout")
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

        Cell:RegisterCallback("UpdateLayout", "CUF_Initial_UpdateLayout", OnCellInitialUpdateLayout)

        return true
    end

    return false
end
CUF:AddEventListener("ADDON_LOADED", OnAddonLoaded)
