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
        widget.overShieldGlow:Hide()
        widget.overShieldGlowReverse:Hide()
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
        shieldBar.overShieldGlow:Hide()
        shieldBar.overShieldGlowReverse:Hide()
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
                bar.overShieldGlowReverse:Show()
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
                bar.overShieldGlow:Show()
            end
        end
    else
        bar.shield:Show()
        bar.shieldReverse:Hide()
        bar.overShieldGlow:Hide()
        bar.overShieldGlowReverse:Hide()

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
                bar.overShieldGlowReverse:Show()
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
                bar.overShieldGlow:Show()
            end
        end
    else
        bar.shield:Show()
        bar.shieldReverse:Hide()
        bar.overShieldGlow:Hide()
        bar.overShieldGlowReverse:Hide()

        bar.shield:SetHeight(barHeight)
    end
end

---@param bar ShieldBarWidget
---@param anchorPoint string
local function Repoint(bar, anchorPoint)
    P.ClearPoints(bar.shield)
    P.ClearPoints(bar.shieldReverse)
    P.ClearPoints(bar.overShieldGlow)
    P.ClearPoints(bar.overShieldGlowReverse)

    bar.shield:Hide()
    bar.shieldReverse:Hide()
    bar.overShieldGlow:Hide()
    bar.overShieldGlowReverse:Hide()

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

        P.Point(bar.shieldReverse, "TOPRIGHT", bar.parentHealthBar)
        P.Point(bar.shieldReverse, "BOTTOMRIGHT", bar.parentHealthBar)

        P.Point(bar.shield, "TOPLEFT", bar.parentHealthBarLoss)
        P.Point(bar.shield, "BOTTOMLEFT", bar.parentHealthBarLoss)

        P.Point(bar.overShieldGlow, "TOPRIGHT", bar.parentHealthBar)
        P.Point(bar.overShieldGlow, "BOTTOMRIGHT", bar.parentHealthBar)
        F:RotateTexture(bar.overShieldGlow, 0)
        P.Width(bar.overShieldGlow, 4)

        P.Point(bar.overShieldGlowReverse, "TOP", bar.shieldReverse, "TOPLEFT")
        P.Point(bar.overShieldGlowReverse, "BOTTOM", bar.shieldReverse, "BOTTOMLEFT")
        F:RotateTexture(bar.overShieldGlowReverse, 0)
        P.Width(bar.overShieldGlowReverse, 4)
    else
        bar.SetValue = ShieldBar_SetValue_Vertical

        P.Point(bar.shieldReverse, "TOPLEFT", bar.parentHealthBar)
        P.Point(bar.shieldReverse, "TOPRIGHT", bar.parentHealthBar)

        P.Point(bar.shield, "BOTTOMLEFT", bar.parentHealthBarLoss)
        P.Point(bar.shield, "BOTTOMRIGHT", bar.parentHealthBarLoss)

        P.Point(bar.overShieldGlow, "TOPLEFT", bar.parentHealthBar)
        P.Point(bar.overShieldGlow, "TOPRIGHT", bar.parentHealthBar)
        F:RotateTexture(bar.overShieldGlow, 90)
        P.Height(bar.overShieldGlow, 4)

        P.Point(bar.overShieldGlowReverse, "LEFT", bar.shieldReverse, "BOTTOMLEFT")
        P.Point(bar.overShieldGlowReverse, "RIGHT", bar.shieldReverse, "BOTTOMRIGHT")
        F:RotateTexture(bar.overShieldGlowReverse, 90)
        P.Height(bar.overShieldGlowReverse, 4)
    end
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

    local shield = CreateFrame("Frame", button:GetName() .. "_ShieldBar_Shield", shieldBar)
    shieldBar.shield = shield
    shield.tex = shield:CreateTexture(nil, "BORDER", nil, -7)
    shield.tex:SetAllPoints()

    local overShieldGlow = shieldBar:CreateTexture(nil, "ARTWORK", nil, -4)
    overShieldGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield")
    overShieldGlow:Hide()
    shieldBar.overShieldGlow = overShieldGlow

    local overShieldGlowReverse = shieldReverse:CreateTexture(nil, "ARTWORK", nil, -4)
    overShieldGlowReverse:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield")
    overShieldGlowReverse:Hide()
    shieldBar.overShieldGlowReverse = overShieldGlowReverse

    function shieldBar:UpdateStyle()
        local colors = DB.GetColors().shieldBar

        if colors.texture == "Interface\\AddOns\\Cell\\Media\\shield" then
            shield.tex:SetTexture(colors.texture, "REPEAT", "REPEAT")
            shield.tex:SetHorizTile(true)
            shield.tex:SetVertTile(true)

            shieldReverse.tex:SetTexture(colors.texture, "REPEAT", "REPEAT")
            shieldReverse.tex:SetHorizTile(true)
            shieldReverse.tex:SetVertTile(true)
        else
            shield.tex:SetTexture(colors.texture)
            shield.tex:SetHorizTile(false)
            shield.tex:SetVertTile(false)

            shieldReverse.tex:SetTexture(colors.texture)
            shieldReverse.tex:SetHorizTile(false)
            shieldReverse.tex:SetVertTile(false)
        end

        shield.tex:SetVertexColor(unpack(colors.color))
        shieldReverse.tex:SetVertexColor(unpack(colors.color))
        overShieldGlow:SetVertexColor(unpack(colors.overShield))
        overShieldGlowReverse:SetVertexColor(unpack(colors.overShield))
    end

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

    shieldBar.Update = Update
    shieldBar.Enable = Enable
    shieldBar.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.SHIELD_BAR, W.CreateShieldBar)
