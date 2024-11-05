---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
---@field WidgetsCreateFuncs table<WIDGET_KIND, fun(self: CUF.widgets, button: CUFUnitButton)>
local W = CUF.widgets
W.WidgetsCreateFuncs = {}

local P = CUF.PixelPerfect

-------------------------------------------------
-- MARK: Widget Setters
-------------------------------------------------

---@param widget Widget
---@param styleTable WidgetTable
function W.SetEnabled(widget, styleTable)
    widget.enabled = styleTable.enabled
    if not styleTable.enabled then
        widget._owner:DisableWidget(widget)
        return
    end
    widget._owner:EnableWidget(widget)
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetPosition(widget, styleTable)
    P.ClearPoints(widget)
    P.Point(widget, styleTable.position.point, widget:GetParent(),
        styleTable.position.offsetX, styleTable.position.offsetY)
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetRelativePosition(widget, styleTable)
    P.ClearPoints(widget)
    P.Point(widget, styleTable.position.point, widget:GetParent(),
        styleTable.position.relativePoint, styleTable.position.offsetX,
        styleTable.position.offsetY)
end

-- Set `_isSelected` property for the widget and call `_OnIsSelected` if it exists
---@param widget Widget
---@param val boolean
function W.SetIsSelected(widget, val)
    widget._isSelected = val
    if widget._OnIsSelected then
        ---@diagnostic disable-next-line: param-type-mismatch
        widget:_OnIsSelected()
    end
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetWidgetSize(widget, styleTable)
    P.Size(widget, styleTable.size.width, styleTable.size.height)
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetWidgetFrameLevel(widget, styleTable)
    widget:SetFrameLevel(styleTable.frameLevel)
end

-------------------------------------------------
-- MARK: Assign Widgets to Buttons
-------------------------------------------------

---@param widgetName WIDGET_KIND
---@param func fun(self: CUF.widgets, button: CUFUnitButton)
function W:RegisterCreateWidgetFunc(widgetName, func)
    self.WidgetsCreateFuncs[widgetName] = func
end

---@param button CUFUnitButton
---@param widgetName WIDGET_KIND
function W:CreateWidget(button, widgetName)
    if not self.WidgetsCreateFuncs[widgetName] then return end

    self.WidgetsCreateFuncs[widgetName](self, button)
end

---@param button CUFUnitButton
---@param unit Unit
function W:AssignWidgets(button, unit)
    -- Unit passed will be 'bossN', we need 'boss'
    if strfind(unit, "boss") then
        unit = "boss"
    end

    for widgetName, _ in pairs(CUF.Defaults.Layouts[unit].widgets) do
        W:CreateWidget(button, widgetName)
    end
end
