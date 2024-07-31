---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.Util
local Util = CUF.Util

---@class CUF.widgets.Handler
---@field widgets table<WIDGET_KIND, function>
---@field options table<WIDGET_KIND, table<number, function>>
local Handler = {}
Handler.widgets = {}
Handler.options = {}

CUF.widgetsHandler = Handler

---@param button CUFUnitButton
---@param unit Unit
---@param widgetName WIDGET_KIND
---@param setting string
---@param subSetting string
local function IterateGenericSetters(button, unit, widgetName, setting, subSetting)
    local widget = button.widgets[widgetName]
    if not widget then return end

    if not setting or setting == "enabled" and type(widget.SetEnabled) == "function" then
        widget:SetEnabled(unit)
    end
    if not setting or setting == "position" and type(widget.SetPosition) == "function" then
        widget:SetPosition(unit)
    end
    if not setting or setting == "font" and type(widget.SetFontStyle) == "function" then
        widget:SetFontStyle(unit)
    end
    if not setting or setting == "textColor" and type(widget.SetFontColor) == "function" then
        widget:SetFontColor(unit)
    end
end

---@param layout string?
---@param unit Unit?
---@param widgetName WIDGET_KIND?
---@param setting string?
function Handler.UpdateWidgets(layout, unit, widgetName, setting, ...)
    CUF:Debug("|cffff7777UpdateWidgets:|r ", layout, unit, widgetName, setting, ...)

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
    CUF:Debug("|cffff7777RegisterWidget:|r", widgetName)
    self.widgets[widgetName] = func
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

    Handler.previousPage = page
    Handler.previousSubPage = subPage

    for widgetName, funcs in pairs(Handler.options) do
        if subPage == widgetName then
            for _, func in pairs(funcs) do
                func(subPage)
            end
        end
    end
end

CUF:RegisterCallback("LoadPageDB", "Handler_LoadPageDB", Handler.LoadPageDB)

---@param func function
--- @param widgetName WIDGET_KIND
--- @param optName string
function Handler:RegisterOption(func, widgetName, optName)
    CUF:Debug("|cffff7777RegisterOption:|r", widgetName, optName)
    if not self.options[widgetName] then
        self.options[widgetName] = {}
    end
    table.insert(self.options[widgetName], func)
end
