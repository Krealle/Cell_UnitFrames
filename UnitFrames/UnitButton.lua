---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local B = Cell.bFuncs
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

local UnitIsConnected = UnitIsConnected
local InCombatLockdown = InCombatLockdown
local GetUnitName = GetUnitName
local UnitGUID = UnitGUID
local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot

--! AI followers, wrong value returned by UnitClassBase
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

local barAnimationType = CellDB["appearance"]["barAnimation"]

-------------------------------------------------
-- MARK: Unit button
-------------------------------------------------

function B:SaveTooltipPosition(unit, tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY)
    Cell.vars.currentLayoutTable[unit]["tooltipPosition"] = { tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY }
end

function B:CreateBaseUnitFrame(unit, configTitle, onEnterLogic)
    local name = unit:gsub("^%l", string.upper)
    local frame = CreateFrame("Frame", "Cell" .. name .. "Frame", Cell.frames.mainFrame, "SecureFrameTemplate")

    -- Anchor
    local anchorFrame = CreateFrame("Frame", "Cell" .. name .. "AnchorFrame", frame)
    PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)

    -- Hover
    local hoverFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
    hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
    hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
    hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)

    A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

    local config = Cell:CreateButton(anchorFrame, nil, "accent", { 20, 10 }, false, true, nil, nil,
        "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
    config:SetFrameStrata("MEDIUM")
    config:SetAllPoints(anchorFrame)
    config:RegisterForDrag("LeftButton")
    config:SetScript("OnDragStart", function()
        anchorFrame:StartMoving()
        anchorFrame:SetUserPlaced(false)
    end)
    config:SetScript("OnDragStop", function()
        anchorFrame:StopMovingOrSizing()
        P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable[unit]["position"])
    end)
    config:HookScript("OnEnter", function()
        hoverFrame:GetScript("OnEnter")(hoverFrame)
        CellTooltip:SetOwner(config, "ANCHOR_NONE")

        local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = unpack(Cell.vars.currentLayoutTable[unit]
            ["tooltipPosition"])
        P:Point(CellTooltip, tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)

        CellTooltip:AddLine(L[configTitle])

        -- Execute additional logic passed to the function
        if type(onEnterLogic) == "function" then
            onEnterLogic(CellTooltip)
        end

        CellTooltip:Show()
    end)
    config:HookScript("OnLeave", function()
        hoverFrame:GetScript("OnLeave")(hoverFrame)
        CellTooltip:Hide()
    end)

    return frame, anchorFrame, hoverFrame, config
end

