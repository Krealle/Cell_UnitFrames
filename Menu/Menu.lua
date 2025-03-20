---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

local L = CUF.L
local Util = CUF.Util
local DB = CUF.DB
local P = CUF.PixelPerfect

---@class CUF.Menu
---@field window CellCombatFrame
---@field tabs table<string, Menu.Tab>
---@field tabsToAdd Menu.Tab[]
---@field tabButtons Menu.TabButton[]
---@field selectedTab Menu.Tab?
local menu = {}
menu.tabs = {}
menu.tabsToAdd = {}
menu.tabButtons = {}
menu.init = false
menu.hookInit = false
menu.baseWidth = 450
menu.paneHeight = 22
menu.paneBuffer = 10
menu.inset = 5

CUF.Menu = menu

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
    if not menu.init then return end

    CUF:Fire("LoadPageDB", unit, widget)
end

-- Load layout vars from DB
--
-- Hooked to `layoutDropdown` from Cell `layoutsTab`
--
-- Fires `LoadPageDB` and `UpdateVisibility` callbacks
---@param layout string
function menu:LoadLayoutDB(layout)
    CUF:Log("|cff00ff00LoadLayoutDB:|r", layout, DB.GetMasterLayout(true), CUF.vars.selectedUnit, CUF.vars
        .selectedWidget)
    CUF.DB.VerifyDB()

    local masterLayout = DB.GetMasterLayout(true)
    if DB.GetMasterLayout(true) == "CUFLayoutMasterNone" then
        CUF.vars.selectedLayout = layout
    else
        CUF.vars.selectedLayout = masterLayout
    end
    self:SetLayoutTitle()

    menu:ShowMenu()
    CUF:Fire("LoadPageDB", CUF.vars.selectedUnit, CUF.vars.selectedWidget)
    CUF:Fire("UpdateVisibility")
    CUF:Fire("UpdateUnitButtons")
end

-------------------------------------------------
-- MARK: Layout Title
-------------------------------------------------

function menu:SetLayoutTitle()
    if not self.window then return end
    if not self.layoutTitle then return end

    self.layoutTitle:SetText(L.EditingLayout .. ": " .. Util:FormatLayoutName(CUF.vars.selectedLayout))
    self.layoutTitleFrame:SetHeight(self.layoutTitle:GetStringHeight() + 5 * 2)
    self.layoutTitleFrame:SetWidth(self.layoutTitle:GetStringWidth() + 5 * 2)
end

function menu:ShowLayoutTitle()
    self.layoutTitleFrame:Show()
    self:SetLayoutTitle()
    self.editModeButton:Show()
end

function menu:HideLayoutTitle()
    self.layoutTitleFrame:Hide()
    self.editModeButton:Hide()
end

-------------------------------------------------
-- MARK: Menu Window
-------------------------------------------------

---@class Menu.Tab
---@field id string
---@field window Frame
---@field Create function
---@field ShowTab function
---@field HideTab function
---@field height number

--- Initialize tabs buttons and adds them to the tab pane
function menu:InitTabs()
    --CUF:Log("menu - InitUnits")
    local prevButton
    local prevAnchor
    local idx = 1

    for _, tab in pairs(self.tabsToAdd) do
        ---@cast tab Menu.Tab
        self.tabs[tab.id] = tab

        ---@class Menu.TabButton: CellButton
        local tabButton = CUF:CreateButton(self.window, L[tab.id], { 100, self.paneHeight })
        tabButton.id = tab.id

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                tabButton:SetPoint("BOTTOMRIGHT", prevAnchor, "TOPRIGHT", 0, 0)
                idx = 1
                prevAnchor = tabButton

                self.window:SetHeight(self.window:GetHeight() + self.paneHeight)
                self.tabPane:SetHeight(self.tabPane:GetHeight() + self.paneHeight)
            else
                tabButton:SetPoint("TOPLEFT", prevButton, "TOPRIGHT", -1, 0)
                idx = idx + 1
            end
        else
            tabButton:SetPoint("BOTTOMLEFT", self.tabPane, "BOTTOMLEFT", 0, 0)
            prevAnchor = tabButton
        end
        prevButton = tabButton

        table.insert(self.tabButtons, tabButton)
    end

    Cell.CreateButtonGroup(self.tabButtons, function(which, b)
        self:SetTab(which)
    end)
