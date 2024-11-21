---@class CUF
local CUF = select(2, ...)

local F = Cell.funcs
local L = CUF.L

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler
local P = CUF.PixelPerfect

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.CAST_BAR,
    Builder.MenuOptions.CastBarGeneral,
    Builder.MenuOptions.CastBarEmpower,
    Builder.MenuOptions.CastBarTimer,
    Builder.MenuOptions.CastBarSpell,
    Builder.MenuOptions.CastBarSpark,
    Builder.MenuOptions.CastBarBorder,
    Builder.MenuOptions.CastBarIcon,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateCastBarWidget(button, unit, setting, subSetting, ...)
    local castBar = button.widgets.castBar
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.CAST_BAR, unit)

    if not setting or setting == const.OPTION_KIND.COLOR then
        castBar:SetCastBarColorStyle()
    end
    if not setting or setting == const.OPTION_KIND.USE_CLASS_COLOR then
        castBar.useClassColor = styleTable.useClassColor
    end

    if not setting or setting == const.OPTION_KIND.TIMER then
        castBar.timerText:SetFontStyle(styleTable.timer)
    end
    if not setting or setting == const.OPTION_KIND.TIMER_FORMAT then
        castBar.timerText.format = styleTable.timerFormat
    end
    if not setting or setting == const.OPTION_KIND.SPELL then
        castBar.spellText:SetFontStyle(styleTable.spell)
    end
    if not setting or setting == const.OPTION_KIND.SHOW_SPELL then
        castBar.spellText.enabled = styleTable.showSpell
    end

    if not setting or setting == const.OPTION_KIND.SPARK then
        castBar.spark.enabled = styleTable.spark.enabled
        castBar:SetSparkColor(styleTable.spark)
        castBar:SetSparkWidth(styleTable.spark.width)
    end

    if not setting or setting == const.OPTION_KIND.EMPOWER then
        castBar:SetEmpowerStyle(styleTable.empower)
    end

    if not setting or setting == const.OPTION_KIND.BORDER then
        castBar:SetBorderStyle(styleTable.border)
    end

    if not setting or setting == const.OPTION_KIND.ICON then
        castBar:SetIconOptions(styleTable.icon)
    end

    if not setting or setting == const.OPTION_KIND.REVERSE then
        castBar:SetFillStyle(styleTable.reverse)
    end

    if not setting or setting == const.OPTION_KIND.SPELL_WIDTH then
        castBar.spellText.width = styleTable.spellWidth
    end
    if not setting or setting == const.OPTION_KIND.ONLY_SHOW_INTERRUPT then
        castBar.onlyShowInterrupt = styleTable.onlyShowInterrupt
    end

    castBar.Update(button)
end

Handler:RegisterWidget(W.UpdateCastBarWidget, const.WIDGET_KIND.CAST_BAR)

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param self CastBarWidget
local function ResetAttributes(self)
    self.castID = nil
    self.casting = nil
    self.channeling = nil
    self.empowering = nil
    self.notInterruptible = nil
    self.spellID = nil
    self.spellName = nil
    self.displayName = nil
    self.spellTexture = nil

    self:ClearStages()
end

---@param self CastBarWidget
local function UpdateElements(self)
    self:SetCastBarColor()

    if self.icon then self.icon:SetTexture(self.spellTexture --[[ or FALLBACK_ICON ]]) end
    if self.spark then self.spark:Show() end

    if self.spellText.enabled and not self.empowering then
        local name = self.displayName ~= "" and self.displayName or self.spellName
        self.SetSpellWidth(self.spellText, name, self.spellText.width, self.statusBar)
    elseif not self.spellText.enabled then
        self.spellText:SetText("")
    end

    if self.empowering then
        if self.showEmpowerSpellName then
            local name = self.displayName ~= "" and self.displayName or self.spellName
            self.SetSpellWidth(self.spellText, name, self.spellText.width, self.statusBar)
        else
            self.spellText:SetText("")
        end
    else
        if self.spellText.enabled then
            local name = self.displayName ~= "" and self.displayName or self.spellName
            self.SetSpellWidth(self.spellText, name, self.spellText.width, self.statusBar)
        else
            self.spellText:SetText("")
        end
    end

    if self.timerText then self.timerText:SetText() end

    if self.empowering and self:IsShown() then
        self:UpdatePips()
    end
