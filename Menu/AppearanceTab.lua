---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L

local DB = CUF.DB
local const = CUF.constants
local Util = CUF.Util

---@class CUF.Menu
local Menu = CUF.Menu

local unitFramesTab = Menu.unitFramesTab

---@class AppearanceTab: Menu.Tab
local AppearanceTab = {}
AppearanceTab.id = "Appearance"
AppearanceTab.height = 300
AppearanceTab.paneHeight = 17

unitFramesTab:AddTab(AppearanceTab)

-------------------------------------------------
-- MARK: Show/Hide
-------------------------------------------------

---@param unit Unit
function AppearanceTab:ShowTab(unit)
    if not self.window then
        self:Create()

        self.window:Show()
        self.LoadUnit(unit)
        return
    end

    self.window:Show()
    self.LoadUnit(unit)
end

function AppearanceTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    self.window:Hide()
end

function AppearanceTab:IsShown()
    return self.window and self.window:IsShown()
end

---@param unit Unit
function AppearanceTab.LoadUnit(unit)
    if not AppearanceTab:IsShown() then return end
    unit = unit or CUF.vars.selectedUnit

    local layout = DB.SelectedLayoutTable()[unit]
    if not layout then
        CUF:Warn("[AppearanceTab] No layout for unit:", unit)
        return
    end
    AppearanceTab.unit = unit

    AppearanceTab.healthBarColorTypeDropdown:SetSelectedValue(layout.healthBarColorType)
    AppearanceTab.healthLossColorTypeDropdown:SetSelectedValue(layout.healthLossColorType)
    AppearanceTab.healthLossColorTypeDropdown:SetEnabled(layout.healthBarColorType ~=
        CUF.constants.UnitButtonColorType.CELL)

    AppearanceTab.healthTextureDropdown:SetSelected(Util.textureToName[layout.healthBarTexture], layout.healthBarTexture)
    AppearanceTab.healthTextureDropdown:SetEnabled(layout.useHealthBarTexture)
    AppearanceTab.healthTextureEnable:SetChecked(layout.useHealthBarTexture)

    AppearanceTab.healthLossTextureDropdown:SetSelected(Util.textureToName[layout.healthLossTexture],
        layout.healthLossTexture)
    AppearanceTab.healthLossTextureDropdown:SetEnabled(layout.useHealthLossTexture)
    AppearanceTab.healthLossTextureEnable:SetChecked(layout.useHealthLossTexture)
end

