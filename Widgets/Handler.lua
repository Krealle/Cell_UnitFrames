---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.Util
local Util = CUF.Util

---@class CUF.widgets.Handler
---@field widgets table<Widgets, function>
---@field options table<Units, table<Widgets, function>>
local Handler = {}
Handler.widgets = {}
Handler.options = {}

CUF.widgetsHandler = Handler

---@param layout string?
---@param unit string?
---@param widgetName Widgets?
---@param setting string?
function Handler.UpdateWidgets(layout, unit, widgetName, setting, ...)
    CUF:Debug("|cffff7777UpdateWidgets:|r ", layout, unit, widgetName, setting, ...)

    if layout and layout ~= Cell.vars.currentLayout then return end

    layout = layout or Cell.vars.currentLayout

    if widgetName then
        Util:IterateAllUnitButtons(Handler.widgets[widgetName], unit, widgetName, ...)
        return
    end

    for name, func in pairs(Handler.widgets) do
        if not widgetName or name == widgetName then
            Util:IterateAllUnitButtons(func, unit, name, ...)
        end
    end
end

CUF:RegisterCallback("UpdateWidget", "Handler_UpdateWidget", Handler.UpdateWidgets)

---@param func function
---@param widgetName Widgets
function Handler:RegisterWidget(func, widgetName)
    CUF:Debug("|cffff7777RegisterWidget:|r", widgetName)
    self.widgets[widgetName] = func
end

---@param page string
---@param subPage string
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

function Handler:RegisterOption(func, widgetName, optName)
    CUF:Debug("|cffff7777RegisterOption:|r", widgetName, optName)
    if not self.options[widgetName] then
        self.options[widgetName] = {}
    end
    table.insert(self.options[widgetName], func)
end
