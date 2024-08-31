---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

local L = CUF.L
local DB = CUF.DB

local Menu = CUF.Menu

---@class GeneralTab: Menu.Tab
local generalTab = {}
generalTab.id = "generalTab"
generalTab.height = 400
generalTab.paneHeight = 17

Menu:AddTab(generalTab)

function generalTab:IsShown()
    return generalTab.window and generalTab.window:IsShown()
end

-------------------------------------------------
-- MARK: Layout Profile
-------------------------------------------------

---@class LayoutProfile: Frame
local layoutProfile = {}
layoutProfile.height = 100

function layoutProfile:SetLayoutItems()
    if not generalTab:IsShown() then return end
    --CUF:Log("|cff00ccffgeneralTab SetLayoutItems|r")

    local dropdownItems = {}

    for layoutName, _ in pairs(CellDB.layouts) do
        tinsert(dropdownItems, {
            ["text"] = L[layoutName],
            ["value"] = layoutName,
            ["onClick"] = function()
                DB.SetMasterLayout(layoutName)
                CUF:Fire("UpdateUnitButtons")
                CUF:Fire("UpdateWidget", layoutName)
            end,
        })
    end

    layoutProfile.layoutDropdown:SetItems(dropdownItems)
    layoutProfile.layoutDropdown:SetSelectedValue(DB.GetMasterLayout())
end

CUF:RegisterCallback("UpdateLayout", "CUF_LayoutProfile_SetLayoutItems", layoutProfile.SetLayoutItems)
CUF:RegisterCallback("LoadPageDB", "CUF_LayoutProfile_SetLayoutItems", layoutProfile.SetLayoutItems)

function layoutProfile:CreateLayoutProfile()
    CUF:Log("|cff00ccffgeneralTab CreateLayoutProfile|r")

    local sectionWidth = generalTab.window:GetWidth() / 2

    local layoutPane = Cell:CreateTitledPane(generalTab.window, L.MasterLayout, sectionWidth, generalTab.paneHeight)
    layoutPane:SetPoint("TOPLEFT")

    ---@type CellDropdown
    self.layoutDropdown = Cell:CreateDropdown(generalTab.window, sectionWidth - 10)
    self.layoutDropdown:SetPoint("TOPLEFT", layoutPane, "BOTTOMLEFT", 5, -10)
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

    layoutProfile:CreateLayoutProfile()
end
