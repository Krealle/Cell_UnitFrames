---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.SHIELD_BAR, "Shield Bar",
    Builder.MenuOptions.ColorPicker,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateShieldBarWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.shieldBar
    local styleTable = DB.GetWidgetTable(const.WIDGET_KIND.SHIELD_BAR, unit) --[[@as ShieldBarWidgetTable]]

    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:SetColor(unpack(styleTable.rgba))
    end

    U:UnitFrame_UpdateShieldBar(button)
end

Handler:RegisterWidget(W.UpdateShieldBarWidget, const.WIDGET_KIND.SHIELD_BAR)

-------------------------------------------------
-- MARK: UpdateShieldBar
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateShieldBar(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    U:UpdateUnitHealthState(button)
    local shieldBar = button.widgets.shieldBar

    if not shieldBar.enabled then
        shieldBar:Hide()
        return
    end

    -- Preview
    if shieldBar._isSelected then
        shieldBar:Show()
        shieldBar:SetValue(0.4)
        return
    end

    if button.states.totalAbsorbs > 0 then
        local shieldPercent = button.states.totalAbsorbs / button.states.healthMax
        shieldBar:Show()
        shieldBar:SetValue(shieldPercent)
        return
    end

    shieldBar:Hide()
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

local function ShieldBar_SetValue(bar, percent)
    local maxWidth = bar:GetParent():GetWidth()
    local barWidth
    if percent >= 1 then
        barWidth = maxWidth
    else
        barWidth = maxWidth * percent
    end
    bar:SetWidth(barWidth)
end


-------------------------------------------------
-- MARK: CreateShieldBar
-------------------------------------------------

---@param button CUFUnitButton
---@param buttonName string
function W:CreateShieldBar(button, buttonName)
    ---@class ShieldBarWidget: Frame, BaseWidget
    local shieldBar = CreateFrame("Frame", buttonName .. "ShieldBar", button, "BackdropTemplate")
    button.widgets.shieldBar = shieldBar

    shieldBar.id = const.WIDGET_KIND.SHIELD_BAR
    shieldBar.enabled = false
    shieldBar._isSelected = false

    shieldBar:Hide()
    shieldBar:SetBackdrop({ edgeFile = Cell.vars.whiteTexture, edgeSize = P:Scale(1) })
    shieldBar:SetBackdropBorderColor(0, 0, 0, 1)

    local tex = shieldBar:CreateTexture(nil, "BORDER", nil, -7)
    tex:SetAllPoints()

    function shieldBar:SetColor(r, g, b, a)
        tex:SetColorTexture(r, g, b, a)
    end

    ---@param styleTable ShieldBarWidgetTable
    function shieldBar:SetPosition(styleTable)
        local pos = styleTable.position
        self:ClearAllPoints()
        self:SetPoint(pos.anchor, button, pos.extraAnchor, pos.offsetX, pos.offsetY)
        self:SetHeight(button:GetHeight())
    end

    function shieldBar:SetWidgetSize(styleTable)
        if styleTable.size.height == 0 then
            self:SetHeight(button:GetHeight())
        else
            self:SetHeight(styleTable.size.height)
        end
    end

    ---@param bar ShieldBarWidget
    ---@param val boolean
    shieldBar._SetIsSelected = function(bar, val)
        bar._isSelected = val
        U:UnitFrame_UpdateShieldBar(button)
    end

    shieldBar.SetValue = ShieldBar_SetValue
    shieldBar.SetEnabled = W.SetEnabled
    shieldBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end
