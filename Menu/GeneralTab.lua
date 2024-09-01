---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

local L = CUF.L
local DB = CUF.DB
local Menu = CUF.Menu
local Util = CUF.Util

---@class GeneralTab: Menu.Tab
local generalTab = {}
generalTab.id = "generalTab"
generalTab.height = 170
generalTab.paneHeight = 17

Menu:AddTab(generalTab)

function generalTab:IsShown()
    return generalTab.window and generalTab.window:IsShown()
end

-------------------------------------------------
-- MARK: Copy From
-------------------------------------------------

---@class CopyFrom: Frame
local copyLayoutFrom = {}

function copyLayoutFrom.SetLayoutItems()
    if not generalTab:IsShown() then return end
    --CUF:Log("|cff00ccffgeneralTab SetCopyFromItems|r")

    local dropdownItems = {}

    for _, layoutName in pairs(Util:GetAllLayoutNames()) do
        if layoutName ~= DB.GetMasterLayout() then
            tinsert(dropdownItems, {
                ["text"] = Util:FormatLayoutName(layoutName),
                ["value"] = layoutName,
                ["onClick"] = function()
                    Menu:ShowPopup(
                        string.format(L.CopyFromPopUp,
                            Util:FormatLayoutName(layoutName, true),
                            Util:FormatLayoutName(DB.GetMasterLayout(), true)),
                        function()
                            DB.CopyFullLayout(layoutName, DB.GetMasterLayout())
                            CUF:Fire("UpdateUnitButtons")
                            CUF:Fire("UpdateWidget", DB.GetMasterLayout())
                        end)
                    copyLayoutFrom.layoutDropdown:ClearSelected()
                end,
            })
        end
    end

    copyLayoutFrom.layoutDropdown:SetItems(dropdownItems)
    copyLayoutFrom.layoutDropdown:ClearSelected()
end

CUF:RegisterCallback("UpdateLayout", "CUF_CopyFrom_SetLayoutItems", copyLayoutFrom.SetLayoutItems)
CUF:RegisterCallback("LoadPageDB", "CUF_CopyFrom_SetLayoutItems", copyLayoutFrom.SetLayoutItems)

function copyLayoutFrom:Create()
    --CUF:Log("|cff00ccffgeneralTab CreateCopyFrom|r")

    local sectionWidth = (generalTab.window:GetWidth() / 2) - 5

    self.frame = CUF:CreateFrame(nil, generalTab.window, sectionWidth, 50, true, true)
    self.frame:SetPoint("TOPRIGHT")

    local pane = Cell:CreateTitledPane(self.frame, L.CopyLayoutFrom, sectionWidth, generalTab.paneHeight)
    pane:SetPoint("TOPLEFT")

    ---@type CellDropdown
    self.layoutDropdown = Cell:CreateDropdown(self.frame, sectionWidth - 10)
    self.layoutDropdown:SetPoint("TOPLEFT", pane, "BOTTOMLEFT", 5, -10)
    CUF:SetTooltips(self.layoutDropdown, "ANCHOR_TOPLEFT", 0, 3, L.CopyLayoutFrom, L.CopyFromTooltip)
end

-------------------------------------------------
-- MARK: Layout Profile
-------------------------------------------------

---@class LayoutProfile: Frame
local layoutProfile = {}

function layoutProfile:SetLayoutItems()
    if not generalTab:IsShown() then return end
    --CUF:Log("|cff00ccffgeneralTab SetLayoutItems|r")

    local dropdownItems = { {
        ["text"] = L.CUFLayoutMasterNone,
        ["value"] = "CUFLayoutMasterNone",
        ["onClick"] = function()
            DB.SetMasterLayout("CUFLayoutMasterNone")
            CUF:Fire("UpdateUnitButtons")
            CUF:Fire("UpdateWidget", Cell.vars.currentLayout)
            copyLayoutFrom.SetLayoutItems()
        end,
    } }

    for _, layoutName in pairs(Util:GetAllLayoutNames()) do
        tinsert(dropdownItems, {
            ---@diagnostic disable-next-line: undefined-field
            ["text"] = layoutName == "default" and _G.DEFAULT or layoutName,
            ["value"] = layoutName,
            ["onClick"] = function()
                DB.SetMasterLayout(layoutName)
                CUF:Fire("UpdateUnitButtons")
                CUF:Fire("UpdateWidget", layoutName)
                copyLayoutFrom.SetLayoutItems()
            end,
        })
    end

    layoutProfile.layoutDropdown:SetItems(dropdownItems)
    layoutProfile.layoutDropdown:SetSelectedValue(DB.GetMasterLayout(true))
end

CUF:RegisterCallback("UpdateLayout", "CUF_LayoutProfile_SetLayoutItems", layoutProfile.SetLayoutItems)
CUF:RegisterCallback("LoadPageDB", "CUF_LayoutProfile_SetLayoutItems", layoutProfile.SetLayoutItems)

