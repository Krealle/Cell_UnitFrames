---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L

local DB = CUF.DB
local const = CUF.constants

---@class CUF.Menu
local Menu = CUF.Menu

local unitFramesTab = Menu.unitFramesTab

---@class FaderTab: Menu.Tab
local FaderTab = {}
FaderTab.id = "Fader"
FaderTab.height = 160
FaderTab.paneHeight = 17

unitFramesTab:AddTab(FaderTab)

-------------------------------------------------
-- MARK: Show/Hide
-------------------------------------------------

---@param unit Unit
function FaderTab:ShowTab(unit)
    if not self.window then
        self:Create()

        self.window:Show()
        self.LoadUnit(unit)
        return
    end

    self.window:Show()
    self.LoadUnit(unit)
end

function FaderTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    self.window:Hide()
end

function FaderTab:IsShown()
    return self.window and self.window:IsShown()
end

---@param unit Unit
function FaderTab.LoadUnit(unit)
    if not FaderTab:IsShown() then return end

    local fader = DB.GetSelectedWidgetTable(const.WIDGET_KIND.FADER, unit) --[[@as FaderWidgetTable]]
    if not fader then
        CUF:Warn("[FaderTab] No layout for unit:", unit)
        return
    end
    FaderTab.unit = unit

    if unit == const.UNIT.PLAYER then
        FaderTab.targetCB:SetText(L.target)

        FaderTab.rangeCB:Hide()
        FaderTab.unitTargetCB:Hide()
    else
        FaderTab.targetCB:SetText(L.PlayerTarget)

        FaderTab.rangeCB:Show()
        FaderTab.unitTargetCB:Show()
    end

    FaderTab.enabledCB:SetChecked(fader.enabled)
    FaderTab.combatCB:SetChecked(fader.combat)
    FaderTab.hoverCB:SetChecked(fader.hover)
    FaderTab.targetCB:SetChecked(fader.target)

    FaderTab.rangeCB:SetChecked(fader.range)
    FaderTab.unitTargetCB:SetChecked(fader.unitTarget)

    FaderTab.fadeDurationSlider:SetValue(fader.fadeDuration)
    FaderTab.maxAlphaSlider:SetValue(fader.maxAlpha)
    FaderTab.minAlphaSlider:SetValue(fader.minAlpha)

    FaderTab:SetEnabled(fader.enabled, fader.range)
end

CUF:RegisterCallback("LoadPageDB", "FaderTab_LoadUnit", FaderTab.LoadUnit)

---@param enabled boolean?
---@param rangeEnabled boolean?
function FaderTab:SetEnabled(enabled, rangeEnabled)
    enabled = enabled or self.enabledCB:GetChecked()
    rangeEnabled = rangeEnabled or self.rangeCB:GetChecked()

    self.combatCB:SetEnabled(enabled and not rangeEnabled)
    self.rangeCB:SetEnabled(enabled)
    self.hoverCB:SetEnabled(enabled)
    self.targetCB:SetEnabled(enabled and not rangeEnabled)
    self.unitTargetCB:SetEnabled(enabled and not rangeEnabled)

    self.fadeDurationSlider:SetEnabled(enabled)
    self.maxAlphaSlider:SetEnabled(enabled)
    self.minAlphaSlider:SetEnabled(enabled)
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function FaderTab:SetOption(opt, val)
    DB.GetSelectedWidgetTable("fader", self.unit)[opt] = val
    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, const.WIDGET_KIND.FADER, opt)
end

function FaderTab:Create()
    local sectionWidth = unitFramesTab.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame_Fader", unitFramesTab.window,
        sectionWidth,
        self.height, true)
    self.window:SetPoint("TOPLEFT", unitFramesTab.tabAnchor, "TOPLEFT")
    self.unit = const.UNIT.PLAYER

    local checkBoxSection = CUF:CreateFrame("CUF_Menu_UnitFrame_Fader_CheckBoxSection", self.window, sectionWidth - 10,
        65, false, true)
    checkBoxSection:SetPoint("TOPLEFT", self.window, "TOPLEFT", 5, -5)

    ---@type CellCheckButton
    local enabledCB = Cell.CreateCheckButton(checkBoxSection, L["Enabled"], function(checked, cb)
        self:SetOption("enabled", checked)
        self:SetEnabled(checked)
    end)
    enabledCB:SetPoint("TOPLEFT", 10, -8)
    self.enabledCB = enabledCB

    ---@type CellCheckButton
    local combatCB = Cell.CreateCheckButton(checkBoxSection, L.Combat, function(checked, cb)
        self:SetOption("combat", checked)
    end)
    combatCB:SetPoint("TOPLEFT", enabledCB, "BOTTOMLEFT", 0, -20)
    self.combatCB = combatCB

    ---@type CellCheckButton
    local hoverCB = Cell.CreateCheckButton(checkBoxSection, L.Hover, function(checked, cb)
        self:SetOption("hover", checked)
    end)
    hoverCB:SetPoint("TOPLEFT", combatCB, "TOPRIGHT", 100, 0)
    self.hoverCB = hoverCB

    ---@type CellCheckButton
    local targetCB = Cell.CreateCheckButton(checkBoxSection, L.target, function(checked, cb)
        self:SetOption("target", checked)
    end)
    targetCB:SetPoint("TOPLEFT", hoverCB, "TOPRIGHT", 100, 0)
    self.targetCB = targetCB

    ---@type CellCheckButton
    local rangeCB = Cell.CreateCheckButton(checkBoxSection, L.Range, function(checked, cb)
        self:SetOption("range", checked)
        self:SetEnabled(nil, checked)
    end)
    rangeCB:SetPoint("TOPLEFT", enabledCB, "TOPRIGHT", 100, 0)
    self.rangeCB = rangeCB

    ---@type CellCheckButton
    local unitTargetCB = Cell.CreateCheckButton(checkBoxSection, L.UnitTarget, function(checked, cb)
        self:SetOption("unitTarget", checked)
    end)
    unitTargetCB:SetPoint("TOPLEFT", rangeCB, "TOPRIGHT", 100, 0)
    self.unitTargetCB = unitTargetCB

    local sliderSection = CUF:CreateFrame("CUF_Menu_UnitFrame_Fader_SliderSection", self.window, sectionWidth - 10,
        60, false, true)
    sliderSection:SetPoint("TOPLEFT", checkBoxSection, "BOTTOMLEFT", 0, -10)

    ---@type CellSlider
    local fadeDurationSlider = Cell.CreateSlider(L.FadeDuration, sliderSection, 0, 4, 117, 0.01, function(value)
        self:SetOption("fadeDuration", value)
    end)
    fadeDurationSlider:SetPoint("TOPLEFT", sliderSection, "TOPLEFT", 5, -25)
    self.fadeDurationSlider = fadeDurationSlider

    ---@type CellSlider
    local minAlphaSlider = Cell.CreateSlider(L.MinAlpha, sliderSection, 0, 1, 117, 0.01, function(value)
        self:SetOption("minAlpha", value)
    end)
    minAlphaSlider:SetPoint("TOPLEFT", fadeDurationSlider, "TOPRIGHT", 30, 0)
    self.minAlphaSlider = minAlphaSlider

    ---@type CellSlider
    local maxAlphaSlider = Cell.CreateSlider(L.MaxAlpha, sliderSection, 0, 1, 117, 0.01, function(value)
        self:SetOption("maxAlpha", value)
    end)
    maxAlphaSlider:SetPoint("TOPLEFT", minAlphaSlider, "TOPRIGHT", 30, 0)
    self.maxAlphaSlider = maxAlphaSlider
end
