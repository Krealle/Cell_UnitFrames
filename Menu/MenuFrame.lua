---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs

local Builder = CUF.Builder
local Handler = CUF.Handler

---@class MenuFrame
---@field window CellCombatFrame
---@field units table<Unit, UnitsMenuPage>
---@field unitsButtons table<UnitMenuPageButton>
---@field widgets table<WIDGET_KIND, WidgetsMenuPage>
---@field widgetsButtons table<WidgetMenuPageButton>
local menuWindow = {}
menuWindow.units = {}
menuWindow.unitsButtons = {}
menuWindow.widgets = {}
menuWindow.widgetsButtons = {}

CUF.MenuWindow = menuWindow

---@param unit Unit
function menuWindow:SetUnit(unit)
    -- Hide old unit
    if self.selectedUnit then
        self.selectedUnit.frame:Hide()
    end

    self.selectedUnit = self.units[unit]
    self.selectedUnit.frame:Show()

    CUF.Menu:UpdateSelectedPages(unit)
end

-- Update the selected widge
---@param widget WIDGET_KIND
function menuWindow:SetWidget(widget)
    -- Hide old widget
    if self.selectedWidget then
        self.selectedWidget.frame:Hide()
    end

    self.selectedWidget = self.widgets[widget]
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

function menuWindow:ShowMenu()
    CUF:Log("|cff00ccffShow Menu|r")
    if not self.window then
        self:Create()

        self.window:Show()

        self.unitsButtons[1]:Click()
        self.widgetsButtons[1]:Click()

        self.init = true
        CUF.vars.isMenuOpen = true

        return
    end

    self.window:Show()
    CUF.vars.isMenuOpen = true
end

function menuWindow:HideMenu()
    if not self.window or not self.window:IsShown() then return end
    CUF:Log("|cff00ccffHide Menu|r")
    self.window:Hide()

    CUF.vars.isMenuOpen = false
    Handler.UpdateSelected()
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

function menuWindow:InitUnits()
    --CUF:Log("menuWindow - InitUnits")
    local prevButton
    local prevAnchor
    local idx = 1

    for _, fn in pairs(CUF.Menu.unitsToAdd) do
        ---@type UnitsMenuPage
        local unit = fn(self)

        self.units[unit.id] = unit

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                unit.button:SetPoint("BOTTOMLEFT", prevAnchor, "TOPLEFT", 0, 0)
                idx = 1
                prevAnchor = unit.button

                self.window:SetHeight(self.window:GetHeight() + self.paneHeight)
                self.unitPane:SetHeight(self.unitPane:GetHeight() + self.paneHeight)
            else
                unit.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", 1)
                idx = idx + 1
            end
        else
            unit.button:SetPoint("BOTTOMRIGHT", self.unitPane, "BOTTOMRIGHT", 0, 1)
            prevAnchor = unit.button
        end
        prevButton = unit.button

        table.insert(self.unitsButtons, unit.button)
    end

    CUF:DevAdd(self.units, "menuWindow - units")
end

