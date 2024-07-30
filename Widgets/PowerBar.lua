---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.Util
local Util = CUF.Util
---@class CUF.widgets.Handler
local Handler = CUF.widgetsHandler

-------------------------------------------------
-- MARK: Button Update PowerBar
-------------------------------------------------

--[[ function function W:UnitFrame_UpdatePowerText(button)
    if enabledIndicators["powerText"] and button.states.powerMax and button.states.power then
        if indicatorBooleans["powerText"] then
            if button.states.power == button.states.powerMax or button.states.power == 0 then
                button.indicators.powerText:Hide()
            else
                button.indicators.powerText:SetValue(button.states.power, button.states.powerMax)
                button.indicators.powerText:Show()
            end
        else
            button.indicators.powerText:SetValue(button.states.power, button.states.powerMax)
            button.indicators.powerText:Show()
        end
    else
        button.indicators.powerText:Hide()
    end
end

function W:UnitFrame_UpdatePowerTextColor(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    if enabledIndicators["powerText"] then
        if indicatorColors["powerText"][1] == "power_color" then
            button.indicators.powerText:SetColor(F:GetPowerColor(unit))
        elseif indicatorColors["powerText"][1] == "class_color" then
            button.indicators.powerText:SetColor(F:GetUnitClassColor(unit))
        else
            button.indicators.powerText:SetColor(unpack(indicatorColors["powerText"][2]))
        end
    end
end ]]

---@param button CUFUnitButton
function W:UnitFrame_UpdatePowerMax(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    button.states.powerMax = UnitPowerMax(unit)
    if button.states.powerMax < 0 then button.states.powerMax = 0 end

    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        button.widgets.powerBar:SetMinMaxSmoothedValue(0, button.states.powerMax)
    else
        button.widgets.powerBar:SetMinMaxValues(0, button.states.powerMax)
    end

    --[[ function W:UnitFrame_UpdatePowerText(button) ]]
end

---@param button CUFUnitButton
function W:UnitFrame_UpdatePower(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    button.states.power = UnitPower(unit)

    button.widgets.powerBar:SetBarValue(button.states.power)

    --[[ function W:UnitFrame_UpdatePowerText(button) ]]
end

---@param button CUFUnitButton
function W:UnitFrame_UpdatePowerType(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local r, g, b, lossR, lossG, lossB
    local a = Cell.loaded and CellDB["appearance"]["lossAlpha"] or 1

    if not UnitIsConnected(unit) then
        r, g, b = 0.4, 0.4, 0.4
        lossR, lossG, lossB = 0.4, 0.4, 0.4
    else
        r, g, b, lossR, lossG, lossB, button.states.powerType = F:GetPowerBarColor(unit, button.states.class)
    end

    button.widgets.powerBar:SetStatusBarColor(r, g, b)
    button.widgets.powerBarLoss:SetVertexColor(lossR, lossG, lossB)

    --[[ W:UnitFrame_UpdatePowerTextColor(button) ]]
end

-------------------------------------------------
-- MARK: CreatePowerBar
-------------------------------------------------

---@param button CUFUnitButton
---@param buttonName string
function W:CreatePowerBar(button, buttonName)
    ---@class PowerBarWidget: SmoothStatusBar
    local powerBar = CreateFrame("StatusBar", buttonName .. "PowerBar", button)
    button.widgets.powerBar = powerBar

    P:Point(powerBar, "TOPLEFT", button.widgets.healthBar, "BOTTOMLEFT", 0, -1)
    P:Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    powerBar:SetFrameLevel(button:GetFrameLevel() + 2)
    powerBar.SetBarValue = powerBar.SetValue

    Mixin(powerBar, SmoothStatusBarMixin)

    local powerBarLoss = powerBar:CreateTexture(buttonName .. "PowerBarLoss", "ARTWORK", nil, -7)
    button.widgets.powerBarLoss = powerBarLoss
    powerBarLoss:SetPoint("TOPLEFT", powerBar:GetStatusBarTexture(), "TOPRIGHT")
    powerBarLoss:SetPoint("BOTTOMRIGHT")
    powerBarLoss:SetTexture(Cell.vars.texture)
end
