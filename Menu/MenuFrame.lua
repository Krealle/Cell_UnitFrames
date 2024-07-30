---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local P = Cell.pixelPerfectFuncs
local F = Cell.funcs

---@class MenuFrame
---@field window CellCombatFrame
---@field units table<Units, UnitsMenuPage>
---@field unitsButtons table<UnitMenuPageButton>
---@field widgets table<Units, WidgetsMenuPage>
---@field widgetsButtons table<WidgetMenuPageButton>
local menuWindow = {}
menuWindow.units = {}
menuWindow.unitsButtons = {}
menuWindow.widgets = {}
menuWindow.widgetsButtons = {}

CUF.MenuWindow = menuWindow

---@param unit string
function menuWindow:SetUnit(unit)
    CUF:Debug("menuWindow - SetUnit", unit)
    -- Hide old unit
    if self.selectedUnit then
        self.selectedUnit.frame:Hide()
    end

    self.selectedUnit = self.units[unit]

    self.selectedUnit.frame:SetAllPoints(self.unitAnchor)
    self.selectedUnit.frame:Show()
end

---@param widget string
function menuWindow:SetWidget(widget)
    CUF:Debug("menuWindow - SetWidget", widget)
    -- Hide old widget
    if self.selectedWidget then
        self.selectedWidget.frame:Hide()
    end

    self.selectedWidget = self.widgets[widget]

    self.selectedWidget.frame:SetAllPoints(self.widgetAnchor)
    self.selectedWidget.frame:Show()

    self:UpdateHeight()
end

function menuWindow:InitUnits()
    CUF:Debug("menuWindow - InitUnits")
    local prevButton

    for _, fn in pairs(CUF.Menu.unitsToAdd) do
        ---@type UnitsMenuPage
        local unit = fn(self)

        self.units[unit.id] = unit

        if prevButton then
            unit.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", P:Scale(1), 0)
        else
            unit.button:SetPoint("TOPRIGHT", self.unitAnchor)
        end
        prevButton = unit.button

        table.insert(self.unitsButtons, unit.button)
    end

    CUF:DevAdd(self.units, "menuWindow - units")
end

function menuWindow:InitWidgets()
    CUF:Debug("menuWindow - InitWidgets")
    local prevButton

    for _, fn in pairs(CUF.Menu.widgetsToAdd) do
        ---@type WidgetsMenuPage
        local widget = fn(self)

        self.widgets[widget.id] = widget

        if prevButton then
            widget.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", P:Scale(1), 0)
        else
            widget.button:SetPoint("TOPRIGHT", self.widgetAnchor)
        end
        prevButton = widget.button

        table.insert(self.widgetsButtons, widget.button)
    end

    CUF:DevAdd(self.widgets, "menuWindow - widgets")
end

function menuWindow:ShowMenu()
    CUF:Debug("menuWindow - ShowMenu")
    if not self.window then
        self:Create()
    end

    self.window:Show()

    self.unitsButtons[1]:Click()
    self.widgetsButtons[1]:Click()
end

function menuWindow:HideMenu()
    CUF:Debug("menuWindow - HideMenu")
    if not self.window then return end
    self.window:Hide()
end

function menuWindow:UpdateHeight()
    CUF:Debug("menuWindow - UpdateHeight")
    local widgetHeight = self.selectedWidget.height

    self.window:SetHeight(self.baseHeight + widgetHeight)
end

function menuWindow:Create()
    CUF:Debug("menuWindow - Create")

    local optionsFrame = Cell.frames.optionsFrame

    self.baseHeight = 200
    self.baseWidth = 422
    self.window = Cell:CreateFrame("CellOptionsFrame_UnitFramesWindow", optionsFrame, self.baseWidth,
        self.baseHeight)
    self.window:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", -self.baseWidth, -105)

    -- mask
    F:ApplyCombatProtectionToFrame(self.window)
    Cell:CreateMask(self.window, nil, { 1, -1, -1, 1 })
    self.window.mask:Hide()

    self.unitPane = Cell:CreateTitledPane(self.window, L["Unit Frames"], self.baseWidth - 10,
        self.baseHeight - 5)
    self.unitPane:SetPoint("TOPLEFT", 5, -5)
    self.unitAnchor = CreateFrame("Frame", nil, self.unitPane)
    self.unitAnchor:SetAllPoints(self.unitPane)

    self:InitUnits()
    CUF:DevAdd(self.unitsButtons, "unitsButtons")
    Cell:CreateButtonGroup(self.unitsButtons, function(unit, b)
        self:SetUnit(unit)
        CUF.Menu:UpdateSelected(unit)
    end)

    self.widgetPane = Cell:CreateTitledPane(self.window, L["Widgets"], self.baseWidth - 10, 200)
    self.widgetPane:SetPoint("TOPLEFT", self.window, "TOPLEFT", 5, -self.window:GetHeight())
    self.widgetAnchor = CreateFrame("Frame", nil, self.widgetPane)
    self.widgetAnchor:SetAllPoints(self.widgetPane)

    self:InitWidgets()
    CUF:DevAdd(self.widgetsButtons, "widgetsButtons")
    Cell:CreateButtonGroup(self.widgetsButtons, function(widget, b)
        self:SetWidget(widget)
        CUF.Menu:UpdateSelected(nil, widget)
    end)
end
