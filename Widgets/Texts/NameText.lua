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
menu:AddWidget(const.WIDGET_KIND.NAME_TEXT,
    Builder.MenuOptions.TextColor,
    Builder.MenuOptions.TextWidth,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)


---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateNameTextWidget(button, unit, setting, subSetting)
    local widget = button.widgets.nameText

    if not setting or setting == const.OPTION_KIND.WIDTH then
        widget.width = DB.GetWidgetTable(const.WIDGET_KIND.NAME_TEXT, unit).width
    end

    widget.Update(button)
end

Handler:RegisterWidget(W.UpdateNameTextWidget, const.WIDGET_KIND.NAME_TEXT)

-------------------------------------------------
-- MARK: Button Update Name
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
    local unit = button.states.unit
    if not unit then return end

    button.states.name = UnitName(unit)
    button.states.fullName = F:UnitFullName(unit)
    button.states.guid = UnitGUID(unit)
    button.states.isPlayer = UnitIsPlayer(unit)
    button.states.class = UnitClassBase(unit) --! update class or it may be nil

    if not button.widgets.nameText.enabled then return end

    button.widgets.nameText:UpdateName()
    button.widgets.nameText:UpdateTextColor()
end

---@param self NameTextWidget
local function Enable(self)
    self._owner:AddEventListener("UNIT_NAME_UPDATE", Update)
    self:Show()

    return true
end

---@param self NameTextWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_NAME_UPDATE", Update)
end

-------------------------------------------------
-- MARK: CreateNameText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateNameText(button)
    ---@class NameTextWidget: TextWidget
    local nameText = W.CreateBaseTextWidget(button, const.WIDGET_KIND.NAME_TEXT)
    button.widgets.nameText = nameText

    nameText.width = CUF.Defaults.Options.fontWidth

    function nameText:UpdateName()
        local name

        if CELL_NICKTAG_ENABLED and Cell.NickTag then
            name = Cell.NickTag:GetNickname(button.states.name, nil, true)
        end
        name = name or F:GetNickname(button.states.name, button.states.fullName)

        Util.UpdateTextWidth(nameText.text, name, nameText.width, button)
    end

    nameText.Update = Update
    nameText.Enable = Enable
    nameText.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.NAME_TEXT, W.CreateNameText)
