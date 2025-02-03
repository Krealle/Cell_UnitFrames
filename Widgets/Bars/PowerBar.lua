---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
---@type LibGroupInfo
local LGI = LibStub:GetLibrary("LibGroupInfo", true)

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local P = CUF.PixelPerfect
local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.POWER_BAR,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.Size,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdatePowerBarWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.powerBar
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.POWER_BAR, unit) --[[@as PowerBarWidgetTable]]

    --[[ if not setting or setting == const.OPTION_KIND.COLOR then
        widget:UpdateColors()
    end ]]
    if not setting or setting == const.OPTION_KIND.SAME_SIZE_AS_HEALTH_BAR then
        widget.sameSizeAsHealthBar = styleTable.sameSizeAsHealthBar
        widget:SetSizeStyle(styleTable.size)
    end
    if not setting or setting == const.OPTION_KIND.SIZE then
        widget:SetSizeStyle(styleTable.size)
    end
    --[[ if not setting or setting == const.OPTION_KIND.HIDE_OUT_OF_COMBAT then
        widget.hideOutOfCombat = styleTable.hideOutOfCombat
        widget:UpdateEventListeners()
    end
    if not setting or setting == const.OPTION_KIND.HIDE_IF_EMPTY then
        widget.hideIfEmpty = styleTable.hideIfEmpty
    end
    if not setting or setting == const.OPTION_KIND.HIDE_IF_FULL then
        widget.hideIfFull = styleTable.hideIfFull
    end ]]

    widget.Update(button)
end

Handler:RegisterWidget(W.UpdatePowerBarWidget, const.WIDGET_KIND.POWER_BAR)

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

    local info = LGI and LGI:GetCachedInfo(button.states.guid)
    if not info then return end
    return info.role
end

---@class CUFUnitButton
---@field ShouldShowPowerBar function
---@param self CUFUnitButton
local function ShouldShowPowerBar(self)
    if not self.widgets.powerBar.enabled then return end

    local guid = self.states.guid or UnitGUID(self.states.unit)
    if not guid then
        C_Timer.After(0.1, function()
            self:EnableWidget(self.widgets.powerBar)
        end)
        return false
    end

    local class, role
    if self.states.inVehicle then
        class = "VEHICLE"
    elseif F:IsPlayer(guid) then
        class = self.states.class
        role = GetRole(self)
    elseif F:IsPet(guid) then
        class = "PET"
    elseif F:IsNPC(guid) then
        if UnitInPartyIsAI(self.states.unit) then
            class = self.states.class
            role = GetRole(self)
        else
            class = "NPC"
        end
    elseif F:IsVehicle(guid) then
        class = "VEHICLE"
    end

    if CUF.DB.CurrentLayoutTable()[self._baseUnit].powerFilter then
        if not Cell.vars.currentLayoutTable then
            C_Timer.After(0.1, function()
                self:EnableWidget(self.widgets.powerBar)
            end)
            return false
        end

        if class and self.states.unit == "player" then
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

    powerBar:Show()

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
    button.widgets.powerBar.bg:SetVertexColor(lossR, lossG, lossB)
end

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerTexture(button)
    if not button:HasWidget(const.WIDGET_KIND.POWER_BAR) then return end
    button.widgets.powerBar:SetStatusBarTexture(F:GetBarTexture())
    button.widgets.powerBar.bg:SetTexture(F:GetBarTexture())
end

---@param button CUFUnitButton
local function Update(button)
    UpdatePowerType(button)
end

---@param self PowerBarWidget
local function Enable(self)
    if not ShouldShowPowerBar(self._owner) then
        self._owner:DisableWidget(self)
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
-- MARK: Options
-------------------------------------------------

---@param self PowerBarWidget
---@param sizeSize SizeOpt
local function SetSizeStyle(self, sizeSize)
    -- account for border such that we can properly make 1 pixel power bar
    -- TODO: this should be prolly be changed in the future as this problem extends
    -- across all widgets
    local height = (CELL_BORDER_SIZE * 2) + sizeSize.height

    if self.sameSizeAsHealthBar then
        self:SetSize(self._owner:GetWidth(), height)
    else
        local width = (CELL_BORDER_SIZE * 2) + sizeSize.width
        self:SetSize(width, height)
    end
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
    powerBar.id = const.WIDGET_KIND.POWER_BAR
    powerBar.sameSizeAsHealthBar = true
    powerBar.anchorToParent = true

    P.Point(powerBar, "TOPLEFT", button.widgets.healthBar, "BOTTOMLEFT", 0, -1)
    P.Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

    powerBar.border = CreateFrame("Frame", nil, powerBar, "BackdropTemplate")
    powerBar.border:SetAllPoints()
    powerBar.border:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = P.Scale(CELL_BORDER_SIZE),
    })
    powerBar.border:SetBackdropBorderColor(0, 0, 0, 1)

    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    powerBar:SetFrameLevel(button:GetFrameLevel() + 2)
    powerBar.SetBarValue = powerBar.SetValue

    Mixin(powerBar, SmoothStatusBarMixin)

    powerBar.bg = powerBar:CreateTexture(nil, "BACKGROUND")
    powerBar.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    powerBar.bg:SetAllPoints()

    local gapTexture = powerBar:CreateTexture(nil, "BORDER")
    powerBar.gapTexture = gapTexture
    gapTexture:SetColorTexture(unpack(CELL_BORDER_COLOR))

    button.ShowPowerBar = ShowPowerBar
    button.HidePowerBar = HidePowerBar
    button.ShouldShowPowerBar = ShouldShowPowerBar

    powerBar.Update = Update
    powerBar.Enable = Enable
    powerBar.Disable = Disable

    powerBar.SetSizeStyle = SetSizeStyle

    powerBar.SetEnabled = W.SetEnabled
    powerBar.SetPosition = W.SetDetachedRelativePosition
    powerBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    powerBar._SetIsSelected = W.SetIsSelected

    powerBar.UpdatePower = UpdatePower
    powerBar.UpdatePowerMax = UpdatePowerMax
    powerBar.UpdatePowerType = UpdatePowerType
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.POWER_BAR, W.CreatePowerBar)
