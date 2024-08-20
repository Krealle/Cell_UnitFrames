---@class CUF
local CUF = select(2, ...)

local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.CAST_BAR,
    Builder.MenuOptions.CastBarGeneral,
    Builder.MenuOptions.CastBarColor,
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
    --if not castBar then return end
    local styleTable = DB.GetWidgetTable(const.WIDGET_KIND.CAST_BAR, unit)

    if not setting or setting == const.OPTION_KIND.COLOR then
        if not subSetting or subSetting == const.OPTION_KIND.TEXTURE then
            castBar:SetStatusBarTexture(styleTable.color.texture)
        end
        if not subSetting or subSetting == const.OPTION_KIND.USE_CLASS_COLOR then
            castBar.useClassColor = styleTable.color.useClassColor
        end
        if not subSetting or subSetting == const.OPTION_KIND.INTERRUPTIBLE then
            castBar.interruptibleColor = styleTable.color.interruptible
        end
        if not subSetting or subSetting == const.OPTION_KIND.NON_INTERRUPTIBLE then
            castBar.nonInterruptibleColor = styleTable.color.nonInterruptible
        end
        if not subSetting or subSetting == const.OPTION_KIND.BACKGROUND then
            castBar.background:SetVertexColor(unpack(styleTable.color.background))
        end
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
        castBar.spark:UpdateColor(styleTable.spark)
        castBar:UpdateSpark(styleTable.spark)
    end

    if not setting or setting == const.OPTION_KIND.EMPOWER then
        castBar:UpdateEmpowerPips(styleTable.empower)
    end

    if not setting or setting == const.OPTION_KIND.BORDER then
        castBar:UpdateBorder(styleTable.border)
    end

    if not setting or setting == const.OPTION_KIND.ICON then
        castBar:SetIconOptions(styleTable.icon)
    end

    if not setting or setting == const.OPTION_KIND.ENABLED then
        U:ToggleCastEvents(button, styleTable.enabled)
    end

    U:UnitFrame_UpdateCastBar(button)
end

Handler:RegisterWidget(W.UpdateCastBarWidget, const.WIDGET_KIND.CAST_BAR)

-------------------------------------------------
-- MARK: UpdateCastBar
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateCastBar(button)
    local castBar = button.widgets.castBar
    if not castBar then return end

    if not castBar.enabled then
        castBar:ResetAttributes()
        return
    end

    if castBar.casting or castBar.channeling or castBar.empowering then
        castBar:UpdateElements()
        return
    end

    U:CastBar_CastStart(button, nil, button.states.unit)
end

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
    self:UpdateColor()

    if self.icon then self.icon:SetTexture(self.spellTexture --[[ or FALLBACK_ICON ]]) end
    if self.spark then self.spark:Show() end

    if self.spellText and self.spellText.enabled then
        if self.empowering and not self.showEmpowerSpellName then
            self.spellText:SetText("")
        else
            self.spellText:SetText(self.displayName ~= "" and self.displayName
                or self.spellName)
        end
    end

    if self.timerText then self.timerText:SetText() end

    if self.empowering and self:IsShown() then
        self:UpdatePips()
    end
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
function U:CastBar_CastStart(button, event, unit, castGUID)
    CUF:DevAdd({ event, unit, castGUID, ShouldShow(button, unit) }, "CastBar_CastStart")
    CUF:Log(event, unit, ShouldShow(button, unit))
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

    if not name then
        ResetAttributes(castBar)
        castBar:Hide()

        return
    end

    castBar.casting = event == "UNIT_SPELLCAST_START"
    castBar.channeling = event == "UNIT_SPELLCAST_CHANNEL_START"
    castBar.empowering = event == "UNIT_SPELLCAST_EMPOWER_START"

    if castBar.empowering then
        endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
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

    if castBar.empowering then
        castBar:AddStages(numStages)
    end
end

