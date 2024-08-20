---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

---@class CUF.uFuncs
local U = CUF.uFuncs

local W = CUF.widgets
local const = CUF.constants

local GetUnitName = GetUnitName
local UnitGUID = UnitGUID

-------------------------------------------------
-- MARK: Aura tables
-------------------------------------------------

---@param self CUFUnitButton
local function ResetAuraTables(self)
    wipe(self.widgets.buffs._auraCache)
    wipe(self.widgets.debuffs._auraCache)
end

-------------------------------------------------
-- MARK: Update InRange
-------------------------------------------------

---@param self CUFUnitButton
---@param ir boolean?
local function UnitFrame_UpdateInRange(self, ir)
    local unit = self.states.displayedUnit
    if not unit then return end

    local inRange = F:IsInRange(unit)

    self.states.inRange = inRange
    if Cell.loaded then
        if self.states.inRange ~= self.states.wasInRange then
            if inRange then
                if CELL_FADE_OUT_HEALTH_PERCENT then
                    if not self.states.healthPercent or self.states.healthPercent < CELL_FADE_OUT_HEALTH_PERCENT then
                        A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                    else
                        A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB.appearance.outOfRangeAlpha)
                    end
                else
                    A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                end
            else
                A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB.appearance.outOfRangeAlpha)
            end
        end
        self.states.wasInRange = inRange
    end
end

-------------------------------------------------
-- MARK: Update All
-------------------------------------------------

---@param button CUFUnitButton
local function UnitFrame_UpdateAll(button)
    if not button:IsVisible() then return end

    U:UnitFrame_UpdateName(button)
    U:UnitFrame_UpdateHealthMax(button)
    U:UnitFrame_UpdateHealth(button)
    U:UnitFrame_UpdateHealthColor(button)
    U:UnitFrame_UpdateHealthText(button)
    U:UnitFrame_UpdatePowerMax(button)
    U:UnitFrame_UpdatePower(button)
    U:UnitFrame_UpdatePowerType(button)
    U:UnitFrame_UpdatePowerText(button)
    U:UnitFrame_UpdatePowerTextColor(button)
    --UnitFrame_UpdateTarget(self)
    UnitFrame_UpdateInRange(button)
    U:UnitFrame_UpdateAuras(button)
    U:UnitFrame_UpdateRaidIcon(button)
    U:UnitFrame_UpdateRoleIcon(button)
    U:UnitFrame_UpdateLeaderIcon(button)
    U:UnitFrame_UpdateCombatIcon(button)
    U:UnitFrame_UpdateShieldBar(button)
    U:UnitFrame_UpdateShieldBarHeight(button)
    U:UnitFrame_UpdateLevel(button)
    U:UnitFrame_UpdateRestingIcon(button)
    U:UnitFrame_UpdateCastBar(button)

    if Cell.loaded and button._powerBarUpdateRequired then
        button._powerBarUpdateRequired = nil
        if button:ShouldShowPowerBar() then
            button:ShowPowerBar()
        else
            button:HidePowerBar()
        end
    else
        U:UnitFrame_UpdatePowerMax(button)
        U:UnitFrame_UpdatePower(button)
    end
end
U.UpdateAll = UnitFrame_UpdateAll

-------------------------------------------------
-- MARK: Helpers
-------------------------------------------------

---@param button CUFUnitButton
local function UnitFrame_ShouldShowAuras(button)
    return button.widgets.buffs.enabled or button.widgets.debuffs.enabled
end

-- Register/Unregister UNIT_AURA event
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleAuras(button, show)
    if not button:IsShown() then return end
    if UnitFrame_ShouldShowAuras(button) or show then
        button:RegisterEvent("UNIT_AURA")
    else
        button:UnregisterEvent("UNIT_AURA")
    end
end

-- Register/Unregister UNIT_AURA event
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleRaidTargetEvents(button, show)
    if not button:IsShown() then return end
    if button.widgets.raidIcon.enabled or show then
        button:RegisterEvent("RAID_TARGET_UPDATE")
    else
        button:UnregisterEvent("RAID_TARGET_UPDATE")
    end
end

