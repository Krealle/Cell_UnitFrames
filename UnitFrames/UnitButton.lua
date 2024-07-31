---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs
---@class CUF.constants
local const = CUF.constants

local GetUnitName = GetUnitName
local UnitGUID = UnitGUID

-------------------------------------------------
-- MARK: Unit button
-------------------------------------------------

---@param unit Unit
---@param tooltipPoint AnchorPoint
---@param tooltipRelativePoint AnchorPoint
---@param tooltipX number
---@param tooltipY number
function U:SaveTooltipPosition(unit, tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY)
    Cell.vars.currentLayoutTable[unit]["tooltipPosition"] = { tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY }
end

---@param unit Unit
---@param configTitle string
---@param onEnterLogic function?
---@return CUFUnitFrame Frame
---@return CUFAnchorFrame anchorFrame
---@return CUFHoverFrame Frame
---@return CUFConfigButton config
function U:CreateBaseUnitFrame(unit, configTitle, onEnterLogic)
    local name = unit:gsub("^%l", string.upper)

    ---@class CUFUnitFrame
    local frame = CreateFrame("Frame", "Cell" .. name .. "Frame", Cell.frames.mainFrame, "SecureFrameTemplate")

    -- Anchor
    ---@class CUFAnchorFrame
    local anchorFrame = CreateFrame("Frame", "Cell" .. name .. "AnchorFrame", frame)
    PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)

    -- Hover
    ---@class CUFHoverFrame
    local hoverFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
    hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
    hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
    hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)

    A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

    ---@class CUFConfigButton
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