end

-- Repoint Icon and StatusBar
---@param self CastBarWidget
local function RepointCastBar(self)
    local bar = self.statusBar
    local icon = self.icon

    P.ClearPoints(bar)
    if not icon.enabled then
        icon:Hide()
        P.Point(bar, "TOPLEFT", self, "TOPLEFT")
        P.Point(bar, "BOTTOMRIGHT", self, "BOTTOMRIGHT")

        self:UpdateElements()
        return
    end

    local barHeight = self:GetHeight()
    icon:SetSize(barHeight, barHeight)
    icon:Show()

    P.ClearPoints(icon)
    if icon.position == "left" then
        P.Point(icon, "TOPLEFT", self, "TOPLEFT")

        P.Point(bar, "TOPLEFT", icon, "TOPRIGHT")
        P.Point(bar, "BOTTOMRIGHT", self, "BOTTOMRIGHT")
    else
        P.Point(icon, "TOPRIGHT", self, "TOPRIGHT")

        P.Point(bar, "TOPLEFT", self, "TOPLEFT")
        P.Point(bar, "BOTTOMRIGHT", icon, "BOTTOMLEFT")
    end
end

---@param self CastBarWidget
---@param reversed boolean
local function SetFillStyle(self, reversed)
    if reversed then
        self.statusBar:SetFillStyle("REVERSE")
    else
        self.statusBar:SetFillStyle("STANDARD")
    end
    self:SetSparkWidth()
end

---@param button CUFUnitButton
---@param unit UnitToken
local function ShouldShow(button, unit)
    return button.states.unit == unit
end

---@param button CUFUnitButton
---@param event ("UNIT_SPELLCAST_START" | "UNIT_SPELLCAST_CHANNEL_START" | "UNIT_SPELLCAST_EMPOWER_START")?
---@param unit UnitToken
---@param castGUID WOWGUID?
function CastStart(button, event, unit, castGUID,...)
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    local name, displayName, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID =
        UnitCastingInfo(unit)

    local numStages, _
    event = event or "UNIT_SPELLCAST_START"
    if not name then
        name, displayName, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages =
            UnitChannelInfo(unit)
        event = (numStages and numStages > 0) and "UNIT_SPELLCAST_EMPOWER_START" or "UNIT_SPELLCAST_CHANNEL_START"
    end

    -- In era UnitChannelInfo does not return information for some unit token (e.g. target)
    -- if we actually want this we currently need to fake it
    if CUF.vars.isVanilla then    
        if not name then
            spellID = ...            
            if spellID then
                local spellChannelDuration = CUF.Util:GetSpellChannelDuration(spellID)
                if spellChannelDuration ~= 0 then
                    local spellInfo = C_Spell.GetSpellInfo(spellID);
                    name = spellInfo.name
                    displayName = L.Channeling
                    texture = spellInfo.originalIconID
                    local fakeTime = (GetTime()*1000)
                    startTime, endTime = fakeTime, fakeTime + spellChannelDuration
                    isTradeSkill, notInterruptible = false, nil
                end                
            end
        end    
    end

    if (not name) or (castBar.onlyShowInterrupt and notInterruptible) then
        castBar:ResetAttributes()
        castBar:Hide()

        return
    end

    castBar.casting = event == "UNIT_SPELLCAST_START"
    castBar.channeling = event == "UNIT_SPELLCAST_CHANNEL_START"

    if CUF.vars.isRetail then
        castBar.empowering = event == "UNIT_SPELLCAST_EMPOWER_START"
        if castBar.empowering then
            endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
        end
    end

    castBar:ClearStages()

    endTime = endTime / 1000
    startTime = startTime / 1000

    castBar.max = endTime - startTime
    castBar.startTime = startTime

    castBar.notInterruptible = notInterruptible
    castBar.castID = castID
    castBar.spellID = spellID
    castBar.spellName = name
    castBar.displayName = displayName
    castBar.spellTexture = texture

    if castBar.channeling then
        castBar.duration = endTime - GetTime()
    else
        castBar.duration = GetTime() - startTime
    end

    castBar:SetMinMaxValues(0, castBar.max)
    castBar:SetValue(castBar.duration)

    castBar:UpdateElements()

    castBar:Show()

    if CUF.vars.isRetail and castBar.empowering then
        castBar:AddStages(numStages)
    end