-- Register/Unregister UNIT_POWER_FREQUENT, UNIT_MAXPOWER, UNIT_DISPLAYPOWER
---@param button CUFUnitButton
---@param show? boolean
function U:TogglePowerEvents(button, show)
    if not button:IsShown() then return end
    if button.widgets.powerBar:IsVisible()
        or button.widgets.powerText.enabled
        or show
    then
        button:RegisterEvent("UNIT_POWER_FREQUENT")
        button:RegisterEvent("UNIT_MAXPOWER")
        button:RegisterEvent("UNIT_DISPLAYPOWER")
    else
        button:UnregisterEvent("UNIT_POWER_FREQUENT")
        button:UnregisterEvent("UNIT_MAXPOWER")
        button:UnregisterEvent("UNIT_DISPLAYPOWER")
    end
end

-- Register/Unregister UNIT_ABSORB_AMOUNT_CHANGED event
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleAbsorbEvents(button, show)
    if not button:IsShown() then return end
    if button.widgets.shieldBar.enabled
        or (button.widgets.healthText._showingAbsorbs and button.widgets.healthText.enabled)
        or show then
        button:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    else
        button:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    end
end

-- Register/Unregister UNIT_READY_CHECK
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleReadyCheckEvents(button, show)
    if not button:IsShown() then return end
    if button.widgets.readyCheckIcon.enabled or show then
        button:RegisterEvent("READY_CHECK")
        button:RegisterEvent("READY_CHECK_FINISHED")
        button:RegisterEvent("READY_CHECK_CONFIRM")
    else
        button:UnregisterEvent("READY_CHECK")
        button:UnregisterEvent("READY_CHECK_FINISHED")
        button:UnregisterEvent("READY_CHECK_CONFIRM")
    end
end

-- Register/Unregister UNIT_RESTING event
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleRestingEvents(button, show)
    if not button:IsShown() then return end
    if button.widgets.restingIcon.enabled or show then
        button:RegisterEvent("PLAYER_UPDATE_RESTING")
    else
        button:UnregisterEvent("PLAYER_UPDATE_RESTING")
    end
end

