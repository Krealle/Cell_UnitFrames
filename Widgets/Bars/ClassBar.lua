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

local SPEC_DEATHKNIGHT_BLOOD = 1
local SPEC_DEATHKNIGHT_FROST = 2
local SPEC_DEATHKNIGHT_UNHOLY = 3

local CLASS_POWER_ID = {
    ["MONK"] = Enum.PowerType.Chi,
    ["PALADIN"] = Enum.PowerType.HolyPower,
    ["WARLOCK"] = Enum.PowerType.SoulShards,
    ["ROGUE"] = Enum.PowerType.ComboPoints,
    ["DRUID"] = Enum.PowerType.ComboPoints,
    ["MAGE"] = Enum.PowerType.ArcaneCharges,
    ["EVOKER"] = Enum.PowerType.Essence,
    ["DEATHKNIGHT"] = Enum.PowerType.Runes,
}

local POWER_NAME = {
    [Enum.PowerType.Chi] = "CHI",
    [Enum.PowerType.HolyPower] = "HOLY_POWER",
    [Enum.PowerType.SoulShards] = "SOUL_SHARDS",
    [Enum.PowerType.ComboPoints] = "COMBO_POINTS",
    [Enum.PowerType.ArcaneCharges] = "ARCANE_CHARGES",
    [Enum.PowerType.Essence] = "ESSENCE",
    [Enum.PowerType.Runes] = "RUNES",
}

local REQUIRED_ENERGY = {
    ["DRUID"] = Enum.PowerType.Energy,
}

local REQUIRED_SPEC = {
    ["MONK"] = SPEC_MONK_WINDWALKER,
    ["MAGE"] = SPEC_MAGE_ARCANE,
}

local USES_PARTIAL_RESOURCE = {
    [SPEC_WARLOCK_DESTRUCTION] = true,
}

local TIMER_TICK_INTERVAL = 0.1

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.CLASS_BAR,
    Builder.MenuOptions.ClassBarOptions,
    Builder.MenuOptions.FrameLevel,
    Builder.MenuOptions.HideOutOfCombat)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateClassBarWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.classBar
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.CLASS_BAR, unit) --[[@as ClassBarWidgetTable]]

    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:UpdateColors()
    end
    if not setting or setting == const.OPTION_KIND.SPACING then
        widget:SetSpacingStyle(styleTable.spacing)
    end
    if not setting or setting == const.OPTION_KIND.VERTICAL_FILL then
        widget:SetFillStyle(styleTable.verticalFill)
    end
    if not setting or setting == const.OPTION_KIND.SAME_SIZE_AS_HEALTH_BAR then
        widget.sameSizeAsHealthBar = styleTable.sameSizeAsHealthBar
        widget:UpdateSize()
    end
    if not setting or setting == const.OPTION_KIND.SIZE then
        widget:SetSizeStyle(styleTable.size)
    end
    if not setting or setting == const.OPTION_KIND.HIDE_OUT_OF_COMBAT then
        widget.hideOutOfCombat = styleTable.hideOutOfCombat
        widget:UpdateEventListeners()
        widget.Update(button)
    end
end

Handler:RegisterWidget(W.UpdateClassBarWidget, const.WIDGET_KIND.CLASS_BAR)

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param bar ClassBar.Bar
---@param color RGBAOpt
local function SetBarColor(bar, color)
    local r, g, b, a = unpack(color)

    bar:SetStatusBarColor(r, g, b, a)
    bar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, a)
end