CUF:RegisterCallback("LoadPageDB", "AppearanceTab_LoadUnit", AppearanceTab.LoadUnit)

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function AppearanceTab:Create()
    local sectionWidth = unitFramesTab.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame_Appearance", unitFramesTab.window,
        sectionWidth,
        self.height, true)
    self.window:SetPoint("TOPLEFT", unitFramesTab.tabAnchor, "TOPLEFT")
    self.unit = const.UNIT.PLAYER

    local section = CUF:CreateFrame("CUF_Menu_UnitFrame_Appearance_Section", self.window, sectionWidth - 10,
        200, false, true)
    section:SetPoint("TOPLEFT", self.window, "TOPLEFT", 5, -5)

    ---@type CellDropdown
    local healthBarColorTypeDropdown = Cell.CreateDropdown(section, 141)
    self.healthBarColorTypeDropdown = healthBarColorTypeDropdown
    healthBarColorTypeDropdown:SetPoint("TOPLEFT", 10, -25)
    healthBarColorTypeDropdown:SetLabel(L["Health Bar Color"])
    healthBarColorTypeDropdown:SetItems({
        {
            ["text"] = L["Cell"],
            ["value"] = CUF.constants.UnitButtonColorType.CELL,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthBarColorType = CUF.constants.UnitButtonColorType
                    .CELL
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
                self.healthLossColorTypeDropdown:SetEnabled(false)
            end,
        },
        {
            ["text"] = L["Class Color"],
            ["value"] = CUF.constants.UnitButtonColorType.CLASS_COLOR,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthBarColorType = CUF.constants.UnitButtonColorType
                    .CLASS_COLOR
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
                self.healthLossColorTypeDropdown:SetEnabled(true)
            end,
        },
        {
            ["text"] = L["Class Color (dark)"],
            ["value"] = CUF.constants.UnitButtonColorType.CLASS_COLOR_DARK,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthBarColorType = CUF.constants.UnitButtonColorType
                    .CLASS_COLOR_DARK
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
                self.healthLossColorTypeDropdown:SetEnabled(true)
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = CUF.constants.UnitButtonColorType.CUSTOM,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthBarColorType = CUF.constants.UnitButtonColorType
                    .CUSTOM
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
                self.healthLossColorTypeDropdown:SetEnabled(true)
            end,
        },
    })

    ---@type CellDropdown
    local healthLossColorTypeDropdown = Cell.CreateDropdown(section, 141)
    self.healthLossColorTypeDropdown = healthLossColorTypeDropdown
    healthLossColorTypeDropdown:SetLabel(L["Health Loss Color"])
    healthLossColorTypeDropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["value"] = CUF.constants.UnitButtonColorType.CLASS_COLOR,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthLossColorType = CUF.constants.UnitButtonColorType
                    .CLASS_COLOR
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
            end,
        },
        {
            ["text"] = L["Class Color (dark)"],
            ["value"] = CUF.constants.UnitButtonColorType.CLASS_COLOR_DARK,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthLossColorType = CUF.constants.UnitButtonColorType
                    .CLASS_COLOR_DARK
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = CUF.constants.UnitButtonColorType.CUSTOM,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthLossColorType = CUF.constants.UnitButtonColorType
                    .CUSTOM
                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "colorType", self.unit)
            end,
        },
    })
    healthLossColorTypeDropdown:SetPoint("TOPLEFT", healthBarColorTypeDropdown, "TOPRIGHT",
        5, 0)

    CUF:SetTooltips(healthBarColorTypeDropdown, "ANCHOR_TOPLEFT", 0, 3, L["Health Bar Color"],
        L.ColorTypeTooltip)

    ---@type CellDropdown
    local healthTextureDropdown = Cell.CreateDropdown(section, 200, "texture")
    self.healthTextureDropdown = healthTextureDropdown
    healthTextureDropdown:SetPoint("TOPLEFT", healthBarColorTypeDropdown, "BOTTOMLEFT", 0, -30)
    healthTextureDropdown:SetLabel(L.healthBarTexture)

    local textureDropdownItems = {}
    for name, tex in pairs(Util:GetTextures()) do
        table.insert(textureDropdownItems, {
            ["text"] = name,
            ["texture"] = tex,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthBarTexture = tex
                CUF:Fire("UpdateAppearance", "texture")
            end,
        })
    end
    healthTextureDropdown:SetItems(textureDropdownItems)

    ---@type CellCheckButton
    local healthTextureEnable = Cell.CreateCheckButton(section, L["Enabled"], function(checked, cb)
        DB.SelectedLayoutTable()[self.unit].useHealthBarTexture = checked
        healthTextureDropdown:SetEnabled(checked)
        CUF:Fire("UpdateAppearance", "texture")
    end)
    healthTextureEnable:SetPoint("LEFT", healthTextureDropdown, "RIGHT", 5, 0)
    self.healthTextureEnable = healthTextureEnable

    ---@type CellDropdown
    local healthLossTextureDropdown = Cell.CreateDropdown(section, 200, "texture")
    self.healthLossTextureDropdown = healthLossTextureDropdown
    healthLossTextureDropdown:SetPoint("TOPLEFT", healthTextureDropdown, "BOTTOMLEFT", 0, -30)
    healthLossTextureDropdown:SetLabel(L.healthLossTexture)

    table.wipe(textureDropdownItems)
    for name, tex in pairs(Util:GetTextures()) do
        table.insert(textureDropdownItems, {
            ["text"] = name,
            ["texture"] = tex,
            ["onClick"] = function()
                DB.SelectedLayoutTable()[self.unit].healthLossTexture = tex
                CUF:Fire("UpdateAppearance", "texture")
            end,
        })
    end
    healthLossTextureDropdown:SetItems(textureDropdownItems)

    ---@type CellCheckButton
    local healthLossTextureEnable = Cell.CreateCheckButton(section, L["Enabled"], function(checked, cb)
        DB.SelectedLayoutTable()[self.unit].useHealthLossTexture = checked
        healthLossTextureDropdown:SetEnabled(checked)
        CUF:Fire("UpdateAppearance", "texture")
    end)
    healthLossTextureEnable:SetPoint("LEFT", healthLossTextureDropdown, "RIGHT", 5, 0)
    self.healthLossTextureEnable = healthLossTextureEnable
end
