---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local L = CUF.L

local Builder = CUF.Builder
local Handler = CUF.Handler

---@class CUF.Menu
local Menu = CUF.Menu

---@class UnitsFramesTab: Menu.Tab
---@field unitPages table<Unit, UnitsMenuPage>
---@field unitPageButtons UnitMenuPageButton[]
---@field selectedWidgetTable WidgetTable
---@field unitsToAdd table<number, function>
local unitFramesTab = {}
unitFramesTab.id = "unitFramesTab"
unitFramesTab.unitPages = {}
unitFramesTab.unitsToAdd = {}
unitFramesTab.unitPageButtons = {}
unitFramesTab.unitHeight = 160
unitFramesTab.paneHeight = 17

Menu.unitFramesTab = unitFramesTab
Menu:AddTab(unitFramesTab)

-------------------------------------------------
-- MARK: Setters
-------------------------------------------------

function unitFramesTab:IsShown()
    return unitFramesTab.window and unitFramesTab.window:IsShown()
end

---@param unit Unit
function unitFramesTab:SetUnitPage(unit)
    -- Hide old unit
    if self.selectedUnitPage then
        self.selectedUnitPage.frame:Hide()
    end

    self.selectedUnitPage = self.unitPages[unit]
    self.selectedUnitPage.frame:Show()

    if self.selectedTab then
        self.selectedTab:ShowTab(unit)
    end
    Menu:UpdateSelectedPages(unit)
end

function unitFramesTab:ShowTab()
    CUF:Log("|cff00ccffShow unitFramesTab|r")
    if not self.window then
        self:Create()

        self.window:Show()

        self.unitPageButtons[1]:Click()
        self.tabButtons[1]:Click()

        Menu:UpdateSelectedPages(CUF.vars.selectedUnit, CUF.vars.selectedWidget)

        self.init = true

        Menu:ShowLayoutTitle()

        return
    end

    self.window:Show()
    self.selectedTab:ShowTab()

    Menu:LoadLayoutDB(CUF.vars.selectedLayout)

    Menu:ShowLayoutTitle()
end

function unitFramesTab:HideTab()
    if not unitFramesTab:IsShown() then return end
    CUF:Log("|cff00ccffHide unitFramesTab|r")
    self.window:Hide()
    self.selectedTab:HideTab()
    Menu:HideLayoutTitle()
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

function unitFramesTab:InitUnits()
    local prevButton
    local prevAnchor
    local idx = 1

    for _, fn in pairs(self.unitsToAdd) do
        ---@type UnitsMenuPage
        local unit = fn(self)

        self.unitPages[unit.id] = unit

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                unit.pageButton:SetPoint("BOTTOMLEFT", prevAnchor, "TOPLEFT", 0, 0)
                idx = 1
                prevAnchor = unit.pageButton

                self.window:SetHeight(self.window:GetHeight() + self.paneHeight)
                self.unitPane:SetHeight(self.unitPane:GetHeight() + self.paneHeight)
            else
                unit.pageButton:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", 1)
                idx = idx + 1
            end
        else
            unit.pageButton:SetPoint("BOTTOMRIGHT", self.unitPane, "BOTTOMRIGHT", 0, 1)
            prevAnchor = unit.pageButton
        end
        prevButton = unit.pageButton

        table.insert(self.unitPageButtons, unit.pageButton)
    end
end

---@param unit function
function Menu:AddUnit(unit)
    table.insert(unitFramesTab.unitsToAdd, unit)
end

-------------------------------------------------
-- MARK: Tabs
-------------------------------------------------

---@type Menu.Tab[]
unitFramesTab.tabsToAdd = {}
---@type table<string, Menu.Tab>
unitFramesTab.tabs = {}
---@type Menu.TabButton[]
unitFramesTab.tabButtons = {}

--- Initialize tabs buttons and adds them to the tab pane
function unitFramesTab:InitTabs()
    local prevButton
    local prevAnchor
    local idx = 1

    for _, tab in pairs(self.tabsToAdd) do
        ---@cast tab Menu.Tab
        self.tabs[tab.id] = tab

        ---@class Menu.TabButton: CellButton
        local tabButton = CUF:CreateButton(self.window, L[tab.id], { 100, 17 })
        tabButton.id = tab.id

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                tabButton:SetPoint("BOTTOMRIGHT", prevAnchor, "TOPRIGHT", 0, 0)
                idx = 1
                prevAnchor = tabButton

                self.unitTabRows = self.unitTabRows + 1
                --self.window:SetHeight(self.window:GetHeight() + self.paneHeight)
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

---@param which string
function unitFramesTab:SetTab(which)
    -- Hide old tab
    if self.selectedTab then
        self.selectedTab:HideTab()
    end

    CUF.vars.selectedSubTab = which
    self.selectedTab = self.tabs[which]
    self.selectedTab:ShowTab(CUF.vars.selectedUnit)

    self.window:SetHeight(self.unitHeight + self.selectedTab.height + (self.paneHeight * (self.unitTabRows + 2)))
    Menu.window:SetHeight(self.window:GetHeight() + Menu.paneHeight + Menu.paneBuffer)
end

unitFramesTab.AddTab = Menu.AddTab

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function unitFramesTab:Create()
    local windowHeight = self.unitHeight + 400 + (self.paneHeight * 2)
    self.unitTabRows = 1

    local sectionWidth = Menu.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame", Menu.window,
        sectionWidth,
        windowHeight, true)
    self.window:SetPoint("TOPLEFT", Menu.tabAnchor, "TOPLEFT")

    -- Unit Buttons
    self.unitPane = Cell.CreateTitledPane(self.window, L.UnitFrames, sectionWidth,
        self.paneHeight)
    self.unitPane:SetPoint("TOPLEFT")

    -- Repoint so it's anchored to bottom
    self.unitPane.line:ClearAllPoints()
    self.unitPane.line:SetPoint("BOTTOMLEFT", self.unitPane, "BOTTOMLEFT")
    self.unitPane.line:SetPoint("BOTTOMRIGHT", self.unitPane, "BOTTOMRIGHT")

    -- Unit Settings
    self.unitSection = CUF:CreateFrame("CUF_Menu_UnitFrame_Unit", self.unitPane,
        sectionWidth,
        self.unitHeight, true, true)
    self.unitSection:SetPoint("TOPLEFT", self.unitPane, "BOTTOMLEFT")

    self:InitUnits()
    Cell.CreateButtonGroup(self.unitPageButtons, function(unit, b)
        self:SetUnitPage(unit)
    end)

    -- Tabs
    self.tabPane = Cell.CreateTitledPane(self.window, nil, sectionWidth, self.paneHeight)
    self.tabPane:SetPoint("TOPLEFT", self.unitSection, "BOTTOMLEFT")

    -- Repoint so it's anchored to bottom
    self.tabPane.line:ClearAllPoints()
    self.tabPane.line:SetPoint("BOTTOMLEFT", self.tabPane, "BOTTOMLEFT")
    self.tabPane.line:SetPoint("BOTTOMRIGHT", self.tabPane, "BOTTOMRIGHT")

    --local anchorWidth = self.baseWidth - gap
    self.tabAnchor = CUF:CreateFrame("TabAnchor", self.tabPane, sectionWidth, 1, true)
    self.tabAnchor:SetPoint("TOPLEFT", self.tabPane, "BOTTOMLEFT", 0, -10)

    self:InitTabs()
end