end

--- Show the menu
---
--- Initializes the menu if it hasn't been initialized yet
function menu:ShowMenu()
    if self.window and self.window:IsShown() then return end
    CUF:Log("|cff00ccffShow Menu|r")
    if not self.window then
        self:CreateMenu()

        self.window:Show()

        self.tabButtons[1]:Click()

        self.init = true
        CUF.vars.isMenuOpen = true

        return
    end

    self.window:Show()
    self.selectedTab:ShowTab()

    CUF.vars.isMenuOpen = true
end

--- Hide the menu and the current tab
function menu:HideMenu()
    if not self.window or not self.window:IsShown() then return end
    CUF:Log("|cff00ccffHide Menu|r")
    self.window:Hide()
    self.selectedTab:HideTab()

    CUF.vars.isMenuOpen = false
end

---@param which string
function menu:SetTab(which)
    -- Hide old unit
    if self.selectedTab then
        self.selectedTab:HideTab()
    end
    CUF.vars.selectedTab = which

    self.selectedTab = self.tabs[which]
    self.selectedTab:ShowTab()

    self.window:SetHeight(self.selectedTab.window:GetHeight() + self.paneHeight + self.paneBuffer)
end

---@param tab Menu.Tab
function menu:AddTab(tab)
    table.insert(self.tabsToAdd, tab)
end

function menu:CreateMenu()
    CUF:Log("|cff00ccffCreate Menu|r")
    local optionsFrame = Cell.frames.optionsFrame

    ---@class CellCombatFrame
    self.window = CUF:CreateFrame("CUF_Menu", CUF.mainFrame, self.baseWidth, 300)
    self.window:SetPoint("TOPRIGHT", CellLayoutsPreviewButton, "BOTTOMRIGHT", 0, -self.inset)
    self.window:SetFrameStrata(optionsFrame:GetFrameStrata())
    self.window:GetFrameLevel(optionsFrame:GetFrameLevel())

    -- Draggable
    self.window:SetMovable(true)
    self.window:RegisterForDrag("LeftButton")

    self.window:SetScript("OnDragStart", function()
        self.window:StartMoving()
        -- We don't want the menu to go to narnia
        self.window:SetClampedToScreen(true)
    end)
    self.window:SetScript("OnDragStop", function()
        self.window:StopMovingOrSizing()
        local x, y = P.GetPositionRelativeToScreenCenter(self.window)

        -- coords are relative to the screen center so we need to offset them
        local centerOffset = self.window:GetHeight() / 2

        -- Set point to TOP so height grows downwards
        P.ClearPoints(self.window)
        P.Point(self.window, "TOP", UIParent, "CENTER", x, y + centerOffset)
    end)

    -- mask
    F.ApplyCombatProtectionToFrame(self.window)
    Cell.CreateMask(self.window, nil, { 1, -1, -1, 1 })
    self.window.mask:Hide()

    -- Title
    local titleFrame = CUF:CreateFrame(nil, self.window, 120, 20, false, true)
    titleFrame:SetPoint("BOTTOMLEFT", self.window, "TOPLEFT", 0, -1)

    local pad = 5

    local title = titleFrame:CreateFontString(nil, "OVERLAY", CUF.constants.FONTS.CLASS_TITLE)
    title:SetPoint("BOTTOMLEFT", pad, pad)
    title:SetText("Cell UnitFrame")
    title:SetTextScale(1.5)
    titleFrame:SetHeight(title:GetStringHeight() + pad * 2)
    titleFrame:SetWidth(title:GetStringWidth() + pad * 2)

    -- Title
    local layoutTitleFrame = CUF:CreateFrame(nil, titleFrame, 160, 10, false, true)
    layoutTitleFrame:SetPoint("BOTTOMLEFT", titleFrame, "TOPLEFT", 0, -1)
    self.layoutTitleFrame = layoutTitleFrame
    layoutTitleFrame:Hide()

    local layoutTitle = layoutTitleFrame:CreateFontString(nil, "OVERLAY", CUF.constants.FONTS.CELL_WIDGET)
    self.layoutTitle = layoutTitle
    layoutTitle:SetPoint("CENTER")
    layoutTitle:SetTextScale(1)

    -- Tabs
    self.tabPane = Cell.CreateTitledPane(self.window, nil, self.baseWidth, self.paneHeight)
    self.tabPane:SetPoint("TOPLEFT")

    -- Repoint so it's anchored to bottom
    self.tabPane.line:ClearAllPoints()
    self.tabPane.line:SetPoint("BOTTOMLEFT", self.tabPane, "BOTTOMLEFT")
    self.tabPane.line:SetPoint("BOTTOMRIGHT", self.tabPane, "BOTTOMRIGHT")

    local gap = self.inset * 2
    local anchorWidth = self.baseWidth - gap
    self.tabAnchor = CUF:CreateFrame(nil, self.tabPane, anchorWidth, 1, true)
    self.tabAnchor:SetPoint("TOPLEFT", self.tabPane, "BOTTOMLEFT", self.inset, -self.paneBuffer)

    self:InitTabs()

    local editModeButton = Cell.CreateButton(self.tabPane, L.EditMode, "accent",
        { 100, 25 })
    editModeButton:SetPoint("TOPLEFT", self.tabPane, "BOTTOMLEFT", 0, 0)
    CUF:SetTooltips(editModeButton, "ANCHOR_TOPLEFT", 0, 3, L.ToggleEditMode,
        L.EditModeButtonTooltip)

    editModeButton:SetScript("OnClick", function()
        CUF.uFuncs:EditMode()
        CUF.HelpTips:Acknowledge(editModeButton, L.HelpTip_EditModeToggle)
    end)
    editModeButton:SetScript("OnHide", function()
        CUF.uFuncs:EditMode(false)
    end)
    self.editModeButton = editModeButton
    self.editModeButton:Hide()

    CUF.HelpTips:Show(editModeButton, {
        text = L.HelpTip_EditModeToggle,
        dbKey = "editModeToggle",
        buttonStyle = HelpTip.ButtonStyle.None,
        alignment = HelpTip.Alignment.Left,
        targetPoint = HelpTip.Point.LeftEdgeCenter,
    })

    hooksecurefunc(optionsFrame, "Hide", function()
        self:HideMenu()
        CUF.vars.selectedLayout = Cell.vars.currentLayout
        CUF:Fire("UpdateUnitButtons")
    end)
