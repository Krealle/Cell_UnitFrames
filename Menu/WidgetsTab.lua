---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local L = CUF.L

local Builder = CUF.Builder
local Handler = CUF.Handler

---@class CUF.Menu
local Menu = CUF.Menu

local unitFramesTab = Menu.unitFramesTab

---@class WidgetsTab: Menu.Tab
---@field widgetsToAdd table<number, WidgetMenuPage.Args>
---@field listButtons table<WIDGET_KIND, CellButton>
---@field widgetPages table<WIDGET_KIND, WidgetMenuPage>
local WidgetsTab = {}
WidgetsTab.widgetPages = {}
WidgetsTab.listButtons = {}
WidgetsTab.widgetsToAdd = {}
WidgetsTab.id = "Widgets"
WidgetsTab.height = 390
WidgetsTab.paneHeight = 17

unitFramesTab:AddTab(WidgetsTab)

-------------------------------------------------
-- MARK: Show/Hide
-------------------------------------------------

---@param unit Unit
function WidgetsTab:ShowTab(unit)
    --CUF:Log("|cff00ccffShow generalTab|r")
    if not self.window then
        self:Create()

        self.window:Show()
        self.LoadWidgetList(unit)

        self.listButtons[self.firstWidgetInList]:Click()

        self.init = true
        return
    end

    self.window:Show()
    self.LoadWidgetList(unit)
    Menu:UpdateSelectedPages(CUF.vars.selectedUnit, CUF.vars.selectedWidget)
end

function WidgetsTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    --CUF:Log("|cff00ccffHide generalTab|r")
    self.window:Hide()

    -- Reset selected widget to hide previews
    Handler.UpdateSelected()
end

function WidgetsTab:IsShown()
    return WidgetsTab.window and WidgetsTab.window:IsShown()
end

-- Update the selected widge
---@param widget WIDGET_KIND
function WidgetsTab:SetWidget(widget)
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

    Menu:UpdateSelectedPages(nil, widget)
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

function WidgetsTab:InitWidgets()
    for _, widget in pairs(self.widgetsToAdd) do
        local widgetPage = Builder:CreateWidgetMenuPage(self.settingsFrame, widget.widgetName, unpack(widget.options))

        self.widgetPages[widgetPage.id] = widgetPage
    end
end

---@param widgetName WIDGET_KIND
---@param ... MenuOptions
function Menu:AddWidget(widgetName, ...)
    table.insert(WidgetsTab.widgetsToAdd,
        { ["widgetName"] = widgetName, ["options"] = { ... } })
end

-------------------------------------------------
-- MARK: Callbacks
-------------------------------------------------

---@param unit Unit
function WidgetsTab.LoadWidgetList(unit)
    if not WidgetsTab:IsShown() then return end

    WidgetsTab.widgetListFrame.scrollFrame:Reset()

    local optionCount = 0
    local widgetTable = CUF.DB.GetSelectedWidgetTables(unit)
    local prevButton
    WidgetsTab.firstWidgetInList = nil

    -- The list is ordered by load order from .toc
    for _, widgetPage in pairs(WidgetsTab.widgetsToAdd) do
        local widgetName = widgetPage.widgetName
        local widget = widgetTable[widgetName]

        if widget then
            if not WidgetsTab.listButtons[widgetName] then
                WidgetsTab.listButtons[widgetName] = CUF:CreateButton(
                    WidgetsTab.widgetListFrame.scrollFrame.content, " ",
                    { 20, 20 }, nil, "transparent-accent")
            end

            ---@class WidgetMenuPageButton: CellButton
            local button = WidgetsTab.listButtons[widgetName]
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

            button:SetParent(WidgetsTab.widgetListFrame.scrollFrame.content)
            button:SetPoint("RIGHT")
            if not prevButton then
                button:SetPoint("TOPLEFT")
            else
                button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, 1)
            end
            button:Show()

            prevButton = button
            if not WidgetsTab.firstWidgetInList then
                WidgetsTab.firstWidgetInList = widgetName
            end
        end
    end

    WidgetsTab.widgetListFrame.scrollFrame:SetContentHeight(20, optionCount, -1)

    Cell:CreateButtonGroup(WidgetsTab.listButtons, function(widget, b)
        WidgetsTab:SetWidget(widget)
    end)

    -- Make sure that the currently selected widget is valid
    if WidgetsTab.selectedWidget then
        if not widgetTable[WidgetsTab.selectedWidget.id] then
            WidgetsTab.listButtons[WidgetsTab.firstWidgetInList]:Click()
        end
    end
