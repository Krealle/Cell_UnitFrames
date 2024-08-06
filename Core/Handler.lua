---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

local Util = CUF.Util
local const = CUF.constants

---@class CUF.Handler
---@field widgets table<WIDGET_KIND, function>
---@field options table<WIDGET_KIND, table<number, function>>
local Handler = {}
Handler.widgets = {}
Handler.options = {}

CUF.Handler = Handler

-------------------------------------------------
-- MARK: Widgets
-------------------------------------------------

---@param button CUFUnitButton
---@param unit Unit
---@param widgetName WIDGET_KIND
---@param setting OPTION_KIND
---@param subSetting string
local function IterateGenericSetters(button, unit, widgetName, setting, subSetting)
    local widget = button.widgets[widgetName] ---@type Widget
    if not widget then return end

    if (not setting or setting == "enabled") and type(widget.SetEnabled) == "function" then
        widget:SetEnabled(unit)
    end
    if (not setting or setting == const.OPTION_KIND.POSITION) and type(widget.SetPosition) == "function" then
        widget:SetPosition(unit)
    end
    if (not setting or setting == const.OPTION_KIND.FONT) and type(widget.SetFontStyle) == "function" then
        widget:SetFontStyle(unit)
    end
    if (not setting or setting == const.OPTION_KIND.COLOR) and type(widget.SetFontColor) == "function" then
        widget:SetFontColor(unit)
    end
    if (not setting or setting == const.OPTION_KIND.SIZE) and type(widget.SetWidgetSize) == "function" then
        widget:SetWidgetSize(unit)
    end
    if (not setting or setting == const.OPTION_KIND.FRAMELEVEL) and type(widget.SetWidgetFrameLevel) == "function" then
        widget:SetWidgetFrameLevel(unit)
    end
end

---@param layout string?
---@param unit Unit?
---@param widgetName WIDGET_KIND?
---@param setting OPTION_KIND?
function Handler.UpdateWidgets(layout, unit, widgetName, setting, ...)
    CUF:Debug("|cffff7777UpdateWidgets:|r", layout, unit, widgetName, setting, ...)

    if layout and layout ~= Cell.vars.currentLayout then return end

    for name, func in pairs(Handler.widgets) do
        if not widgetName or name == widgetName then
            Util:IterateAllUnitButtons(IterateGenericSetters, unit, name, setting, ...)
            Util:IterateAllUnitButtons(func, unit, setting, ...)
        end
    end
end

CUF:RegisterCallback("UpdateWidget", "Handler_UpdateWidget", Handler.UpdateWidgets)

---@param func function
---@param widgetName WIDGET_KIND
function Handler:RegisterWidget(func, widgetName)
    --CUF:Debug("|cffff7777RegisterWidget:|r", widgetName)
    self.widgets[widgetName] = func
end

-------------------------------------------------
-- MARK: Pages
-------------------------------------------------

-- Set `_isSelected` for the button and corresponding widget that is selected in menu.
--
-- Called when `LoadPageDB` is called or when optionsFrame is hidden.
---@param selectedUnit Unit?
---@param selectedWidget WIDGET_KIND?
function Handler.UpdateSelected(selectedUnit, selectedWidget)
    CUF:Debug("|cffff7777Handler.UpdateSelected:|r", selectedUnit, selectedWidget, CUF.vars.isMenuOpen)
    Util:IterateAllUnitButtons(
    ---@param button CUFUnitButton
        function(button)
            button._isSelected = button.states.unit == selectedUnit and CUF.vars.isMenuOpen
            for _, widget in pairs(const.WIDGET_KIND) do
                local isSelected = widget == selectedWidget and button._isSelected
                button.widgets[widget]:_SetIsSelected(isSelected)
            end
        end)
end

---@param page Unit
---@param subPage WIDGET_KIND
function Handler.LoadPageDB(page, subPage)
    -- Both params are only present when LoadLayoutDB is called
    if not page or not subPage then
        if (page and page == Handler.previousPage)
            or (subPage and subPage == Handler.previousSubPage) then
            CUF:Debug("|cffff7777Handler.LoadPageDB:|r", page, subPage, "skipping")
            return
        end
    end

    CUF:Debug("|cffff7777Handler.LoadPageDB:|r", page, subPage)

    subPage = subPage or CUF.vars.selectedWidget
    page = page or CUF.vars.selectedUnit

    Handler.previousPage = page
    Handler.previousSubPage = subPage

    for widgetName, funcs in pairs(Handler.options) do
        if subPage == widgetName then
            for _, func in pairs(funcs) do
                func(subPage)
            end
        end
    end

    Handler.UpdateSelected(page, subPage)
end

CUF:RegisterCallback("LoadPageDB", "Handler_LoadPageDB", Handler.LoadPageDB)

---@param func function
--- @param widgetName WIDGET_KIND
--- @param optName string
function Handler:RegisterOption(func, widgetName, optName)
    --CUF:Debug("|cffff7777RegisterOption:|r", widgetName, optName)
    if not self.options[widgetName] then
        self.options[widgetName] = {}
    end
    table.insert(self.options[widgetName], func)
end
