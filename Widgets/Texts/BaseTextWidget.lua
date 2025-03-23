---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets

local Util = CUF.Util
local const = CUF.constants
local P = CUF.PixelPerfect

---@param button CUFUnitButton
---@param kind WIDGET_KIND
---@return TextWidget
function W.CreateBaseTextWidget(button, kind)
    ---@class TextWidget: Frame
    local textWidget = CreateFrame("Frame", button:GetName() .. "_" .. Util:ToTitleCase(kind), button)

    ---@class TextWidget.text: FontString
    local text = textWidget:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)

    -- Point frame to text so size is always correct
    textWidget:SetAllPoints(text)

    textWidget.text = text
    textWidget.enabled = false
    textWidget.id = kind
    textWidget._isSelected = false
    textWidget.colorType = const.ColorType.CLASS_COLOR ---@type HealthColorType
    textWidget.rgb = { 1, 1, 1 }
    textWidget._owner = button

    ---@param styleTable WidgetTable
    function textWidget:SetFontStyle(styleTable)
        local font = F.GetFont(styleTable.font.style)

        local fontFlags ---@type TBFFlags|nil
        if styleTable.font.outline == "Outline" then
            fontFlags = "OUTLINE"
        elseif styleTable.font.outline == "Monochrome" then
            fontFlags = "MONOCHROME"
        end

        self.text:SetFont(font, styleTable.font.size, fontFlags)

        if styleTable.font.shadow then
            self.text:SetShadowOffset(1, -1)
            self.text:SetShadowColor(0, 0, 0, 1)
        else
            self.text:SetShadowOffset(0, 0)
            self.text:SetShadowColor(0, 0, 0, 0)
        end

        self.text:SetJustifyH(styleTable.font.justify)
    end

    ---@param styleTable WidgetTable
    function textWidget:SetFontColor(styleTable)
        self.colorType = styleTable.color.type
        self.rgb = styleTable.color.rgb

        self:UpdateTextColor()
    end

    function textWidget:UpdateTextColor()
        if self.colorType == const.ColorType.CLASS_COLOR then
            self.text:SetTextColor(Util:GetUnitClassColor(button.states.unit))
        else
            self.text:SetTextColor(unpack(self.rgb))
        end
    end

    ---@param styleTable WidgetTable
    function textWidget:SetPosition(styleTable)
        P.ClearPoints(self.text)
        P.Point(self.text, styleTable.position.point, button,
            styleTable.position.relativePoint,
            styleTable.position.offsetX, styleTable.position.offsetY)
    end

    -- Forward common methods to text
    function textWidget:SetText(...)
        self.text:SetText(...)
    end

    function textWidget:SetFormattedText(...)
        self.text:SetFormattedText(...)
    end

    function textWidget:SetTextColor(...)
        self.text:SetTextColor(...)
    end

    -- Implement common methods
    textWidget.SetEnabled = W.SetEnabled
    textWidget._SetIsSelected = W.SetIsSelected
    textWidget.SetWidgetFrameLevel = W.SetWidgetFrameLevel

    return textWidget
end
