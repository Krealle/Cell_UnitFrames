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

menu:AddWidget(const.WIDGET_KIND.RAID_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateRaidIconWidget(button, unit, setting, subSetting)
    if not setting or setting == const.OPTION_KIND.ENABLED then
        U:ToggleRaidIcon(button)
    end

    U:UnitFrame_UpdateRaidIcon(button)
end

Handler:RegisterWidget(W.UpdateRaidIconWidget, const.WIDGET_KIND.RAID_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateRaidIcon(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local raidIcon = button.widgets.raidIcon
    if not raidIcon.enabled then
        raidIcon:Hide()
        return
    end

    local index = GetRaidTargetIndex(unit)
    if index then
        raidIcon:Show()
        SetRaidTargetIconTexture(raidIcon.tex, index)
    elseif raidIcon._isSelected then -- Preview
        raidIcon:Show()
        SetRaidTargetIconTexture(raidIcon.tex, 1)
    else
        raidIcon:Hide()
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateRaidIcon(button, buttonName)
    ---@class RaidIconWidget: Frame, BaseWidget
    local raidIcon = CreateFrame("Frame", buttonName .. "RaidIcon", button)
    button.widgets.raidIcon = raidIcon

    raidIcon:SetPoint("TOPLEFT", 0, 0)
    raidIcon.enabled = false
    raidIcon.id = const.WIDGET_KIND.RAID_ICON
    raidIcon._isSelected = false

    raidIcon.tex = raidIcon:CreateTexture(nil, "ARTWORK")
    raidIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    raidIcon.tex:SetAllPoints(raidIcon)

    function raidIcon:_OnIsSelected()
        U:UnitFrame_UpdateRaidIcon(button)
    end

    raidIcon.SetEnabled = W.SetEnabled
    raidIcon.SetPosition = W.SetPosition
    raidIcon._SetIsSelected = W.SetIsSelected
    raidIcon.SetWidgetSize = W.SetWidgetSize
    raidIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end