---@param button CUFUnitButton
---@param event "UNIT_SPELLCAST_DELAYED"|"UNIT_SPELLCAST_CHANNEL_UPDATE"|"UNIT_SPELLCAST_EMPOWER_UPDATE"
---@param unit UnitToken
---@param castID WOWGUID
---@param spellID number
function U:CastBar_CastUpdate(button, event, unit, castID, spellID)
    CUF:DevAdd({ event, unit, castID, spellID, ShouldShow(button, unit) }, "CastBar_CastUpdate")
    CUF:Log(event, unit, spellID, ShouldShow(button, unit))
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    if not castBar:IsShown()
        or castBar.castID ~= castID
        or castBar.spellID ~= spellID then
        return
    end

    local name, startTime, endTime, _
    if (event == "UNIT_SPELLCAST_DELAYED") then
        name, _, _, startTime, endTime = UnitCastingInfo(unit)
    else
        name, _, _, startTime, endTime = UnitChannelInfo(unit)
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
    castBar:UpdateColor()
end

---@param button CUFUnitButton
---@param event "UNIT_SPELLCAST_STOP"|"UNIT_SPELLCAST_CHANNEL_STOP"|"UNIT_SPELLCAST_EMPOWER_STOP"
---@param unit UnitToken
---@param castID WOWGUID
---@param spellID number
---@param complete boolean?
function U:CastBar_CastStop(button, event, unit, castID, spellID, complete)
    CUF:DevAdd({ event, unit, castID, spellID, ShouldShow(button, unit) }, "CastBar_CastStop")
    CUF:Log(event, unit, spellID, complete)
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    if not castBar:IsShown()
        or castBar.castID ~= castID
        or castBar.spellID ~= spellID then
        return
    end

    ResetAttributes(castBar)
end

---@param button CUFUnitButton
---@param event "UNIT_SPELLCAST_FAILED"|"UNIT_SPELLCAST_INTERRUPTED"
---@param unit UnitToken
---@param castID WOWGUID
---@param spellID number
function U:CastBar_CastFail(button, event, unit, castID, spellID)
    CUF:DevAdd({ event, unit, castID, spellID, ShouldShow(button, unit) }, "CastBar_CastFail")
    CUF:Log(event, unit, castID, spellID)
    if not ShouldShow(button, unit) then return end

    local castBar = button.widgets.castBar

    if not castBar:IsShown()
        or castBar.castID ~= castID
        or castBar.spellID ~= spellID then
        return
    end

    ResetAttributes(castBar)
end

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

        if (self.timerText) and (self.elapsed >= .01) then
            local timerFormat = self.timerText.format
            if self.empowering then
                self.timerText:SetFormattedText("%d", self.CurStage)
            elseif timerFormat == const.CastBarTimerFormat.DURATION then
                self.timerText:SetFormattedText("%.1f", self.duration)
            elseif timerFormat == const.CastBarTimerFormat.REMAINING then
                self.timerText:SetFormattedText("%.1f", (self.max - self.duration))
            elseif timerFormat == const.CastBarTimerFormat.DURATION_AND_MAX then
                local dur = self.duration
                if self.channeling then
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

            self.elapsed = 0
        end

        self:SetValue(self.duration)
    else
        self:ResetAttributes()
        self:Hide()
    end
end

-- Register/Unregister events for CastBar
---@param button CUFUnitButton
---@param show? boolean
function U:ToggleCastEvents(button, show)
    if not button:IsShown() then return end
    local castBar = button.widgets.castBar
    if not castBar then return end

    if castBar.enabled or show then
        button:RegisterEvent("UNIT_SPELLCAST_START")
        button:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        button:RegisterEvent("UNIT_SPELLCAST_STOP")
        button:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        button:RegisterEvent("UNIT_SPELLCAST_DELAYED")
        button:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
        button:RegisterEvent("UNIT_SPELLCAST_FAILED")
        button:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

        if CUF.vars.isRetail then
            button:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            button:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
            button:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
        end

        castBar:SetScript("OnUpdate", onUpdate)
    else
        button:UnregisterEvent("UNIT_SPELLCAST_START")
        button:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        button:UnregisterEvent("UNIT_SPELLCAST_STOP")
        button:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        button:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
        button:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
        button:UnregisterEvent("UNIT_SPELLCAST_FAILED")
        button:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")

        if CUF.vars.isRetail then
            button:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            button:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
            button:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
        end

        castBar:SetScript("OnUpdate", nil)
    end
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
local function CreatePip(self, stage)
    local pip = CreateFrame("Frame", "Pip" .. stage, self, "CastingBarFrameStagePipTemplate")

    -- Hide the art line
    pip.BasePip:SetAlpha(0)

    pip.texture = pip:CreateTexture("Pip" .. stage .. "Tex", "OVERLAY")
    pip.texture:SetAllPoints()

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

