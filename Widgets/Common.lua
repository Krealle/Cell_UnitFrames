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

---@param widget Widget
---@param styleTable WidgetTable
function W.SetFontStyle(widget, styleTable)
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
---@param styleTable WidgetTable
function W.SetFontColor(widget, styleTable)
    widget.colorType = styleTable.color.type
    widget.rgb = styleTable.color.rgb

    ---@diagnostic disable-next-line: param-type-mismatch
    widget:UpdateTextColor()
end

-- Set `_isSelected` property for the widget
---@param widget Widget
---@param val boolean
function W.SetIsSelected(widget, val)
    widget._isSelected = val
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