---@param self ClassBarWidget
local function UpdateColors(self)
    if not self.enabled then return end

    if self.classPowerID == Enum.PowerType.Essence then
        local colors = DB.GetColors().essence
        for i = 1, self.maxPower do
            SetBarColor(self[i], colors[tostring(i)])
        end
    elseif self.classPowerID == Enum.PowerType.SoulShards then
        local color = DB.GetColors().classResources.soulShards
        for i = 1, self.maxPower do
            SetBarColor(self[i], color)
        end
    elseif self.classPowerID == Enum.PowerType.HolyPower then
        local color = DB.GetColors().classResources.holyPower
        for i = 1, self.maxPower do
            SetBarColor(self[i], color)
        end
    elseif self.classPowerID == Enum.PowerType.ArcaneCharges then
        local color = DB.GetColors().classResources.arcaneCharges
        for i = 1, self.maxPower do
            SetBarColor(self[i], color)
        end
    elseif self.classPowerID == Enum.PowerType.ComboPoints then
        local colors = DB.GetColors().comboPoints
        for i = 1, self.maxPower do
            SetBarColor(self[i], colors[tostring(i)])
        end
    elseif self.classPowerID == Enum.PowerType.Chi then
        local colors = DB.GetColors().chi
        for i = 1, self.maxPower do
            SetBarColor(self[i], colors[tostring(i)])
        end
    elseif self.classPowerID == Enum.PowerType.Runes then
        local color

        local spec = GetSpecialization()
        if spec == SPEC_DEATHKNIGHT_BLOOD then
            color = DB.GetColors().runes.bloodRune
        elseif spec == SPEC_DEATHKNIGHT_FROST then
            color = DB.GetColors().runes.frostRune
        elseif spec == SPEC_DEATHKNIGHT_UNHOLY then
            color = DB.GetColors().runes.unholyRune
        end

        for i = 1, self.maxPower do
            SetBarColor(self[i], color)
        end
    else
        for i = 1, self.maxPower do
            local r, g, b = 1 / i, i * 0.2, 0
            SetBarColor(self[i], { r, g, b, 1 })
        end
    end

    for i = 1, self.maxPower do
        self[i]:SetStatusBarTexture(DB.GetColors().classBar.texture)
        self[i].bg:SetTexture(DB.GetColors().classBar.texture)
    end
end

---@param self ClassBarWidget
local function UpdateSize(self)
    if not self.enabled then return end

    local maxWidth
    if self.sameSizeAsHealthBar then
        maxWidth = self._owner:GetWidth() + (self.spacing == -1 and -1 or 0)
    else
        maxWidth = self.width + (self.spacing == -1 and -1 or 0)
    end
    self:SetSize(maxWidth, self.height)

    local barWidth = maxWidth / self.maxPower
    local totalWidth = (barWidth * self.maxPower) - self.spacing
    local startX = (maxWidth - totalWidth) / 2

    for i = 1, #self do
        local bar = self[i]

        if i <= self.maxPower then
            P.ClearPoints(bar)
            bar:SetSize(barWidth - self.spacing, self.height)

            if i == 1 then
                P.Point(bar, "LEFT", self, "LEFT", startX, 0)
            else
                P.Point(bar, "LEFT", self[i - 1], "RIGHT", self.spacing, 0)
            end

            bar:Show()
        else
            bar:Hide()
        end
    end

    self:UpdateColors()
end

---@param self ClassBarWidget
local function UpdatePowerType(self)
    if self.inVehicle and PlayerVehicleHasComboPoints() then
        self.classPowerID = Enum.PowerType.ComboPoints
        self.powerType = POWER_NAME[self.classPowerID]
        return
    end

    if self.requiredSpec then
        local spec = GetSpecialization()
        if spec ~= self.requiredSpec then
            self.classPowerID = nil
            return
        end
    end

    self.classPowerID = CLASS_POWER_ID[self._owner.states.class] or nil
    self.powerType = self.classPowerID and POWER_NAME[self.classPowerID] or nil
end

