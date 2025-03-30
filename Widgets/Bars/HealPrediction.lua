---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler
local P = CUF.PixelPerfect

local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.HEAL_PREDICTION,
    Builder.MenuOptions.HealPredictionOptions,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string?
---@param subSetting string?
function W.UpdateHealPredictionWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.healPrediction
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.HEAL_PREDICTION, unit) --[[@as HealPredictionWidgetTable]]

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
    if not setting or setting == const.OPTION_KIND.OVER_HEAL then
        widget.showOverHeal = styleTable.overHeal
    end

    if widget.enabled and button:IsVisible() then
        widget.overHealGlow:Hide()
        widget.overHealGlowReverse:Hide()
        widget.heal:Hide()
        widget.healReverse:Hide()

        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdateHealPredictionWidget, const.WIDGET_KIND.HEAL_PREDICTION)

-------------------------------------------------
-- MARK: UpdateHealPredict
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local healPrediction = button.widgets.healPrediction
    if not healPrediction.enabled then
        healPrediction:Hide()
        return
    end
    if not healPrediction.showOverHeal or healPrediction.currentPoint ~= "healthBar" then
        healPrediction.overHealGlow:Hide()
        healPrediction.overHealGlowReverse:Hide()
    end

    -- Preview
    if healPrediction._isSelected then
        healPrediction:Show()

        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)

        healPrediction:SetValue(0.4, healthPercent)
        return
    end

    local totalIncomingHeal = UnitGetIncomingHeals(unit) or 0
    if totalIncomingHeal > 0 then
        healPrediction:Show()

        local healPercent = totalIncomingHeal / UnitHealthMax(unit)
        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)

        healPrediction:SetValue(healPercent, healthPercent)
        return
    end

    healPrediction:Hide()
end

---@param self HealPredictionWidget
local function Enable(self)
    self._owner:AddEventListener("UNIT_HEAL_PREDICTION", Update)
    self._owner:AddEventListener("UNIT_MAXHEALTH", Update)
    self._owner:AddEventListener("UNIT_HEALTH", Update)

    self.Update(self._owner)

    return true
end

---@param self HealPredictionWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_HEAL_PREDICTION", Update)
    self._owner:RemoveEventListener("UNIT_MAXHEALTH", Update)
    self._owner:RemoveEventListener("UNIT_HEALTH", Update)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param bar HealPredictionWidget
---@param percent number
---@param healthPercent number
local function HealPredict_SetValue_Horizontal(bar, percent, healthPercent)
    percent = math.min(percent, 1)

    local maxWidth = bar.parentHealthBar:GetWidth()
    local barWidth = maxWidth * percent

    if not bar.anchorToHealthBar then
        bar.healReverse:Show()
        bar.healReverse:SetWidth(barWidth)
        return
    end

    local ratio = 1 - healthPercent

    -- overHeal
    if percent > ratio then
        if bar.reverseFill then
            bar.healReverse:Show()
            bar.heal:Hide()

            if bar.showOverHeal then
                bar.overHealGlowReverse:Show()
            end

            bar.healReverse:SetWidth(barWidth)
        else
            bar.healReverse:Hide()
            if ratio ~= 0 then
                bar.heal:Show()

                barWidth = maxWidth * ratio
                bar.heal:SetWidth(barWidth)
            else
                bar.heal:Hide()
            end

            if bar.showOverHeal then
                bar.overHealGlow:Show()
            end
        end
    else
        bar.heal:Show()
        bar.healReverse:Hide()
        bar.overHealGlow:Hide()
        bar.overHealGlowReverse:Hide()

        bar.heal:SetWidth(barWidth)
    end
end

---@param bar HealPredictionWidget
---@param percent number
---@param healthPercent number
local function HealPredict_SetValue_Vertical(bar, percent, healthPercent)
    percent = math.min(percent, 1)

    local maxHeight = bar.parentHealthBar:GetHeight()
    local barHeight = maxHeight * percent

    if not bar.anchorToHealthBar then
        bar.healReverse:Show()
        bar.healReverse:SetHeight(barHeight)
        return
    end

    local ratio = 1 - healthPercent

    -- overHeal
    if percent > ratio then
        if bar.reverseFill then
            bar.healReverse:Show()
            bar.heal:Hide()

            if bar.showOverHeal then
                bar.overHealGlowReverse:Show()
            end

            bar.healReverse:SetHeight(barHeight)
        else
            bar.healReverse:Hide()
            if ratio ~= 0 then
                bar.heal:Show()

                barHeight = maxHeight * ratio
                bar.heal:SetHeight(barHeight)
            else
                bar.heal:Hide()
            end

            if bar.showOverHeal then
                bar.overHealGlow:Show()
            end
        end
    else
        bar.heal:Show()
        bar.healReverse:Hide()
        bar.overHealGlow:Hide()
        bar.overHealGlowReverse:Hide()

        bar.heal:SetHeight(barHeight)
    end