end

-------------------------------------------------
-- MARK: Util
-------------------------------------------------

--- Show a confirmation popup in the middle of the menu
---@param text string
---@param onAccept function?
---@param onReject function?
function menu:ShowPopup(text, onAccept, onReject)
    self.popUp = CUF:CreateConfirmPopup(self.window, 300, text, onAccept, onReject, true)
    self.popUp:SetPoint("CENTER")
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

    if not layoutsTab then
        if CUF.vars.testMode then
            CUF:Print("UpdatePreview Unable to find layoutsTab")
        end
        return
    end

    local layoutPane = Util.findChildByName(layoutsTab, "Layout")
    if not layoutPane then
        if CUF.vars.testMode then
            CUF:Print("UpdatePreview Unable to find layoutPane")
        end
        return
    end

    local layoutDropdown = Util.findChildByProp(layoutPane, "items")
    if not layoutDropdown then
        if CUF.vars.testMode then
            CUF:Print("UpdatePreview Unable to find layoutDropdown")
        end
        return
    end

    hooksecurefunc(layoutDropdown, "SetSelectedValue", function(self)
        --CUF:Log("Cell_SetSelectedValue", self:GetSelected())
        menu:LoadLayoutDB(self:GetSelected())
    end)

    -- Initial load
    menu:LoadLayoutDB(layoutDropdown:GetSelected())

    -- Unhook
    Cell.UnregisterCallback("UpdatePreview", "CUF_UpdatePreview")
end

---@param tab string
local function ShowTab(tab)
    --CUF:Log("Cell_ShowTab", tab)
    if CUF.vars.testMode then
        CUF:Print("Cell_ShowTab", tab)
    end

    if tab ~= "layouts" then
        menu:HideMenu()
    elseif not menu.init then
        -- Inital hook
        Cell.RegisterCallback("UpdatePreview", "CUF_UpdatePreview", UpdatePreview)
    end
end
CUF:RegisterCallback("ShowOptionsTab", "ShowTab", ShowTab)
