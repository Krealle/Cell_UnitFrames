---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local A = Cell.animations
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets

local DB = CUF.DB
local Handler = CUF.Handler
local const = CUF.constants

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.FaderWidget(button, unit, setting, subSetting)
    local fader = button.widgets.fader
    local layoutTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.FADER, unit) --[[@as FaderWidgetTable]]

    if not setting or setting == "range" then
        fader.range = layoutTable.range
    end
    if not setting or setting == "combat" then
        fader.combat = layoutTable.combat
    end
    if not setting or setting == "hover" then
        fader.hover = layoutTable.hover
    end
    if not setting or setting == "target" then
        fader.target = layoutTable.target
    end
    if not setting or setting == "unitTarget" then
        fader.unitTarget = layoutTable.unitTarget
    end
    if not setting or setting == "maxAlpha" or setting == "minAlpha" then
        fader.minAlpha = layoutTable.minAlpha
        fader.maxAlpha = layoutTable.maxAlpha
    end
    if not setting or setting == "fadeDuration" then
        fader.fadeDuration = layoutTable.fadeDuration
    end

    if fader.enabled and button:IsVisible() then
        fader:UpdateListeners()
    end

    fader.Update(button)
end

Handler:RegisterWidget(W.FaderWidget, const.WIDGET_KIND.FADER)

-------------------------------------------------
-- MARK: Checks
-------------------------------------------------

local DEFAULT_HARM_SPELLS = {
    ["WARLOCK"] = 234153, -- Drain Life
    ["EVOKER"] = 361469,  -- Living Flame
}

---@param self FaderWidget
---@param unit UnitToken
local function RangeCheck(self, unit)
    local inRange = F.IsInRange(unit)

    -- Hack to circumvent override issue with C_Spell.IsSpellInRange and override spells
    if not inRange and UnitCanAttack("player", unit) then
        local overrideSpell = DEFAULT_HARM_SPELLS[UnitClassBase("player")]
        if overrideSpell then
            inRange = C_Spell.IsSpellInRange(overrideSpell, unit) or false
        end
    end

    return inRange
end

---@param frame Frame
local function IsFrameFocused(frame)
    local focusedFrames = GetMouseFoci()
    return focusedFrames and focusedFrames[1] == frame
end

---@param self FaderWidget
---@param event WowEvent?
---@param unit UnitToken
local function ShouldFadeIn(self, event, unit)
    if self.range then
        return self:RangeCheck(unit) or
            (self.hover and IsFrameFocused(self._owner))
    end

    return (self.combat and UnitAffectingCombat(unit)) or
        (self.target and UnitExists("target")) or
        (self.unitTarget and UnitExists(unit .. "target")) or
        (self.hover and IsFrameFocused(self._owner))
end

---@param button CUFUnitButton
local function HoverHook(button)
    local fader = button.widgets.fader
    if fader.hover then
        fader.Update(button)
    end
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event? string
---@param unit UnitToken?
local function Update(button, event, unit)
    if not button:IsVisible() then return end
    unit = unit or button.states.unit

    local fader = button.widgets.fader

    if not fader.enabled or fader.optCount == 0 then
        button:SetAlpha(1)
        return
    end

    local shouldFadeIn = fader:ShouldFadeIn(event, unit)
    if shouldFadeIn then
        if fader.isFadedIn ~= shouldFadeIn then
            fader.isFadedIn = true
            A.FrameFadeIn(button, fader.fadeDuration, button:GetAlpha(), fader.maxAlpha)
        end
    else
        if fader.isFadedIn ~= shouldFadeIn then
            fader.isFadedIn = false
            A.FrameFadeOut(button, fader.fadeDuration, button:GetAlpha(), fader.minAlpha)
        end
    end
end

---@param self FaderWidget
local function Enable(self)
    self:UpdateListeners(true)
    self:Show()
    self.Update(self._owner)

    return true
end

---@param self FaderWidget
local function Disable(self)
    self:UpdateListeners(false)
    self.optCount = 0
    self.isFadedIn = false

    -- Reset Alpha
    self._owner:SetAlpha(1)
end

---@param self FaderWidget
---@param enabled boolean?
local function UpdateListeners(self, enabled)
    if enabled == nil then
        enabled = self._isEnabled
    end

    self.optCount = 0
    self.isFadedIn = nil
    local owner = self._owner
    local unit = owner.states.unit

    if self.range and enabled then
        self.optCount = self.optCount + 1

        self:SetScript("OnUpdate", function(_, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.1 then
                self.elapsed = 0
                self.Update(owner)
            end
        end)
    else
        self:SetScript("OnUpdate", nil)
    end

    if self.combat and enabled then
        self.optCount = self.optCount + 1

        if unit == "player" then
            owner:AddEventListener("PLAYER_REGEN_DISABLED", Update, true)
            owner:AddEventListener("PLAYER_REGEN_ENABLED", Update, true)
        else
            owner:AddEventListener("UNIT_FLAGS", Update)
        end
    else
        owner:RemoveEventListener("PLAYER_REGEN_DISABLED", Update)
        owner:RemoveEventListener("PLAYER_REGEN_ENABLED", Update)
        owner:RemoveEventListener("UNIT_FLAGS", Update)
    end

    if self.target and enabled then
        self.optCount = self.optCount + 1

        owner:AddEventListener("PLAYER_TARGET_CHANGED", Update, true)
    else
        owner:RemoveEventListener("PLAYER_TARGET_CHANGED", Update)
    end

    if self.unitTarget and enabled then
        self.optCount = self.optCount + 1

        owner:AddEventListener("UNIT_TARGET", Update)
    else
        owner:RemoveEventListener("UNIT_TARGET", Update)
    end

    if self.hover and enabled then
        self.optCount = self.optCount + 1

        if not self.hoverHooked then
            owner:HookScript("OnEnter", HoverHook)
            owner:HookScript("OnLeave", HoverHook)

            self.hoverHooked = true
        end
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateFader(button)
    ---@class FaderWidget: Frame, BaseWidget
    local fader = CreateFrame("Frame")
    button.widgets.fader = fader

    fader.enabled = false
    fader.id = const.WIDGET_KIND.FADER
    fader._isSelected = false
    fader._owner = button
    fader.elapsed = 0

    fader.range = false
    fader.combat = false
    fader.hover = false
    fader.target = false
    fader.unitTarget = false
    fader.fadeDuration = 0.25
    fader.maxAlpha = 1
    fader.minAlpha = 0.25

    fader.optCount = 0
    fader.isFadedIn = false
    fader.hoverHooked = false

    fader.Enable = Enable
    fader.Disable = Disable
    fader.Update = Update
    fader.UpdateListeners = UpdateListeners
    fader.ShouldFadeIn = ShouldFadeIn

    fader.RangeCheck = RangeCheck

    fader.SetEnabled = W.SetEnabled
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.FADER, W.CreateFader)