---@param self ClassBarWidget
---@param enable boolean
local function TogglePowerEvents(self, enable)
    if enable then
        if self._owner.states.class == "DEATHKNIGHT" then
            self._owner:AddEventListener("RUNE_POWER_UPDATE", self.UpdateRunes, true)
        elseif self._owner.states.class == "EVOKER" then
            -- Essence is a special case - it *NEEDS* frequent updates
            -- Or it will *NOT* update properly
            self._owner:AddEventListener("UNIT_POWER_FREQUENT", self.UpdateEssence)
        else
            -- Check for Charged Combo Points
            if self._owner.states.class == "ROGUE" then
                self._owner:AddEventListener("UNIT_POWER_POINT_CHARGE", self.UpdateChargedComboPoints)
            end
            self._owner:AddEventListener("UNIT_POWER_UPDATE", self.UpdatePower)
        end

        self._owner:AddEventListener("UNIT_MAXPOWER", self.UpdateMaxPower)
    else
        self._owner:RemoveEventListener("UNIT_MAXPOWER", self.UpdateMaxPower)
        self._owner:RemoveEventListener("UNIT_POWER_UPDATE", self.UpdatePower)
        self._owner:RemoveEventListener("RUNE_POWER_UPDATE", self.UpdateRunes)
        self._owner:RemoveEventListener("UNIT_POWER_FREQUENT", self.UpdateEssence)
        self._owner:RemoveEventListener("UNIT_POWER_POINT_CHARGE", self.UpdateChargedComboPoints)
    end
end

---@param self ClassBarWidget
---@param event ("UNIT_ENTERED_VEHICLE"|"UNIT_EXITED_VEHICLE"|"PLAYER_SPECIALIZATION_CHANGED"|"UNIT_DISPLAYPOWER"|"PLAYER_REGEN_ENABLED"|"PLAYER_REGEN_DISABLED")?
local function ShouldShow(self, event)
    if self.hideOutOfCombat then
        if event == "PLAYER_REGEN_ENABLED" then return false end
        if not UnitAffectingCombat("player") then return false end
    end
    if not self.classPowerID then return false end
    if self.requiredPowerType and self.requiredPowerType ~= UnitPowerType("player") then return false end
    return true
end

-------------------------------------------------
-- MARK: Power
-------------------------------------------------

---@param button CUFUnitButton
---@param event "UNIT_POWER_UPDATE"?
---@param unit "player"
---@param powerType string?
local function UpdatePower(button, event, unit, powerType)
    --CUF:Log(event, unit, powerType)
    if not (powerType and unit and UnitIsUnit(unit, "player")) then return end

    local classBar = button.widgets.classBar
    if powerType ~= classBar.powerType then
        return
    end

    local cur
    local partialBar = 0

    if classBar.isPartialResource then
        local mod = UnitPowerDisplayMod(classBar.classPowerID)
        cur = UnitPower(unit, classBar.classPowerID, true) / mod
        partialBar = math.ceil(cur)
    else
        cur = UnitPower(unit, classBar.classPowerID)
    end

    for i = 1, classBar.maxPower do
        local bar = classBar[i]
        if i <= cur then
            bar:SetValue(cur)
        elseif i == partialBar then
            bar:SetValue(cur - i + 1)
        else
            bar:SetValue(0)
        end
    end
end

---@param button CUFUnitButton
---@param event "UNIT_MAXPOWER"
---@param unit "player"
---@param powerType string?
local function UpdateMaxPower(button, event, unit, powerType)
    local classBar = button.widgets.classBar
    if powerType ~= classBar.powerType then
        return
    end
    classBar.maxPower = UnitPowerMax(unit, classBar.classPowerID)

    classBar:UpdateSize()
end

---@param button CUFUnitButton
---@param event "UNIT_POWER_POINT_CHARGE"
---@param unit Unit
local function UpdateChargedComboPoints(button, event, unit)
    local classBar = button.widgets.classBar

    -- Update the relevant bars
    local chargedPoints = GetUnitChargedPowerPoints(button.states.unit)
    if chargedPoints and #chargedPoints > 0 then
        local color = DB.GetColors().comboPoints.charged

        for _, point in ipairs(chargedPoints) do
            SetBarColor(classBar[point], color)
        end

        return
    end

    -- Update all to reset colors if no charged points
    classBar:UpdateColors()
end

-------------------------------------------------
-- MARK: Essence
-------------------------------------------------