function B:UpdateUnitButtonPosition(unit, button, anchorFrame)
    local layout = Cell.vars.currentLayoutTable

    local anchor
    if layout[unit]["sameSizeAsPlayer"] then
        anchor = layout["player"]["anchor"]
    else
        anchor = layout[unit]["anchor"]
    end

    button:ClearAllPoints()
    -- NOTE: detach from PreviewAnchor
    P:LoadPosition(anchorFrame, layout[unit]["position"])

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)

        if anchor == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            B:SaveTooltipPosition(unit, "TOPLEFT", "BOTTOMLEFT", 0, -3)
        elseif anchor == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            B:SaveTooltipPosition(unit, "TOPRIGHT", "BOTTOMRIGHT", 0, -3)
        elseif anchor == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            B:SaveTooltipPosition(unit, "BOTTOMLEFT", "TOPLEFT", 0, 3)
        elseif anchor == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            B:SaveTooltipPosition(unit, "BOTTOMRIGHT", "TOPRIGHT", 0, 3)
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            B:SaveTooltipPosition(unit, "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0)
        elseif anchor == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            B:SaveTooltipPosition(unit, "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0)
        elseif anchor == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            B:SaveTooltipPosition(unit, "TOPRIGHT", "TOPLEFT", -3, 0)
        elseif anchor == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            B:SaveTooltipPosition(unit, "TOPLEFT", "TOPRIGHT", 3, 0)
        end
    end
end

function B:UpdateUnitButtonLayout(unit, which, button, anchorFrame)
    local layout = Cell.vars.currentLayoutTable

    -- Size
    if not which or strfind(which, "size$") then
        local width, height
        if layout[unit]["sameSizeAsPlayer"] then
            width, height = unpack(layout["player"]["size"])
        else
            width, height = unpack(layout[unit]["size"])
        end

        P:Size(button, width, height)
    end

    -- Anchor points
    if not which or strfind(which, "arrangement$") then
        local anchor
        if layout[unit]["sameSizeAsPlayer"] then
            anchor = layout["player"]["anchor"]
        else
            anchor = layout[unit]["anchor"]
        end

        -- anchors
        local anchorPoint
        if anchor == "BOTTOMLEFT" then
            anchorPoint = "TOPLEFT"
        elseif anchor == "BOTTOMRIGHT" then
            anchorPoint = "TOPRIGHT"
        elseif anchor == "TOPLEFT" then
            anchorPoint = "BOTTOMLEFT"
        elseif anchor == "TOPRIGHT" then
            anchorPoint = "BOTTOMRIGHT"
        end

        button:ClearAllPoints()
        button:SetPoint(anchor, anchorFrame, anchorPoint, 0)

        B:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    --[[ if not which or which == "barOrientation" then
        B:SetOrientation(button, layout["barOrientation"][1], layout["barOrientation"][2])
    end ]]

    --[[ if not which or strfind(which, "power$") or which == "barOrientation" then
        if layout[unit]["sameSizeAsPlayer"] then
            B:SetPowerSize(button, layout["player"]["powerSize"])
        else
            B:SetPowerSize(button, layout[unit]["powerSize"])
        end
    end ]]

    -- load position
    if not P:LoadPosition(anchorFrame, layout[unit]["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end

function B:UpdateUnitButtonMenu(which, unit, button, anchorFrame, config)
    if not which or which == "lock" then
        if CellDB["general"]["locked"] then
            config:RegisterForDrag()
        else
            config:RegisterForDrag("LeftButton")
        end
    end

    if not which or which == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            anchorFrame.fadeOut:Play()
        else
            anchorFrame.fadeIn:Play()
        end
    end

    if which == "position" then
        B:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end
end

function B:UpdateUnitFrameVisibility(which, unit, button, frame)
    if not which or which == unit then
        if Cell.vars.currentLayoutTable[unit]["enabled"] then
            RegisterUnitWatch(button)
            frame:Show()
            --F:HideBlizzardUnitFrame(unit)
        else
            UnregisterUnitWatch(button)
            frame:Hide()
        end
    end
end

-------------------------------------------------
-- MARK: Aura tables
-------------------------------------------------
local function InitAuraTables(self)
    -- vars
    self._casts = {}
    self._timers = {}

    -- for icon animation only
    self._buffs_cache = {}
    self._buffs_count_cache = {}
end

local function ResetAuraTables(self)
    wipe(self._casts)
    wipe(self._timers)
    wipe(self._buffs_cache)
    wipe(self._buffs_count_cache)
end

-- MARK: Update Name

local function UnitFrame_UpdateName(self)
    local unit = self.states.unit
    if not unit then return end

    self.states.name = UnitName(unit)
    self.states.fullName = F:UnitFullName(unit)
    self.states.class = UnitClassBase(unit)
    self.states.guid = UnitGUID(unit)
    self.states.isPlayer = UnitIsPlayer(unit)

    self.widgets.nameText:UpdateName()
end

local function UnitFrame_UpdateNameColor(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    self.class = UnitClassBase(unit) --! update class or it may be nil

    if not Cell.vars.currentLayoutTable[unit] then
        self.widgets.nameText:SetTextColor(1, 1, 1)
        return
    end

    if not UnitIsConnected(unit) then
        self.widgets.nameText:SetTextColor(F:GetClassColor(self.class))
    else
        if Cell.vars.currentLayoutTable[unit].widgets.name.color.type == "class_color" then
            self.widgets.nameText:SetTextColor(F:GetClassColor(self.class))
        else
            self.widgets.nameText:SetTextColor(unpack(Cell.vars.currentLayoutTable[unit].widgets.name.color.rgb))
        end
    end
end

-- MARK: Update Health bar

local function UnitFrame_UpdateHealthColor(self)
    local unit = self.states.unit
    if not unit then return end

    self.states.class = UnitClassBase(unit) --! update class

    local barR, barG, barB
    local lossR, lossG, lossB
    local barA, lossA = 1, 1

    if Cell.loaded then
        barA = CellDB["appearance"]["barAlpha"]
        lossA = CellDB["appearance"]["lossAlpha"]
    end

    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then -- player
        if not UnitIsConnected(unit) then
            barR, barG, barB = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        elseif UnitIsCharmed(unit) then
            barR, barG, barB, barA = 0.5, 0, 1, 1
            lossR, lossG, lossB, lossA = barR * 0.2, barG * 0.2, barB * 0.2, 1
        elseif self.states.inVehicle then
            barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent,
                self.states.isDeadOrGhost or self.states.isDead, 0, 1, 0.2)
        else
            barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent,
                self.states.isDeadOrGhost or self.states.isDead, F:GetClassColor(self.states.class))
        end
    elseif F:IsPet(self.states.guid, self.states.unit) then -- pet
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent,
            self.states.isDeadOrGhost or self.states.isDead, 0.5, 0.5, 1)
    else -- npc
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent,
            self.states.isDeadOrGhost or self.states.isDead, 0, 1, 0.2)
    end

    self.widgets.healthBar:SetStatusBarColor(barR, barG, barB, barA)
    self.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, lossA)

    --[[ if Cell.loaded and CellDB["appearance"]["healPrediction"][2] then
        self.widgets.incomingHeal:SetVertexColor(CellDB["appearance"]["healPrediction"][3][1], CellDB["appearance"]["healPrediction"][3][2], CellDB["appearance"]["healPrediction"][3][3], CellDB["appearance"]["healPrediction"][3][4])
    else
        self.widgets.incomingHeal:SetVertexColor(barR, barG, barB, 0.4)
    end ]]
