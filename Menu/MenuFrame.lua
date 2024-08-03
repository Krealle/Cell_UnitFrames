---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local P = Cell.pixelPerfectFuncs
local F = Cell.funcs

local Builder = CUF.Builder
local Handler = CUF.widgetsHandler

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

    self.settingsFrame.scrollFrame:SetContentHeight(self.selectedWidget.height)
    self.settingsFrame.scrollFrame:ResetScroll()

    CUF.Menu:UpdateSelectedPages(nil, widget)
end

function menuWindow:ShowMenu()
    CUF:Debug("|cff00ccffShow Menu|r")
    if not self.window then
        self:Create()
    end

    self.window:Show()
    CUF.vars.isMenuOpen = true
end

function menuWindow:HideMenu()
    if not self.window or not self.window:IsShown() then return end
    CUF:Debug("|cff00ccffHide Menu|r")
    self.window:Hide()

    CUF.vars.isMenuOpen = false
    Handler.UpdateSelected()
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

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
    local idx = 1

    for _, widget in pairs(CUF.Menu.widgetsToAdd) do
        ---@type WidgetsMenuPage
        local widgetPage = Builder:CreateWidgetMenuPage(self.settingsFrame, widget.widgetName, widget.menuHeight,
            unpack(widget.options))

        self.widgets[widgetPage.id] = widgetPage

        -- button
        widgetPage.button = Cell:CreateButton(self.widgetPane, L[widget.pageName], "accent-hover", { 85, 17 })
        widgetPage.button.id = widget.widgetName

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                widgetPage.button:SetPoint("TOPRIGHT", self.widgetPane, 0, 16)
                idx = 0
                --[[ self.window:SetHeight(self.window:GetHeight() + 16)
                self.unitPane:SetHeight(self.unitPane:GetHeight() + 16) ]]
            else
                widgetPage.button:SetPoint("TOPRIGHT", prevButton, "TOPLEFT", P:Scale(1), 0)
            end
            idx = idx + 1
        else
            widgetPage.button:SetPoint("TOPRIGHT", self.widgetPane)
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
    CUF:Debug("|cff00ccffCreate Menu|r")
    local optionsFrame = Cell.frames.optionsFrame

    self.unitHeight = 200
    self.widgetHeight = 300
    self.baseWidth = 450
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
    end)

    self.widgetPane = Cell:CreateTitledPane(self.window, L["Widgets"], self.baseWidth - 10, 17)
    self.widgetPane:SetPoint("TOPLEFT", self.unitPane, "BOTTOMLEFT", 0, 0)

    -- settings frame
    self.settingsFrame = Cell:CreateFrame("CUFOptionsFrame_WidgetSettingsFrame", self.widgetPane, 10, 10, true)
    self.settingsFrame:SetSize(self.widgetPane:GetWidth(), self.widgetHeight)
    self.settingsFrame:SetPoint("TOPLEFT", self.widgetPane, "BOTTOMLEFT", 0, -5)
    self.settingsFrame:Show()

    Cell:CreateScrollFrame(self.settingsFrame)
    self.settingsFrame.scrollFrame:SetScrollStep(25)

    self:InitWidgets()
    CUF:DevAdd(self.widgetsButtons, "widgetsButtons")
    Cell:CreateButtonGroup(self.widgetsButtons, function(widget, b)
        self:SetWidget(widget)
    end)

    self.unitsButtons[1]:Click()
    self.widgetsButtons[1]:Click()

    self.init = true

    hooksecurefunc(optionsFrame, "Hide", function()
        self:HideMenu()
    end)
end