end

---@param button CUFUnitButton
---@param event "UNIT_SPELLCAST_DELAYED"|"UNIT_SPELLCAST_CHANNEL_UPDATE"|"UNIT_SPELLCAST_EMPOWER_UPDATE"
---@param unit UnitToken
---@param castID WOWGUID
---@param spellID number
function CastUpdate(button, event, unit, castID, spellID)
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    if not castBar:IsShown()
        or castBar.castID ~= castID
        or castBar.spellID ~= spellID then
        return
    end

    local name, startTime, endTime, _, notInterruptible
    if (event == "UNIT_SPELLCAST_DELAYED") then
        name, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
    else
        name, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
    end

    if castBar.onlyShowInterrupt and notInterruptible then
        castBar:ResetAttributes()
        castBar:Hide()

        return
    end

    if (not name) then return end

    if castBar.empowering then
        endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
    end

    endTime = endTime / 1000
    startTime = startTime / 1000

    if (castBar.channeling) then
        castBar.duration = endTime - GetTime()
    else
        castBar.duration = GetTime() - startTime
    end

    castBar.max = endTime - startTime
    castBar.startTime = startTime

    castBar:SetMinMaxValues(0, castBar.max)
    castBar:SetValue(castBar.duration)
    castBar:SetCastBarColor()
end

---@param button CUFUnitButton
---@param event "UNIT_SPELLCAST_STOP"|"UNIT_SPELLCAST_CHANNEL_STOP"|"UNIT_SPELLCAST_EMPOWER_STOP"
---@param unit UnitToken
---@param castID WOWGUID
---@param spellID number
---@param complete boolean?
function CastStop(button, event, unit, castID, spellID, complete)
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    if not castBar:IsShown()
        or castBar.castID ~= castID
        or castBar.spellID ~= spellID then
        return
    end

    castBar:ResetAttributes()
end

---@param button CUFUnitButton
---@param event "UNIT_SPELLCAST_FAILED"|"UNIT_SPELLCAST_INTERRUPTED"
---@param unit UnitToken
---@param castID WOWGUID
---@param spellID number
function CastFail(button, event, unit, castID, spellID)
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    if not castBar:IsShown()
        or castBar.castID ~= castID
        or castBar.spellID ~= spellID then
        return
    end

    castBar:ResetAttributes()
end

-------------------------------------------------
-- MARK: OnUpdate
-------------------------------------------------

---@param self CastBarWidget
---@param elapsed number
local function onUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if (self.casting or self.channeling or self.empowering) then
        local isCasting = self.casting or self.empowering
        if (isCasting) then
            self.duration = self.duration + elapsed
            if (self.duration >= self.max) then
                self:ResetAttributes()
                self:Hide()

                return
            end
        else
            self.duration = self.duration - elapsed
            if (self.duration <= 0) then
                self:ResetAttributes()
                self:Hide()

                return
            end
        end

        self:SetValue(self.duration)

        if self.elapsed >= .01 then
            self.elapsed = 0

            local timerFormat = self.timerText.format
            if timerFormat == const.CastBarTimerFormat.HIDDEN then
                self.timerText:SetText("")
                return
            end

            if self.empowering then
                self.timerText:SetFormattedText("%d", self.CurStage)
            elseif timerFormat == const.CastBarTimerFormat.DURATION then
                local dur = self.duration
                if self.channeling then
                    dur = (self.max - self.duration)
                end
                self.timerText:SetFormattedText("%.1f", dur)
            elseif timerFormat == const.CastBarTimerFormat.DURATION_AND_MAX then
                local dur = self.duration
                if self.channeling then
                    dur = (self.max - self.duration)
                end
                self.timerText:SetFormattedText("%.1f / %.1f", dur, self.max)
            elseif timerFormat == const.CastBarTimerFormat.REMAINING then
                local dur = self.duration
                if not self.channeling then
                    dur = (self.max - self.duration)
                end
                self.timerText:SetFormattedText("%.1f", dur)
            elseif timerFormat == const.CastBarTimerFormat.REMAINING_AND_MAX then
                local dur = self.duration
                if not self.channeling then
                    dur = (self.max - self.duration)
                end
                self.timerText:SetFormattedText("%.1f / %.1f", dur, self.max)
            elseif self.channeling then
                self.timerText:SetFormattedText("%.1f", self.duration)
            else
                self.timerText:SetFormattedText("%.1f", (self.max - self.duration))
            end

            if (self.empowering) then
                self:OnUpdateStage()
            end
        end
    else
        self:ResetAttributes()
        self:Hide()
    end
