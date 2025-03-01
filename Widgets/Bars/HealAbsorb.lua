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
        local r, g, b = F.InvertColor(self.parentHealthBar:GetStatusBarColor())
        self.tex:SetVertexColor(r, g, b)
        self.overabsorbGlow:SetVertexColor(r, g, b)
    end

    local barWidth = self.parentHealthBar:GetWidth()
    if healAbsorbPercent > healthPercent then
        self:SetWidth(healthPercent * barWidth)
        self.overabsorbGlow:Show()
    else
        self:SetWidth(healAbsorbPercent * barWidth)
        self.overabsorbGlow:Hide()
    end
    self:Show()
end

---@param self HealAbsorbWidget
---@param healAbsorbPercent number
---@param healthPercent number
local function SetValue_Vertical(self, healAbsorbPercent, healthPercent)
    if self.absorbInvertColor then
        local r, g, b = F.InvertColor(self.parentHealthBar:GetStatusBarColor())
        self.tex:SetVertexColor(r, g, b)
        self.overabsorbGlow:SetVertexColor(r, g, b)
    end

    local barHeight = self.parentHealthBar:GetHeight()
    if healAbsorbPercent > healthPercent then
        self:SetHeight(healthPercent * barHeight)
        self.overabsorbGlow:Show()
    else
        self:SetHeight(healAbsorbPercent * barHeight)
        self.overabsorbGlow:Hide()
    end
    self:Show()
end

---@param self HealAbsorbWidget
---@param orientation string?
local function SetOrientation(self, orientation)
    P.ClearPoints(self)
    P.ClearPoints(self.overabsorbGlow)

    if orientation == "horizontal" then
        if self.parentHealthBar:GetReverseFill() then
            P.Point(self, "TOPLEFT", self.parentHealthBar:GetStatusBarTexture())
            P.Point(self, "BOTTOMLEFT", self.parentHealthBar:GetStatusBarTexture())

            P.Point(self.overabsorbGlow, "TOP", self.parentHealthBar, "TOPRIGHT")
            P.Point(self.overabsorbGlow, "BOTTOM", self.parentHealthBar, "BOTTOMRIGHT")
        else
            P.Point(self, "TOPRIGHT", self.parentHealthBar:GetStatusBarTexture())
            P.Point(self, "BOTTOMRIGHT", self.parentHealthBar:GetStatusBarTexture())

            P.Point(self.overabsorbGlow, "TOP", self.parentHealthBar, "TOPLEFT")
            P.Point(self.overabsorbGlow, "BOTTOM", self.parentHealthBar, "BOTTOMLEFT")
        end
        P.Width(self.overabsorbGlow, self.overabsorbGlow.size)
        F.RotateTexture(self.overabsorbGlow, 0)

        self.SetValue = SetValue_Horizontal
    else
        if self.parentHealthBar:GetReverseFill() then
            P.Point(self, "BOTTOMLEFT", self.parentHealthBar:GetStatusBarTexture())
            P.Point(self, "BOTTOMRIGHT", self.parentHealthBar:GetStatusBarTexture())

            P.Point(self.overabsorbGlow, "LEFT", self.parentHealthBar, "TOPLEFT")
            P.Point(self.overabsorbGlow, "RIGHT", self.parentHealthBar, "TOPRIGHT")
        else
            P.Point(self, "TOPLEFT", self.parentHealthBar:GetStatusBarTexture())
            P.Point(self, "TOPRIGHT", self.parentHealthBar:GetStatusBarTexture())

            P.Point(self.overabsorbGlow, "LEFT", self.parentHealthBar, "BOTTOMLEFT")
            P.Point(self.overabsorbGlow, "RIGHT", self.parentHealthBar, "BOTTOMRIGHT")
        end
        P.Height(self.overabsorbGlow, self.overabsorbGlow.size)
        F.RotateTexture(self.overabsorbGlow, 90)

        self.SetValue = SetValue_Vertical
    end

    self.Update(self._owner)
end

---@param self HealAbsorbWidget
local function UpdateStyle(self)
    local colors = DB.GetColors().healAbsorb

    self.absorbInvertColor = colors.invertColor

    if colors.absorbTexture == CUF.constants.Textures.CELL_SHIELD then
        self.tex:SetTexture(colors.absorbTexture, "REPEAT", "REPEAT")
        self.tex:SetHorizTile(true)
        self.tex:SetVertTile(true)
        --[[ elseif colors.absorbTexture == CUF.constants.Textures.BLIZZARD_ABSORB_FILL then
        -- TODO: This is prolly not correct
        self.tex:SetTexture(colors.absorbTexture)
        self.tex:SetHorizTile(true)
        self.tex:SetVertTile(true) ]]
    elseif colors.absorbTexture == CUF.constants.Textures.BLIZZARD_SHIELD_FILL then
        self.tex:SetTexture(colors.absorbTexture, "REPEAT", "REPEAT")
        self.tex:SetHorizTile(false)
        self.tex:SetVertTile(false)
    else
        self.tex:SetTexture(colors.absorbTexture)
        self.tex:SetHorizTile(false)
        self.tex:SetVertTile(false)
    end

    self.tex:SetVertexColor(unpack(colors.absorbColor))

    self.overabsorbGlow:SetTexture(colors.overabsorbTexture)
    self.overabsorbGlow:SetVertexColor(unpack(colors.overabsorbColor))

    if colors.overabsorbTexture == CUF.constants.Textures.BLIZZARD_OVERABSORB then
        self.overabsorbGlow.size = 16
    else
        self.overabsorbGlow.size = 4
    end
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

    healAbsorb.showOverabsorbGlow = false
    healAbsorb.absorbInvertColor = false

    healAbsorb:Hide()

    local tex = healAbsorb:CreateTexture(nil, "ARTWORK", nil, -7)
    tex:SetAllPoints()
    healAbsorb.tex = tex

    ---@class OverabsorbGlow: Texture
    local overabsorbGlow = healAbsorb:CreateTexture(nil, "ARTWORK", nil, -4)
    overabsorbGlow:SetTexture(CUF.constants.Textures.CELL_OVERABSORB)
    overabsorbGlow:Hide()
    overabsorbGlow:SetBlendMode("ADD")
    healAbsorb.overabsorbGlow = overabsorbGlow
    overabsorbGlow.size = 4

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
    healAbsorb.UpdateStyle = UpdateStyle

    healAbsorb.Update = Update
    healAbsorb.Enable = Enable
    healAbsorb.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.HEAL_ABSORB, W.CreateHealAbsorb)
