---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local F = Cell.funcs

local Builder = CUF.Builder
local Handler = CUF.Handler
local MenuWindow = CUF.MenuWindow

---@class UnitsFramesTab: Menu.Tab
---@field unitPages table<Unit, UnitsMenuPage>
---@field unitPageButtons UnitMenuPageButton[]
---@field widgetPages table<WIDGET_KIND, WidgetMenuPage>
---@field listButtons table<WIDGET_KIND, CellButton>
local unitFramesTab = {}
unitFramesTab.unitPages = {}
unitFramesTab.unitPageButtons = {}
unitFramesTab.widgetPages = {}
unitFramesTab.listButtons = {}
unitFramesTab.firstWidgetInList = nil
unitFramesTab.id = "unitFramesTab"
unitFramesTab.widgetHeight = 400
unitFramesTab.unitHeight = 180
unitFramesTab.paneHeight = 17

MenuWindow:AddTab(unitFramesTab)

---@param unit Unit
function unitFramesTab:SetUnitPage(unit)
    -- Hide old unit
    if self.selectedUnitPage then
        self.selectedUnitPage.frame:Hide()
    end

    self.selectedUnitPage = self.unitPages[unit]
    self.selectedUnitPage.frame:Show()

    self:LoadWidgetList(unit)
    CUF.Menu:UpdateSelectedPages(unit)
end

-- Update the selected widge
---@param widget WIDGET_KIND
function unitFramesTab:SetWidget(widget)
    -- Hide old widget
    if self.selectedWidget then
        self.selectedWidget.frame:Hide()
    end

    self.selectedWidget = self.widgetPages[widget]
    self.selectedWidget.frame:Show()

    self.selectedWidget.frame:ClearAllPoints()
    self.selectedWidget.frame:SetPoint("TOPLEFT", self.settingsFrame.scrollFrame.content)

    -- Extremely dirty hack, but without this options will sometimes not be shown
    C_Timer.After(0.1, function()
        self.settingsFrame.scrollFrame:SetContentHeight(self.selectedWidget.height)
        self.settingsFrame.scrollFrame:ResetScroll()
    end)

    CUF.Menu:UpdateSelectedPages(nil, widget)
end

---@param unit Unit
function unitFramesTab:LoadWidgetList(unit)
    self.widgetListFrame.scrollFrame:Reset()

    local optionCount = 0
    local widgetTable = CUF.DB.GetAllWidgetTables(unit)
    local prevButton
    self.firstWidgetInList = nil

    -- The list is ordered by load order from .toc
    for _, widgetPage in pairs(CUF.Menu.widgetsToAdd) do
        local widgetName = widgetPage.widgetName
        local widget = widgetTable[widgetName]

        if widget then
            if not self.listButtons[widgetName] then
                self.listButtons[widgetName] = CUF:CreateButton(self.widgetListFrame.scrollFrame.content, " ",
                    { 20, 20 }, nil, "transparent-accent")
            end

            ---@class WidgetMenuPageButton: CellButton
            local button = self.listButtons[widgetName]
            button:SetText(L[widgetName])
            button:GetFontString():ClearAllPoints()
            button:GetFontString():SetPoint("LEFT", 5, 0)
            button:GetFontString():SetPoint("RIGHT", -5, 0)

            button.id = widgetName
            optionCount = optionCount + 1

            if widget.enabled then
                button:SetTextColor(1, 1, 1, 1)
            else
                button:SetTextColor(0.466, 0.466, 0.466, 1)
            end

            button:SetParent(self.widgetListFrame.scrollFrame.content)
            button:SetPoint("RIGHT")
            if not prevButton then
                button:SetPoint("TOPLEFT")
            else
                button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, 1)
            end
            button:Show()

            prevButton = button
            if not self.firstWidgetInList then
                self.firstWidgetInList = widgetName
            end
        end
    end

    self.widgetListFrame.scrollFrame:SetContentHeight(20, optionCount, -1)

    Cell:CreateButtonGroup(self.listButtons, function(widget, b)
        self:SetWidget(widget)
    end)

    -- Make sure that the currently selected widget is valid
    if self.selectedWidget then
        if not widgetTable[self.selectedWidget.id] then
            self.listButtons[self.firstWidgetInList]:Click()
        end
    end
end

