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
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.SHIELD_BAR,
    Builder.MenuOptions.ShieldBarOptions,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string?
---@param subSetting string?
function W.UpdateShieldBarWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.shieldBar
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.SHIELD_BAR, unit) --[[@as ShieldBarWidgetTable]]

    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:UpdateStyle()
    end
    if not setting or setting == const.OPTION_KIND.ANCHOR_POINT then
        widget.anchorToHealthBar = styleTable.point == "healthBar"
        widget:Repoint(styleTable.point)
    end
    if not setting or setting == const.OPTION_KIND.REVERSE_FILL then
        widget.reverseFill = styleTable.reverseFill
    end
    if not setting or setting == const.OPTION_KIND.OVER_SHIELD then
        widget.showOverShield = styleTable.overShield
    end

    if widget.enabled and button:IsVisible() then
        widget.overshieldGlow:Hide()
        widget.overshieldGlowReverse:Hide()
        widget.shield:Hide()
        widget.shieldReverse:Hide()

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
    if not shieldBar.showOverShield or shieldBar.currentPoint ~= "healthBar" then
        shieldBar.overshieldGlow:Hide()
        shieldBar.overshieldGlowReverse:Hide()
    end

    -- Preview
    if shieldBar._isSelected then
        shieldBar:Show()

        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)

        shieldBar:SetValue(0.4, healthPercent)
        return
    end

    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs > 0 then
        shieldBar:Show()

        local shieldPercent = totalAbsorbs / UnitHealthMax(unit)
        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)

        shieldBar:SetValue(shieldPercent, healthPercent)
        return
    end

    shieldBar:Hide()
end

---@param self ShieldBarWidget
local function Enable(self)
    self._owner:AddEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:AddEventListener("UNIT_MAXHEALTH", Update)
    self._owner:AddEventListener("UNIT_HEALTH", Update)

    self.Update(self._owner)

    return true
end

---@param self ShieldBarWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:RemoveEventListener("UNIT_MAXHEALTH", Update)
    self._owner:RemoveEventListener("UNIT_HEALTH", Update)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param bar ShieldBarWidget
---@param percent number
---@param healthPercent number
local function ShieldBar_SetValue_Horizontal(bar, percent, healthPercent)
    percent = math.min(percent, 1)

    local maxWidth = bar.parentHealthBar:GetWidth()
    local barWidth = maxWidth * percent

    if not bar.anchorToHealthBar then
        bar.shieldReverse:Show()
        bar.shieldReverse:SetWidth(barWidth)
        return
    end

    local ratio = 1 - healthPercent

    -- Overshield
    if percent > ratio then
        if bar.reverseFill then
            bar.shieldReverse:Show()
            bar.shield:Hide()

            if bar.showOverShield then
                bar.overshieldGlowReverse:Show()
            end

            bar.shieldReverse:SetWidth(barWidth)
        else
            bar.shieldReverse:Hide()
            if ratio ~= 0 then
                bar.shield:Show()

                barWidth = maxWidth * ratio
                bar.shield:SetWidth(barWidth)
            else
                bar.shield:Hide()
            end

            if bar.showOverShield then
                bar.overshieldGlow:Show()
            end
        end
    else
        bar.shield:Show()
        bar.shieldReverse:Hide()
        bar.overshieldGlow:Hide()
        bar.overshieldGlowReverse:Hide()

        bar.shield:SetWidth(barWidth)
    end
end

---@param bar ShieldBarWidget
---@param percent number
---@param healthPercent number
local function ShieldBar_SetValue_Vertical(bar, percent, healthPercent)
    percent = math.min(percent, 1)

    local maxHeight = bar.parentHealthBar:GetHeight()
    local barHeight = maxHeight * percent

    if not bar.anchorToHealthBar then
        bar.shieldReverse:Show()
        bar.shieldReverse:SetHeight(barHeight)
        return
    end

    local ratio = 1 - healthPercent

    -- Overshield
    if percent > ratio then
        if bar.reverseFill then
            bar.shieldReverse:Show()
            bar.shield:Hide()

            if bar.showOverShield then
                bar.overshieldGlowReverse:Show()
            end

            bar.shieldReverse:SetHeight(barHeight)
        else
            bar.shieldReverse:Hide()
            if ratio ~= 0 then
                bar.shield:Show()

                barHeight = maxHeight * ratio
                bar.shield:SetHeight(barHeight)
            else
                bar.shield:Hide()
            end

            if bar.showOverShield then
                bar.overshieldGlow:Show()
            end
        end
    else
        bar.shield:Show()
        bar.shieldReverse:Hide()
        bar.overshieldGlow:Hide()
        bar.overshieldGlowReverse:Hide()

        bar.shield:SetHeight(barHeight)
    end
