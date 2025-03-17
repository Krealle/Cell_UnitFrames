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
    CUF.vars.selectedLayout = CUF.DB.GetMasterLayout()
    CUF.vars.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    CUF.vars.inEditMode = false

    -- Hide Blizzard Frames
    for type, hidden in pairs(CUF_DB.blizzardFrames) do
        if hidden then
            CUF:HideBlizzardUnitFrame(type)
        end
    end

    -- TODO: This is kinda non-ideal and should be looked into
    -- Mixin in some extra bleeds/enrages
    -- These values can be overwritten by the user via snippets
    local LibDispel = LibStub("LibDispel")
    if Cell.vars.bleedList then
        Mixin(LibDispel.bleed, Cell.vars.bleedList)
    end
    Mixin(LibDispel.bleed, CUF.Defaults.Values.extraBleeds)
    Mixin(LibDispel.enrage, CUF.Defaults.Values.extraEnrages)

    -- Init Unit Buttons
    CUF.uFuncs:InitUnitButtons()
    CUF:Fire("UpdateUnitButtons")

    CUF.Compat:InitDummyAnchors()

    -- Register callbacks
    Cell.RegisterCallback("UpdateIndicators", "CUF_UpdateIndicators",
        function(layout) CUF:Fire("UpdateWidget", layout) end)

    Cell.RegisterCallback("UpdateLayout", "CUF_UpdateLayout",
        function(layout, kind) CUF:Fire("UpdateLayout", layout, kind) end)

    Cell.RegisterCallback("ShowOptionsTab", "CUF_ShowOptionsTab",
        function(tab) CUF:Fire("ShowOptionsTab", tab) end)

    Cell.RegisterCallback("UpdateMenu", "CUF_UpdateMenu",
        function(kind) CUF:Fire("UpdateMenu", kind) end)

    Cell.RegisterCallback("UpdatePixelPerfect", "CUF_UpdatePixelPerfect",
        function() CUF:Fire("UpdatePixelPerfect") end)

    Cell.RegisterCallback("UpdateVisibility", "CUF_UpdateVisibility",
        function(which) CUF:Fire("UpdateVisibility", which) end)

    Cell.RegisterCallback("UpdateAppearance", "CUF_UpdateAppearance",
        function(kind) CUF:Fire("UpdateAppearance", kind) end)

    Cell.RegisterCallback("UpdateQueuedClickCastings", "CUF_UpdateQueuedClickCastings",
        function() CUF:Fire("UpdateClickCasting", true, true) end)
    Cell.RegisterCallback("UpdateClickCastings", "CUF_UpdateClickCastings",
        function(noReload, onlyqueued) CUF:Fire("UpdateClickCasting", noReload, onlyqueued) end)

    -- Hook Cell's UpdateLayout function so we can ensure full updates properly
    hooksecurefunc(Cell.funcs, "UpdateLayout", function(layout)
        CUF:Log("|cff00ff00F:UpdateLayout:|r", layout)
        if InCombatLockdown() then return end
        CUF:Fire("UpdateWidget")
        CUF:Fire("UpdateUnitButtons")
    end)

    -- Init widgets
    CUF:Fire("UpdateWidget", CUF.DB.GetMasterLayout())

    -- Callback used to make it easier for Cell snippets to know when the frames are initialized
    Cell.Fire("CUF_FramesInitialized")

    Cell.UnregisterCallback("UpdateLayout", "CUF_Initial_UpdateLayout")
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

        -- Main Frame
        ---@class CUFMainFrame: Frame
        local CUFMainFrame = CreateFrame("Frame", "CUFMainFrame", UIParent, "SecureFrameTemplate")
        CUFMainFrame:SetAllPoints(UIParent)
        CUF.mainFrame = CUFMainFrame
        CUF.PixelPerfect.SetPixelScale(CUFMainFrame)

        Cell.RegisterCallback("UpdateLayout", "CUF_Initial_UpdateLayout", OnCellInitialUpdateLayout)

        CUF:Fire("AddonLoaded")

        -- Use this to allow Cell snippets to manipulate functions before we start using them
        Cell.Fire("CUF_AddonLoaded")

        return true
    end

    return false
end
CUF:AddEventListener("ADDON_LOADED", OnAddonLoaded)
