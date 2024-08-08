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

menu:AddWidget(const.WIDGET_KIND.ROLE_ICON,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.SingleSize,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateRoleIconWidget(button, unit, setting, subSetting)
    U:UnitFrame_UpdateRoleIcon(button)
end

Handler:RegisterWidget(W.UpdateRoleIconWidget, const.WIDGET_KIND.ROLE_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateRoleIcon(button)
    local unit = button.states.displayedUnit
    if not unit then return end

    local role = UnitGroupRolesAssigned(unit)
    button.states.role = role

    local roleIcon = button.widgets.roleIcon

    if roleIcon.enabled then
        roleIcon:SetRole(role)
    else
        roleIcon:Hide()
    end
end

-------------------------------------------------
-- MARK: Funcs
-------------------------------------------------
local ICON_PATH = "Interface\\AddOns\\Cell\\Media\\Roles\\"

---@param self RoleIconWidget
---@param role string
local function RoleIcon_SetRole(self, role)
    self.tex:SetTexCoord(0, 1, 0, 1)
    self.tex:SetVertexColor(1, 1, 1)

    if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
        self.tex:SetTexture(ICON_PATH .. "Default_" .. role)
        self:Show()
    else
        self:Hide()
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateRoleIcon(button, buttonName)
    ---@class RoleIconWidget: Frame
    local roleIcon = CreateFrame("Frame", buttonName .. "RoleIcon", button)
    button.widgets.roleIcon = roleIcon

    roleIcon:SetPoint("TOPLEFT", 0, 0)
    roleIcon.enabled = false
    roleIcon.id = const.WIDGET_KIND.ROLE_ICON

    roleIcon.tex = roleIcon:CreateTexture(nil, "ARTWORK")
    roleIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    roleIcon.tex:SetAllPoints(roleIcon)

    roleIcon.SetRole = RoleIcon_SetRole

    roleIcon.SetEnabled = W.SetEnabled
    roleIcon.SetPosition = W.SetPosition
    roleIcon._SetIsSelected = W.SetIsSelected
    roleIcon.SetWidgetSize = W.SetWidgetSize
    roleIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end