end

---@param bar HealPredictionWidget
---@param anchorPoint string
local function Repoint(bar, anchorPoint)
    P.ClearPoints(bar.heal)
    P.ClearPoints(bar.healReverse)
    P.ClearPoints(bar.overHealGlow)
    P.ClearPoints(bar.overHealGlowReverse)

    bar.heal:Hide()
    bar.healReverse:Hide()
    bar.overHealGlow:Hide()
    bar.overHealGlowReverse:Hide()

    -- Only the heal predict bar is used if not anchored to Health Bar
    if not bar.anchorToHealthBar then
        bar.SetValue = HealPredict_SetValue_Horizontal

        P.Point(bar.healReverse, "TOP", bar.parentHealthBar)
        P.Point(bar.healReverse, "BOTTOM", bar.parentHealthBar)
        P.Point(bar.healReverse, anchorPoint, bar.parentHealthBar)

        return
    end

    if bar._owner.orientation == "horizontal" then
        bar.SetValue = HealPredict_SetValue_Horizontal

        if bar.parentHealthBar:GetReverseFill() then
            P.Point(bar.healReverse, "TOPLEFT", bar.parentHealthBar)
            P.Point(bar.healReverse, "BOTTOMLEFT", bar.parentHealthBar)

            P.Point(bar.heal, "TOPRIGHT", bar.parentHealthBarLoss)
            P.Point(bar.heal, "BOTTOMRIGHT", bar.parentHealthBarLoss)

            P.Point(bar.overHealGlow, "TOPLEFT", bar.parentHealthBar)
            P.Point(bar.overHealGlow, "BOTTOMLEFT", bar.parentHealthBar)

            P.Point(bar.overHealGlowReverse, "TOP", bar.healReverse, "TOPRIGHT")
            P.Point(bar.overHealGlowReverse, "BOTTOM", bar.healReverse, "BOTTOMRIGHT")
        else
            P.Point(bar.healReverse, "TOPRIGHT", bar.parentHealthBar)
            P.Point(bar.healReverse, "BOTTOMRIGHT", bar.parentHealthBar)

            P.Point(bar.heal, "TOPLEFT", bar.parentHealthBarLoss)
            P.Point(bar.heal, "BOTTOMLEFT", bar.parentHealthBarLoss)

            P.Point(bar.overHealGlow, "TOPRIGHT", bar.parentHealthBar)
            P.Point(bar.overHealGlow, "BOTTOMRIGHT", bar.parentHealthBar)

            P.Point(bar.overHealGlowReverse, "TOP", bar.healReverse, "TOPLEFT")
            P.Point(bar.overHealGlowReverse, "BOTTOM", bar.healReverse, "BOTTOMLEFT")
        end

        F.RotateTexture(bar.overHealGlow, 0)
        P.Width(bar.overHealGlow, 4)

        F.RotateTexture(bar.overHealGlowReverse, 0)
        P.Width(bar.overHealGlowReverse, 4)
    else
        bar.SetValue = HealPredict_SetValue_Vertical

        if bar.parentHealthBar:GetReverseFill() then
            P.Point(bar.healReverse, "BOTTOMLEFT", bar.parentHealthBar)
            P.Point(bar.healReverse, "BOTTOMRIGHT", bar.parentHealthBar)

            P.Point(bar.heal, "TOPLEFT", bar.parentHealthBarLoss)
            P.Point(bar.heal, "TOPRIGHT", bar.parentHealthBarLoss)

            P.Point(bar.overHealGlow, "BOTTOMLEFT", bar.parentHealthBar)
            P.Point(bar.overHealGlow, "BOTTOMRIGHT", bar.parentHealthBar)

            P.Point(bar.overHealGlowReverse, "LEFT", bar.healReverse, "TOPLEFT")
            P.Point(bar.overHealGlowReverse, "RIGHT", bar.healReverse, "TOPRIGHT")
        else
            P.Point(bar.healReverse, "TOPLEFT", bar.parentHealthBar)
            P.Point(bar.healReverse, "TOPRIGHT", bar.parentHealthBar)

            P.Point(bar.heal, "BOTTOMLEFT", bar.parentHealthBarLoss)
            P.Point(bar.heal, "BOTTOMRIGHT", bar.parentHealthBarLoss)

            P.Point(bar.overHealGlow, "TOPLEFT", bar.parentHealthBar)
            P.Point(bar.overHealGlow, "TOPRIGHT", bar.parentHealthBar)

            P.Point(bar.overHealGlowReverse, "LEFT", bar.healReverse, "BOTTOMLEFT")
            P.Point(bar.overHealGlowReverse, "RIGHT", bar.healReverse, "BOTTOMRIGHT")
        end

        F.RotateTexture(bar.overHealGlowReverse, 90)
        P.Height(bar.overHealGlowReverse, 4)

        F.RotateTexture(bar.overHealGlow, 90)
        P.Height(bar.overHealGlow, 4)
    end
