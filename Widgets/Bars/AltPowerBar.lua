---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
local W = CUF.widgets

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler
local P = CUF.PixelPerfect

local ALT_MANA_POWERS = {
    DRUID = {
        [Enum.PowerType.Energy] = Enum.PowerType.Mana,
        [Enum.PowerType.LunarPower] = Enum.PowerType.Mana,
        [Enum.PowerType.Rage] = Enum.PowerType.Mana
    },
    SHAMAN = { [Enum.PowerType.Maelstrom] = Enum.PowerType.Mana },
    PRIEST = { [Enum.PowerType.Insanity] = Enum.PowerType.Mana }
}

local POWER_NAME = {
    [Enum.PowerType.Chi] = "CHI",
    [Enum.PowerType.HolyPower] = "HOLY_POWER",
    [Enum.PowerType.SoulShards] = "SOUL_SHARDS",
    [Enum.PowerType.ComboPoints] = "COMBO_POINTS",
    [Enum.PowerType.ArcaneCharges] = "ARCANE_CHARGES",
    [Enum.PowerType.Essence] = "ESSENCE",
    [Enum.PowerType.Runes] = "RUNES",
    [Enum.PowerType.Maelstrom] = "MAELSTROM",
    [Enum.PowerType.Mana] = "MANA",
}

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.ALT_POWER_BAR,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.Size,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateAltPowerBarWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.altPowerBar
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.ALT_POWER_BAR, unit) --[[@as AltPowerBarWidgetTable]]

    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:UpdateColors()
    end
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
        widget.Update(button)
    end ]]

    widget.Update(button)
end

Handler:RegisterWidget(W.UpdateAltPowerBarWidget, const.WIDGET_KIND.ALT_POWER_BAR)

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param self AltPowerBarWidget
---@param color RGBAOpt
local function SetBarColor(self, color)
    local r, g, b, a = unpack(color)

    self:SetStatusBarColor(r, g, b, a)
    self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2, a)
end

---@param self AltPowerBarWidget
local function UpdateColors(self)
    SetBarColor(self, { 0, 0.5, 1, 1 })
    self:SetStatusBarTexture(DB.GetColors().classBar.texture)
    self.bg:SetTexture(DB.GetColors().classBar.texture)
end

---@param self AltPowerBarWidget
local function UpdatePowerType(self)
    self.powerTypeID, self.powerType = UnitPowerType("player")

    self.altPowerTypeID = self.altPowerTypes[self.powerTypeID]
    self.altPowerType = POWER_NAME[self.altPowerTypeID]

    if self.altPowerType then
        self:UpdateColors()
    end
end

---@param self AltPowerBarWidget
---@param enable boolean
local function TogglePowerEvents(self, enable)
    if enable then
        self._owner:AddEventListener("UNIT_MAXPOWER", self.UpdateMaxPower)
        self._owner:AddEventListener("UNIT_POWER_UPDATE", self.UpdatePower)
    else
        self._owner:RemoveEventListener("UNIT_MAXPOWER", self.UpdateMaxPower)
        self._owner:RemoveEventListener("UNIT_POWER_UPDATE", self.UpdatePower)
    end
end

---@param self AltPowerBarWidget
---@param event ("UNIT_ENTERED_VEHICLE"|"UNIT_EXITED_VEHICLE"|"PLAYER_SPECIALIZATION_CHANGED"|"UNIT_DISPLAYPOWER"|"PLAYER_REGEN_ENABLED"|"PLAYER_REGEN_DISABLED")?
local function ShouldShow(self, event)
    if self.hideOutOfCombat then
        if event == "PLAYER_REGEN_ENABLED" then return false end
        if not UnitAffectingCombat("player") then return false end
    end

    if not self.altPowerType then return false end

    return true
end

-------------------------------------------------
-- MARK: Power
-------------------------------------------------

---@param button CUFUnitButton
---@param event "UNIT_POWER_UPDATE"
---@param unit "player"
---@param powerType string?
local function UpdatePower(button, event, unit, powerType)
    local altPowerBar = button.widgets.altPowerBar

    powerType = powerType or altPowerBar.altPowerType
    if powerType ~= altPowerBar.altPowerType then return end

    altPowerBar:SetValue(UnitPower(unit, altPowerBar.altPowerTypeID))
end

---@param button CUFUnitButton
---@param event "UNIT_MAXPOWER"
---@param unit "player"
---@param powerType string?
local function UpdateMaxPower(button, event, unit, powerType)
    local altPowerBar = button.widgets.altPowerBar

    powerType = powerType or altPowerBar.altPowerType
    if powerType ~= altPowerBar.altPowerType then return end

    altPowerBar.maxPower = UnitPowerMax(unit, altPowerBar.altPowerTypeID)
    altPowerBar:SetMinMaxValues(0, altPowerBar.maxPower)
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event ("UNIT_ENTERED_VEHICLE"|"UNIT_EXITED_VEHICLE"|"PLAYER_SPECIALIZATION_CHANGED"|"UNIT_DISPLAYPOWER"|"PLAYER_REGEN_ENABLED"|"PLAYER_REGEN_DISABLED")?
local function Update(button, event)
    local altPowerBar = button.widgets.altPowerBar
    if not altPowerBar.enabled then return end

    altPowerBar:UpdatePowerType()

    if not altPowerBar:ShouldShow(event) then
        altPowerBar:Hide()
        altPowerBar:TogglePowerEvents(false)
        return
    end

    altPowerBar:TogglePowerEvents(true)
    altPowerBar:Show()

    altPowerBar.UpdateMaxPower(button, "UNIT_MAXPOWER", "player")
    altPowerBar.UpdatePower(button, "UNIT_POWER_UPDATE", "player")