end

-------------------------------------------------
-- MARK: UpdateCastBar
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
    local castBar = button.widgets.castBar
    if not castBar then return end

    castBar:ResetAttributes()

    if not castBar.enabled then
        return
    end

    CastStart(button, nil, button.states.unit)
end

-- Register/Unregister events for CastBar
---@param self CastBarWidget
local function Enable(self)
    local button = self._owner

    button:AddEventListener("UNIT_SPELLCAST_START", CastStart)
    button:AddEventListener("UNIT_SPELLCAST_CHANNEL_START", CastStart)
    button:AddEventListener("UNIT_SPELLCAST_STOP", CastStop)
    button:AddEventListener("UNIT_SPELLCAST_CHANNEL_STOP", CastStop)
    button:AddEventListener("UNIT_SPELLCAST_DELAYED", CastUpdate)
    button:AddEventListener("UNIT_SPELLCAST_CHANNEL_UPDATE", CastUpdate)
    button:AddEventListener("UNIT_SPELLCAST_FAILED", CastFail)
    button:AddEventListener("UNIT_SPELLCAST_INTERRUPTED", CastFail)

    if CUF.vars.isRetail and button.states.class == "EVOKER" then
        button:AddEventListener("UNIT_SPELLCAST_EMPOWER_START", CastStart)
        button:AddEventListener("UNIT_SPELLCAST_EMPOWER_STOP", CastStop)
        button:AddEventListener("UNIT_SPELLCAST_EMPOWER_UPDATE", CastUpdate)
    end

    self:SetScript("OnUpdate", onUpdate)

    return true
end

---@param self CastBarWidget
local function Disable(self)
    local button = self._owner

    button:RemoveEventListener("UNIT_SPELLCAST_START", CastStart)
    button:RemoveEventListener("UNIT_SPELLCAST_CHANNEL_START", CastStart)
    button:RemoveEventListener("UNIT_SPELLCAST_STOP", CastStop)
    button:RemoveEventListener("UNIT_SPELLCAST_CHANNEL_STOP", CastStop)
    button:RemoveEventListener("UNIT_SPELLCAST_DELAYED", CastUpdate)
    button:RemoveEventListener("UNIT_SPELLCAST_CHANNEL_UPDATE", CastUpdate)
    button:RemoveEventListener("UNIT_SPELLCAST_FAILED", CastFail)
    button:RemoveEventListener("UNIT_SPELLCAST_INTERRUPTED", CastFail)

    if CUF.vars.isRetail then
        button:RemoveEventListener("UNIT_SPELLCAST_EMPOWER_START", CastStart)
        button:RemoveEventListener("UNIT_SPELLCAST_EMPOWER_STOP", CastStop)
        button:RemoveEventListener("UNIT_SPELLCAST_EMPOWER_UPDATE", CastUpdate)
    end

    self:SetScript("OnUpdate", nil)
end

-------------------------------------------------
-- MARK: Stages
-------------------------------------------------

