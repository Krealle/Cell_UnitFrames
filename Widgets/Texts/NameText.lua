---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Util = CUF.Util
local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants
local DB = CUF.DB

--! AI followers, wrong value returned by UnitClassBase
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------
menu:AddWidget(const.WIDGET_KIND.NAME_TEXT, "Name",
    Builder.MenuOptions.TextColor,
    Builder.MenuOptions.TextWidth,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font)


---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateNameTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.nameText

    if not setting or setting == const.OPTION_KIND.TEXT_WIDTH then
        widget.width = DB.GetWidgetTable(const.WIDGET_KIND.NAME_TEXT, unit).width
    end

    U:UnitFrame_UpdateName(button)
end

Handler:RegisterWidget(W.UpdateNameTextWidget, const.WIDGET_KIND.NAME_TEXT)

-------------------------------------------------
-- MARK: Button Update Name
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateName(button)
    local unit = button.states.unit
    if not unit then return end

    button.states.name = UnitName(unit)
    button.states.fullName = F:UnitFullName(unit)
    button.states.class = UnitClassBase(unit)
    button.states.guid = UnitGUID(unit)
    button.states.isPlayer = UnitIsPlayer(unit)
    button.states.class = UnitClassBase(unit) --! update class or it may be nil

    if not button.widgets.nameText.enabled then return end

    button.widgets.nameText:UpdateName()
    button.widgets.nameText:UpdateTextColor()
end

-------------------------------------------------
-- MARK: CreateNameText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateNameText(button)
    ---@class NameTextWidget: TextWidget
    local nameText = button:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    button.widgets.nameText = nameText
    nameText.width = CUF.defaults.fontWidth
    nameText:ClearAllPoints()
    nameText:SetPoint("CENTER", 0, 0)
    nameText:SetFont("Cell Default", 12, "OUTLINE")
    nameText.enabled = false
    nameText.id = const.WIDGET_KIND.NAME_TEXT
    ---@type ColorType
    nameText.colorType = const.ColorType.CLASS_COLOR
    nameText.rgb = { 1, 1, 1 }

    function nameText:UpdateName()
        local name

        if CELL_NICKTAG_ENABLED and Cell.NickTag then
            name = Cell.NickTag:GetNickname(button.states.name, nil, true)
        end
        name = name or F:GetNickname(button.states.name, button.states.fullName)

        Util:UpdateTextWidth(nameText, name, nameText.width, button)
    end

    function nameText:UpdateTextColor()
        if self.colorType == const.ColorType.CLASS_COLOR then
            self:SetTextColor(F:GetClassColor(button.states.class))
        else
            self:SetTextColor(unpack(self.rgb))
        end
    end

    nameText.SetEnabled = W.SetEnabled
    nameText.SetPosition = W.SetPosition
    nameText.SetFontStyle = W.SetFontStyle
    nameText.SetFontColor = W.SetFontColor
    nameText._SetIsSelected = W.SetIsSelected
end