---@param bar ClassBar.Bar
---@param duration number
---@param elapsedPortion number
local function StartEssenceTimer(bar, duration, elapsedPortion)
    bar:StopEssenceTimer()
    bar:SetValue(elapsedPortion)

    local stepValue = TIMER_TICK_INTERVAL / duration

    bar.essenceUpdateTimer = C_Timer.NewTicker(TIMER_TICK_INTERVAL, function()
        local newElapsedPortion = bar:GetValue() + stepValue
        bar:SetValue(newElapsedPortion)

        if newElapsedPortion >= 1 then
            bar:StopEssenceTimer()
        end
    end)
end

---@param bar ClassBar.Bar
local function StopEssenceTimer(bar)
    if bar.essenceUpdateTimer then
        bar.essenceUpdateTimer:Cancel()
        bar.essenceUpdateTimer = nil
    end
end

---@param button CUFUnitButton
---@param event "UNIT_POWER_FREQUENT"
---@param unit "player"
---@param powerType string
local function UpdateEssence(button, event, unit, powerType)
    local classBar = button.widgets.classBar
    if powerType ~= "ESSENCE" then
        return
    end

    local current = UnitPower(unit, Enum.PowerType.Essence)
    -- No need to update if the current value is the same as the last one
    if current == classBar.lastPower then return end

    local isAtMaxEssence = current == classBar.maxPower

    for i = 1, classBar.maxPower do
        local bar = classBar[i]

        -- Stop the timer from previously filling bar
        if i == classBar.lastPower + 1 then
            bar:StopEssenceTimer()
        end

        if i == current + 1 and not isAtMaxEssence then
            local partialPoint = UnitPartialPower(unit, Enum.PowerType.Essence)
            local elapsedPortion = (partialPoint / 1000.0)

            local baseRechargeRate = GetPowerRegenForPowerType(Enum.PowerType.Essence)
            if baseRechargeRate == nil or baseRechargeRate == 0 then
                baseRechargeRate = 0.2
            end
            local essenceRechargeRate = 1 / baseRechargeRate

            bar:StartEssenceTimer(essenceRechargeRate, elapsedPortion)
        elseif i <= current then
            bar:SetValue(1)
        else
            bar:SetValue(0)
        end
    end

    classBar.lastPower = current
end

-------------------------------------------------
-- MARK: Runes
-------------------------------------------------

---@param bar ClassBar.Bar
local function StartRuneTimer(bar)
    if not bar.runeUpdateTimer then
        bar.runeUpdateTimer = C_Timer.NewTicker(TIMER_TICK_INTERVAL, function()
            bar:UpdateRune()
        end)
    end
end

---@param bar ClassBar.Bar
local function StopRuneTimer(bar)
    if bar.runeUpdateTimer then
        bar.runeUpdateTimer:Cancel()
        bar.runeUpdateTimer = nil
    end
end

---@param bar ClassBar.Bar
local function UpdateRune(bar)
    local start, duration, runeReady = GetRuneCooldown(bar.index)

    -- When changing zones this API can return nil
    if start == nil then return end

    if runeReady then
        bar:SetValue(1)
        bar:StopRuneTimer()
    else
        local timeLeft = duration - (GetTime() - start)
        local progress = 1 - (timeLeft / duration)
        bar:SetValue(progress)
        bar:StartRuneTimer()
    end
end

