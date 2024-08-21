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

menu:AddWidget(const.WIDGET_KIND.READY_CHECK_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateReadyCheckIconWidget(button, unit, setting, subSetting)
    if not setting or setting == const.OPTION_KIND.ENABLED then
        U:ToggleReadyCheckEvents(button)
    end

    U:UnitFrame_UpdateReadyCheckIcon(button)
end

Handler:RegisterWidget(W.UpdateReadyCheckIconWidget, const.WIDGET_KIND.READY_CHECK_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateReadyCheckIcon(button)
    if not button:HasWidget(const.WIDGET_KIND.READY_CHECK_ICON) then return end
    local unit = button.states.displayedUnit
    if not unit then return end

    local status = GetReadyCheckStatus(unit)
    button.states.readyCheckStatus = status

    local readyCheckIcon = button.widgets.readyCheckIcon

    if readyCheckIcon.enabled and (status or readyCheckIcon._isSelected) then
        readyCheckIcon:SetStatus(status)
    else
        readyCheckIcon:Hide()
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

local READY_CHECK_STATUS = {
    ready = { t = "Interface\\AddOns\\Cell\\Media\\Icons\\readycheck-ready", c = { 0, 1, 0, 1 } },
    waiting = { t = "Interface\\AddOns\\Cell\\Media\\Icons\\readycheck-waiting", c = { 1, 1, 0, 1 } },
    notready = { t = "Interface\\AddOns\\Cell\\Media\\Icons\\readycheck-notready", c = { 1, 0, 0, 1 } },
}

---@param button CUFUnitButton
function W:CreateReadyCheckIcon(button)
    ---@class ReadyCheckIconWidget: Frame, BaseWidget
    local readyCheckIcon = CreateFrame("Frame", button:GetName() .. "_ReadyCheckIcon", button)
    button.widgets.readyCheckIcon = readyCheckIcon

    readyCheckIcon:SetPoint("TOPLEFT", 0, 0)
    readyCheckIcon.enabled = false
    readyCheckIcon.id = const.WIDGET_KIND.READY_CHECK_ICON
    readyCheckIcon._isSelected = false

    readyCheckIcon.tex = readyCheckIcon:CreateTexture(nil, "ARTWORK")
    readyCheckIcon.tex:SetAllPoints(readyCheckIcon)

    function readyCheckIcon:_OnIsSelected()
        U:UnitFrame_UpdateReadyCheckIcon(button)
    end

    function readyCheckIcon:SetStatus(status)
        local status = status or "waiting" -- Preview
        readyCheckIcon.tex:SetTexture(READY_CHECK_STATUS[status].t)
        readyCheckIcon:Show()
    end

    readyCheckIcon.SetEnabled = W.SetEnabled
    readyCheckIcon.SetPosition = W.SetPosition
    readyCheckIcon._SetIsSelected = W.SetIsSelected
    readyCheckIcon.SetWidgetSize = W.SetWidgetSize
    readyCheckIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.READY_CHECK_ICON, W.CreateReadyCheckIcon)