end

local function UpdateUnitHealthState(self, diff)
    local unit = self.states.displayedUnit

    local health = UnitHealth(unit) + (diff or 0)
    local healthMax = UnitHealthMax(unit)
    health = min(health, healthMax) --! diff

    self.states.health = health
    self.states.healthMax = healthMax
    self.states.totalAbsorbs = UnitGetTotalAbsorbs(unit)

    if healthMax == 0 then
        self.states.healthPercent = 0
    else
        self.states.healthPercent = health / healthMax
    end

    self.states.wasDead = self.states.isDead
    self.states.isDead = health == 0
    if self.states.wasDead ~= self.states.isDead then
        --UnitButton_UpdateStatusText(self)
        --I.UpdateStatusIcon_Resurrection(self)
        if not self.states.isDead then
            self.states.hasSoulstone = nil
            --I.UpdateStatusIcon(self)
        end
    end

    self.states.wasDeadOrGhost = self.states.isDeadOrGhost
    self.states.isDeadOrGhost = UnitIsDeadOrGhost(unit)
    if self.states.wasDeadOrGhost ~= self.states.isDeadOrGhost then
        --I.UpdateStatusIcon_Resurrection(self)
        UnitFrame_UpdateHealthColor(self)
    end

    --[[ if enabledIndicators["healthText"] and healthMax ~= 0 then
        if indicatorBooleans["healthText"] then
            if health == healthMax or self.states.isDeadOrGhost or self.states.isDead then
                self.indicators.healthText:Hide()
            else
                self.indicators.healthText:SetValue(health, healthMax, self.states.totalAbsorbs)
                self.indicators.healthText:Show()
            end
        else
            self.indicators.healthText:SetValue(health, healthMax, self.states.totalAbsorbs)
            self.indicators.healthText:Show()
        end
    else
        self.indicators.healthText:Hide()
    end ]]
end

local function UnitFrame_UpdateHealth(self, diff)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self, diff)
    local healthPercent = self.states.healthPercent

    if barAnimationType == "Flash" then
        self.widgets.healthBar:SetValue(self.states.health)
        local diff = healthPercent - (self.states.healthPercentOld or healthPercent)
        if diff >= 0 or self.states.healthMax == 0 then
            B:HideFlash(self)
        elseif diff <= -0.05 and diff >= -1 then --! player (just joined) UnitHealthMax(unit) may be 1 ====> diff == -maxHealth
            B:ShowFlash(self, abs(diff))
        end
    else
        self.widgets.healthBar:SetValue(self.states.health)
    end

    if Cell.vars.useGradientColor or Cell.vars.useFullColor then
        UnitButton_UpdateHealthColor(self)
    end

    self.states.healthPercentOld = healthPercent

    --[[ self.widgets.healthBar:SetValue(UnitHealth(unit)) ]]

    if UnitIsDeadOrGhost(unit) then
        self.widgets.deadTex:Show()
    else
        self.widgets.deadTex:Hide()
    end
end

local function UnitFrame_UpdateHealthMax(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)

    if barAnimationType == "Smooth" then
        self.widgets.healthBar:SetMinMaxSmoothedValue(0, self.states.healthMax)
    else
        self.widgets.healthBar:SetMinMaxValues(0, self.states.healthMax)
    end

    if Cell.vars.useGradientColor or Cell.vars.useFullColor then
        UnitButton_UpdateHealthColor(self)
    end