---@param unit Unit
---@param button CUFUnitButton
---@param anchorFrame CUFAnchorFrame
function U:UpdateUnitButtonPosition(unit, button, anchorFrame)
    local layout = Cell.vars.currentLayoutTable

    local anchor
    if layout[unit]["sameSizeAsPlayer"] then
        anchor = layout[const.UNIT.PLAYER]["anchor"]
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
            U:SaveTooltipPosition(unit, "TOPLEFT", "BOTTOMLEFT", 0, -3)
        elseif anchor == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            U:SaveTooltipPosition(unit, "TOPRIGHT", "BOTTOMRIGHT", 0, -3)
        elseif anchor == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            U:SaveTooltipPosition(unit, "BOTTOMLEFT", "TOPLEFT", 0, 3)
        elseif anchor == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            U:SaveTooltipPosition(unit, "BOTTOMRIGHT", "TOPRIGHT", 0, 3)
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            U:SaveTooltipPosition(unit, "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0)
        elseif anchor == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            U:SaveTooltipPosition(unit, "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0)
        elseif anchor == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            U:SaveTooltipPosition(unit, "TOPRIGHT", "TOPLEFT", -3, 0)
        elseif anchor == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            U:SaveTooltipPosition(unit, "TOPLEFT", "TOPRIGHT", 3, 0)
        end
    end
end

---@param unit Unit
---@param which string?
---@param button CUFUnitButton
---@param anchorFrame CUFAnchorFrame
function U:UpdateUnitButtonLayout(unit, which, button, anchorFrame)
    local layout = Cell.vars.currentLayoutTable

    -- Size
    if not which or strfind(which, "size$") then
        local width, height
        if layout[unit]["sameSizeAsPlayer"] then
            width, height = unpack(layout[const.UNIT.PLAYER]["size"])
        else
            width, height = unpack(layout[unit]["size"])
        end

        P:Size(button, width, height)
    end

    -- Anchor points
    if not which or strfind(which, "arrangement$") then
        local anchor
        if layout[unit]["sameSizeAsPlayer"] then
            anchor = layout[const.UNIT.PLAYER]["anchor"]
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

        U:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        U:SetOrientation(button, layout["barOrientation"][1], layout["barOrientation"][2])
    end

    if not which or strfind(which, "power$") or which == "barOrientation" then
        if layout[unit]["sameSizeAsPlayer"] then
            W:SetPowerSize(button, layout[const.UNIT.PLAYER]["powerSize"])
        else
            W:SetPowerSize(button, layout[unit]["powerSize"])
        end
    end

    -- load position
    if not P:LoadPosition(anchorFrame, layout[unit]["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end

---@param which string?
---@param unit Unit
---@param button CUFUnitButton
---@param anchorFrame CUFAnchorFrame
---@param config CUFConfigButton
function U:UpdateUnitButtonMenu(which, unit, button, anchorFrame, config)
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
        U:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end
end

---@param which string?
---@param unit Unit
---@param button CUFUnitButton
---@param frame CUFUnitFrame
function U:UpdateUnitFrameVisibility(which, unit, button, frame)
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

---@param button CUFUnitButton
---@param orientation string
---@param rotateTexture boolean
function U:SetOrientation(button, orientation, rotateTexture)
    local healthBar = button.widgets.healthBar
    local healthBarLoss = button.widgets.healthBarLoss
    local powerBar = button.widgets.powerBar
    local powerBarLoss = button.widgets.powerBarLoss
    --[[ local incomingHeal = button.widgets.incomingHeal
    local damageFlashTex = button.widgets.damageFlashTex
    local gapTexture = button.widgets.gapTexture
    local shieldBar = button.widgets.shieldBar
    local shieldBarR = button.widgets.shieldBarR
    local overShieldGlow = button.widgets.overShieldGlow
    local overShieldGlowR = button.widgets.overShieldGlowR
    local overAbsorbGlow = button.widgets.overAbsorbGlow
    local absorbsBar = button.widgets.absorbsBar ]]

    button.orientation = orientation
    if orientation == "vertical_health" then
        healthBar:SetOrientation("VERTICAL")
        powerBar:SetOrientation("HORIZONTAL")
    else
        healthBar:SetOrientation(orientation)
        powerBar:SetOrientation(orientation)
    end
    healthBar:SetRotatesTexture(rotateTexture)
    powerBar:SetRotatesTexture(rotateTexture)

    if rotateTexture then
        F:RotateTexture(healthBarLoss, 90)
        F:RotateTexture(powerBarLoss, 90)
    else
        F:RotateTexture(healthBarLoss, 0)
        F:RotateTexture(powerBarLoss, 0)
    end

    if orientation == "horizontal" then
        -- update healthBarLoss
        P:ClearPoints(healthBarLoss)
        P:Point(healthBarLoss, "TOPRIGHT", healthBar)
        P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update powerBarLoss
        P:ClearPoints(powerBarLoss)
        P:Point(powerBarLoss, "TOPRIGHT", powerBar)
        P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    else -- vertical / vertical_health
        P:ClearPoints(healthBarLoss)
        P:Point(healthBarLoss, "TOPRIGHT", healthBar)
        P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")

        if orientation == "vertical" then
            -- update powerBarLoss
            P:ClearPoints(powerBarLoss)
            P:Point(powerBarLoss, "TOPRIGHT", powerBar)
            P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "TOPLEFT")
        else -- vertical_health
            -- update powerBarLoss
            P:ClearPoints(powerBarLoss)
            P:Point(powerBarLoss, "TOPRIGHT", powerBar)
            P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
        end
    end

    -- update actions
    --I.UpdateActionsOrientation(button, orientation)
end

-------------------------------------------------
-- MARK: Aura tables
-------------------------------------------------
---@param self CUFUnitButton
local function InitAuraTables(self)
    -- vars
    self._casts = {}
    self._timers = {}

    -- for icon animation only
    self._buffs_cache = {}
    self._buffs_count_cache = {}
end

---@param self CUFUnitButton
local function ResetAuraTables(self)
    wipe(self._casts)
    wipe(self._timers)
    wipe(self._buffs_cache)
    wipe(self._buffs_count_cache)
end

-- MARK: Update InRange
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
    --[[
    UnitFrame_UpdateAuras(self) ]]

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
-- MARK: RegisterEvents
-------------------------------------------------

---@param self CUFUnitButton
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

    if self.states.unit == const.UNIT.TARGET then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
    if self.states.unit == const.UNIT.FOCUS then
        self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end

    self:RegisterEvent("UNIT_NAME_UPDATE")

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
---@param arg any
---@param arg2 any
local function UnitFrame_OnEvent(self, event, unit, arg, arg2)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if event == "UNIT_AURA" then
            --[[ UnitFrame_UpdateAuras(self, arg) ]]
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            --UnitFrame_UpdateCasts(self, arg2)
        elseif event == "UNIT_HEALTH" then
            U:UnitFrame_UpdateHealth(self)
        elseif event == "UNIT_MAXHEALTH" then
            U:UnitFrame_UpdateHealthMax(self)
            U:UnitFrame_UpdateHealth(self)
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
            UnitFrame_UpdateInRange(self, arg)
        elseif event == "UNIT_NAME_UPDATE" then
            U:UnitFrame_UpdatePowerTextColor(self)
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
        end
    end
end

---@param self CUFUnitButton
local function UnitFrame_OnShow(self)
    --CUF:Debug(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent UnitFrame_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    self._powerBarUpdateRequired = true
    UnitFrame_RegisterEvents(self)
end

---@param self CUFUnitButton
local function UnitFrame_OnHide(self)
    --CUF:Debug(GetTime(), "OnHide", self:GetName())
    UnitFrame_UnregisterEvents(self)
    ResetAuraTables(self)

    -- NOTE: update Cell.vars.guids
    -- CUF:Debug("hide", self.states.unit, self.__unitGuid, self.__unitName)
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

---@param self CUFUnitButton
local function UnitFrame_OnEnter(self)
    --if not IsEncounterInProgress() then UnitButton_UpdateStatusText(self) end

    --if highlightEnabled then self.widgets.mouseoverHighlight:Show() end

    local unit = self.states.displayedUnit
    if not unit then return end

    F:ShowTooltips(self, "unit", unit)
end

---@param self CUFUnitButton
local function UnitFrame_OnLeave(self)
    self.widgets.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

local UNKNOWN = _G["UNKNOWN"]
local UNKNOWNOBJECT = _G["UNKNOWNOBJECT"]

---@param self CUFUnitButton
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
                self._updateRequired = true
                self._powerBarUpdateRequired = true
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

            ResetAuraTables(self)
        end
    end
end

-- ----------------------------------------------------------------------- --
-- MARK:                                 OnLoad                            --
-- ----------------------------------------------------------------------- --
---@param button CUFUnitButton
function CUFUnitButton_OnLoad(button)
    local buttonName = button:GetName()
    --CUF:Debug(buttonName, "OnLoad")

    InitAuraTables(button)

    ---@diagnostic disable-next-line: missing-fields
    button.widgets = {}
    ---@diagnostic disable-next-line: missing-fields
    button.states = {}
    --button.indicators = {}

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
    W:CreateHealthBar(button, buttonName)
    W:CreateNameText(button)
    W:CreatePowerBar(button, buttonName)
    W:CreateHealthText(button)
    W:CreatePowerText(button)

    -- targetHighlight
    ---@class HighlightWidget
    local targetHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.widgets.targetHighlight = targetHighlight
    targetHighlight:SetIgnoreParentAlpha(true)
    targetHighlight:SetFrameLevel(button:GetFrameLevel() + 2)
    targetHighlight:Hide()

    -- mouseoverHighlight
    ---@class HighlightWidget
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
    --CUF:Debug(button:GetName(), "OnLoad end")
end