-- Update textures of all pips
---@param self CastBarWidget
local function UpdatePips(self)
    for stage = 0, self.NumStages do
        local pip = self.StagePips[stage]
        pip.texture:SetTexture(self:GetStatusBarTexture():GetTexture())

        local r, g, b, a = self:GetStageColor(stage)

        if stage < self.NumStages then
            local anchor = self.StagePips[stage + 1]
            pip.texture:Point("LEFT", self, "RIGHT", 0, 0)
            pip.texture:Point("RIGHT", anchor, 0, 0)
            pip.texture:SetVertexColor(r, g, b, a)
        else
            pip.texture:Point("LEFT", self, "RIGHT", 0, 0)
            pip.texture:Point("RIGHT", self, 0, 0)
            -- Set the last stage to completed color
            pip.texture:SetVertexColor(r, g, b, a)
        end
    end
end

-- Add stages to the castbar
---@param self CastBarWidget
local function AddStages(self, numStages)
    local stageTotalDuration = 0
    local stageMaxValue = self.max * 1000
    local castBarWidth = self:GetWidth()
    self.NumStages = numStages
    self.CurStage = CASTBAR_STAGE_INVALID

    for stage = 1, numStages do
        local duration
        if (stage > numStages) then
            duration = GetUnitEmpowerHoldAtMaxTime(self.parent.states.unit)
        else
            duration = GetUnitEmpowerStageDuration(self.parent.states.unit, stage - 1)
        end

        if (duration > CASTBAR_STAGE_DURATION_INVALID) then
            stageTotalDuration = stageTotalDuration + duration
            self.StagePoints[stage] = stageTotalDuration

            local portion = stageTotalDuration / stageMaxValue
            local offset = castBarWidth * portion

            local pip = self.StagePips[stage]
            if not pip then
                pip = self:CreatePip(stage)
                self.StagePips[stage] = pip
            end

            pip:ClearAllPoints()
            pip:Show()

            pip:SetPoint("TOP", self, "TOPLEFT", offset, 0)
            pip:SetPoint("BOTTOM", self, "BOTTOMLEFT", offset, 0)

            -- Create a dummy pip for "stage 0"
            if stage == 1 then
                local dummyPip = self.StagePips[stage - 1]
                if not dummyPip then
                    dummyPip = CreatePip(self, stage - 1)
                    self.StagePips[stage - 1] = dummyPip
                end

                dummyPip:ClearAllPoints()
                dummyPip:Show()

                dummyPip:SetPoint("TOP", self, "TOPLEFT", 0, 0)
                dummyPip:SetPoint("BOTTOM", pip, "BOTTOMRIGHT", 0, 0)
            end
        end
    end

    self:UpdatePips()
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
local function UpdateColor(self)
    if self.useClassColor then
        local r, g, b = CUF.Util:GetUnitClassColor(self.parent.states.unit)
        self:SetStatusBarColor(r, g, b, 1)
    elseif self.notInterruptible then
        self:SetStatusBarColor(unpack(self.nonInterruptibleColor))
    else
        self:SetStatusBarColor(unpack(self.interruptibleColor))
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
    self:ClearAllPoints()
    self:SetPoint(styleTable.point, self:GetParent(),
        styleTable.offsetX,
        styleTable.offsetY)
end

---@param self CastBarWidget
---@param styleTable CastBarSparkOpt
local function UpdateSpark(self, styleTable)
    local spark = self.spark
    if spark.enabled then
        spark:ClearAllPoints()
        spark:SetPoint("CENTER", self:GetStatusBarTexture(), "RIGHT")
        spark:SetHeight(self:GetHeight())
        spark:SetWidth(styleTable.width)
    else
        spark:Hide()
    end
end

---@param self SparkTexture
---@param styleTable CastBarSparkOpt
local function UpdateSparkColor(self, styleTable)
    self:SetVertexColor(unpack(styleTable.color))
end

---@param self CastBarWidget
---@param styleTable EmpowerOpt
local function UpdateEmpower(self, styleTable)
    self.useFullyCharged = styleTable.useFullyCharged
    self.showEmpowerSpellName = styleTable.showEmpowerName

    local colors = styleTable.pipColors
    self.PipColorMap = {
        [0] = colors.stageZero,
        [1] = colors.stageOne,
        [2] = colors.stageTwo,
        [3] = colors.stageThree,
        [4] = colors.stageFour,
        [5] = colors.fullyCharged,
    }
