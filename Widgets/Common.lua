---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.widgets.builder

-------------------------------------------------
-- MARK: Widget Setters
-------------------------------------------------

---@param widget Widget
---@param unit Unit
function W.SetEnabled(widget, unit)
    local enabled = CUF.vars.selectedLayoutTable[unit].widgets[widget.id].enabled

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
    local position = CUF.vars.selectedLayoutTable[unit].widgets[widget.id].position

    widget:ClearAllPoints()
    widget:SetPoint(position.anchor, widget:GetParent(),
        position.offsetX,
        position.offsetY)
end

---@param widget Widget
---@param unit Unit
function W.SetFontStyle(widget, unit)
    local styleTable = CUF.vars.selectedLayoutTable[unit].widgets[widget.id]

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
    local color = CUF.vars.selectedLayoutTable[unit].widgets[widget.id].color

    widget.colorType = color.type
    widget.rgb = color.rgb

    widget:UpdateTextColor()
end
