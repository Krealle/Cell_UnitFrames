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

menu:AddWidget(const.WIDGET_KIND.LEADER_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateLeaderIconWidget(button, unit, setting, subSetting)
    U:UnitFrame_UpdateLeaderIcon(button)
end

Handler:RegisterWidget(W.UpdateLeaderIconWidget, const.WIDGET_KIND.LEADER_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateLeaderIcon(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local leaderIcon = button.widgets.leaderIcon

    if leaderIcon.enabled then
        local isLeader = UnitIsGroupLeader(unit)
        button.states.isLeader = isLeader
        local isAssistant = UnitIsGroupAssistant(unit) and IsInRaid()
        button.states.isAssistant = isAssistant

        leaderIcon:SetIcon(isLeader, isAssistant)
    else
        leaderIcon:Hide()
    end
end

-------------------------------------------------
-- MARK: Funcs
-------------------------------------------------

---@param self LeaderIconWidget
---@param isLeader boolean
---@param isAssistant boolean
local function LeaderIcon_SetIcon(self, isLeader, isAssistant)
    if isLeader then
        self.tex:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        self:Show()
    elseif isAssistant then
        self.tex:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        self:Show()
    else
        self:Hide()
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateLeaderIcon(button, buttonName)
    ---@class LeaderIconWidget: Frame
    local leaderIcon = CreateFrame("Frame", buttonName .. "LeaderIcon", button)
    button.widgets.leaderIcon = leaderIcon

    leaderIcon:SetPoint("TOPLEFT", 0, 0)
    leaderIcon.enabled = false
    leaderIcon.id = const.WIDGET_KIND.LEADER_ICON

    leaderIcon.tex = leaderIcon:CreateTexture(nil, "ARTWORK")
    leaderIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    leaderIcon.tex:SetAllPoints(leaderIcon)

    leaderIcon.SetIcon = LeaderIcon_SetIcon

    leaderIcon.SetEnabled = W.SetEnabled
    leaderIcon.SetPosition = W.SetPosition
    leaderIcon._SetIsSelected = W.SetIsSelected
    leaderIcon.SetWidgetSize = W.SetWidgetSize
    leaderIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end