---@param button CUFUnitButton
---@param event "RUNE_POWER_UPDATE"
---@param runeIndex number
---@param added boolean?
local function UpdateRunes(button, event, runeIndex, added)
    local classBar = button.widgets.classBar

    -- This event throws huge numbers when runes are fully charged
    -- For now we just ignore them, since we have timers running anyways
    -- So no need to go iterating through all bars
    if runeIndex < 1 or runeIndex > classBar.maxPower then return end
    classBar[runeIndex]:UpdateRune()
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event ("UNIT_ENTERED_VEHICLE"|"UNIT_EXITED_VEHICLE"|"PLAYER_SPECIALIZATION_CHANGED"|"UNIT_DISPLAYPOWER"|"PLAYER_REGEN_ENABLED"|"PLAYER_REGEN_DISABLED")?
local function Update(button, event)
    local classBar = button.widgets.classBar

    if classBar.showForVehicle then
        classBar.inVehicle = UnitHasVehicleUI("player")
    end

    classBar:UpdatePowerType()

    local shouldShow = classBar:ShouldShow(event)
    if not shouldShow then
        classBar:HideBars()
        classBar:TogglePowerEvents(false)
        return
    end

    classBar.maxPower = UnitPowerMax("player", classBar.classPowerID)
    classBar.isPartialResource = USES_PARTIAL_RESOURCE[GetSpecialization()] or false

    classBar:TogglePowerEvents(true)
    classBar:UpdateSize()

    --[[ CUF:Log("ClassBar - Update:", event, "classPowerID:", classBar.classPowerID, "powerType:", classBar.powerType,
        "maxPower:", classBar.maxPower, "isPartialResource:", classBar.isPartialResource,
        "maxPower:", classBar.maxPower) ]]
    classBar.UpdatePower(button, nil, "player", classBar.powerType)
end

---@param self ClassBarWidget
local function UpdateEventListeners(self)
    if self.hideOutOfCombat then
        self._owner:AddEventListener("PLAYER_REGEN_DISABLED", self.Update, true)
        self._owner:AddEventListener("PLAYER_REGEN_ENABLED", self.Update, true)
    else
        self._owner:RemoveEventListener("PLAYER_REGEN_DISABLED", self.Update)
        self._owner:RemoveEventListener("PLAYER_REGEN_ENABLED", self.Update)
    end

    -- We need to listen for changes in the spec so we can appropriately toggle the bars
    if self.requiredSpec then
        self._owner:AddEventListener("SPELLS_CHANGED", self.Update, true)
    end

    if self.showForVehicle then
        self._owner:AddEventListener("UNIT_ENTERED_VEHICLE", self.Update)
        self._owner:AddEventListener("UNIT_EXITED_VEHICLE", self.Update)
    end

    -- We only want to show when going into catform
    if self._owner.states.class == "DRUID" then
        self._owner:AddEventListener("UNIT_DISPLAYPOWER", self.Update)
    end
end

---@param self ClassBarWidget
local function Enable(self)
    self.requiredPowerType = REQUIRED_ENERGY[self._owner.states.class]
    self.requiredSpec = REQUIRED_SPEC[self._owner.states.class]

    self:UpdatePowerType()
    self.Update(self._owner)

    -- This class doesn't have a power type so no reason to show bars
    if not self.classPowerID then
        -- If want it shown for Vehicles we should still enable
        if not self.showForVehicle then
            self:HideBars()
            return false
        end
    end

    self:UpdateEventListeners()

    return true
end

---@param self ClassBarWidget
local function Disable(self)
    self._owner:RemoveEventListener("SPELLS_CHANGED", self.Update)
    self._owner:RemoveEventListener("UNIT_ENTERED_VEHICLE", self.Update)
    self._owner:RemoveEventListener("UNIT_EXITED_VEHICLE", self.Update)
    self._owner:RemoveEventListener("UNIT_DISPLAYPOWER", self.Update)
    self._owner:RemoveEventListener("PLAYER_REGEN_DISABLED", self.Update)
    self._owner:RemoveEventListener("PLAYER_REGEN_ENABLED", self.Update)

    self:TogglePowerEvents(false)

    self:HideBars()

    return true
end

-------------------------------------------------
-- MARK: Options
-------------------------------------------------

---@param self ClassBarWidget
---@param spacing number
local function SetSpacingStyle(self, spacing)
    self.spacing = spacing
    self:UpdateSize()
end

---@param self ClassBarWidget
---@param verticalFill boolean
local function SetFillStyle(self, verticalFill)
    local orientation = verticalFill and "VERTICAL" or "HORIZONTAL"
    for i = 1, #self do
        local bar = self[i]
        bar:SetOrientation(orientation)
    end
