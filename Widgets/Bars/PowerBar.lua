---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
---@type LibGroupInfo
local LGI = LibStub:GetLibrary("LibGroupInfo")

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

-------------------------------------------------
-- MARK: Layout Update PowerBar
-------------------------------------------------

---@param button CUFUnitButton
---@param size number
function W:SetPowerSize(button, size)
    --print(GetTime(), "SetPowerSize", button:GetName(), button:IsShown(), button:IsVisible(), size)
    button.powerSize = size

    if size == 0 then
        button:HidePowerBar()
    else
        if button:ShouldShowPowerBar() then
            button:ShowPowerBar()
        else
            button:HidePowerBar()
        end
    end
end

-------------------------------------------------
-- MARK: Button Functions
-------------------------------------------------

---@param button CUFUnitButton
local function GetRole(button)
    if button.states.role and button.states.role ~= "NONE" then
        return button.states.role
    end

    local info = LGI:GetCachedInfo(button.states.guid)
    if not info then return end
    return info.role
end

---@class CUFUnitButton
---@field ShouldShowPowerBar function
---@param self CUFUnitButton
local function ShouldShowPowerBar(self)
    if not self:IsVisible() then return end
    if not self.powerSize or self.powerSize == 0 then return end

    if not self.states.guid then
        return true
    end

    local class, role
    if self.states.inVehicle then
        class = "VEHICLE"
    elseif F:IsPlayer(self.states.guid) then
        class = self.states.class
        role = GetRole(self)
    elseif F:IsPet(self.states.guid) then
        class = "PET"
    elseif F:IsNPC(self.states.guid) then
        if UnitInPartyIsAI(self.states.unit) then
            class = self.states.class
            role = GetRole(self)
        else
            class = "NPC"
        end
    elseif F:IsVehicle(self.states.guid) then
        class = "VEHICLE"
    end

    if class and Cell.vars.currentLayoutTable then
        if type(Cell.vars.currentLayoutTable["powerFilters"][class]) == "boolean" then
            return Cell.vars.currentLayoutTable["powerFilters"][class]
        else
            if role then
                return Cell.vars.currentLayoutTable["powerFilters"][class][role]
            else
                return true -- show power if role not found
            end
        end
    end

    return true
end

---@class CUFUnitButton
---@field ShowPowerBar function
---@param self CUFUnitButton
local function ShowPowerBar(self)
    self.widgets.powerBar:Show()
    self.widgets.powerBarLoss:Show()

    U:TogglePowerEvents(self)

    P:ClearPoints(self.widgets.healthBar)
    P:ClearPoints(self.widgets.powerBar)
    if self.orientation == "horizontal" or self.orientation == "vertical_health" then
        P:Point(self.widgets.healthBar, "TOPLEFT", self, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P:Point(self.widgets.healthBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE,
            self.powerSize + CELL_BORDER_SIZE * 2)
        P:Point(self.widgets.powerBar, "TOPLEFT", self.widgets.healthBar, "BOTTOMLEFT", 0, -CELL_BORDER_SIZE)
        P:Point(self.widgets.powerBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    else
        P:Point(self.widgets.healthBar, "TOPLEFT", self, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P:Point(self.widgets.healthBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT",
            -(self.powerSize + CELL_BORDER_SIZE * 2),
            CELL_BORDER_SIZE)
        P:Point(self.widgets.powerBar, "TOPLEFT", self.widgets.healthBar, "TOPRIGHT", CELL_BORDER_SIZE, 0)
        P:Point(self.widgets.powerBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    end

    if self:IsVisible() then
        -- update now
        U:UnitFrame_UpdatePowerMax(self)
        U:UnitFrame_UpdatePower(self)
        U:UnitFrame_UpdatePowerType(self)
    end
end

---@class CUFUnitButton
---@field HidePowerBar function
---@param self CUFUnitButton
local function HidePowerBar(self)
    self.widgets.powerBar:Hide()
    self.widgets.powerBarLoss:Hide()

    U:TogglePowerEvents(self)

    P:ClearPoints(self.widgets.healthBar)
    P:Point(self.widgets.healthBar, "TOPLEFT", self, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P:Point(self.widgets.healthBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
end

-------------------------------------------------
-- MARK: Button Update PowerBar
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerMax(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    button.states.powerMax = UnitPowerMax(unit)
    if button.states.powerMax < 0 then button.states.powerMax = 0 end

    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        button.widgets.powerBar:SetMinMaxSmoothedValue(0, button.states.powerMax)
    else
        button.widgets.powerBar:SetMinMaxValues(0, button.states.powerMax)
    end
end

---@param button CUFUnitButton
function U:UnitFrame_UpdatePower(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    button.states.power = UnitPower(unit)

    button.widgets.powerBar:SetBarValue(button.states.power)
end

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerType(button)
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

    button.ShowPowerBar = ShowPowerBar
    button.HidePowerBar = HidePowerBar
    button.ShouldShowPowerBar = ShouldShowPowerBar
end
