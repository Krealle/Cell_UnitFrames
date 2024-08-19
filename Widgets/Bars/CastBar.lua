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
    Builder.MenuOptions.CastBarTimer,
    Builder.MenuOptions.CastBarSpell,
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

    wipe(self.stagePoints)

    --[[ for _, pip in next, castBar.Pips do
        pip:Hide()
    end ]]
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
        event = "UNIT_SPELLCAST_CHANNEL_START"
        --event = (numStages and numStages > 0) and "UNIT_SPELLCAST_EMPOWER_START" or "UNIT_SPELLCAST_CHANNEL_START"
    end

    if not name then
        ResetAttributes(castBar)
        castBar:Hide()

        return
    end

    castBar.casting = event == "UNIT_SPELLCAST_START"
    castBar.channeling = event == "UNIT_SPELLCAST_CHANNEL_START"

    endTime = endTime / 1000
    startTime = startTime / 1000

    castBar.max = endTime - startTime
    castBar.startTime = startTime

    castBar.notInterruptible = notInterruptible
    castBar.castID = castID
    castBar.spellID = spellID
    castBar.spellName = name

    if castBar.channeling then
        castBar.duration = endTime - GetTime()
    else
        castBar.duration = GetTime() - startTime
    end

    castBar:SetMinMaxValues(0, castBar.max)
    castBar:SetValue(castBar.duration)
    castBar:UpdateColor()

    if (castBar.icon) then castBar.icon:SetTexture(texture --[[ or FALLBACK_ICON ]]) end
    if (castBar.spark) then castBar.spark:Show() end
    if (castBar.spellText and castBar.spellText.enabled) then
        castBar.spellText:SetText(displayName ~= "" and displayName or
            name)
    end
    if (castBar.timerText) then castBar.timerText:SetText() end

    castBar:Show()
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
local function OnUpdateStage(self)
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
            if timerFormat == const.CastBarTimerFormat.DURATION then
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
                OnUpdateStage(self)
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

        castBar:SetScript("OnUpdate", nil)
    end
end

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
    castBar.casting = false ---@type boolean?
    castBar.channeling = false ---@type boolean?
    castBar.empowering = false ---@type boolean?
    castBar.notInterruptible = false ---@type boolean?
    castBar.spellID = 0 ---@type number?
    castBar.numStages = nil ---@type number?
    castBar.curStage = nil ---@type number?
    castBar.stagePoints = {}

    castBar.interruptibleColor = { 1, 1, 0, 0.25 }
    castBar.nonInterruptibleColor = { 1, 1, 0, 0.25 }
    castBar.useClassColor = false

    castBar:SetSize(200, 30)
    castBar:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -20)
    castBar:Hide()

    local background = castBar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(castBar)
    background:SetColorTexture(1, 1, 1, .5)

    local spark = castBar:CreateTexture(nil, "OVERLAY")
    spark:SetSize(2, 30)
    spark:SetBlendMode("ADD")
    spark:SetPoint("CENTER", castBar:GetStatusBarTexture(), "RIGHT", 0, 0)
    spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])

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

    local icon = castBar:CreateTexture(nil, "OVERLAY")
    icon:SetSize(30, 30)
    icon:SetPoint("RIGHT", castBar, "LEFT")

    castBar.background = background
    castBar.spark = spark
    castBar.timerText = timerText
    castBar.spellText = spellText
    castBar.icon = icon

    ---@param bar CastBarWidget
    ---@param val boolean
    castBar._SetIsSelected = function(bar, val)
        bar._isSelected = val
        --U:UnitFrame_UpdateCastBar(button)
    end

    castBar.ResetAttributes = ResetAttributes
    castBar.UpdateColor = UpdateColor

    castBar.SetEnabled = W.SetEnabled
    castBar.SetWidgetFrameLevel = W.SetWidgetFrameLevel
    castBar.SetWidgetSize = W.SetWidgetSize
    castBar.SetPosition = W.SetPosition
end