-------------------------------------------------
-- MARK: RegisterEvents
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_RegisterEvents(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")

    --self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    --self:RegisterEvent("UNIT_HEAL_PREDICTION")
    --self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

    --self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    --self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    --self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    --self:RegisterEvent("UNIT_EXITED_VEHICLE")

    self:RegisterEvent("UNIT_CONNECTION")  -- offline
    --self:RegisterEvent("PLAYER_FLAGS_CHANGED")  -- afk
    self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
    --self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    if self.states.unit == const.UNIT.TARGET then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
    if self.states.unit == const.UNIT.FOCUS then
        self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end
    if self.states.unit == const.UNIT.PET then
        self:RegisterEvent("UNIT_PET")
    end
    U:ToggleRaidTargetEvents(self)
    U:TogglePowerEvents(self)
    U:ToggleAuras(self)
    U:ToggleAbsorbEvents(self)
    U:ToggleReadyCheckEvents(self)
    U:ToggleRestingEvents(self)
    U:ToggleCastEvents(self)

    self:RegisterEvent("UNIT_NAME_UPDATE")

    local success, result = pcall(UnitFrame_UpdateAll, self)
    if not success then
        F:Debug("UnitFrame_UpdateAll |cffff0000FAILED:|r", self:GetName(), result)
    end
end

-------------------------------------------------
-- MARK: UnregisterEvents
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

-------------------------------------------------
-- MARK: OnEvents
-------------------------------------------------

---@param self CUFUnitButton
---@param event WowEvent
---@param unit string
---@param ... any
local function UnitFrame_OnEvent(self, event, unit, ...)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if event == "UNIT_AURA" then
            U:UnitFrame_UpdateAuras(self, ...)
        elseif event == "UNIT_HEALTH" then
            U:UnitFrame_UpdateHealth(self)
            U:UnitFrame_UpdateShieldBar(self)
        elseif event == "UNIT_MAXHEALTH" then
            U:UnitFrame_UpdateHealthMax(self)
            U:UnitFrame_UpdateHealth(self)
            U:UnitFrame_UpdateShieldBar(self)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            U:UnitFrame_UpdateHealth(self)
            U:UnitFrame_UpdateShieldBar(self)
        elseif event == "UNIT_MAXPOWER" then
            U:UnitFrame_UpdatePowerMax(self)
            U:UnitFrame_UpdatePower(self)
        elseif event == "UNIT_POWER_FREQUENT" then
            U:UnitFrame_UpdatePower(self)
            U:UnitFrame_UpdatePowerText(self)
        elseif event == "UNIT_DISPLAYPOWER" then
            U:UnitFrame_UpdatePowerMax(self)
            U:UnitFrame_UpdatePower(self)
            U:UnitFrame_UpdatePowerText(self)
            U:UnitFrame_UpdatePowerType(self)
            U:UnitFrame_UpdatePowerTextColor(self)
        elseif event == "UNIT_CONNECTION" then
            self._updateRequired = true
        elseif event == "UNIT_NAME_UPDATE" then
            U:UnitFrame_UpdateName(self)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            UnitFrame_UpdateInRange(self, ...)
        elseif event == "UNIT_NAME_UPDATE" then
            U:UnitFrame_UpdatePowerTextColor(self)
        elseif event == "READY_CHECK_CONFIRM" then
            U:UnitFrame_UpdateReadyCheckIcon(self)
        elseif event == "UNIT_SPELLCAST_START"
            or event == "UNIT_SPELLCAST_CHANNEL_START"
            or event == "UNIT_SPELLCAST_EMPOWER_START" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastStart(self, event, unit, ...)
        elseif event == "UNIT_SPELLCAST_STOP"
            or event == "UNIT_SPELLCAST_CHANNEL_STOP"
            or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastStop(self, event, unit, ...)
        elseif event == "UNIT_SPELLCAST_DELAYED"
            or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
            or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastUpdate(self, event, unit, ...)
        elseif event == "UNIT_SPELLCAST_FAILED"
            or event == "UNIT_SPELLCAST_INTERRUPTED" then
            ---@diagnostic disable-next-line: param-type-mismatch
            U:CastBar_CastFail(self, event, unit, ...)
        end
    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = true
        elseif event == "PLAYER_TARGET_CHANGED" then
            --[[  UnitButton_UpdateTarget(self)
            UnitButton_UpdateThreatBar(self) ]]
            UnitFrame_UpdateAll(self)
        elseif event == "PLAYER_FOCUS_CHANGED" then
            UnitFrame_UpdateAll(self)
        elseif event == "UNIT_PET" and unit == const.UNIT.PLAYER then
            UnitFrame_UpdateAll(self)
        elseif event == "RAID_TARGET_UPDATE" then
            U:UnitFrame_UpdateRaidIcon(self)
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            U:UnitFrame_UpdateCombatIcon(self, event)
        elseif event == "READY_CHECK" or event == "READY_CHECK_FINISHED" then
            U:UnitFrame_UpdateReadyCheckIcon(self)
        elseif event == "PLAYER_UPDATE_RESTING" then
            U:UnitFrame_UpdateRestingIcon(self)
        end
    end
end

-------------------------------------------------
-- MARK: OnShow
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnShow(self)
    --CUF:Log(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent UnitFrame_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    self._powerBarUpdateRequired = true
    UnitFrame_RegisterEvents(self)
end

-------------------------------------------------
-- MARK: OnHide
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnHide(self)
    --CUF:Log(GetTime(), "OnHide", self:GetName())
    UnitFrame_UnregisterEvents(self)
    ResetAuraTables(self)

    -- NOTE: update Cell.vars.guids
    -- CUF:Log("hide", self.states.unit, self.__unitGuid, self.__unitName)
    if self.__unitGuid then
        Cell.vars.guids[self.__unitGuid] = nil
        self.__unitGuid = nil
    end
    if self.__unitName then
        Cell.vars.names[self.__unitName] = nil
        self.__unitName = nil
    end
    self.__displayedGuid = nil
    F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
end

-------------------------------------------------
-- MARK: OnEnter
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnEnter(self)
    --if not IsEncounterInProgress() then UnitButton_UpdateStatusText(self) end

    --if highlightEnabled then self.widgets.mouseoverHighlight:Show() end

    local unit = self.states.displayedUnit
    if not unit then return end

    F:ShowTooltips(self, "unit", unit)
end

-------------------------------------------------
-- MARK: OnLeave
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnLeave(self)
    self.widgets.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

local UNKNOWN = _G["UNKNOWN"]
local UNKNOWNOBJECT = _G["UNKNOWNOBJECT"]

-------------------------------------------------
-- MARK: OnTick
-------------------------------------------------

---@param self CUFUnitButton
local function UnitFrame_OnTick(self)
    -- CUF:Log(GetTime(), "OnTick", self._updateRequired, self:GetAttribute("refreshOnUpdate"), self:GetName())
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0

        if self.states.unit and self.states.displayedUnit then
            local displayedGuid = UnitGUID(self.states.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                self._updateRequired = true
                self._powerBarUpdateRequired = true
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- CUF:Log("guidChanged:", self:GetName(), self.states.unit, guid)
                -- NOTE: unit entity changed
                -- update Cell.vars.guids
                self.__unitGuid = guid
                Cell.vars.guids[guid] = self.states.unit

                -- NOTE: only save players' names
                if UnitIsPlayer(self.states.unit) then
                    -- update Cell.vars.names
                    local name = GetUnitName(self.states.unit, true)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        Cell.vars.names[name] = self.states.unit
                        self.__nameRetries = nil
                    else
                        -- NOTE: update on next tick
                        self.__nameRetries = (self.__nameRetries or 0) + 1
                        self.__unitGuid = nil
                    end
                end
            end
        end
    end

    self.__tickCount = e

    UnitFrame_UpdateInRange(self)

    if self._updateRequired then
        self._updateRequired = nil
        UnitFrame_UpdateAll(self)
    end
end

-------------------------------------------------
-- MARK: OnUpdate
-------------------------------------------------

---@param self CUFUnitButton
---@param elapsed number
local function UnitFrame_OnUpdate(self, elapsed)
    local e = (self.__updateElapsed or 0) + elapsed
    if e > 0.25 then
        UnitFrame_OnTick(self)
        e = 0
    end
    self.__updateElapsed = e
end

-------------------------------------------------
-- MARK: OnAttributeChanged
-------------------------------------------------

---@param self CUFUnitButton
---@param name string
---@param value string?
local function UnitFrame_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if not value or value ~= self.states.unit then
            -- NOTE: when unitId for this button changes
            if self.__unitGuid then -- self.__unitGuid is deleted when hide
                Cell.vars.guids[self.__unitGuid] = nil
                self.__unitGuid = nil
            end
            if self.__unitName then
                Cell.vars.names[self.__unitName] = nil
                self.__unitName = nil
            end
            wipe(self.states)
        end

        if type(value) == "string" then
            self.states.unit = value
            self.states.displayedUnit = value

            W:AssignWidgets(self, value)
            ResetAuraTables(self)
        end
    end
end

-------------------------------------------------
-- MARK: OnLoad
-------------------------------------------------

---@param button CUFUnitButton
function CUFUnitButton_OnLoad(button)
    --CUF:Log(buttonName, "OnLoad")

    ---@diagnostic disable-next-line: missing-fields
    button.widgets = {}
    ---@diagnostic disable-next-line: missing-fields
    button.states = {}

    -- ping system
    Mixin(button, PingableType_UnitFrameMixin)
    button:SetAttribute("ping-receiver", true)

    function button:GetTargetPingGUID()
        return button.__unitGuid
    end

    -- backdrop
    button:SetBackdrop({
        bgFile = Cell.vars.whiteTexture,
        edgeFile = Cell.vars.whiteTexture,
        edgeSize = P:Scale(
            CELL_BORDER_SIZE)
    })
    button:SetBackdropColor(0, 0, 0, 1)
    button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))

    -- Widgets
    W:CreateHealthBar(button)
    W:CreatePowerBar(button)

    -- targetHighlight
    ---@class HighlightWidget: BackdropTemplate, Frame
    local targetHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.widgets.targetHighlight = targetHighlight
    targetHighlight:SetIgnoreParentAlpha(true)
    targetHighlight:SetFrameLevel(button:GetFrameLevel() + 2)
    targetHighlight:Hide()

    -- mouseoverHighlight
    local mouseoverHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate") --[[@as HighlightWidget]]
    button.widgets.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetIgnoreParentAlpha(true)
    mouseoverHighlight:SetFrameLevel(button:GetFrameLevel() + 3)
    mouseoverHighlight:Hide()

    -- script
    button:SetScript("OnAttributeChanged", UnitFrame_OnAttributeChanged) -- init
    button:HookScript("OnShow", UnitFrame_OnShow)
    button:HookScript("OnHide", UnitFrame_OnHide)                        -- click-castings: _onhide
    button:HookScript("OnEnter", UnitFrame_OnEnter)                      -- click-castings: _onenter
    button:HookScript("OnLeave", UnitFrame_OnLeave)                      -- click-castings: _onleave
    button:SetScript("OnUpdate", UnitFrame_OnUpdate)
    --[[ button:SetScript("OnSizeChanged", UnitFrame_OnSizeChanged) ]]
    button:SetScript("OnEvent", UnitFrame_OnEvent)
    button:RegisterForClicks("AnyDown")
    --CUF:Log(button:GetName(), "OnLoad end")
end