end

-- MARK: Update InRange
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
                        A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
                    end
                else
                    A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                end
            else
                A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
            end
        end
        self.states.wasInRange = inRange
    end
end

-------------------------------------------------
-- MARK: Update All
-------------------------------------------------
local function UnitFrame_UpdateAll(self)
    if not self:IsVisible() then return end

    UnitFrame_UpdateName(self)
    UnitFrame_UpdateNameColor(self)
    UnitFrame_UpdateHealthMax(self)
    UnitFrame_UpdateHealth(self)
    UnitFrame_UpdateHealthColor(self)
    --UnitFrame_UpdateTarget(self)
    UnitFrame_UpdateInRange(self)
    --[[
    UnitFrame_UpdateAuras(self) ]]
end

local function UnitFrame_RegisterEvents(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")

    self:RegisterEvent("UNIT_POWER_FREQUENT")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_DISPLAYPOWER")

    self:RegisterEvent("UNIT_AURA")
    --self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    self:RegisterEvent("UNIT_HEAL_PREDICTION")
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self:RegisterEvent("UNIT_EXITED_VEHICLE")

    self:RegisterEvent("UNIT_CONNECTION")       -- offline
    self:RegisterEvent("PLAYER_FLAGS_CHANGED")  -- afk
    self:RegisterEvent("UNIT_NAME_UPDATE")      -- unknown target
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    --[[ if Cell.loaded then
        if enabledIndicators["playerRaidIcon"] then
            self:RegisterEvent("RAID_TARGET_UPDATE")
        end
        if enabledIndicators["targetRaidIcon"] then
            self:RegisterEvent("UNIT_TARGET")
        end
        if enabledIndicators["readyCheckIcon"] then
            self:RegisterEvent("READY_CHECK")
            self:RegisterEvent("READY_CHECK_FINISHED")
            self:RegisterEvent("READY_CHECK_CONFIRM")
        end
    else
        self:RegisterEvent("RAID_TARGET_UPDATE")
        self:RegisterEvent("UNIT_TARGET")
        self:RegisterEvent("READY_CHECK")
        self:RegisterEvent("READY_CHECK_FINISHED")
        self:RegisterEvent("READY_CHECK_CONFIRM")
    end ]]

    local success, result = pcall(UnitFrame_UpdateAll, self)
    if not success then
        F:Debug("UnitFrame_UpdateAll |cffff0000FAILED:|r", self:GetName(), result)
    end
end

local function UnitFrame_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

-------------------------------------------------
-- MARK: OnEvent
-------------------------------------------------
local function UnitFrame_OnEvent(self, event, unit, arg, arg2)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if event == "UNIT_AURA" then
            --[[ UnitFrame_UpdateAuras(self, arg) ]]
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            --UnitFrame_UpdateCasts(self, arg2)
        elseif event == "UNIT_HEALTH" then
            UnitFrame_UpdateHealth(self)
        elseif event == "UNIT_MAXHEALTH" then
            UnitFrame_UpdateHealthMax(self)
            UnitFrame_UpdateHealth(self)
        elseif event == "UNIT_CONNECTION" then
            self._updateRequired = 1
        elseif event == "UNIT_NAME_UPDATE" then
            UnitFrame_UpdateName(self)
            UnitFrame_UpdateNameColor(self)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            UnitFrame_UpdateInRange(self, arg)
        end
    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = 1
        elseif event == "PLAYER_TARGET_CHANGED" then
            --[[ UnitFrame_UpdateTarget(self) ]]
        end
    end
end

local function UnitFrame_OnShow(self)
    CUF:Debug(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent UnitFrame_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    self._powerBarUpdateRequired = 1
    UnitFrame_RegisterEvents(self)
end

local function UnitFrame_OnHide(self)
    CUF:Debug(GetTime(), "OnHide", self:GetName())
    UnitFrame_UnregisterEvents(self)
    ResetAuraTables(self)

    -- NOTE: update Cell.vars.guids
    -- CUF:Debug("hide", self.states.unit, self.__unitGuid, self.__unitName)
    if self.__unitGuid then
        if not self.isSpotlight then Cell.vars.guids[self.__unitGuid] = nil end
        self.__unitGuid = nil
    end
    if self.__unitName then
        if not self.isSpotlight then Cell.vars.names[self.__unitName] = nil end
        self.__unitName = nil
    end
    self.__displayedGuid = nil
    F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
end

local function UnitFrame_OnEnter(self)
    --if not IsEncounterInProgress() then UnitButton_UpdateStatusText(self) end

    --if highlightEnabled then self.widgets.mouseoverHighlight:Show() end

    local unit = self.states.displayedUnit
    if not unit then return end

    F:ShowTooltips(self, "unit", unit)
end

local function UnitFrame_OnLeave(self)
    self.widgets.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

local UNKNOWN = _G["UNKNOWN"]
local UNKNOWNOBJECT = _G["UNKNOWNOBJECT"]
local function UnitFrame_OnTick(self)
    -- CUF:Debug(GetTime(), "OnTick", self._updateRequired, self:GetAttribute("refreshOnUpdate"), self:GetName())
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0

        if self.states.unit and self.states.displayedUnit then
            local displayedGuid = UnitGUID(self.states.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                self._updateRequired = 1
                self._powerBarUpdateRequired = 1
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- CUF:Debug("guidChanged:", self:GetName(), self.states.unit, guid)
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

local function UnitFrame_OnUpdate(self, elapsed)
    local e = (self.__updateElapsed or 0) + elapsed
    if e > 0.25 then
        UnitFrame_OnTick(self)
        e = 0
    end
    self.__updateElapsed = e
end

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

            ResetAuraTables(self)
        end
    end
end

-- ----------------------------------------------------------------------- --
-- MARK:                                 OnLoad                            --
-- ----------------------------------------------------------------------- --
function CUFUnitButton_OnLoad(button)
    local buttonName = button:GetName()

    CUF:Debug(buttonName, "OnLoad")
    InitAuraTables(button)

    button.widgets = {}
    button.states = {}
    button.indicators = {}

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

    -- healthBar
    local healthBar = CreateFrame("StatusBar", buttonName .. "HealthBar", button)
    button.widgets.healthBar = healthBar

    healthBar:SetStatusBarTexture(Cell.vars.texture)
    healthBar:SetFrameLevel(button:GetFrameLevel() + 1)
    healthBar:SetPoint("TOPLEFT", button, "TOPLEFT", P:Scale(1), P:Scale(-1))
    healthBar:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", P:Scale(-1), P:Scale(1))

    -- heathLoss
    local healthBarLoss = healthBar:CreateTexture(nil, "ARTWORK", nil, -7)
    button.widgets.healthBarLoss = healthBarLoss
    healthBarLoss:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    healthBarLoss:SetPoint("BOTTOMRIGHT")
    healthBarLoss:SetTexture(Cell.vars.texture)

    -- dead texture
    local deadTex = healthBar:CreateTexture(nil, "OVERLAY")
    button.widgets.deadTex = deadTex
    deadTex:SetAllPoints(healthBar)
    deadTex:SetTexture(Cell.vars.whiteTexture)
    deadTex:SetGradient("VERTICAL", CreateColor(0.545, 0, 0, 1), CreateColor(0, 0, 0, 1))
    deadTex:Hide()

    -- nameText
    local nameText = healthBar:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    button.widgets.nameText = nameText
    nameText.width = { "percentage", 0.75 }
    nameText:ClearAllPoints()
    nameText:SetPoint("CENTER", 0, 0)
    nameText:SetFont("Cell Default", 12, "Outline")

    function nameText:UpdateName()
        local name

        if CELL_NICKTAG_ENABLED and Cell.NickTag then
            name = Cell.NickTag:GetNickname(button.states.name, nil, true)
        end
        name = name or F:GetNickname(button.states.name, button.states.fullName)

        F:UpdateTextWidth(nameText, name, nameText.width, button)
    end

    --[[ -- powerbar
    local powerBar = CreateFrame("StatusBar", buttonName .. "PowerBar", button)
    button.widgets.powerBar = powerBar
    -- P:Point(powerBar, "TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    -- P:Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    powerBar:SetFrameLevel(button:GetFrameLevel() + 2)
    powerBar.SetBarValue = powerBar.SetValue ]]

    -- smooth
    Mixin(healthBar, SmoothStatusBarMixin)
    --Mixin(powerBar, SmoothStatusBarMixin)

    -- targetHighlight
    local targetHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.widgets.targetHighlight = targetHighlight
    targetHighlight:SetIgnoreParentAlpha(true)
    targetHighlight:SetFrameLevel(button:GetFrameLevel() + 2)
    targetHighlight:Hide()

    -- mouseoverHighlight
    local mouseoverHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
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
    CUF:Debug(button:GetName(), "OnLoad end")
end
