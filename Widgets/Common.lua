---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
---@field WidgetsCreateFuncs table<WIDGET_KIND, fun(self: CUF.widgets, button: CUFUnitButton)>
local W = CUF.widgets
W.WidgetsCreateFuncs = {}

local P = CUF.PixelPerfect
local DB = CUF.DB
local const = CUF.constants

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

---@param widget Widget
---@param styleTable WidgetTable
function W.SetDetachedRelativePosition(widget, styleTable)
    P.ClearPoints(widget)

    if not styleTable.anchorToParent then
        -- Boss Frames widgets should be relative to the parent
        local unitN = tonumber(string.match(widget._owner._unit, "%d+"))

        if unitN and unitN > 1 then
            local layout = DB.CurrentLayoutTable()
            local unitLayout = layout[widget._owner._baseUnit]

            if unitLayout.growthDirection == const.GROWTH_ORIENTATION.TOP_TO_BOTTOM then
                P.Point(widget, "CENTER", UIParent, "CENTER",
                    styleTable.detachedPosition.offsetX,
                    styleTable.detachedPosition.offsetY - ((unitN - 1) * (unitLayout.spacing + unitLayout.size[2])))
            elseif unitLayout.growthDirection == const.GROWTH_ORIENTATION.BOTTOM_TO_TOP then
                P.Point(widget, "CENTER", UIParent, "CENTER",
                    styleTable.detachedPosition.offsetX,
                    styleTable.detachedPosition.offsetY + ((unitN - 1) * (unitLayout.spacing + unitLayout.size[2])))
            elseif unitLayout.growthDirection == const.GROWTH_ORIENTATION.LEFT_TO_RIGHT then
                P.Point(widget, "CENTER", UIParent, "CENTER",
                    styleTable.detachedPosition.offsetX + ((unitN - 1) * (unitLayout.spacing + unitLayout.size[1])),
                    styleTable.detachedPosition.offsetY)
            elseif unitLayout.growthDirection == const.GROWTH_ORIENTATION.RIGHT_TO_LEFT then
                P.Point(widget, "CENTER", UIParent, "CENTER",
                    styleTable.detachedPosition.offsetX - ((unitN - 1) * (unitLayout.spacing + unitLayout.size[1])),
                    styleTable.detachedPosition.offsetY)
            end

            return
        end

        P.Point(widget, "CENTER", UIParent, "CENTER",
            styleTable.detachedPosition.offsetX,
            styleTable.detachedPosition.offsetY)

        return
    end

    P.Point(widget, styleTable.position.point,
        widget._parentAnchor or widget:GetParent(),
        styleTable.position.relativePoint,
        styleTable.position.offsetX,
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
-- MARK: Widget Helpers
-------------------------------------------------

---@param widget WIDGET_KIND
---@param unit Unit
---@param x number
---@param y number
---@param setDetached boolean?
function W.SaveDetachedPosition(widget, unit, x, y, setDetached)
    local styleTable = DB.GetCurrentWidgetTable(widget, unit)

    local maxX, maxY = GetPhysicalScreenSize()

    if x > maxX / 2 then
        x = maxX
    end
    if y > maxY / 2 then
        y = maxY
    end

    if setDetached ~= nil then
        styleTable.anchorToParent = false
    end
    styleTable.detachedPosition.offsetX = x
    styleTable.detachedPosition.offsetY = y

    CUF:Fire("UpdateWidget", nil, unit, widget, "position")
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
    if string.find(unit, "boss") then
        unit = "boss"
    end

    for widgetName, _ in pairs(CUF.Defaults.Layouts[unit].widgets) do
        W:CreateWidget(button, widgetName)
    end
end
