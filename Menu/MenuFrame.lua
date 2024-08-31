---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local F = Cell.funcs

local Builder = CUF.Builder
local Handler = CUF.Handler

---@class Menu.Tab
---@field id string
---@field window Frame
---@field Create function
---@field ShowTab function
---@field HideTab function

---@class MenuFrame
---@field window CellCombatFrame
---@field tabs table<string, Menu.Tab>
---@field tabsToAdd Menu.Tab[]
---@field tabButtons Menu.TabButton[]
---@field selectedTab Menu.Tab?
local menuWindow = {}
menuWindow.tabs = {}
menuWindow.tabsToAdd = {}
menuWindow.tabButtons = {}
menuWindow.baseWidth = 450
menuWindow.paneHeight = 22
menuWindow.paneBuffer = 10
menuWindow.inset = 5

CUF.MenuWindow = menuWindow

function menuWindow:InitTabs()
    --CUF:Log("menuWindow - InitUnits")
    local prevButton
    local prevAnchor
    local idx = 1

    for _, tab in pairs(self.tabsToAdd) do
        ---@cast tab Menu.Tab
        self.tabs[tab.id] = tab

        ---@class Menu.TabButton: CellButton
        local tabButton = CUF:CreateButton(self.window, L[tab.id], { 100, self.paneHeight })
        tabButton.id = tab.id

        if prevButton then
            -- Max 4 buttons per row
            if idx % 4 == 0 then
                tabButton:SetPoint("BOTTOMRIGHT", prevAnchor, "TOPRIGHT", 0, 0)
                idx = 1
                prevAnchor = tabButton

                self.window:SetHeight(self.window:GetHeight() + self.paneHeight)
                self.tabPane:SetHeight(self.tabPane:GetHeight() + self.paneHeight)
            else
                tabButton:SetPoint("TOPLEFT", prevButton, "TOPRIGHT", 1)
                idx = idx + 1
            end
        else
            tabButton:SetPoint("BOTTOMLEFT", self.tabPane, "BOTTOMLEFT", 0, 1)
            prevAnchor = tabButton
        end
        prevButton = tabButton

        table.insert(self.tabButtons, tabButton)
    end

    Cell:CreateButtonGroup(self.tabButtons, function(which, b)
        self:SetTab(which)
    end)
end

function menuWindow:ShowMenu()
    CUF:Log("|cff00ccffShow Menu|r")
    if not self.window then
        self:Create()

        self.window:Show()

        self.tabButtons[1]:Click()

        self.init = true
        CUF.vars.isMenuOpen = true

        return
    end

    self.window:Show()
    CUF.vars.isMenuOpen = true
end

function menuWindow:HideMenu()
    if not self.window or not self.window:IsShown() then return end
    CUF:Log("|cff00ccffHide Menu|r")
    self.window:Hide()

    CUF.vars.isMenuOpen = false
    Handler.UpdateSelected()
end

---@param which string
function menuWindow:SetTab(which)
    -- Hide old unit
    if self.selectedTab then
        self.selectedTab:HideTab()
    end

    self.selectedTab = self.tabs[which]
    self.selectedTab:ShowTab()

    self.window:SetHeight(self.selectedTab.window:GetHeight() + self.paneHeight + self.paneBuffer)
end

---@param tab Menu.Tab
function menuWindow:AddTab(tab)
    table.insert(self.tabsToAdd, tab)
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function menuWindow:Create()
    CUF:Log("|cff00ccffCreate Menu|r")
    local optionsFrame = Cell.frames.optionsFrame

    ---@class CellCombatFrame
    self.window = CUF:CreateFrame("CUF_Menu", optionsFrame, self.baseWidth, 300)
    self.window:SetPoint("TOPRIGHT", CellLayoutsPreviewButton, "BOTTOMRIGHT", 0, -self.inset)

    -- mask
    F:ApplyCombatProtectionToFrame(self.window)
    Cell:CreateMask(self.window, nil, { 1, -1, -1, 1 })
    self.window.mask:Hide()

    -- Tabs
    self.tabPane = Cell:CreateTitledPane(self.window, nil, self.baseWidth, self.paneHeight)
    self.tabPane:SetPoint("TOPLEFT")

    -- Repoint so it's anchored to bottom
    self.tabPane.line:ClearAllPoints()
    self.tabPane.line:SetPoint("BOTTOMLEFT", self.tabPane, "BOTTOMLEFT")
    self.tabPane.line:SetPoint("BOTTOMRIGHT", self.tabPane, "BOTTOMRIGHT")

    local gap = self.inset * 2
    local anchorWidth = self.baseWidth - gap
    self.tabAnchor = CUF:CreateFrame(nil, self.tabPane, anchorWidth, 1, true)
    self.tabAnchor:SetPoint("TOPLEFT", self.tabPane, "BOTTOMLEFT", self.inset, -self.paneBuffer)

    self:InitTabs()

    hooksecurefunc(optionsFrame, "Hide", function()
        self:HideMenu()
    end)
end
