---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local optionsFrame = Cell.frames.optionsFrame
local unitFramesWindowSize = { x = 322, y = 300 }

local unitFramesWindow = Cell:CreateFrame("CellOptionsFrame_UnitFramesWindow", optionsFrame, unitFramesWindowSize.x,
    unitFramesWindowSize.y)
Cell.frames.unitFramesWindow = unitFramesWindow
unitFramesWindow:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", -unitFramesWindowSize.x, -105)
unitFramesWindow:Hide()

-------------------------------------------------
-- MARK: Layout setup
-------------------------------------------------
local selectedLayout, selectedLayoutTable
local selectedPage = "player"

-- Check Buttons
local playerFrameCB, targetFrameCB, focusFrameCB
local sameSizeAsPlayerCB
-- Sliders
local widthSlider, heightSlider, powerSizeSlider
-- Dropdowns
local anchorDropdown

local function UpdateSize()
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", selectedLayout, selectedPage .. "-size")
    end
end

local function UpdateArrangement()
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", selectedLayout, selectedPage .. "-arrangement")
    end
end

-- Load page from DB
---@param page string
local function LoadPageDB(page)
    local pageLayoutTable = selectedLayoutTable[page]
    -- size
    widthSlider:SetValue(pageLayoutTable["size"][1])
    heightSlider:SetValue(pageLayoutTable["size"][2])
    powerSizeSlider:SetValue(pageLayoutTable["powerSize"])

    -- unit arrangement
    anchorDropdown:SetSelectedValue(pageLayoutTable["anchor"])

    -- same as player
    if page ~= "player" then
        sameSizeAsPlayerCB:SetChecked(pageLayoutTable["sameSizeAsPlayer"])
    end

    if page == "player" then
        widthSlider:SetEnabled(true)
        heightSlider:SetEnabled(true)
        powerSizeSlider:SetEnabled(true)
        anchorDropdown:SetEnabled(true)
    else
        widthSlider:SetEnabled(not pageLayoutTable["sameSizeAsPlayer"])
        heightSlider:SetEnabled(not pageLayoutTable["sameSizeAsPlayer"])
        powerSizeSlider:SetEnabled(not pageLayoutTable["sameSizeAsPlayer"])
        anchorDropdown:SetEnabled(not pageLayoutTable["sameSizeAsPlayer"])
    end
end

-- Load layout from DB
---@param layout string
local function LoadLayoutDB(layout)
    selectedLayout = layout
    selectedLayoutTable = CellDB["layouts"][layout]

    -- pages
    LoadPageDB(selectedPage)

    playerFrameCB:SetChecked(selectedLayoutTable["player"]["enabled"])
    targetFrameCB:SetChecked(selectedLayoutTable["target"]["enabled"])
    focusFrameCB:SetChecked(selectedLayoutTable["focus"]["enabled"])

    CUF:Fire("UpdateVisibility")
end