end

---@param bar ShieldBarWidget
---@param anchorPoint string
local function Repoint(bar, anchorPoint)
    P.ClearPoints(bar.shield)
    P.ClearPoints(bar.shieldReverse)
    P.ClearPoints(bar.overshieldGlow)
    P.ClearPoints(bar.overshieldGlowReverse)

    bar.shield:Hide()
    bar.shieldReverse:Hide()
    bar.overshieldGlow:Hide()
    bar.overshieldGlowReverse:Hide()

    -- Only the shield bar is used if not anchored to Health Bar
    if not bar.anchorToHealthBar then
        bar.SetValue = ShieldBar_SetValue_Horizontal

        P.Point(bar.shieldReverse, "TOP", bar.parentHealthBar)
        P.Point(bar.shieldReverse, "BOTTOM", bar.parentHealthBar)
        P.Point(bar.shieldReverse, anchorPoint, bar.parentHealthBar)

        return
    end

    if bar._owner.orientation == "horizontal" then
        bar.SetValue = ShieldBar_SetValue_Horizontal

        if bar.parentHealthBar:GetReverseFill() then
            P.Point(bar.shieldReverse, "TOPLEFT", bar.parentHealthBar)
            P.Point(bar.shieldReverse, "BOTTOMLEFT", bar.parentHealthBar)

            P.Point(bar.shield, "TOPRIGHT", bar.parentHealthBarLoss)
            P.Point(bar.shield, "BOTTOMRIGHT", bar.parentHealthBarLoss)

            P.Point(bar.overshieldGlow, "TOPLEFT", bar.parentHealthBar, -bar.overshieldGlow.offset, 0)
            P.Point(bar.overshieldGlow, "BOTTOMLEFT", bar.parentHealthBar, -bar.overshieldGlow.offset, 0)

            P.Point(bar.overshieldGlowReverse, "TOP", bar.shieldReverse, "TOPRIGHT", bar.overshieldGlowReverse.offset, 0)
            P.Point(bar.overshieldGlowReverse, "BOTTOM", bar.shieldReverse, "BOTTOMRIGHT",
                bar.overshieldGlowReverse.offset,
                0)
        else
            P.Point(bar.shieldReverse, "TOPRIGHT", bar.parentHealthBar)
            P.Point(bar.shieldReverse, "BOTTOMRIGHT", bar.parentHealthBar)

            P.Point(bar.shield, "TOPLEFT", bar.parentHealthBarLoss)
            P.Point(bar.shield, "BOTTOMLEFT", bar.parentHealthBarLoss)

            P.Point(bar.overshieldGlow, "TOPRIGHT", bar.parentHealthBar, bar.overshieldGlow.offset, 0)
            P.Point(bar.overshieldGlow, "BOTTOMRIGHT", bar.parentHealthBar, bar.overshieldGlow.offset, 0)

            P.Point(bar.overshieldGlowReverse, "TOP", bar.shieldReverse, "TOPLEFT", bar.overshieldGlowReverse.offset, 0)
            P.Point(bar.overshieldGlowReverse, "BOTTOM", bar.shieldReverse, "BOTTOMLEFT",
                bar.overshieldGlowReverse.offset,
                0)
        end
        F.RotateTexture(bar.overshieldGlow, 0)
        P.Width(bar.overshieldGlow, bar.overshieldGlow.size)

        F.RotateTexture(bar.overshieldGlowReverse, 0)
        P.Width(bar.overshieldGlowReverse, bar.overshieldGlowReverse.size)
    else
        bar.SetValue = ShieldBar_SetValue_Vertical

        if bar.parentHealthBar:GetReverseFill() then
            P.Point(bar.shieldReverse, "BOTTOMLEFT", bar.parentHealthBar)
            P.Point(bar.shieldReverse, "BOTTOMRIGHT", bar.parentHealthBar)

            P.Point(bar.shield, "TOPLEFT", bar.parentHealthBarLoss)
            P.Point(bar.shield, "TOPRIGHT", bar.parentHealthBarLoss)

            P.Point(bar.overshieldGlow, "BOTTOMLEFT", bar.parentHealthBar, 0, -bar.overshieldGlow.offset)
            P.Point(bar.overshieldGlow, "BOTTOMRIGHT", bar.parentHealthBar, 0, -bar.overshieldGlow.offset)

            P.Point(bar.overshieldGlowReverse, "LEFT", bar.shieldReverse, "TOPLEFT", 0,
                bar.overshieldGlowReverse.offset)
            P.Point(bar.overshieldGlowReverse, "RIGHT", bar.shieldReverse, "TOPRIGHT", 0, bar.overshieldGlowReverse
                .offset)
        else
            P.Point(bar.shieldReverse, "TOPLEFT", bar.parentHealthBar)
            P.Point(bar.shieldReverse, "TOPRIGHT", bar.parentHealthBar)

            P.Point(bar.shield, "BOTTOMLEFT", bar.parentHealthBarLoss)
            P.Point(bar.shield, "BOTTOMRIGHT", bar.parentHealthBarLoss)

            P.Point(bar.overshieldGlow, "TOPLEFT", bar.parentHealthBar, 0, bar.overshieldGlow.offset)
            P.Point(bar.overshieldGlow, "TOPRIGHT", bar.parentHealthBar, 0, bar.overshieldGlow.offset)

            P.Point(bar.overshieldGlowReverse, "LEFT", bar.shieldReverse, "BOTTOMLEFT", 0,
                bar.overshieldGlowReverse.offset)
            P.Point(bar.overshieldGlowReverse, "RIGHT", bar.shieldReverse, "BOTTOMRIGHT", 0, bar.overshieldGlowReverse
                .offset)
        end
        F.RotateTexture(bar.overshieldGlow, 90)
        P.Height(bar.overshieldGlow, bar.overshieldGlow.size)

        F.RotateTexture(bar.overshieldGlowReverse, 90)
        P.Height(bar.overshieldGlowReverse, bar.overshieldGlowReverse.size)
    end