-- NOTE: these constants are defined in the CastingBarFrame.lua file
local CASTBAR_STAGE_INVALID = -1
local CASTBAR_STAGE_DURATION_INVALID = -1

-- Create a pip with overlay texture and hidden art line
---@param self CastBarWidget
---@param stage number
---@return Pip
local function CreatePip(self, stage)
    ---@class Pip: Frame
    ---@field BasePip Frame
    local pip = CreateFrame("Frame", nil, self.statusBar, "CastingBarFrameStagePipTemplate")
    pip.stage = stage

    -- Hide the art line
    pip.BasePip:SetAlpha(0)

    pip.texture = pip:CreateTexture(nil, "OVERLAY")
    pip.texture:SetAllPoints()

    return pip
end

---@param self CastBarWidget
---@param stage number
---@return Pip
local function GetPip(self, stage)
    local pip = self.StagePips[stage]
    if not pip then
        pip = self:CreatePip(stage)
        self.StagePips[stage] = pip
    end

    return pip
end

-- Get the color for a stage
---@param self CastBarWidget
---@param stage number
---@return number r
---@return number g
---@return number b
---@return number a
local function GetStageColor(self, stage)
    if self.useFullyCharged and stage == self.NumStages then
        stage = #self.PipColorMap
    end

    return unpack(self.PipColorMap[stage])
end

-- Point pip to the next pip or the castbar
---@param self CastBarWidget
---@param pip Pip
local function RepointPip(self, pip)
    local reversed = self.statusBar:GetReverseFill()

    local point = reversed and "LEFT" or "RIGHT"
    local relativePoint = reversed and "RIGHT" or "LEFT"

    if pip.stage < self.NumStages then
        P.Point(pip, point, self:GetPip(pip.stage + 1), relativePoint, 0, 0)
    else
        P.Point(pip, point, self.statusBar, point, 0, 0)
    end
end

-- Update pip texture/color
---@param self CastBarWidget
---@param pip Pip
local function UpdatePipTexture(self, pip)
    pip.texture:SetTexture(self.statusBar:GetStatusBarTexture():GetTexture())
    pip.texture:SetVertexColor(self:GetStageColor(pip.stage))
end

-- Repoint and update pip textures of all pips
---@param self CastBarWidget
local function UpdatePips(self)
    for stage = 0, self.NumStages do
        local pip = self:GetPip(stage)
        self:UpdatePipTexture(pip)
        self:RepointPip(pip)
    end
end

-- Add stages to the castbar
---@param self CastBarWidget
local function AddStages(self, numStages)
    local castBar = self.statusBar
    local reversed = castBar:GetReverseFill()

    local stageTotalDuration = 0
    local stageMaxValue = self.max * 1000
    local castBarWidth = castBar:GetWidth()
    self.NumStages = numStages
    self.CurStage = CASTBAR_STAGE_INVALID

    for stage = 1, numStages do
        local duration
        if (stage > numStages) then
            duration = GetUnitEmpowerHoldAtMaxTime(self._owner.states.unit)
        else
            duration = GetUnitEmpowerStageDuration(self._owner.states.unit, stage - 1)
        end

        if (duration > CASTBAR_STAGE_DURATION_INVALID) then
            stageTotalDuration = stageTotalDuration + duration
            self.StagePoints[stage] = stageTotalDuration

            local portion = stageTotalDuration / stageMaxValue
            local offset = castBarWidth * portion

            local pip = self:GetPip(stage)
            P.ClearPoints(pip)
            pip:Show()

            if reversed then
                -- Left to right
                P.Point(pip, "TOPRIGHT", castBar, "TOPRIGHT", -offset, 0)
                P.Point(pip, "BOTTOMRIGHT", castBar, "BOTTOMRIGHT", -offset, 0)
            else
                -- Right to left
                P.Point(pip, "TOPLEFT", castBar, "TOPLEFT", offset, 0)
                P.Point(pip, "BOTTOMLEFT", castBar, "BOTTOMLEFT", offset, 0)
            end

            self:RepointPip(pip)
            self:UpdatePipTexture(pip)

            -- Create a dummy pip for "stage 0"
            if stage == 1 then
                local dummyPip = self:GetPip(0)
                P.ClearPoints(dummyPip)
                dummyPip:Show()

                if reversed then
                    P.Point(dummyPip, "TOPRIGHT", castBar, "TOPRIGHT", 0, 0)
                    P.Point(dummyPip, "BOTTOMLEFT", pip, "BOTTOMLEFT", 0, 0)
                else
                    P.Point(dummyPip, "TOPLEFT", castBar, "TOPLEFT", 0, 0)
                    P.Point(dummyPip, "BOTTOMRIGHT", pip, "BOTTOMRIGHT", 0, 0)
                end
                self:UpdatePipTexture(dummyPip)
            end
        end
    end
