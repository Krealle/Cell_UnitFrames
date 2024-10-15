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
    CUF.vars.testMode = false

    CUF.vars.selectedUnit = CUF.constants.UNIT.PLAYER
    CUF.vars.selectedWidget = CUF.constants.WIDGET_KIND.NAME_TEXT
    CUF.vars.selectedLayout = Cell.vars.currentLayout
    CUF.vars.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    CUF.vars.inEditMode = false

    -- Hide Blizzard Unit Frames
    for _, unit in pairs(CUF.constants.UNIT) do
        if CUF.DB.CurrentLayoutTable()[unit].enabled then
            CUF:HideBlizzardUnitFrame(unit)
        end
    end

    -- Main Frame
    ---@class CUFMainFrame: Frame
    local CUFMainFrame = CreateFrame("Frame", "CUFMainFrame", UIParent, "SecureFrameTemplate")
    CUF.mainFrame = CUFMainFrame
    CUFMainFrame:SetIgnoreParentScale(true)
    CUF.Util.SetPixelScale(CUFMainFrame)

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

    Cell:RegisterCallback("UpdateQueuedClickCastings", "CUF_UpdateQueuedClickCastings",
        function() CUF:Fire("UpdateClickCasting", true, true) end)
    Cell:RegisterCallback("UpdateClickCastings", "CUF_UpdateClickCastings",
        function(noReload, onlyqueued) CUF:Fire("UpdateClickCasting", noReload, onlyqueued) end)

    -- Init widgets
    CUF:Fire("UpdateWidget", CUF.DB.GetMasterLayout())

    -- Callback used to make it easier for Cell snippets to know when the frames are initialized
    Cell:Fire("CUF_FramesInitialized")

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
        CUF.DB.InitDB()

        -- Load Cell and type it
        CUF.Cell = Cell
        CellDB = CellDB --[[@as CellDB]]
        Cell.vars.currentLayout = Cell.vars.currentLayout --[[@as string]]
        Cell.vars.currentLayoutTable = Cell.vars.currentLayoutTable --[[@as LayoutTable]]

        CUF.DB.VerifyDB()
        CUF.DB.VerifyUnitPositions()

        CUF_DB.version = CUF.version

        Cell:RegisterCallback("UpdateLayout", "CUF_Initial_UpdateLayout", OnCellInitialUpdateLayout)

        CUF:Fire("AddonLoaded")

        -- Use this to allow Cell snippets to manipulate functions before we start using them
        Cell:Fire("CUF_AddonLoaded")

        return true
    end

    return false
end
CUF:AddEventListener("ADDON_LOADED", OnAddonLoaded)