end

---@param self CastBarWidget
---@param styleTable BorderOpt
local function UpdateBorder(self, styleTable)
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
        edgeSize = styleTable.size,
    })

    border:SetBackdropBorderColor(unpack(styleTable.color))

    border:ClearAllPoints()
    if self.icon then
        border:SetPoint("TOPLEFT", self.icon, "TOPLEFT", -styleTable.offset, styleTable.offset)
    else
        border:SetPoint("TOPLEFT", self, "TOPLEFT", -styleTable.offset, styleTable.offset)
    end
    border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", styleTable.offset, -styleTable.offset)
end

---@param self CastBarWidget
---@param styleTable CastBarIconOpt
local function SetIconOptions(self, styleTable)
    local icon = self.icon
    icon.enabled = styleTable.enabled
    icon.position = styleTable.position
    icon.zoom = styleTable.zoom
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateCastBar(button)
    ---@class CastBarWidget: StatusBar, BaseWidget, BackdropTemplate
    ---@field max number
    ---@field startTime number
    ---@field duration number
    ---@field elapsed number
    local castBar = CreateFrame("StatusBar", button:GetName() .. "_CastBar", button, "BackdropTemplate")
    button.widgets.castBar = castBar
    castBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])

    castBar.id = const.WIDGET_KIND.CAST_BAR
    castBar.enabled = true
    castBar._isSelected = false
    castBar.parent = button

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
        [5] = { 0.77, 0.1, 0.2, 1 }, ---@type RGBAOpt -- Final stage
    }
    -- Use fully charged color for the final stage
    castBar.useFullyCharged = true
    castBar.showEmpowerSpellName = false

    castBar.AddStages = AddStages
    castBar.CreatePip = CreatePip
    castBar.UpdatePips = UpdatePips
    castBar.ClearStages = ClearStages
    castBar.GetStageColor = GetStageColor
    castBar.OnUpdateStage = OnUpdateStage

    local background = castBar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(castBar)
    background:SetColorTexture(1, 1, 1, .5)

    ---@class SparkTexture: Texture
    local spark = castBar:CreateTexture(nil, "OVERLAY")
    spark:SetWidth(2)
    spark:SetBlendMode("BLEND")
    spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    spark.UpdateColor = UpdateSparkColor
    spark.enabled = false

    ---@class TimerText: FontString
    local timerText = castBar:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    timerText:SetPoint("RIGHT", castBar)
    timerText.SetFontStyle = SetFontStyle
    timerText.SetPosition = SetFontPosition
    timerText.format = const.CastBarTimerFormat.REMAINING

    ---@class SpellText: FontString
    local spellText = castBar:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    spellText:SetPoint("LEFT", castBar, 30, 0)
    spellText.SetFontStyle = SetFontStyle
    spellText.SetPosition = SetFontPosition
    spellText.enabled = true

    ---@class IconTexture: Texture
    local icon = castBar:CreateTexture(nil, "OVERLAY")
    icon:SetSize(30, 30)
    icon:SetPoint("RIGHT", castBar, "LEFT")
    icon.enabled = true
    icon.position = "left"
    icon.zoom = 30

    local border = CreateFrame("Frame", nil, castBar, "BackdropTemplate")

    castBar.background = background
    castBar.spark = spark
    castBar.timerText = timerText
    castBar.spellText = spellText
    castBar.icon = icon
    castBar.border = border

    ---@param bar CastBarWidget
    ---@param val boolean
    castBar._SetIsSelected = function(bar, val)
        bar._isSelected = val
        --U:UnitFrame_UpdateCastBar(button)
    end

    castBar.ResetAttributes = ResetAttributes
    castBar.UpdateColor = UpdateColor
    castBar.UpdateSpark = UpdateSpark
    castBar.UpdateEmpowerPips = UpdateEmpower
    castBar.UpdateBorder = UpdateBorder

    castBar.UpdateElements = UpdateElements

    castBar.SetEnabled = W.SetEnabled
    castBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    castBar.SetWidgetSize = W.SetWidgetSize
    castBar.SetPosition = W.SetPosition
    castBar.SetIconOptions = SetIconOptions
end