end

-- Hide all stages and reset stage counter
---@param self CastBarWidget
local function ClearStages(self)
    for _, pip in pairs(self.StagePips) do
        pip:Hide()
    end

    self.NumStages = 0
    table.wipe(self.StagePoints)
end

-- Update current stage
---@param self CastBarWidget
local function OnUpdateStage(self)
    local maxStage = 0
    local stageValue = self.duration * 1000
    for i = 1, self.NumStages do
        local step = self.StagePoints[i]
        if not step or stageValue < step then
            break
        else
            maxStage = i
        end
    end

    if maxStage ~= self.CurStage then
        self.CurStage = maxStage
    end

    -- TODO: Add logic for hitting different stages
    -- eg. glow when fully charged
end

-------------------------------------------------
-- MARK: Options
-------------------------------------------------

---@param self CastBarWidget
local function SetCastBarColor(self)
    if self.useClassColor then
        local r, g, b = CUF.Util:GetUnitClassColor(self._owner.states.unit)
        self.statusBar:SetStatusBarColor(r, g, b, 1)
    elseif self.notInterruptible then
        self.statusBar:SetStatusBarColor(unpack(self.nonInterruptibleColor))
    else
        self.statusBar:SetStatusBarColor(unpack(self.interruptibleColor))
    end
end

---@param self TimerText|SpellText
---@param styleTable BigFontOpt
local function SetFontStyle(self, styleTable)
    local font = F:GetFont(styleTable.style)

    local fontFlags ---@type TBFFlags|nil
    if styleTable.outline == "Outline" then
        fontFlags = "OUTLINE"
    elseif styleTable.outline == "Monochrome" then
        fontFlags = "MONOCHROME"
    end

    self:SetFont(font, styleTable.size, fontFlags)

    if styleTable.shadow then
        self:SetShadowOffset(1, -1)
        self:SetShadowColor(0, 0, 0, 1)
    else
        self:SetShadowOffset(0, 0)
        self:SetShadowColor(0, 0, 0, 0)
    end

    self:SetTextColor(unpack(styleTable.rgb))

    self:SetPosition(styleTable)
end

---@param self TimerText|SpellText
---@param styleTable BigFontOpt
local function SetFontPosition(self, styleTable)
    P.ClearPoints(self)
    P.Point(self, styleTable.point, self:GetParent(),
        styleTable.offsetX, styleTable.offsetY)
end

---@param self CastBarWidget
---@param width number?
local function SetSparkWidth(self, width)
    local spark = self.spark
    if spark.enabled then
        -- Repoint
        local relativeSide = self.statusBar:GetReverseFill() and "LEFT" or "RIGHT"
        P.ClearPoints(spark)
        P.Point(spark, "TOP", self.statusBar:GetStatusBarTexture(), "TOP" .. relativeSide)
        P.Point(spark, "BOTTOM", self.statusBar:GetStatusBarTexture(), "BOTTOM" .. relativeSide)

        -- Resize
        if width then
            P.Width(spark, width)
        end

        spark:Show()
    else
        P.ClearPoints(spark)
        spark:Hide()
    end
end

---@param self CastBarWidget
---@param styleTable CastBarSparkOpt
local function SetSparkColor(self, styleTable)
    self.spark:SetVertexColor(unpack(styleTable.color))
end

