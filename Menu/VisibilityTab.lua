---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L

local DB = CUF.DB
local const = CUF.constants

---@class CUF.Menu
local Menu = CUF.Menu

local unitFramesTab = Menu.unitFramesTab

---@class VisibilityTab: Menu.Tab
local VisibilityTab = {}
VisibilityTab.id = "Visibility"
VisibilityTab.height = 90
VisibilityTab.paneHeight = 17

unitFramesTab:AddTab(VisibilityTab)

-------------------------------------------------
-- MARK: Show/Hide
-------------------------------------------------

---@param unit Unit
function VisibilityTab:ShowTab(unit)
    if not self.window then
        self:Create()

        self.window:Show()
        self.LoadUnit(unit)
        return
    end

    self.window:Show()
    self.LoadUnit(unit)
end

function VisibilityTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    self.window:Hide()
end

function VisibilityTab:IsShown()
    return self.window and self.window:IsShown()
end

---@param unit Unit
function VisibilityTab.LoadUnit(unit)
    if not VisibilityTab:IsShown() then return end
    unit = unit or CUF.vars.selectedUnit

    local visibility = DB.SelectedLayoutTable()[unit].visibility
    VisibilityTab.unit = unit

    VisibilityTab.visibilityEditBox:SetText(visibility)
end

CUF:RegisterCallback("LoadPageDB", "FaderTab_LoadUnit", VisibilityTab.LoadUnit)

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function VisibilityTab:Create()
    local sectionWidth = unitFramesTab.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame_Fader", unitFramesTab.window,
        sectionWidth,
        self.height, true)
    self.window:SetPoint("TOPLEFT", unitFramesTab.tabAnchor, "TOPLEFT")
    self.unit = const.UNIT.PLAYER

    local checkBoxSection = CUF:CreateFrame("CUF_Menu_UnitFrame_Fader_CheckBoxSection", self.window, sectionWidth - 10,
        65, false, true)
    checkBoxSection:SetPoint("TOPLEFT", self.window, "TOPLEFT", 5, -5)

    local visibilityEditBox = CUF:CreateEditBox(checkBoxSection, checkBoxSection:GetWidth() - 20, 30, L["Visibility"])
    visibilityEditBox:SetPoint("TOPLEFT", 10, -25)
    self.visibilityEditBox = visibilityEditBox

    visibilityEditBox:SetScript("OnEnterPressed", function()
        visibilityEditBox:ClearFocus()
        local value = visibilityEditBox:GetText()
        DB.SelectedLayoutTable()[self.unit].visibility = value
        CUF:Fire("UpdateVisibility", self.unit)
    end)
end