end

---@param self AltPowerBarWidget
local function UpdateEventListeners(self)
    if self.hideOutOfCombat then
        self._owner:AddEventListener("PLAYER_REGEN_DISABLED", self.Update, true)
        self._owner:AddEventListener("PLAYER_REGEN_ENABLED", self.Update, true)
    else
        self._owner:RemoveEventListener("PLAYER_REGEN_DISABLED", self.Update)
        self._owner:RemoveEventListener("PLAYER_REGEN_ENABLED", self.Update)
    end

    self._owner:AddEventListener("SPELLS_CHANGED", self.Update, true)

    -- We only want to show when going into catform
    if self._owner.states.class == "DRUID" then
        self._owner:AddEventListener("UNIT_DISPLAYPOWER", self.Update)
    end
end

---@param self AltPowerBarWidget
local function Enable(self)
    self.altPowerTypes = ALT_MANA_POWERS[self._owner.states.class]

    if not self.altPowerTypes then
        self:Hide()
        return false
    end

    self.Update(self._owner)

    self:UpdateEventListeners()

    return true
end

---@param self AltPowerBarWidget
local function Disable(self)
    self.altPowerTypes = nil
    self.powerTypeID = nil
    self.powerType = nil
    self.altPowerType = nil
    self.altPowerTypeID = nil

    self._owner:RemoveEventListener("SPELLS_CHANGED", self.Update)
    self._owner:RemoveEventListener("UNIT_DISPLAYPOWER", self.Update)
    self._owner:RemoveEventListener("PLAYER_REGEN_DISABLED", self.Update)
    self._owner:RemoveEventListener("PLAYER_REGEN_ENABLED", self.Update)

    self:TogglePowerEvents(false)
end

-------------------------------------------------
-- MARK: Options
-------------------------------------------------

---@param self AltPowerBarWidget
---@param verticalFill boolean
local function SetFillStyle(self, verticalFill)
    local orientation = verticalFill and "VERTICAL" or "HORIZONTAL"
    self:SetOrientation(orientation)
end

---@param self AltPowerBarWidget
---@param sizeSize SizeOpt
local function SetSizeStyle(self, sizeSize)
    if self.sameSizeAsHealthBar then
        self:SetSize(self._owner:GetWidth(), sizeSize.height)
    else
        self:SetSize(sizeSize.width, sizeSize.height)
    end
end

-------------------------------------------------
-- MARK: CreateAltPowerBar
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateAltPowerBar(button)
    ---@class AltPowerBarWidget: BaseWidget, StatusBar
    ---@field powerType string?
    ---@field powerTypeID Enum.PowerType?
    ---@field altPowerTypes table<Enum.PowerType, boolean>?
    ---@field altPowerType string?
    ---@field altPowerTypeID Enum.PowerType?
    local altPowerBar = CreateFrame("StatusBar", button:GetName() .. "_AltPowerBar", button,
        "BackdropTemplate")
    button.widgets.altPowerBar = altPowerBar

    altPowerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")

    altPowerBar.bg = altPowerBar:CreateTexture(nil, "BACKGROUND")
    altPowerBar.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    altPowerBar.bg:SetAllPoints()

    altPowerBar.border = CreateFrame("Frame", nil, altPowerBar, "BackdropTemplate")
    altPowerBar.border:SetAllPoints()
    altPowerBar.border:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = P.Scale(CELL_BORDER_SIZE),
    })
    altPowerBar.border:SetBackdropBorderColor(0, 0, 0, 1)

    altPowerBar.id = const.WIDGET_KIND.ALT_POWER_BAR
    altPowerBar._owner = button
    altPowerBar.enabled = false
    altPowerBar.parent = button.widgets.healthBar

    altPowerBar.maxPower = 100
    altPowerBar.hideOutOfCombat = false
    altPowerBar.sameSizeAsHealthBar = true
    altPowerBar.hideIfEmptyOrFull = false
    altPowerBar.hideIfFull = false
    altPowerBar.hideIfEmpty = false

    altPowerBar.Update = Update
    altPowerBar.Enable = Enable
    altPowerBar.Disable = Disable

    altPowerBar.UpdatePower = UpdatePower
    altPowerBar.UpdateMaxPower = UpdateMaxPower

    altPowerBar.ShouldShow = ShouldShow
    altPowerBar.UpdateColors = UpdateColors
    altPowerBar.UpdatePowerType = UpdatePowerType
    altPowerBar.TogglePowerEvents = TogglePowerEvents

    altPowerBar.UpdateEventListeners = UpdateEventListeners

    altPowerBar.SetEnabled = W.SetEnabled
    altPowerBar.SetPosition = W.SetRelativePosition
    altPowerBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    altPowerBar._SetIsSelected = W.SetIsSelected

    altPowerBar.SetFillStyle = SetFillStyle
    altPowerBar.SetSizeStyle = SetSizeStyle
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.ALT_POWER_BAR, W.CreateAltPowerBar)
