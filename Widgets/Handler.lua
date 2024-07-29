---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.Util
local Util = CUF.Util

---@class CUF.widgets.Handler
---@field widgets table<string, function>
local Handler = {}
Handler.widgets = {}

CUF.widgetsHandler = Handler

---@param layout string?
---@param unit string?
---@param widgetName string?
---@param setting string?
function Handler.UpdateWidgets(layout, unit, widgetName, setting, ...)
    CUF:Debug("|cffff7777UpdateWidgets:|r ", layout, unit, widgetName, setting, ...)

    if layout and layout ~= Cell.vars.currentLayout then return end

    layout = layout or Cell.vars.currentLayout

    if widgetName then
        Util:IterateAllUnitButtons(Handler.widgets[widgetName], unit, setting, ...)
        return
    end

    for name, func in pairs(Handler.widgets) do
        if not widgetName or name == widgetName then
            Util:IterateAllUnitButtons(func, unit, setting, ...)
        end
    end
end

CUF:RegisterCallback("UpdateWidget", "Handler_UpdateWidget", Handler.UpdateWidgets)

---@param func function
---@param name string
function Handler:RegisterWidget(func, name)
    CUF:Debug("|cffff7777RegisterWidget:|r", name)
    self.widgets[name] = func
end
