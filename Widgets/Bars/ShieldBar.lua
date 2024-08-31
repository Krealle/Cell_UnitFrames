---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler

local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.SHIELD_BAR,
    Builder.MenuOptions.ColorPicker,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateShieldBarWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.shieldBar
    local styleTable = DB.GetSelectedWidgetTable(const.WIDGET_KIND.SHIELD_BAR, unit) --[[@as ShieldBarWidgetTable]]

    if not setting or setting == const.OPTION_KIND.RGBA then
        widget:SetColor(unpack(styleTable.rgba))
    end

    if widget.enabled and button:IsVisible() then
        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdateShieldBarWidget, const.WIDGET_KIND.SHIELD_BAR)

-------------------------------------------------
-- MARK: UpdateShieldBar
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
    local unit = button.states.displayedUnit
    if not unit then return end

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

    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs > 0 then
        local shieldPercent = totalAbsorbs / UnitHealthMax(unit)
        shieldBar:Show()
        shieldBar:SetValue(shieldPercent)
        return
    end

    shieldBar:Hide()
end

---@param self ShieldBarWidget
local function Enable(self)
    self._owner:AddEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:AddEventListener("UNIT_MAXHEALTH", Update)

    self.Update(self._owner)

    return true
end

---@param self ShieldBarWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:RemoveEventListener("UNIT_MAXHEALTH", Update)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param bar ShieldBarWidget
---@param percent number
local function ShieldBar_SetValue(bar, percent)
    local maxWidth = bar.parentHealthBar:GetWidth()
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
function W:CreateShieldBar(button)
    ---@class ShieldBarWidget: Frame, BaseWidget, BackdropTemplate
    local shieldBar = CreateFrame("Frame", button:GetName() .. "_ShieldBar", button, "BackdropTemplate")
    button.widgets.shieldBar = shieldBar

    shieldBar.id = const.WIDGET_KIND.SHIELD_BAR
    shieldBar.enabled = false
    shieldBar._isSelected = false
    shieldBar.parentHealthBar = button.widgets.healthBar
    shieldBar._owner = button

    shieldBar:Hide()
    shieldBar:SetBackdrop({ edgeFile = Cell.vars.whiteTexture, edgeSize = 0.1 })
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
        self:SetPoint("TOP", self.parentHealthBar, "TOP", 0, 0)
        self:SetPoint("BOTTOM", self.parentHealthBar, "BOTTOM", 0, 0)
        self:SetPoint(pos.point, self.parentHealthBar, pos.relativePoint, pos.offsetX, pos.offsetY)
    end

    ---@param bar ShieldBarWidget
    ---@param val boolean
    shieldBar._SetIsSelected = function(bar, val)
        bar._isSelected = val
        bar.Update(bar._owner)
    end

    shieldBar.SetValue = ShieldBar_SetValue
    shieldBar.SetEnabled = W.SetEnabled
    shieldBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel

    shieldBar.Update = Update
    shieldBar.Enable = Enable
    shieldBar.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.SHIELD_BAR, W.CreateShieldBar)
