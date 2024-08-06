---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
local DB = CUF.DB

-------------------------------------------------
-- MARK: Widget Setters
-------------------------------------------------

---@param widget Widget
---@param unit Unit
function W.SetEnabled(widget, unit)
    local enabled = DB.IsWidgetEnabled(widget.id, unit)

    widget.enabled = enabled
    if not enabled then
        widget:Hide()
        return
    else
        widget:Show()
    end
end

---@param widget Widget
---@param unit Unit
function W.SetPosition(widget, unit)
    local position = DB.GetWidgetPosition(widget.id, unit)

    widget:ClearAllPoints()
    widget:SetPoint(position.anchor, widget:GetParent(),
        position.offsetX,
        position.offsetY)
end

---@param widget Widget
---@param unit Unit
function W.SetFontStyle(widget, unit)
    local styleTable = DB.GetWidgetTable(widget.id, unit)

    local font = F:GetFont(styleTable.font.style)

    local fontFlags
    if styleTable.font.outline == "None" then
        fontFlags = ""
    elseif styleTable.font.outline == "Outline" then
        fontFlags = "OUTLINE"
    else
        fontFlags = "OUTLINE,MONOCHROME"
    end

    widget:SetFont(font, styleTable.font.size, fontFlags)

    if styleTable.font.shadow then
        widget:SetShadowOffset(1, -1)
        widget:SetShadowColor(0, 0, 0, 1)
    else
        widget:SetShadowOffset(0, 0)
        widget:SetShadowColor(0, 0, 0, 0)
    end
end

---@param widget Widget
---@param unit Unit
function W.SetFontColor(widget, unit)
    local color = DB.GetWidgetTable(widget.id, unit).color

    widget.colorType = color.type
    widget.rgb = color.rgb

    widget:UpdateTextColor()
end

-- Set `_isSelected` property for the widget
---@param widget Widget
---@param val boolean
function W.SetIsSelected(widget, val)
    widget._isSelected = val
end

---@param widget Widget
---@param unit Unit
function W.SetWidgetSize(widget, unit)
    local size = DB.GetWidgetTable(widget.id, unit).size

    widget:SetWidth(size.width)
    widget:SetHeight(size.height)
end

---@param widget Widget
---@param unit Unit
function W.SetWidgetFrameLevel(widget, unit)
    local frameLevel = DB.GetWidgetTable(widget.id, unit).frameLevel

    widget:SetFrameLevel(frameLevel)
end
