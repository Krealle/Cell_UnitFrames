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

    if widget.enabled and widget:IsVisible() then
        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdatePowerBarWidget, const.WIDGET_KIND.POWER_BAR)

-------------------------------------------------
-- MARK: Button Functions
-------------------------------------------------

---@param button CUFUnitButton
local function GetRole(button)
    --[[ if button.states.role and button.states.role ~= "NONE" then
        return button.states.role
    end ]]

    local info = LGI and LGI:GetCachedInfo(button.states.guid)
    if not info then
        return UnitGroupRolesAssigned(button.states.unit)
    end
    return info.role
end

---@param self PowerBarWidget
local function PowerFilterCheck(self)
    local owner = self._owner
    local guid = owner.states.guid or UnitGUID(owner.states.unit)
    if not guid then return end

    local class, role
    if owner.states.inVehicle then
        class = "VEHICLE"
    elseif F:IsPlayer(guid) then
        class = UnitClassBase(owner.states.unit)
        role = GetRole(owner)
    elseif F:IsPet(guid) then
        class = "PET"
    elseif F:IsNPC(guid) then
        if UnitInPartyIsAI(owner.states.unit) then
            class = UnitClassBase(owner.states.unit)
            role = GetRole(owner)
        else
            class = "NPC"
        end
    elseif F:IsVehicle(guid) then
        class = "VEHICLE"
    end

    if not Cell.vars.currentLayoutTable then return end

    print("PowerFilterCheck", self._owner.states.unit, class, role)

    if class then
        if type(Cell.vars.currentLayoutTable["powerFilters"][class]) == "boolean" then
            return Cell.vars.currentLayoutTable["powerFilters"][class]
        else
            if role then
                if role == "NONE" then
                    return true
                end
                return Cell.vars.currentLayoutTable["powerFilters"][class][role]
            else
                return
            end
        end
    end

    return true
end

---@param self PowerBarWidget
local function UpdateVisibility(self)
    if self.powerFilter then
        local powerFilterCheck = PowerFilterCheck(self)

        if powerFilterCheck == nil then
            C_Timer.After(0.1, function()
                self:UpdateVisibility()
            end)
            return
        elseif not powerFilterCheck then
            self:Hide()
            self:UpdateEventListeners(false)
            return
        end
    end

    self:Show()
    self:UpdateEventListeners(true)
end

-------------------------------------------------
-- MARK: Power
-------------------------------------------------

---@param button CUFUnitButton
---@param event "UNIT_POWER_FREQUENT"?
---@param unit UnitToken?
---@param powerType string?
local function UpdatePower(button, event, unit, powerType)
    unit = unit or button.states.displayedUnit

    button.widgets.powerBar:SetBarValue(UnitPower(unit))
end

---@param button CUFUnitButton
---@param event "UNIT_MAXPOWER"?
---@param unit UnitToken?
---@param powerType string?
local function UpdatePowerMax(button, event, unit, powerType)
    unit = unit or button.states.displayedUnit
    local powerBar = button.widgets.powerBar

    local powerMax = UnitPowerMax(unit)
    if powerMax < 0 then powerMax = 0 end

    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        powerBar:SetMinMaxSmoothedValue(0, powerMax)
    else
        powerBar:SetMinMaxValues(0, powerMax)
    end

    powerBar.UpdatePower(button)
end

---@param button CUFUnitButton
local function UpdatePowerType(button)
    local powerBar = button.widgets.powerBar
    powerBar.UpdatePowerMax(button)

    local unit = button.states.displayedUnit

    local r, g, b, lossR, lossG, lossB
    local a = Cell.loaded and CellDB["appearance"]["lossAlpha"] or 1

    if not UnitIsConnected(unit) then
        r, g, b = 0.4, 0.4, 0.4
        lossR, lossG, lossB = 0.4, 0.4, 0.4
    else
        r, g, b, lossR, lossG, lossB = F:GetPowerBarColor(unit, button.states.class)
    end

    powerBar:SetStatusBarColor(r, g, b)
    powerBar.bg:SetVertexColor(lossR, lossG, lossB)
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event "UNIT_DISPLAYPOWER"|"PLAYER_SPECIALIZATION_CHANGED"?
---@param unit UnitToken?
local function Update(button, event, unit)
    local powerBar = button.widgets.powerBar
    powerBar.UpdatePowerType(button)
    powerBar:UpdateVisibility()
end

---@param self PowerBarWidget
---@param enable boolean
local function UpdateEventListeners(self, enable)
    if self.active == enable then return end

    self.active = enable

    if enable then
        self._owner:AddEventListener("UNIT_POWER_FREQUENT", self.UpdatePower)
        self._owner:AddEventListener("UNIT_MAXPOWER", self.UpdatePowerMax)
    else
        self._owner:RemoveEventListener("UNIT_POWER_FREQUENT", self.UpdatePower)
        self._owner:RemoveEventListener("UNIT_MAXPOWER", self.UpdatePowerMax)
    end
end

---@param self PowerBarWidget
local function Enable(self)
    self.Update(self._owner)

    self._owner:AddEventListener("UNIT_DISPLAYPOWER", self.Update)
    if F:IsPlayer(UnitGUID(self._owner.states.unit)) then
        self._owner:AddEventListener("PLAYER_SPECIALIZATION_CHANGED", self.Update)
    end

    return true
end

---@param self PowerBarWidget
local function Disable(self)
    self:UpdateEventListeners(false)

    self._owner:RemoveEventListener("UNIT_DISPLAYPOWER", self.Update)
    self._owner:RemoveEventListener("PLAYER_SPECIALIZATION_CHANGED", self.Update)
end

-------------------------------------------------
-- MARK: Options
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdatePowerTexture(button)
    button.widgets.powerBar:SetStatusBarTexture(F:GetBarTexture())
    button.widgets.powerBar.bg:SetTexture(F:GetBarTexture())
end

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
    powerBar.powerFilter = true

    powerBar.active = false

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
    powerBar.UpdateVisibility = UpdateVisibility
    powerBar.UpdateEventListeners = UpdateEventListeners
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.POWER_BAR, W.CreatePowerBar)
