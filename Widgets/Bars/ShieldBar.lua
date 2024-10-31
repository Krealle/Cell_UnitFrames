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
        if button.orientation == "horizontal" then
            widget.reversePoint = "RIGHT"
        else
            widget.reversePoint = "TOP"
        end
        widget.currentAnchorPoint = nil

        widget:UpdatePosition(styleTable)
    end
    if not setting or setting == const.OPTION_KIND.REVERSE_FILL then
        widget.reverseFill = styleTable.reverseFill
        widget:Repoint()
    end
    if not setting or setting == const.OPTION_KIND.OVER_SHIELD then
        widget.showOverShield = styleTable.overShield
    end

    if widget.enabled and button:IsVisible() then
        widget.overShieldGlow:Hide()
        widget.overShieldGlowReverse:Hide()

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
        shieldBar:SetValue(0.4, unit)
        return
    end

    local totalAbsorbs = UnitGetTotalAbsorbs(unit)
    if totalAbsorbs > 0 then
        local shieldPercent = totalAbsorbs / UnitHealthMax(unit)
        shieldBar:Show()
        shieldBar:SetValue(shieldPercent, unit)
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
---@param unit UnitToken
local function ShieldBar_SetValue(bar, percent, unit)
    percent = math.min(percent, 1)

    local maxWidth
    if bar.reversePoint == "RIGHT" then
        maxWidth = bar.parentHealthBar:GetWidth()
    else
        maxWidth = bar.parentHealthBar:GetHeight()
    end
    local barWidth = maxWidth * percent

    if bar.currentPoint == "healthBar" then
        local healthPercent = UnitHealth(unit) / UnitHealthMax(unit)
        local ratio = 1 - healthPercent

        if percent > ratio then
            if bar.reverseFill then
                bar:Repoint(bar.reversePoint)
            else
                barWidth = maxWidth * ratio
            end
        elseif bar.reverseFill then
            bar:Repoint()
        end

        if bar.showOverShield and ratio == 0 then
            if bar.reverseFill then
                bar.overShieldGlowReverse:Show()
            else
                bar.overShieldGlow:Show()
            end
        else
            bar.overShieldGlow:Hide()
            bar.overShieldGlowReverse:Hide()
        end
    end

    if bar.reversePoint == "RIGHT" then
        bar:SetWidth(barWidth)
    else
        bar:SetHeight(barWidth)
    end
end

---@param bar ShieldBarWidget
---@param anchorPoint string?
local function Repoint(bar, anchorPoint)
    local point = anchorPoint or bar.currentPoint --[[@as FramePoint]]
    if bar.currentAnchorPoint == point then return end
    bar.currentAnchorPoint = point

    bar:ClearAllPoints()

    if point == "RIGHT" or point == "LEFT" then
        bar:SetPoint("TOP", bar.parentHealthBar, "TOP", 0, 0)
        bar:SetPoint("BOTTOM", bar.parentHealthBar, "BOTTOM", 0, 0)
        bar:SetPoint(point, bar.parentHealthBar, point, 0, 0)
    elseif point == "TOP" or point == "BOTTOM" then
        bar:SetPoint("LEFT", bar.parentHealthBar, "LEFT", 0, 0)
        bar:SetPoint("RIGHT", bar.parentHealthBar, "RIGHT", 0, 0)
        bar:SetPoint(point, bar.parentHealthBar, point, 0, 0)
    else
        if bar._owner.orientation == "horizontal" then
            bar:SetPoint("TOP", bar.parentHealthBarLoss, "TOP", 0, 0)
            bar:SetPoint("BOTTOM", bar.parentHealthBarLoss, "BOTTOM", 0, 0)
            bar:SetPoint("LEFT", bar.parentHealthBarLoss, "LEFT", 0, 0)

            bar.overShieldGlow:ClearAllPoints()
            bar.overShieldGlow:SetPoint("TOPRIGHT")
            bar.overShieldGlow:SetPoint("BOTTOMRIGHT")
            F:RotateTexture(bar.overShieldGlow, 0)
            bar.overShieldGlow:SetWidth(4)

            bar.overShieldGlowReverse:ClearAllPoints()
            bar.overShieldGlowReverse:SetPoint("TOPLEFT")
            bar.overShieldGlowReverse:SetPoint("BOTTOMLEFT")
            F:RotateTexture(bar.overShieldGlowReverse, 0)
            bar.overShieldGlowReverse:SetWidth(4)
        else
            bar:SetPoint("LEFT", bar.parentHealthBarLoss, "LEFT", 0, 0)
            bar:SetPoint("RIGHT", bar.parentHealthBarLoss, "RIGHT", 0, 0)
            bar:SetPoint("BOTTOM", bar.parentHealthBarLoss, "BOTTOM", 0, 0)

            bar.overShieldGlow:ClearAllPoints()
            bar.overShieldGlow:SetPoint("TOPLEFT")
            bar.overShieldGlow:SetPoint("TOPRIGHT")
            F:RotateTexture(bar.overShieldGlow, 90)
            bar.overShieldGlow:SetHeight(4)

            bar.overShieldGlowReverse:ClearAllPoints()
            bar.overShieldGlowReverse:SetPoint("BOTTOMLEFT")
            bar.overShieldGlowReverse:SetPoint("BOTTOMRIGHT")
            F:RotateTexture(bar.overShieldGlowReverse, 90)
            bar.overShieldGlowReverse:SetHeight(4)
        end
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
    shieldBar.reversePoint = "RIGHT"
    shieldBar.currentPoint = "RIGHT"
    shieldBar.currentAnchorPoint = ""
    shieldBar.showOverShield = false

    shieldBar:Hide()
    shieldBar:SetBackdrop({ edgeFile = Cell.vars.whiteTexture, edgeSize = 0.1 })
    shieldBar:SetBackdropBorderColor(0, 0, 0, 1)

    local tex = shieldBar:CreateTexture(nil, "BORDER", nil, -7)
    tex:SetAllPoints()

    local overShieldGlow = shieldBar:CreateTexture(nil, "ARTWORK", nil, -4)
    overShieldGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield")
    overShieldGlow:Hide()
    shieldBar.overShieldGlow = overShieldGlow

    local overShieldGlowReverse = shieldBar:CreateTexture(nil, "ARTWORK", nil, -4)
    overShieldGlowReverse:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield")
    overShieldGlowReverse:Hide()
    shieldBar.overShieldGlowReverse = overShieldGlowReverse

    function shieldBar:UpdateStyle()
        local colors = DB.GetColors().shieldBar

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
        overShieldGlow:SetVertexColor(unpack(colors.overShield))
    end

    ---@param styleTable ShieldBarWidgetTable
    function shieldBar:UpdatePosition(styleTable)
        local point = styleTable.point
        self.currentPoint = point
        self:Repoint()
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
    shieldBar.Repoint = Repoint

    shieldBar.Update = Update
    shieldBar.Enable = Enable
    shieldBar.Disable = Disable
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.SHIELD_BAR, W.CreateShieldBar)