function layoutProfile:Create()
    --CUF:Log("|cff00ccffgeneralTab CreateLayoutProfile|r")

    local sectionWidth = (generalTab.window:GetWidth() / 2) - 5

    self.frame = CUF:CreateFrame(nil, generalTab.window, sectionWidth, 50, true, true)
    self.frame:SetPoint("TOPLEFT")

    local layoutPane = Cell:CreateTitledPane(self.frame, L.MasterLayout, sectionWidth, generalTab.paneHeight)
    layoutPane:SetPoint("TOPLEFT")

    ---@type CellDropdown
    self.layoutDropdown = Cell:CreateDropdown(self.frame, sectionWidth - 10)
    self.layoutDropdown:SetPoint("TOPLEFT", layoutPane, "BOTTOMLEFT", 5, -10)
    CUF:SetTooltips(self.layoutDropdown, "ANCHOR_TOPLEFT", 0, 3, L.MasterLayout, L.MasterLayoutTooltip)
end

-------------------------------------------------
-- MARK: Backup
-------------------------------------------------

---@class LayoutBackup: Frame
local layoutBackup = {}

--- Show popup to restore a backup
---@param backupType "manual"|"automatic"
function layoutBackup:OnRestoreSelect(backupType)
    local currentBackupInfo = DB.GetBackupInfo(backupType)
    local popupMsg = string.format(L.RestoreBackupPopup, currentBackupInfo)

    Menu:ShowPopup(
        popupMsg,
        function()
            DB.RestoreFromBackup("automatic")
            layoutBackup.Update()
        end)
end

--- Update the dropdown items (maybe we didnt havent manual back but we do now)
---
--- Update tooltips
function layoutBackup.Update()
    if not generalTab:IsShown() then return end

    layoutBackup.restoreDropdown:ClearItems()
    for backupName, _ in pairs(CUF_DB.backups) do
        layoutBackup.restoreDropdown:AddItem({
            ["text"] = L["Backup_" .. backupName],
            ["value"] = backupName,
            ["onClick"] = function()
                layoutBackup:OnRestoreSelect(backupName)
            end,
        })
    end

    layoutBackup.restoreDropdown:ClearSelected()

    local restoreTooltip = string.format(L.RestoreBackupTooltip, DB.GetBackupInfo("automatic"),
        DB.GetBackupInfo("manual"))
    CUF:SetTooltips(layoutBackup.restoreDropdown, "ANCHOR_TOPLEFT", 0, 3, L.RestoreBackup, restoreTooltip)

    local createTooltip = string.format(L.CreateBackupTooltip, Util:GetAllLayoutNamesAsString(true))
    CUF:SetTooltips(layoutBackup.createManulBackup, "ANCHOR_TOPLEFT", 0, 3, L.CreateBackup, createTooltip)
end

function layoutBackup:Create()
    local sectionWidth = (generalTab.window:GetWidth() / 2) - 5

    self.frame = CUF:CreateFrame(nil, generalTab.window, sectionWidth, 85, true, true)
    self.frame:SetPoint("TOPLEFT", layoutProfile.frame, "BOTTOMLEFT", 0, -20)

    local layoutPane = Cell:CreateTitledPane(self.frame, L.Backups, sectionWidth, generalTab.paneHeight)
    layoutPane:SetPoint("TOPLEFT")

    ---@type CellDropdown
    self.restoreDropdown = Cell:CreateDropdown(self.frame, sectionWidth - 10)
    self.restoreDropdown:SetPoint("TOPLEFT", layoutPane, "BOTTOMLEFT", 5, -20)
    self.restoreDropdown:SetLabel(L.RestoreBackup)

    self.createManulBackup = CUF:CreateButton(self.frame, L.CreateBackup, { sectionWidth - 10, 16 },
        function()
            local popupMsg = string.format(L.CreateBackupPopup, Util:GetAllLayoutNamesAsString(true))

            local currentBackupInfo = DB.GetBackupInfo("manual")
            if currentBackupInfo ~= "" then
                popupMsg = popupMsg .. "\n\n" .. string.format(L.BackupOverwrite, currentBackupInfo)
            end

            Menu:ShowPopup(
                popupMsg,
                function()
                    DB.CreateManulBackup()
                    layoutBackup.Update()
                end)
        end)
    self.createManulBackup:SetPoint("TOPLEFT", self.restoreDropdown, "BOTTOMLEFT", 0, -10)
end

-------------------------------------------------
-- MARK: Show/Hide
-------------------------------------------------

function generalTab:ShowTab()
    CUF:Log("|cff00ccffShow generalTab|r")
    if not self.window then
        self:Create()
        self.init = true
    end

    self.window:Show()
    layoutProfile:SetLayoutItems()
    copyLayoutFrom:SetLayoutItems()
    layoutBackup:Update()
end

function generalTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    CUF:Log("|cff00ccffHide generalTab|r")
    self.window:Hide()
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function generalTab:Create()
    CUF:Log("|cff00ccffCreate generalTab|r")

    local sectionWidth = Menu.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame", Menu.window,
        sectionWidth,
        self.height, true)
    self.window:SetPoint("TOPLEFT", Menu.tabAnchor, "TOPLEFT")

    layoutProfile:Create()
    copyLayoutFrom:Create()
    layoutBackup:Create()
end