---@param self CastBarWidget
---@param styleTable EmpowerOpt
local function SetEmpowerStyle(self, styleTable)
    self.useFullyCharged = styleTable.useFullyCharged
    self.showEmpowerSpellName = styleTable.showEmpowerName
end

---@param self CastBarWidget
local function SetCastBarColorStyle(self)
    local colors = DB.GetColors().castBar

    self.PipColorMap = {
        [0] = colors.stageZero,
        [1] = colors.stageOne,
        [2] = colors.stageTwo,
        [3] = colors.stageThree,
        [4] = colors.stageFour,
        [5] = colors.fullyCharged,
    }

    self.interruptibleColor = colors.interruptible
    self.nonInterruptibleColor = colors.nonInterruptible
    self.background:SetVertexColor(unpack(colors.background))

    self.statusBar:SetStatusBarTexture(colors.texture)
end

---@param self CastBarWidget
---@param styleTable BorderOpt
local function SetBorderStyle(self, styleTable)
    local border = self.border
    if styleTable.showBorder then
        border:Show()
    else
        border:Hide()
        return
    end

    border:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = P.Scale(styleTable.size),
    })

    border:SetBackdropBorderColor(unpack(styleTable.color))

    P.ClearPoints(border)
    P.Point(border, "TOPLEFT", self, "TOPLEFT", -styleTable.offset, styleTable.offset)
    P.Point(border, "BOTTOMRIGHT", self, "BOTTOMRIGHT", styleTable.offset, -styleTable.offset)
end

