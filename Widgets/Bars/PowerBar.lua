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

    ---@diagnostic disable-next-line: param-type-mismatch
    button.widgets.powerBar:Enable()
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

    if CUF.DB.CurrentLayoutTable()[self._baseUnit].powerFilter then
        if class and Cell.vars.currentLayoutTable and self.states.unit == "player" then
            if type(Cell.vars.currentLayoutTable["powerFilters"][class]) == "boolean" then
                return Cell.vars.currentLayoutTable["powerFilters"][class]
            else
                if role then
                    return Cell.vars.currentLayoutTable["powerFilters"][class][role]
                else
                    C_Timer.After(0.1, function()
                        self:EnableWidget(self.widgets.powerBar)
                    end)
                    return false
                end
            end
        end
    end

    return true
end

---@class CUFUnitButton
---@field ShowPowerBar function
---@param self CUFUnitButton
local function ShowPowerBar(self)
    local powerBar = self.widgets.powerBar
    local healthBar = self.widgets.healthBar

    powerBar:Show()
    self.widgets.powerBarLoss:Show()

    P:ClearPoints(healthBar)
    P:ClearPoints(powerBar)
    if self.orientation == "horizontal" or self.orientation == "vertical_health" then
        P:Point(healthBar, "TOPLEFT", self, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P:Point(healthBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE,
            self.powerSize + CELL_BORDER_SIZE * 2)
        P:Point(powerBar, "TOPLEFT", healthBar, "BOTTOMLEFT", 0, -CELL_BORDER_SIZE)
        P:Point(powerBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    else
        P:Point(healthBar, "TOPLEFT", self, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P:Point(healthBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT",
            -(self.powerSize + CELL_BORDER_SIZE * 2),
            CELL_BORDER_SIZE)
        P:Point(powerBar, "TOPLEFT", healthBar, "TOPRIGHT", CELL_BORDER_SIZE, 0)
        P:Point(powerBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    end

    if self:IsVisible() then
        -- update now
        powerBar.UpdatePowerType(self)
    end
end

---@class CUFUnitButton
---@field HidePowerBar function
---@param self CUFUnitButton
local function HidePowerBar(self)
    self.widgets.powerBar:Hide()
    self.widgets.powerBarLoss:Hide()

    P:ClearPoints(self.widgets.healthBar)
    P:Point(self.widgets.healthBar, "TOPLEFT", self, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P:Point(self.widgets.healthBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
end

-------------------------------------------------
-- MARK: Button Update PowerBar
-------------------------------------------------

---@param button CUFUnitButton
local function UpdatePower(button)
    local unit = button.states.displayedUnit

    button.states.power = UnitPower(unit)

    button.widgets.powerBar:SetBarValue(button.states.power)
end

-- Calls UpdatePower
---@param button CUFUnitButton
local function UpdatePowerMax(button)
    local unit = button.states.displayedUnit

    button.states.powerMax = UnitPowerMax(unit)
    if button.states.powerMax < 0 then button.states.powerMax = 0 end

    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        button.widgets.powerBar:SetMinMaxSmoothedValue(0, button.states.powerMax)
    else
        button.widgets.powerBar:SetMinMaxValues(0, button.states.powerMax)
    end

    UpdatePower(button)
end

-- Calls UpdatePowerMax
---@param button CUFUnitButton
local function UpdatePowerType(button)
    UpdatePowerMax(button)

    local unit = button.states.displayedUnit

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

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerTexture(button)
    button.widgets.powerBar:SetStatusBarTexture(F:GetBarTexture())
    button.widgets.powerBarLoss:SetTexture(F:GetBarTexture())
end

---@param button CUFUnitButton
local function Update(button)
    UpdatePowerType(button)
end

---@param self PowerBarWidget
local function Enable(self)
    if not ShouldShowPowerBar(self._owner) then
        if self:IsVisible() then
            self._owner:DisableWidget(self)
        end
        return false
    end

    self._owner:AddEventListener("UNIT_DISPLAYPOWER", UpdatePowerType)
    self._owner:AddEventListener("UNIT_POWER_FREQUENT", UpdatePower)
    self._owner:AddEventListener("UNIT_MAXPOWER", UpdatePowerMax)

    self._owner:ShowPowerBar()

    return true
end

---@param self PowerBarWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_DISPLAYPOWER", UpdatePowerType)
    self._owner:RemoveEventListener("UNIT_POWER_FREQUENT", UpdatePower)
    self._owner:RemoveEventListener("UNIT_MAXPOWER", UpdatePowerMax)

    self._owner:HidePowerBar()
end

-------------------------------------------------
-- MARK: CreatePowerBar
-------------------------------------------------

---@param button CUFUnitButton
function W:CreatePowerBar(button)
    ---@class PowerBarWidget: SmoothStatusBar
    local powerBar = CreateFrame("StatusBar", button:GetName() .. "_PowerBar", button)
    button.widgets.powerBar = powerBar
    powerBar._owner = button
    powerBar.enabled = true

    P:Point(powerBar, "TOPLEFT", button.widgets.healthBar, "BOTTOMLEFT", 0, -1)
    P:Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    powerBar:SetFrameLevel(button:GetFrameLevel() + 2)
    powerBar.SetBarValue = powerBar.SetValue

    Mixin(powerBar, SmoothStatusBarMixin)

    local powerBarLoss = powerBar:CreateTexture(button:GetName() .. "_PowerBarLoss", "ARTWORK", nil, -7)
    button.widgets.powerBarLoss = powerBarLoss
    powerBarLoss:SetPoint("TOPLEFT", powerBar:GetStatusBarTexture(), "TOPRIGHT")
    powerBarLoss:SetPoint("BOTTOMRIGHT")
    powerBarLoss:SetTexture(Cell.vars.texture)

    button.ShowPowerBar = ShowPowerBar
    button.HidePowerBar = HidePowerBar
    button.ShouldShowPowerBar = ShouldShowPowerBar

    powerBar.Update = Update
    powerBar.Enable = Enable
    powerBar.Disable = Disable

    powerBar.UpdatePower = UpdatePower
    powerBar.UpdatePowerMax = UpdatePowerMax
    powerBar.UpdatePowerType = UpdatePowerType
end
