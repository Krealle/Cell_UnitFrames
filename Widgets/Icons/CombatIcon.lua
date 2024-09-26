---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.COMBAT_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateCombatIconWidget(button, unit, setting, subSetting)
    button.widgets.combatIcon.Update(button)
end

Handler:RegisterWidget(W.UpdateCombatIconWidget, const.WIDGET_KIND.COMBAT_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event? "PLAYER_REGEN_DISABLED" | "PLAYER_REGEN_ENABLED" | "UNIT_FLAGS"
local function Update(button, event)
    local unit = button.states.displayedUnit
    if not unit then return end

    local combatIcon = button.widgets.combatIcon

    if combatIcon.enabled
        and (event == "PLAYER_REGEN_DISABLED"
            or UnitAffectingCombat(unit)
            or combatIcon._isSelected) then
        combatIcon:Show()
    else
        combatIcon:Hide()
    end
end

---@param self CombatIconWidget
local function Enable(self)
    if self._owner.states.unit == "player" then
        self._owner:AddEventListener("PLAYER_REGEN_DISABLED", Update, true)
        self._owner:AddEventListener("PLAYER_REGEN_ENABLED", Update, true)
    else
        self._owner:AddEventListener("UNIT_FLAGS", Update)
    end

    return true
end

---@param self CombatIconWidget
local function Disable(self)
    if self._owner.states.unit == "player" then
        self._owner:RemoveEventListener("PLAYER_REGEN_DISABLED", Update)
        self._owner:RemoveEventListener("PLAYER_REGEN_ENABLED", Update)
    else
        self._owner:RemoveEventListener("UNIT_FLAGS", Update)
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateCombatIcon(button)
    ---@class CombatIconWidget: Frame, BaseWidget
    local combatIcon = CreateFrame("Frame", button:GetName() .. "_CombatIcon", button)
    button.widgets.combatIcon = combatIcon

    combatIcon:SetPoint("TOPLEFT", 0, 0)
    combatIcon.enabled = false
    combatIcon.id = const.WIDGET_KIND.COMBAT_ICON
    combatIcon._isSelected = false
    combatIcon._owner = button

    combatIcon.tex = combatIcon:CreateTexture(nil, "ARTWORK")
    combatIcon.tex:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    combatIcon.tex:SetAllPoints(combatIcon)
    combatIcon.tex:SetTexCoord(.5, 1, 0, .49)

    function combatIcon:_OnIsSelected()
        self.Update(self._owner)
    end

    combatIcon.Enable = Enable
    combatIcon.Disable = Disable
    combatIcon.Update = Update

    combatIcon.SetEnabled = W.SetEnabled
    combatIcon.SetPosition = W.SetPosition
    combatIcon._SetIsSelected = W.SetIsSelected
    combatIcon.SetWidgetSize = W.SetWidgetSize
    combatIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.COMBAT_ICON, W.CreateCombatIcon)