---@param self CastBarWidget
---@param styleTable CastBarIconOpt
local function SetIconStyle(self, styleTable)
    local icon = self.icon
    icon.enabled = styleTable.enabled
    icon.position = styleTable.position

    if styleTable.enabled then
        icon:SetIconZoom(styleTable.zoom)
    end

    self:RepointCastBar()
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateCastBar(button)
    ---@class CastBarWidget: Frame, BaseWidget
    ---@field max number
    ---@field startTime number
    ---@field duration number
    ---@field elapsed number
    local castBar = CreateFrame("Frame", button:GetName() .. "_CastBar", button)
    button.widgets.castBar = castBar

    castBar.id = const.WIDGET_KIND.CAST_BAR
    castBar.enabled = true
    castBar._isSelected = false
    castBar._owner = button

    castBar.castID = nil ---@type string?
    castBar.spellName = nil ---@type string?
    castBar.displayName = nil ---@type string?
    castBar.casting = false ---@type boolean?
    castBar.channeling = false ---@type boolean?
    castBar.empowering = false ---@type boolean?
    castBar.notInterruptible = false ---@type boolean?
    castBar.spellID = 0 ---@type number?
    castBar.spellTexture = nil ---@type integer?

    castBar.interruptibleColor = { 1, 1, 0, 0.25 }
    castBar.nonInterruptibleColor = { 1, 1, 0, 0.25 }
    castBar.useClassColor = false
    castBar.onlyShowInterrupt = false

    -- Number of stages in current empower
    castBar.NumStages = 0
    -- Current stage defaults to CASTBAR_STAGE_INVALID (-1)
    castBar.CurStage = CASTBAR_STAGE_INVALID
    -- Map stages to duration
    castBar.StagePoints = {} ---@type number[]
    -- Table of all stage pips
    castBar.StagePips = {}
    -- Color map for each stage
    castBar.PipColorMap = {
        [0] = { 0.2, 0.57, 0.5, 1 }, ---@type RGBAOpt -- Dummy stage
        [1] = { 0.3, 0.47, 0.45, 1 }, ---@type RGBAOpt
        [2] = { 0.4, 0.4, 0.4, 1 }, ---@type RGBAOpt
        [3] = { 0.54, 0.3, 0.3, 1 }, ---@type RGBAOpt
        [4] = { 0.65, 0.2, 0.3, 1 }, ---@type RGBAOpt
        [5] = { 0.77, 0.1, 0.2, 1 }, ---@type RGBAOpt -- Fully charged
    }
    -- Use fully charged color for the final stage
    castBar.useFullyCharged = true
    castBar.showEmpowerSpellName = false

    castBar.GetPip = GetPip
    castBar.AddStages = AddStages
    castBar.CreatePip = CreatePip
    castBar.RepointPip = RepointPip
    castBar.UpdatePips = UpdatePips
    castBar.ClearStages = ClearStages
    castBar.GetStageColor = GetStageColor
    castBar.OnUpdateStage = OnUpdateStage
    castBar.UpdatePipTexture = UpdatePipTexture

    ---@class CastBar: StatusBar, BackdropTemplate
    local statusBar = CreateFrame("StatusBar", nil, castBar, "BackdropTemplate")
    statusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])

    local background = statusBar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(statusBar)
    background:SetColorTexture(1, 1, 1, 1)

    -- Frame for Texts & Spark to ensure they are above border
    local topLevelFrame = CreateFrame("Frame", nil, statusBar)
    topLevelFrame:SetAllPoints()
    topLevelFrame:SetFrameLevel(statusBar:GetFrameLevel() + 2)

    ---@class SparkTexture: Texture
    local spark = topLevelFrame:CreateTexture(nil, "OVERLAY")
    spark:SetWidth(2)
    spark:SetBlendMode("BLEND")
    spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    spark.enabled = false

    ---@class TimerText: FontString
    local timerText = topLevelFrame:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    timerText.SetFontStyle = SetFontStyle
    timerText.SetPosition = SetFontPosition
    timerText.format = const.CastBarTimerFormat.REMAINING

    ---@class SpellText: FontString
    local spellText = topLevelFrame:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    spellText.SetFontStyle = SetFontStyle
    spellText.SetPosition = SetFontPosition
    spellText.enabled = true
    spellText.width = CUF.Defaults.Options.fontWidth

    ---@class IconTexture: Texture
    local icon = castBar:CreateTexture(nil, "OVERLAY")
    icon.enabled = true
    icon.position = "left"
    icon.SetIconZoom = CUF.Util.SetIconZoom

    local border = CreateFrame("Frame", nil, castBar, "BackdropTemplate")
    border:SetFrameLevel(statusBar:GetFrameLevel() + 1)

    castBar.background = background
    castBar.spark = spark
    castBar.timerText = timerText
    castBar.spellText = spellText
    castBar.icon = icon
    castBar.border = border
    castBar.statusBar = statusBar

    ---@param bar CastBarWidget
    ---@param val boolean
    castBar._SetIsSelected = function(bar, val)
        bar._isSelected = val
        --U:UnitFrame_UpdateCastBar(button)
    end

    ---@param val number
    function castBar:SetValue(val)
        self.statusBar:SetValue(val)
    end

    ---@param min number
    ---@param max number
    function castBar:SetMinMaxValues(min, max)
        self.statusBar:SetMinMaxValues(min, max)
    end

    castBar.ResetAttributes = ResetAttributes
    castBar.UpdateElements = UpdateElements
    castBar.RepointCastBar = RepointCastBar

    castBar.SetWidgetSize = function(...)
        W.SetWidgetSize(...)
        castBar:RepointCastBar()
    end
    castBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    castBar.SetPosition = W.SetDetachedRelativePosition
    castBar.SetEnabled = W.SetEnabled

    castBar.Enable = Enable
    castBar.Disable = Disable
    castBar.Update = Update

    castBar.SetCastBarColorStyle = SetCastBarColorStyle
    castBar.SetCastBarColor = SetCastBarColor
    castBar.SetEmpowerStyle = SetEmpowerStyle
    castBar.SetBorderStyle = SetBorderStyle
    castBar.SetIconOptions = SetIconStyle
    castBar.SetSparkColor = SetSparkColor
    castBar.SetSparkWidth = SetSparkWidth
    castBar.SetFillStyle = SetFillStyle
    castBar.SetSpellWidth = CUF.Util.UpdateTextWidth
end

W:RegisterCreateWidgetFunc(CUF.constants.WIDGET_KIND.CAST_BAR, W.CreateCastBar)
