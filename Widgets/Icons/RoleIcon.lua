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
    button.widgets.roleIcon.Update(button)
end

Handler:RegisterWidget(W.UpdateRoleIconWidget, const.WIDGET_KIND.ROLE_ICON)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
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

---@param self RoleIconWidget
local function Enable(self)
    return true
end

---@param self RoleIconWidget
local function Disable(self)
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
    elseif self._isSelected then -- Preview
        self.tex:SetTexture(ICON_PATH .. "Default_" .. "DAMAGER")
        self:Show()
    else
        self:Hide()
    end
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateRoleIcon(button)
    ---@class RoleIconWidget: Frame, BaseWidget
    local roleIcon = CreateFrame("Frame", button:GetName() .. "_RoleIcon", button)
    button.widgets.roleIcon = roleIcon

    roleIcon:SetPoint("TOPLEFT", 0, 0)
    roleIcon.enabled = false
    roleIcon.id = const.WIDGET_KIND.ROLE_ICON
    roleIcon._isSelected = false
    roleIcon._owner = button

    roleIcon.tex = roleIcon:CreateTexture(nil, "ARTWORK")
    roleIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    roleIcon.tex:SetAllPoints(roleIcon)

    roleIcon.SetRole = RoleIcon_SetRole

    function roleIcon:_OnIsSelected()
        self.Update(self._owner)
    end

    roleIcon.Enable = Enable
    roleIcon.Disable = Disable
    roleIcon.Update = Update

    roleIcon.SetEnabled = W.SetEnabled
    roleIcon.SetPosition = W.SetPosition
    roleIcon._SetIsSelected = W.SetIsSelected
    roleIcon.SetWidgetSize = W.SetWidgetSize
    roleIcon.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.ROLE_ICON, W.CreateRoleIcon)