function menuWindow:InitWidgets()
    --CUF:Log("menuWindow - InitWidgets")
    local prevButton
    local prevAnchor
    local idx = 1

    for _, widget in pairs(CUF.Menu.widgetsToAdd) do
        ---@type WidgetsMenuPage
        local widgetPage = Builder:CreateWidgetMenuPage(self.settingsFrame, widget.widgetName, unpack(widget.options))

        self.widgets[widgetPage.id] = widgetPage

        -- button
        widgetPage.button = Cell:CreateButton(self.widgetPane, L[widget.pageName], "accent-hover", { 95, 17 })
        widgetPage.button.id = widget.widgetName

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                widgetPage.button:SetPoint("BOTTOMLEFT", prevAnchor, "TOPLEFT", 0, 0)
                idx = 1
                prevAnchor = widgetPage.button

                self.window:SetHeight(self.window:GetHeight() + self.paneHeight)
                self.widgetPane:SetHeight(self.widgetPane:GetHeight() + self.paneHeight)
            else
                widgetPage.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", 1, 0)
                idx = idx + 1
            end
        else
            widgetPage.button:SetPoint("BOTTOMRIGHT", self.widgetPane, "BOTTOMRIGHT", 0, 1)
            prevAnchor = widgetPage.button
        end
        prevButton = widgetPage.button

        table.insert(self.widgetsButtons, widgetPage.button)
    end

    CUF:DevAdd(self.widgets, "menuWindow - widgets")
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function menuWindow:Create()
    CUF:Log("|cff00ccffCreate Menu|r")
    local optionsFrame = Cell.frames.optionsFrame

    self.unitHeight = 180
    self.widgetHeight = 310
    self.baseWidth = 450
    self.paneHeight = 17

    local buffer = 5
    local gap = buffer * 2
    local windowHeight = self.unitHeight + self.widgetHeight + (self.paneHeight * 2)
    local sectionWidth = self.baseWidth - gap

    ---@class CellCombatFrame
    self.window = CUF:CreateFrame("CUFOptionsFrame_UnitFramesWindow", optionsFrame,
        self.baseWidth,
        windowHeight)
    self.window:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", -self.baseWidth, -105)

    -- mask
    F:ApplyCombatProtectionToFrame(self.window)
    Cell:CreateMask(self.window, nil, { 1, -1, -1, 1 })
    self.window.mask:Hide()

    -- Unit Buttons
    self.unitPane = Cell:CreateTitledPane(self.window, L["Unit Frames"], sectionWidth,
        self.paneHeight)
    self.unitPane:SetPoint("TOPLEFT", buffer, -buffer)

    -- Repoint so it's anchored to bottom
    self.unitPane.line:ClearAllPoints()
    self.unitPane.line:SetPoint("BOTTOMLEFT", self.unitPane, "BOTTOMLEFT")
    self.unitPane.line:SetPoint("BOTTOMRIGHT", self.unitPane, "BOTTOMRIGHT")

    -- Unit Settings
    self.unitSection = CUF:CreateFrame("CUFOptionsFrame_UnitSettingsFrame", self.unitPane,
        sectionWidth,
        self.unitHeight, true, true)
    self.unitSection:SetPoint("TOPLEFT", self.unitPane, "BOTTOMLEFT")

    self:InitUnits()
    CUF:DevAdd(self.unitsButtons, "unitsButtons")
    Cell:CreateButtonGroup(self.unitsButtons, function(unit, b)
        self:SetUnit(unit)
    end)

    -- Widget Buttons
    self.widgetPane = Cell:CreateTitledPane(self.unitSection, L["Widgets"],
        sectionWidth, self.paneHeight)
    self.widgetPane:SetPoint("TOPLEFT", self.unitSection, "BOTTOMLEFT")

    -- Repoint so it's anchored to bottom
    self.widgetPane.line:ClearAllPoints()
    self.widgetPane.line:SetPoint("BOTTOMLEFT", self.widgetPane, "BOTTOMLEFT")
    self.widgetPane.line:SetPoint("BOTTOMRIGHT", self.widgetPane, "BOTTOMRIGHT")

    -- settings frame
    self.settingsFrame = CUF:CreateFrame("CUFOptionsFrame_WidgetSettingsFrame", self.widgetPane,
        sectionWidth,
        (self.widgetHeight - self.paneHeight), true, true)
    self.settingsFrame:SetPoint("TOPLEFT", self.widgetPane, "BOTTOMLEFT", 0, -buffer)

    Cell:CreateScrollFrame(self.settingsFrame)
    self.settingsFrame.scrollFrame:SetScrollStep(25)

    self:InitWidgets()
    CUF:DevAdd(self.widgetsButtons, "widgetsButtons")
    Cell:CreateButtonGroup(self.widgetsButtons, function(widget, b)
        self:SetWidget(widget)
    end)

    hooksecurefunc(optionsFrame, "Hide", function()
        self:HideMenu()
    end)
end
