---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local P = Cell.pixelPerfectFuncs
local F = Cell.funcs

---@class CUF.builder
local Builder = CUF.Builder

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
    --CUF:Debug("menuWindow - SetUnit", unit)
    -- Hide old unit
    if self.selectedUnit then
        self.selectedUnit.frame:Hide()
    end

    self.selectedUnit = self.units[unit]
    self.selectedUnit.frame:Show()
end

---@param widget WIDGET_KIND
function menuWindow:SetWidget(widget)
    --CUF:Debug("menuWindow - SetWidget", widget)
    -- Hide old widget
    if self.selectedWidget then
        self.selectedWidget.frame:Hide()
    end

    self.selectedWidget = self.widgets[widget]
    self.selectedWidget.frame:Show()

    self.settingsFrame.scrollFrame:SetContentHeight(self.selectedWidget.height)
    self.settingsFrame.scrollFrame:ResetScroll()
end

function menuWindow:InitUnits()
    --CUF:Debug("menuWindow - InitUnits")
    local prevButton

    for _, fn in pairs(CUF.Menu.unitsToAdd) do
        ---@type UnitsMenuPage
        local unit = fn(self)

        self.units[unit.id] = unit

        if prevButton then
            unit.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", P:Scale(1), 0)
        else
            unit.button:SetPoint("TOPRIGHT", self.unitPane)
        end
        prevButton = unit.button

        table.insert(self.unitsButtons, unit.button)
    end

    CUF:DevAdd(self.units, "menuWindow - units")
end

function menuWindow:InitWidgets()
    --CUF:Debug("menuWindow - InitWidgets")
    local prevButton

    for _, widget in pairs(CUF.Menu.widgetsToAdd) do
        ---@type WidgetsMenuPage
        local widgetPage = Builder:CreateWidgetMenuPage(self.settingsFrame, widget.widgetName, widget.menuHeight,
            unpack(widget.options))

        self.widgets[widgetPage.id] = widgetPage

        -- button
        widgetPage.button = Cell:CreateButton(self.widgetPane, L[widget.pageName], "accent-hover", { 85, 17 })
        widgetPage.button.id = widget.widgetName
        if prevButton then
            widgetPage.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", P:Scale(1), 0)
        else
            widgetPage.button:SetPoint("TOPRIGHT", self.widgetPane)
        end
        prevButton = widgetPage.button

        table.insert(self.widgetsButtons, widgetPage.button)
    end

    CUF:DevAdd(self.widgets, "menuWindow - widgets")
end

function menuWindow:ShowMenu()
    --CUF:Debug("menuWindow - ShowMenu")
    if not self.window then
        self:Create()
    end

    self.window:Show()

    self.unitsButtons[1]:Click()
    self.widgetsButtons[1]:Click()
end

function menuWindow:HideMenu()
    --CUF:Debug("menuWindow - HideMenu")
    if not self.window then return end
    self.window:Hide()
end

function menuWindow:Create()
    --CUF:Debug("menuWindow - Create")
    local optionsFrame = Cell.frames.optionsFrame

    self.unitHeight = 200
    self.widgetHeight = 230
    self.baseWidth = 422
    self.window = Cell:CreateFrame("CUFOptionsFrame_UnitFramesWindow", optionsFrame, self.baseWidth,
        self.unitHeight + self.widgetHeight + 10 + 17)
    self.window:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", -self.baseWidth, -105)

    -- mask
    F:ApplyCombatProtectionToFrame(self.window)
    Cell:CreateMask(self.window, nil, { 1, -1, -1, 1 })
    self.window.mask:Hide()

    self.unitPane = Cell:CreateTitledPane(self.window, L["Unit Frames"], self.baseWidth - 10,
        200)
    self.unitPane:SetPoint("TOPLEFT", 5, -5)

    self:InitUnits()
    CUF:DevAdd(self.unitsButtons, "unitsButtons")
    Cell:CreateButtonGroup(self.unitsButtons, function(unit, b)
        self:SetUnit(unit)
        CUF.Menu:UpdateSelected(unit)
    end)

    self.widgetPane = Cell:CreateTitledPane(self.window, L["Widgets"], self.baseWidth - 10, 17)
    self.widgetPane:SetPoint("TOPLEFT", self.unitPane, "BOTTOMLEFT", 0, 0)

    -- settings frame
    self.settingsFrame = Cell:CreateFrame("CUFOptionsFrame_WidgetSettingsFrame", self.widgetPane, 10, 10, true)
    self.settingsFrame:SetSize(self.widgetPane:GetWidth(), self.widgetHeight)
    self.settingsFrame:SetPoint("TOPLEFT", self.widgetPane, "BOTTOMLEFT")
    self.settingsFrame:Show()

    Cell:CreateScrollFrame(self.settingsFrame)
    self.settingsFrame.scrollFrame:SetScrollStep(25)

    self:InitWidgets()
    CUF:DevAdd(self.widgetsButtons, "widgetsButtons")
    Cell:CreateButtonGroup(self.widgetsButtons, function(widget, b)
        self:SetWidget(widget)
        CUF.Menu:UpdateSelected(nil, widget)
    end)
end