end

CUF:RegisterCallback("LoadPageDB", "unitFramesTab_LoadWidgetList", WidgetsTab.LoadWidgetList)

---@param layout string?
---@param unit Unit?
---@param widgetName WIDGET_KIND?
function WidgetsTab.UpdateWidgetListEnabled(layout, unit, widgetName, setting)
    if not WidgetsTab:IsShown() then return end
    if not widgetName then return end
    if not setting == CUF.constants.OPTION_KIND.ENABLED then return end
    if not WidgetsTab.listButtons[widgetName] then return end

    if CUF.DB.GetSelectedWidgetTable(widgetName, unit).enabled then
        WidgetsTab.listButtons[widgetName]:SetTextColor(1, 1, 1, 1)
    else
        WidgetsTab.listButtons[widgetName]:SetTextColor(0.466, 0.466, 0.466, 1)
    end
end

CUF:RegisterCallback("UpdateWidget", "WidgetsTab_UpdateWidgetListEnabled", WidgetsTab.UpdateWidgetListEnabled)

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

-- Create
function WidgetsTab:Create()
    --CUF:Log("|cff00ccffCreate generalTab|r")

    local sectionWidth = unitFramesTab.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame_Widget", unitFramesTab.window,
        sectionWidth,
        self.height, true)
    self.window:SetPoint("TOPLEFT", unitFramesTab.tabAnchor, "TOPLEFT")

    -- settings frame
    ---@class UnitsFramesTab.settingsFrame: Frame
    ---@field scrollFrame CellScrollFrame
    self.settingsFrame = CUF:CreateFrame("CUF_Menu_UnitFrame_Widget_Settings", self.window,
        sectionWidth, self.height, true, true)
    self.settingsFrame:SetPoint("TOPLEFT")

    Cell:CreateScrollFrame(self.settingsFrame)
    self.settingsFrame.scrollFrame:SetScrollStep(50)

    self:InitWidgets()

    ---@class UnitsFramesTab.widgetListFrame: CellCombatFrame
    local widgetListWindow = CUF:CreateFrame("CUF_Menu_UnitFrame_WidgetList", self.window,
        sectionWidth / 3,
        self.settingsFrame:GetHeight(), false, true)
    widgetListWindow:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMLEFT", -5 + 1, 0)

    -- Give the widget list a mask and hook it to the menu's mask
    F:ApplyCombatProtectionToFrame(widgetListWindow)
    Cell:CreateMask(widgetListWindow, nil, { 1, -1, -1, 1 })
    widgetListWindow.mask:Hide()

    hooksecurefunc(Menu.window.mask, "Show", function()
        widgetListWindow.mask:Show()
    end)
    hooksecurefunc(Menu.window.mask, "Hide", function()
        widgetListWindow.mask:Hide()
    end)

    ---@class UnitsFramesTab.widgetListFrame: Frame
    ---@field scrollFrame CellScrollFrame
    self.widgetListFrame = CUF:CreateFrame("CUF_Menu_UnitFrame_WidgetListFrame", widgetListWindow,
        widgetListWindow:GetWidth(),
        widgetListWindow:GetHeight(), false, true)
    self.widgetListFrame:SetPoint("TOPLEFT", widgetListWindow, "TOPLEFT", 0, 0)

    Cell:CreateScrollFrame(self.widgetListFrame)
    self.widgetListFrame.scrollFrame:SetScrollStep(25)
end
