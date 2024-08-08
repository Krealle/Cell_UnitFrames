---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
local W = CUF.widgets

-------------------------------------------------
-- MARK: Widget Setters
-------------------------------------------------

---@param widget Widget
---@param styleTable WidgetTable
function W.SetEnabled(widget, styleTable)
    widget.enabled = styleTable.enabled
    if not styleTable.enabled then
        widget:Hide()
        return
    else
        widget:Show()
    end
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetPosition(widget, styleTable)
    widget:ClearAllPoints()
    widget:SetPoint(styleTable.position.anchor, widget:GetParent(),
        styleTable.position.offsetX,
        styleTable.position.offsetY)
end

-- Set `_isSelected` property for the widget and call `_OnIsSelected` if it exists
---@param widget Widget
---@param val boolean
function W.SetIsSelected(widget, val)
    widget._isSelected = val
    if widget._OnIsSelected then
        widget:_OnIsSelected()
    end
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetWidgetSize(widget, styleTable)
    widget:SetWidth(styleTable.size.width)
    widget:SetHeight(styleTable.size.height)
end

---@param widget Widget
---@param styleTable WidgetTable
function W.SetWidgetFrameLevel(widget, styleTable)
    widget:SetFrameLevel(styleTable.frameLevel)
end