end

---@param self ShieldBarWidget
local function UpdateStyle(self)
    local colors = DB.GetColors().shieldBar

    if colors.shieldTexture == CUF.constants.Textures.CELL_SHIELD then
        self.shield.tex:SetTexture(colors.shieldTexture, "REPEAT", "REPEAT")
        self.shield.tex:SetHorizTile(true)
        self.shield.tex:SetVertTile(true)

        self.shieldReverse.tex:SetTexture(colors.shieldTexture, "REPEAT", "REPEAT")
        self.shieldReverse.tex:SetHorizTile(true)
        self.shieldReverse.tex:SetVertTile(true)
    elseif colors.shieldTexture == CUF.constants.Textures.BLIZZARD_SHIELD_FILL then
        self.shield.tex:SetTexture(colors.shieldTexture, "REPEAT", "REPEAT")
        self.shield.tex:SetHorizTile(false)
        self.shield.tex:SetVertTile(false)

        self.shieldReverse.tex:SetTexture(colors.shieldTexture, "REPEAT", "REPEAT")
        self.shieldReverse.tex:SetHorizTile(false)
        self.shieldReverse.tex:SetVertTile(false)
    else
        self.shield.tex:SetTexture(colors.shieldTexture)
        self.shield.tex:SetHorizTile(false)
        self.shield.tex:SetVertTile(false)

        self.shieldReverse.tex:SetTexture(colors.shieldTexture)
        self.shieldReverse.tex:SetHorizTile(false)
        self.shieldReverse.tex:SetVertTile(false)
    end

    if colors.useOverlay then
        self.shieldOverlay:SetTexture(colors.overlayTexture, "REPEAT", "REPEAT")
        self.shieldReverseOverlay:SetTexture(colors.overlayTexture, "REPEAT", "REPEAT")
        self.shieldOverlay:SetHorizTile(true)
        self.shieldOverlay:SetVertTile(true)
        self.shieldReverseOverlay:SetHorizTile(true)
        self.shieldReverseOverlay:SetVertTile(true)

        self.shieldOverlay:SetVertexColor(unpack(colors.overlayColor))
        self.shieldReverseOverlay:SetVertexColor(unpack(colors.overlayColor))

        self.shieldOverlay:Show()
        self.shieldReverseOverlay:Show()
    else
        self.shieldOverlay:Hide()
        self.shieldReverseOverlay:Hide()
    end

    self.overshieldGlow:SetTexture(colors.overshieldTexture)
    self.overshieldGlowReverse:SetTexture(colors.overshieldTexture)

    self.overshieldGlow.offset = colors.overshieldOffset
    self.overshieldGlow.size = colors.overshieldSize
    self.overshieldGlowReverse.offset = colors.overshieldReverseOffset
    self.overshieldGlowReverse.size = colors.overshieldSize

    self.shield.tex:SetVertexColor(unpack(colors.shieldColor))
    self.shieldReverse.tex:SetVertexColor(unpack(colors.shieldColor))

    self.overshieldGlow:SetVertexColor(unpack(colors.overshieldColor))
    self.overshieldGlowReverse:SetVertexColor(unpack(colors.overshieldColor))
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
    shieldBar.parentHealthBarLoss = button.widgets.healthBarLoss
    shieldBar._owner = button

    shieldBar.reverseFill = false
    shieldBar.showOverShield = false
    shieldBar.anchorToHealthBar = false

    shieldBar:Hide()

    local shieldReverse = CreateFrame("Frame", button:GetName() .. "_ShieldBar_ShieldReverse", shieldBar)
    shieldBar.shieldReverse = shieldReverse
    shieldReverse.tex = shieldReverse:CreateTexture(nil, "BORDER", nil, -7)
    shieldReverse.tex:SetAllPoints()

    local shieldReverseOverlay = shieldReverse:CreateTexture(nil, "ARTWORK", nil, -6)
    shieldBar.shieldReverseOverlay = shieldReverseOverlay
    shieldReverseOverlay:SetTexture(const.Textures.BLIZZARD_SHIELD_OVERLAY)
    shieldReverseOverlay:SetAllPoints()

    local shield = CreateFrame("Frame", button:GetName() .. "_ShieldBar_Shield", shieldBar)
    shieldBar.shield = shield
    shield.tex = shield:CreateTexture(nil, "BORDER", nil, -7)
    shield.tex:SetAllPoints()

    local shieldOverlay = shield:CreateTexture(nil, "ARTWORK", nil, -6)
    shieldBar.shieldOverlay = shieldOverlay
    shieldOverlay:SetTexture(const.Textures.BLIZZARD_SHIELD_OVERLAY)
    shieldOverlay:SetAllPoints()

    ---@class OvershieldGlow: Texture
    local overshieldGlow = shieldBar:CreateTexture(nil, "ARTWORK")
    overshieldGlow.size = 4
    overshieldGlow.offset = 0
    overshieldGlow:SetTexture(const.Textures.CELL_OVERSHIELD)
    overshieldGlow:Hide()
    overshieldGlow:SetBlendMode("ADD")
    shieldBar.overshieldGlow = overshieldGlow

    local overshieldGlowReverse = shieldReverse:CreateTexture(nil, "ARTWORK") --[[@as OvershieldGlow]]
    overshieldGlowReverse.size = 4
    overshieldGlowReverse.offset = 0
    overshieldGlowReverse:SetTexture(const.Textures.CELL_OVERSHIELD)
    overshieldGlowReverse:Hide()
    overshieldGlowReverse:SetBlendMode("ADD")
    shieldBar.overshieldGlowReverse = overshieldGlowReverse

    ---@param styleTable ShieldBarWidgetTable
    function shieldBar:UpdatePosition(styleTable)
        local point = styleTable.point
        self.currentPoint = point
        self:Repoint(point)
    end

    ---@param bar ShieldBarWidget
    ---@param val boolean
    shieldBar._SetIsSelected = function(bar, val)
        bar._isSelected = val
        bar.Update(bar._owner)
    end

    shieldBar.SetValue = ShieldBar_SetValue_Horizontal
    shieldBar.SetEnabled = W.SetEnabled
    shieldBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    shieldBar.Repoint = Repoint
    shieldBar.UpdateStyle = UpdateStyle

    shieldBar.Update = Update
    shieldBar.Enable = Enable
    shieldBar.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.SHIELD_BAR, W.CreateShieldBar)