local function CreateLayoutSetupPane()
    local layoutSetupPane = Cell:CreateTitledPane(unitFramesWindow, L["Unit Frames"], unitFramesWindowSize.x - 10,
        unitFramesWindowSize.y - 5)
    layoutSetupPane:SetPoint("TOPLEFT", 5, -5)

    -- buttons
    local player = Cell:CreateButton(layoutSetupPane, L["Player"], "accent-hover", { 85, 17 })
    player:SetPoint("TOPRIGHT", layoutSetupPane)
    player.id = "player"

    local target = Cell:CreateButton(layoutSetupPane, "Target", "accent-hover", { 70, 17 })
    target:SetPoint("TOPRIGHT", player, "TOPLEFT", P:Scale(1), 0)
    target.id = "target"

    local focus = Cell:CreateButton(layoutSetupPane, L["Focus"], "accent-hover", { 70, 17 })
    focus:SetPoint("TOPRIGHT", target, "TOPLEFT", P:Scale(1), 0)
    focus.id = "focus"

    -- same size as player
    sameSizeAsPlayerCB = Cell:CreateCheckButton(layoutSetupPane, L["Use Same Size As Player"], function(checked)
        selectedLayoutTable[selectedPage]["sameSizeAsPlayer"] = checked
        widthSlider:SetEnabled(not checked)
        heightSlider:SetEnabled(not checked)
        powerSizeSlider:SetEnabled(not checked)
        anchorDropdown:SetEnabled(not checked)
        -- update size and power
        UpdateSize()
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, selectedPage .. "-power")
        end
    end)
    sameSizeAsPlayerCB:Hide()

    -- width
    widthSlider = Cell:CreateSlider(L["Width"], layoutSetupPane, 20, 500, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["size"][1] = value
        UpdateSize()
    end)

    -- height
    heightSlider = Cell:CreateSlider(L["Height"], layoutSetupPane, 20, 500, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["size"][2] = value
        UpdateSize()
    end)
    heightSlider:SetPoint("TOPLEFT", widthSlider, 0, -55)

    -- power height
    powerSizeSlider = Cell:CreateSlider(L["Power Size"], layoutSetupPane, 0, 100, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["powerSize"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, selectedPage .. "-power")
        end
    end)
    powerSizeSlider:SetPoint("TOPLEFT", heightSlider, 0, -55)

    -- anchor
    anchorDropdown = Cell:CreateDropdown(layoutSetupPane, 117)
    anchorDropdown:SetPoint("TOPLEFT", widthSlider, "TOPRIGHT", 30, 0)
    anchorDropdown:SetItems({
        {
            ["text"] = L["BOTTOMLEFT"],
            ["value"] = "BOTTOMLEFT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "BOTTOMLEFT"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["BOTTOMRIGHT"],
            ["value"] = "BOTTOMRIGHT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "BOTTOMRIGHT"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["TOPLEFT"],
            ["value"] = "TOPLEFT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "TOPLEFT"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["TOPRIGHT"],
            ["value"] = "TOPRIGHT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "TOPRIGHT"
                UpdateArrangement()
            end,
        },
    })

    local anchorText = layoutSetupPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    anchorText:SetPoint("BOTTOMLEFT", anchorDropdown, "TOPLEFT", 0, 1)
    anchorText:SetText(L["Anchor Point"])

    hooksecurefunc(anchorDropdown, "SetEnabled", function(self, enabled)
        if enabled then
            anchorText:SetTextColor(1, 1, 1)
        else
            anchorText:SetTextColor(0.4, 0.4, 0.4)
        end
    end)

    -- pages
    local pages = {}

    --* player ------------------------------------
    pages.player = CreateFrame("Frame", nil, unitFramesWindow)
    pages.player:SetAllPoints(layoutSetupPane)
    pages.player:Hide()

    playerFrameCB = Cell:CreateCheckButton(pages.player, L["Enable Player Frame"], function(checked)
        selectedLayoutTable["player"]["enabled"] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "player")
        end
        Cell:Fire("UpdateVisibility", "player")
    end)
    playerFrameCB:SetPoint("TOPLEFT", 5, -27)

    --* target -------------------------------------
    pages.target = CreateFrame("Frame", nil, unitFramesWindow)
    pages.target:SetAllPoints(layoutSetupPane)
    pages.target:Hide()

    targetFrameCB = Cell:CreateCheckButton(pages.target, L["Enable Target Frame"], function(checked)
        selectedLayoutTable["target"]["enabled"] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "target")
        end
        Cell:Fire("UpdateVisibility", "target")
    end)
    targetFrameCB:SetPoint("TOPLEFT", 5, -27)

    --* focus -------------------------------------
    pages.focus = CreateFrame("Frame", nil, unitFramesWindow)
    pages.focus:SetAllPoints(layoutSetupPane)
    pages.focus:Hide()

    focusFrameCB = Cell:CreateCheckButton(pages.focus, L["Enable Focus Frame"], function(checked)
        selectedLayoutTable["focus"]["enabled"] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "focus")
        end
        Cell:Fire("UpdateVisibility", "focus")
    end)
    focusFrameCB:SetPoint("TOPLEFT", 5, -27)

    -- button group
    Cell:CreateButtonGroup({ player, target, focus }, function(tab)
        selectedPage = tab

        -- load
        LoadPageDB(tab)

        -- repoint
        sameSizeAsPlayerCB:ClearAllPoints()
        if tab == "player" then
        elseif tab == "target" then
            sameSizeAsPlayerCB:SetPoint("TOPLEFT", targetFrameCB, "BOTTOMLEFT", 0, -14)
        elseif tab == "focus" then
            sameSizeAsPlayerCB:SetPoint("TOPLEFT", focusFrameCB, "BOTTOMLEFT", 0, -14)
        end

        widthSlider:ClearAllPoints()
        if tab == "player" then
            sameSizeAsPlayerCB:Hide()
            widthSlider:SetPoint("TOPLEFT", playerFrameCB, 0, -50)
        else
            sameSizeAsPlayerCB:Show()
            widthSlider:SetPoint("TOPLEFT", sameSizeAsPlayerCB, 0, -50)
        end

        -- show & hide
        for name, page in pairs(pages) do
            if name == tab then
                page:Show()
            else
                page:Hide()
            end
        end
    end)

    layoutSetupPane:SetScript("OnShow", function()
        if layoutSetupPane.shown then return end
        layoutSetupPane.shown = true
        player:Click()
    end)
end

----------------------------------------------------------------------------
-- MARK: Callbacks
-----------------------------------------------------------------------------
local init, hookInit

-- This is hacky, but it works
-- This is needed to get access to current layout, since this
-- is the only place where this info is outside of local scope
local function UpdatePreview()
    if not init or hookInit then return end

    local layoutsTab = CUF.findChildByName(optionsFrame, "CellOptionsFrame_LayoutsTab")
    local layoutPane = CUF.findChildByName(layoutsTab, "Layout")
    local layoutDropdown = CUF.findChildByProp(layoutPane, "items")

    hooksecurefunc(layoutDropdown, "SetSelected", function(self)
        LoadLayoutDB(self:GetSelected())
    end)
    hooksecurefunc(layoutDropdown, "SetSelectedValue", function(self)
        LoadLayoutDB(self:GetSelected())
    end)

    LoadLayoutDB(layoutDropdown:GetSelected())
    Cell:UnregisterCallback("UpdatePreview", "CellUnitFrames_UpdatePreview")

    hookInit = true
end
Cell:RegisterCallback("UpdatePreview", "CellUnitFrames_UpdatePreview", UpdatePreview)

---@param tab string
local function ShowTab(tab)
    if tab == "layouts" then
        if not init then
            init = true

            CreateLayoutSetupPane()

            -- mask
            F:ApplyCombatProtectionToFrame(unitFramesWindow)
            Cell:CreateMask(unitFramesWindow, nil, { 1, -1, -1, 1 })
            unitFramesWindow.mask:Hide()
        end

        LoadLayoutDB(Cell.vars.currentLayout)

        unitFramesWindow:Show()
    else
        unitFramesWindow:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "CellUnitFrames_ShowTab", ShowTab)

unitFramesWindow:SetScript("OnHide", function()
    if unitFramesWindow:IsShown() then
        unitFramesWindow:SetScript("OnShow", function()
            LoadLayoutDB(Cell.vars.currentLayout)
        end)
    else
        unitFramesWindow:SetScript("OnShow", nil)
    end
end)