end

---@param self ClassBarWidget
---@param sizeSize SizeOpt
local function SetSizeStyle(self, sizeSize)
    self.width = sizeSize.width
    self.height = sizeSize.height
    self:UpdateSize()
end

-------------------------------------------------
-- MARK: CreatePowerBar
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateClassBar(button)
    ---@class ClassBarWidget: Frame, BaseWidget, BackdropTemplate
    ---@field classPowerID Enum.PowerType?
    ---@field requiredSpec number?
    ---@field powerType string?
    ---@field requiredPowerType Enum.PowerType?
    ---@field [number] ClassBar.Bar
    local classBar = CreateFrame("Frame", button:GetName() .. "_ClassBar", button, "BackdropTemplate")
    button.widgets.classBar = classBar

    classBar.id = const.WIDGET_KIND.CLASS_BAR
    classBar._owner = button
    classBar.enabled = false
    classBar.parent = button.widgets.healthBar

    classBar.spacing = 5
    classBar.sameSizeAsHealthBar = true
    classBar.height = 8
    classBar.width = 200
    classBar.hideOutOfCombat = false

    classBar.showForVehicle = false
    classBar.inVehicle = false
    classBar.maxPower = 4
    classBar.isPartialResource = false
    classBar.lastPower = 0

    for i = 1, 7 do
        ---@class ClassBar.Bar: StatusBar
        ---@field runeUpdateTimer FunctionContainer?
        ---@field essenceUpdateTimer FunctionContainer?
        local bar = CreateFrame("StatusBar", classBar:GetName() .. "Bar" .. i, classBar)
        classBar[i] = bar
        bar.index = i

        bar:SetStatusBarTexture(CUF.constants.Textures.SOLID)
        bar:SetMinMaxValues(0, 1)

        bar.bg = bar:CreateTexture(nil, "BACKGROUND")
        bar.bg:SetTexture(CUF.constants.Textures.SOLID)
        bar.bg:SetAllPoints()

        bar.border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
        bar.border:SetAllPoints()
        bar.border:SetBackdrop({
            bgFile = nil,
            edgeFile = CUF.constants.Textures.SOLID,
            edgeSize = P.Scale(CELL_BORDER_SIZE),
        })
        bar.border:SetBackdropBorderColor(0, 0, 0, 1)

        bar:Hide()

        bar.UpdateRune = UpdateRune
        bar.StopRuneTimer = StopRuneTimer
        bar.StartRuneTimer = StartRuneTimer

        bar.StopEssenceTimer = StopEssenceTimer
        bar.StartEssenceTimer = StartEssenceTimer
    end

    function classBar:HideBars()
        for i = 1, #self do
            self[i]:Hide()
        end
    end

    classBar.Update = Update
    classBar.Enable = Enable
    classBar.Disable = Disable

    classBar.UpdatePower = UpdatePower
    classBar.UpdateRunes = UpdateRunes
    classBar.UpdateEssence = UpdateEssence
    classBar.UpdateMaxPower = UpdateMaxPower
    classBar.UpdateChargedComboPoints = UpdateChargedComboPoints

    classBar.ShouldShow = ShouldShow
    classBar.UpdateSize = UpdateSize
    classBar.UpdateColors = UpdateColors
    classBar.UpdatePowerType = UpdatePowerType
    classBar.TogglePowerEvents = TogglePowerEvents

    classBar.UpdateEventListeners = UpdateEventListeners

    classBar.SetEnabled = W.SetEnabled
    classBar.SetPosition = W.SetPosition
    classBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    classBar._SetIsSelected = W.SetIsSelected

    classBar.SetFillStyle = SetFillStyle
    classBar.SetSizeStyle = SetSizeStyle
    classBar.SetSpacingStyle = SetSpacingStyle
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.CLASS_BAR, W.CreateClassBar)
