---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler
local P = CUF.PixelPerfect

local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealth = UnitHealth

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.HEAL_ABSORB,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string?
---@param subSetting string?
function W.UpdateHealAbsorbWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.healAbsorb
    --local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.HEAL_ABSORB, unit) --[[@as HealAbsorbWidgetTable]]

    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:UpdateStyle()
    end

    if widget.enabled and button:IsVisible() then
        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdateHealAbsorbWidget, const.WIDGET_KIND.HEAL_ABSORB)

-------------------------------------------------
-- MARK: UpdateShieldBar
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local healAbsorb = button.widgets.healAbsorb
    if not healAbsorb.enabled then
        healAbsorb:Hide()
        return
    end

    -- Preview
    if healAbsorb._isSelected then
        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)
        healAbsorb:Show()
        healAbsorb:SetValue(0.4, healthPercent)
        return
    end

    local totalHealAbsorb = UnitGetTotalHealAbsorbs(unit)
    if totalHealAbsorb > 0 then
        local healAbsorbPercent = totalHealAbsorb / UnitHealthMax(unit)
        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)
        healAbsorb:Show()
        healAbsorb:SetValue(healAbsorbPercent, healthPercent)
        return
    end

    healAbsorb:Hide()
end

---@param self HealAbsorbWidget
local function Enable(self)
    self._owner:AddEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:AddEventListener("UNIT_MAXHEALTH", Update)
    self._owner:AddEventListener("UNIT_HEALTH", Update)

    self.Update(self._owner)
    self:SetOrientation(self._owner.orientation)

    return true
end

---@param self HealAbsorbWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:RemoveEventListener("UNIT_MAXHEALTH", Update)
    self._owner:RemoveEventListener("UNIT_HEALTH", Update)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param self HealAbsorbWidget
---@param healAbsorbPercent number
---@param healthPercent number
local function SetValue_Horizontal(self, healAbsorbPercent, healthPercent)
    if self.absorbInvertColor then
        local r, g, b = F:InvertColor(self.parentHealthBar:GetStatusBarColor())
        self.tex:SetVertexColor(r, g, b)
        self.overAbsorbGlow:SetVertexColor(r, g, b)
    end

    local barWidth = self.parentHealthBar:GetWidth()
    if healAbsorbPercent > healthPercent then
        self:SetWidth(healthPercent * barWidth)
        self.overAbsorbGlow:Show()
    else
        self:SetWidth(healAbsorbPercent * barWidth)
        self.overAbsorbGlow:Hide()
    end
    self:Show()
end

---@param self HealAbsorbWidget
---@param healAbsorbPercent number
---@param healthPercent number
local function SetValue_Vertical(self, healAbsorbPercent, healthPercent)
    if self.absorbInvertColor then
        local r, g, b = F:InvertColor(self.parentHealthBar:GetStatusBarColor())
        self.tex:SetVertexColor(r, g, b)
        self.overAbsorbGlow:SetVertexColor(r, g, b)
    end

    local barHeight = self.parentHealthBar:GetHeight()
    if healAbsorbPercent > healthPercent then
        self:SetHeight(healthPercent * barHeight)
        self.overAbsorbGlow:Show()
    else
        self:SetHeight(healAbsorbPercent * barHeight)
        self.overAbsorbGlow:Hide()
    end
    self:Show()
end

---@param self HealAbsorbWidget
---@param orientation string?
local function SetOrientation(self, orientation)
    P.ClearPoints(self)
    P.ClearPoints(self.overAbsorbGlow)

    if orientation == "horizontal" then
        P.Point(self, "TOPRIGHT", self.parentHealthBar:GetStatusBarTexture())
        P.Point(self, "BOTTOMRIGHT", self.parentHealthBar:GetStatusBarTexture())

        P.Point(self.overAbsorbGlow, "TOPLEFT", self.parentHealthBar)
        P.Point(self.overAbsorbGlow, "BOTTOMLEFT", self.parentHealthBar)
        P.Width(self.overAbsorbGlow, 4)
        F:RotateTexture(self.overAbsorbGlow, 0)

        self.SetValue = SetValue_Horizontal
    else
        P.Point(self, "TOPLEFT", self.parentHealthBar:GetStatusBarTexture())
        P.Point(self, "TOPRIGHT", self.parentHealthBar:GetStatusBarTexture())

        P.Point(self.overAbsorbGlow, "BOTTOMLEFT", self.parentHealthBar)
        P.Point(self.overAbsorbGlow, "BOTTOMRIGHT", self.parentHealthBar)
        P.Height(self.overAbsorbGlow, 4)
        F:RotateTexture(self.overAbsorbGlow, 90)

        self.SetValue = SetValue_Vertical
    end

    self.Update(self._owner)
end

-------------------------------------------------
-- MARK: CreateHealAbsorb
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateHealAbsorb(button)
    ---@class HealAbsorbWidget: Frame, BaseWidget, BackdropTemplate
    local healAbsorb = CreateFrame("Frame", button:GetName() .. "_HealAbsorb", button, "BackdropTemplate")
    button.widgets.healAbsorb = healAbsorb

    healAbsorb.id = const.WIDGET_KIND.HEAL_ABSORB
    healAbsorb.enabled = false
    healAbsorb._isSelected = false
    healAbsorb.parentHealthBar = button.widgets.healthBar
    healAbsorb._owner = button

    healAbsorb.showOverAbsorbGlow = false
    healAbsorb.absorbInvertColor = false

    healAbsorb:Hide()

    local tex = healAbsorb:CreateTexture(nil, "ARTWORK", nil, -7)
    tex:SetAllPoints()
    healAbsorb.tex = tex

    local overAbsorbGlow = healAbsorb:CreateTexture(nil, "ARTWORK", nil, -4)
    overAbsorbGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overabsorb")
    overAbsorbGlow:Hide()
    healAbsorb.overAbsorbGlow = overAbsorbGlow

    function healAbsorb:UpdateStyle()
        local colors = DB.GetColors().healAbsorb

        if colors.texture == "Interface\\AddOns\\Cell\\Media\\shield" then
            tex:SetTexture(colors.texture, "REPEAT", "REPEAT")
            tex:SetHorizTile(true)
            tex:SetVertTile(true)
        else
            tex:SetTexture(colors.texture)
            tex:SetHorizTile(false)
            tex:SetVertTile(false)
        end

        tex:SetVertexColor(unpack(colors.color))
        overAbsorbGlow:SetVertexColor(unpack(colors.overAbsorb))

        healAbsorb.absorbInvertColor = colors.invertColor
    end

    ---@param bar HealAbsorbWidget
    ---@param val boolean
    healAbsorb._SetIsSelected = function(bar, val)
        bar._isSelected = val
        bar.Update(bar._owner)
    end

    healAbsorb.SetValue = SetValue_Horizontal
    healAbsorb.SetEnabled = W.SetEnabled
    healAbsorb.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    healAbsorb.SetOrientation = SetOrientation

    healAbsorb.Update = Update
    healAbsorb.Enable = Enable
    healAbsorb.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.HEAL_ABSORB, W.CreateHealAbsorb)