end

-------------------------------------------------
-- MARK: CreateHealPrediction
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateHealPrediction(button)
    ---@class HealPredictionWidget: Frame, BaseWidget, BackdropTemplate
    local healPrediction = CreateFrame("Frame", button:GetName() .. "_HealPrediction", button, "BackdropTemplate")
    button.widgets.healPrediction = healPrediction

    healPrediction.id = const.WIDGET_KIND.HEAL_PREDICTION
    healPrediction.enabled = false
    healPrediction._isSelected = false
    healPrediction.parentHealthBar = button.widgets.healthBar
    healPrediction.parentHealthBarLoss = button.widgets.healthBarLoss
    healPrediction._owner = button

    healPrediction.reverseFill = false
    healPrediction.showOverHeal = false
    healPrediction.anchorToHealthBar = false

    healPrediction:Hide()

    local healReverse = CreateFrame("Frame", healPrediction:GetName() .. "_HealPredictionReverse", healPrediction)
    healPrediction.healReverse = healReverse
    healReverse.tex = healReverse:CreateTexture(nil, "BORDER", nil, -7)
    healReverse.tex:SetAllPoints()

    local heal = CreateFrame("Frame", healPrediction:GetName() .. "_HealPrediction", healPrediction)
    healPrediction.heal = heal
    heal.tex = heal:CreateTexture(nil, "BORDER", nil, -7)
    heal.tex:SetAllPoints()

    local overHealGlow = healPrediction:CreateTexture(nil, "ARTWORK", nil, -4)
    overHealGlow:SetTexture(CUF.constants.Textures.CELL_OVERSHIELD)
    overHealGlow:Hide()
    healPrediction.overHealGlow = overHealGlow

    local overHealGlowReverse = healReverse:CreateTexture(nil, "ARTWORK", nil, -4)
    overHealGlowReverse:SetTexture(CUF.constants.Textures.CELL_OVERSHIELD)
    overHealGlowReverse:Hide()
    healPrediction.overHealGlowReverse = overHealGlowReverse

    function healPrediction:UpdateStyle()
        local colors = DB.GetColors().healPrediction

        if colors.texture == CUF.constants.Textures.CELL_SHIELD then
            heal.tex:SetTexture(colors.texture, "REPEAT", "REPEAT")
            heal.tex:SetHorizTile(true)
            heal.tex:SetVertTile(true)

            healReverse.tex:SetTexture(colors.texture, "REPEAT", "REPEAT")
            healReverse.tex:SetHorizTile(true)
            healReverse.tex:SetVertTile(true)
        else
            heal.tex:SetTexture(colors.texture)
            heal.tex:SetHorizTile(false)
            heal.tex:SetVertTile(false)

            healReverse.tex:SetTexture(colors.texture)
            healReverse.tex:SetHorizTile(false)
            healReverse.tex:SetVertTile(false)
        end

        heal.tex:SetVertexColor(unpack(colors.color))
        healReverse.tex:SetVertexColor(unpack(colors.color))
        overHealGlow:SetVertexColor(unpack(colors.overHeal))
        overHealGlowReverse:SetVertexColor(unpack(colors.overHeal))
    end

    ---@param styleTable HealPredictionWidgetTable
    function healPrediction:UpdatePosition(styleTable)
        local point = styleTable.point
        self.currentPoint = point
        self:Repoint(point)
    end

    ---@param bar HealPredictionWidget
    ---@param val boolean
    healPrediction._SetIsSelected = function(bar, val)
        bar._isSelected = val
        bar.Update(bar._owner)
    end

    healPrediction.SetValue = HealPredict_SetValue_Horizontal
    healPrediction.SetEnabled = W.SetEnabled
    healPrediction.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    healPrediction.Repoint = Repoint

    healPrediction.Update = Update
    healPrediction.Enable = Enable
    healPrediction.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.HEAL_PREDICTION, W.CreateHealPrediction)