---@param layout string?
---@param unit Unit?
---@param widgetName WIDGET_KIND?
function unitFramesTab.UpdateWidgetListEnabled(layout, unit, widgetName, setting)
    if not widgetName then return end
    if not setting == CUF.constants.OPTION_KIND.ENABLED then return end
    if not unitFramesTab.listButtons[widgetName] then return end

    if CUF.DB.GetWidgetTable(widgetName, unit, layout).enabled then
        unitFramesTab.listButtons[widgetName]:SetTextColor(1, 1, 1, 1)
    else
        unitFramesTab.listButtons[widgetName]:SetTextColor(0.466, 0.466, 0.466, 1)
    end
end

CUF:RegisterCallback("UpdateWidget", "UpdateWidgetListEnabled", unitFramesTab.UpdateWidgetListEnabled)

function unitFramesTab:ShowTab()
    CUF:Log("|cff00ccffShow unitFramesTab|r")
    if not self.window then
        self:Create()

        self.window:Show()

        self.unitPageButtons[1]:Click()
        self.listButtons[self.firstWidgetInList]:Click()

        self.init = true

        return
    end

    self.window:Show()
end

function unitFramesTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    CUF:Log("|cff00ccffHide unitFramesTab|r")
    self.window:Hide()

    Handler.UpdateSelected()
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

function unitFramesTab:InitUnits()
    --CUF:Log("menuWindow - InitUnits")
    local prevButton
    local prevAnchor
    local idx = 1

    for _, fn in pairs(CUF.Menu.unitsToAdd) do
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

function unitFramesTab:InitWidgets()
    --CUF:Log("menuWindow - InitWidgets")

    for _, widget in pairs(CUF.Menu.widgetsToAdd) do
        ---@type WidgetMenuPage
        local widgetPage = Builder:CreateWidgetMenuPage(self.settingsFrame, widget.widgetName, unpack(widget.options))

        self.widgetPages[widgetPage.id] = widgetPage
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function unitFramesTab:Create()
    CUF:Log("|cff00ccffCreate UnitFramesTab|r")

    local inset = MenuWindow.inset
    local windowHeight = self.unitHeight + self.widgetHeight + (self.paneHeight * 2)

    local sectionWidth = MenuWindow.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame", MenuWindow.window,
        sectionWidth,
        windowHeight, true)
    self.window:SetPoint("TOPLEFT", MenuWindow.tabAnchor, "TOPLEFT")

    -- Unit Buttons
    self.unitPane = Cell:CreateTitledPane(self.window, L.UnitFrames, sectionWidth,
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
    Cell:CreateButtonGroup(self.unitPageButtons, function(unit, b)
        self:SetUnitPage(unit)
    end)

    -- Widget Buttons
    self.widgetPane = Cell:CreateTitledPane(self.unitSection, L.Widgets,
        sectionWidth, self.paneHeight)
    self.widgetPane:SetPoint("TOPLEFT", self.unitSection, "BOTTOMLEFT")

    -- Repoint so it's anchored to bottom
    self.widgetPane.line:ClearAllPoints()
    self.widgetPane.line:SetPoint("BOTTOMLEFT", self.widgetPane, "BOTTOMLEFT")
    self.widgetPane.line:SetPoint("BOTTOMRIGHT", self.widgetPane, "BOTTOMRIGHT")

    -- settings frame
    ---@class UnitsFramesTab.settingsFrame: Frame
    ---@field scrollFrame CellScrollFrame
    self.settingsFrame = CUF:CreateFrame("CUF_Menu_UnitFrame_Widget", self.widgetPane,
        sectionWidth,
        (self.widgetHeight - self.paneHeight), true, true)
    self.settingsFrame:SetPoint("TOPLEFT", self.widgetPane, "BOTTOMLEFT", 0, -inset)

    Cell:CreateScrollFrame(self.settingsFrame)
    self.settingsFrame.scrollFrame:SetScrollStep(50)

    self:InitWidgets()

    local widgetListWindow = CUF:CreateFrame("CUF_Menu_UnitFrame_WidgetList", self.window,
        sectionWidth / 3,
        self.settingsFrame:GetHeight(), false, true)
    widgetListWindow:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMLEFT", 1 - inset, 0)

    ---@class UnitsFramesTab.widgetListFrame: Frame
    ---@field scrollFrame CellScrollFrame
    self.widgetListFrame = CUF:CreateFrame("CUF_Menu_UnitFrame_WidgetListFrame", widgetListWindow,
        widgetListWindow:GetWidth(),
        widgetListWindow:GetHeight(), false, true)
    self.widgetListFrame:SetPoint("TOPLEFT", widgetListWindow, "TOPLEFT", 0, 0)

    Cell:CreateScrollFrame(self.widgetListFrame)
    self.widgetListFrame.scrollFrame:SetScrollStep(25)
end