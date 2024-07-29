---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local P = Cell.pixelPerfectFuncs
local F = Cell.funcs

---@class MenuFrame
local menuWindow = {}
menuWindow.units = {}
menuWindow.unitsButtons = {}
menuWindow.widgets = {}
menuWindow.widgetsButtons = {}

CUF.MenuWindow = menuWindow

local menu

---@param unit string
function menuWindow:SetUnit(unit)
    CUF:Debug("menuWindow - SetUnit", unit)
    -- Hide old unit
    if self.units[self.selectedUnit] then
        self.units[self.selectedUnit].frame:Hide()
    end

    self.selectedUnit = unit
    self.units[unit].frame:SetAllPoints(self.unitAnchor)

    self.units[unit].frame:Show()

    menu.selectedUnit = unit
end

---@param widget string
function menuWindow:SetWidget(widget)
    CUF:Debug("menuWindow - SetWidget", widget)
    -- Hide old widget
    self.widgets[self.selectedWidget]:Hide()

    self.selectedWidget = widget

    self.selectedWidget[widget]:ClearAllPoints()
    self.selectedWidget[widget]:SetPoint("TOPRIGHT", self.widgetPane)

    self.widgets[widget]:Show()

    self:UpdateHeight()
end

function menuWindow:InitUnits()
    CUF:Debug("menuWindow - InitUnits")
    local prevButton

    for idx, fn in pairs(CUF.Menu.unitsToAdd) do
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

function menuWindow:AddWidget(widget)
    CUF:Debug("menuWindow - AddWidget", widget)
    self.widgets[widget.id] = widget
    table.insert(self.widgetsButtons, widget.button)
end

function menuWindow:ShowMenu()
    CUF:Debug("menuWindow - ShowMenu")
    if not self.window then
        self:Create()
    end

    self.window:Show()

    self.unitsButtons[1]:Click()
    --self.widgetsButtons[0]:Click()

    self:UpdateHeight()
end

function menuWindow:HideMenu()
    CUF:Debug("menuWindow - HideMenu")
    if not self.window then return end
    self.window:Hide()
end

function menuWindow:UpdateHeight()
    CUF:Debug("menuWindow - UpdateHeight")
    local widgetHeight = self.widgets[self.selectedWidget] and
        self.widgets[self.selectedWidget]:GetHeight() or 0

    self.window:SetHeight(self.baseHeight + widgetHeight)
end

function menuWindow:Create()
    CUF:Debug("menuWindow - Create")
    menu = CUF.Menu

    local optionsFrame = Cell.frames.optionsFrame

    self.baseHeight = 300
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
        CUF:Fire("LoadPageDB", unit)
    end)

    self.widgetPane = Cell:CreateTitledPane(self.window, L["Widgets"], self.baseWidth - 10, 384)
    self.widgetPane:SetPoint("TOPLEFT", self.window, "TOPLEFT", 5, -self.window:GetHeight())
    --[[ Cell:CreateButtonGroup(self.widgetsButtons, function(widget, b)
        self:SetWidget(widget)
    end) ]]
end
