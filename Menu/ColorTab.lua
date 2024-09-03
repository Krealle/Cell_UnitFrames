---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

local L = CUF.L
local DB = CUF.DB
local Menu = CUF.Menu
local Util = CUF.Util
local const = CUF.constants

---@class ColorTab: Menu.Tab
local ColorTab = {}
ColorTab.id = "colorTab"
ColorTab.paneHeight = 17

-------------------------------------------------
-- MARK: Import / Export
-------------------------------------------------

function ColorTab:CreateImportExport()
    local section = CUF:CreateFrame(nil, self.window, self.window:GetWidth(), 45, true, true)
    section:SetPoint("TOPLEFT")
    self.importExportSection = section

    self.importExportFrame = CUF.ImportExport:CreateImportExportFrame("Colors",
        function(imported)
            Util:SafeImport(imported, CUF_DB.colors)

            self:UpdateColors()
            CUF:Fire("UpdateUnitButtons")
            CUF:Fire("UpdateWidget", DB.GetMasterLayout())
        end,
        DB.GetColors,
        function(imported)
            -- We allow missing keys here since we might be importing old versions
            -- And it's not a big deal if any new ones are missing
            return Util:IsValidCopy(imported, CUF.Defaults.Colors, true)
        end)

    local pane = Cell:CreateTitledPane(section, L.ImportExportColors, section:GetWidth(), self.paneHeight)
    pane:SetPoint("TOPLEFT")

    local buttonWidth = (section:GetWidth() / 2) - 5
    local importButton = CUF:CreateButton(section, L["Import"], { buttonWidth, 20 }, function()
        self.importExportFrame:ShowImport()
    end)
    importButton:SetPoint("TOPLEFT", pane, "BOTTOMLEFT", 0, -5)

    local exportButton = CUF:CreateButton(section, L["Export"], { buttonWidth, 20 }, function()
        self.importExportFrame:ShowExport()
    end)
    exportButton:SetPoint("TOPRIGHT", pane, "BOTTOMRIGHT", 0, -5)
end

-------------------------------------------------
-- MARK: Sections
-------------------------------------------------

--- Update all color pickers with the current color table
---
--- This is called when a new color table is imported
function ColorTab:UpdateColors()
    for _, section in pairs(self.colorSections) do
        local colorTable = DB.GetColors()[section.id]
        for _, cp in pairs(section.cps) do
            cp:SetColor(colorTable[cp.id])
        end
    end
end

--- Create a color picker
---@param which Defaults.Colors.Types
---@param colorName string
---@param colorTable table<string, RGBAOpt>
---@param parent Frame
---@return CUF.ColorSection.ColorPicker, number
local function CreateColorPicker(which, colorName, colorTable, parent)
    ---@class CUF.ColorSection.ColorPicker: CellColorPicker
    local cp = Cell:CreateColorPicker(parent, L[colorName], true)
    cp.id = colorName
    cp:SetColor(colorTable[colorName])
    cp.onChange = function(r, g, b, a)
        DB.SetColor(which, colorName, { r, g, b, a })
        CUF:Fire("UpdateWidget", DB.GetMasterLayout(), nil, which, const.OPTION_KIND.COLOR)
    end

    local cpWidth = math.max(cp:GetWidth() + cp.label:GetWidth() + 5, (ColorTab.window:GetWidth() / 3) - 15)

    return cp, cpWidth
end

--- Create a sperator title
---@param title string
---@param parent Frame
---@return Frame
local function CreateSperatorTitle(title, parent)
    local sectionTitle = CUF:CreateFrame(nil, parent, 1, 1, true, true) --[[@as OptionTitle]]
    sectionTitle:SetPoint("TOPLEFT", 0, -10)
    sectionTitle.title = sectionTitle:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
    sectionTitle.title:SetText(L[title])
    sectionTitle.title:SetScale(1)
    sectionTitle.title:SetPoint("TOPLEFT")

    return sectionTitle
end

--- Create sections with color pickers for each color type
function ColorTab:CreateSections()
    local heightPerCp = 25
    local cpGap = (self.window:GetWidth() / 3) * 0.80
    local sectionGap = 10

    self.colorSections = {} ---@type CUF.ColorSection[]

    local prevSection
    local colorTables = DB.GetColors()
    local colorOrder = CUF.Defaults.ColorsMenuOrder

    for which, order in pairs(colorOrder) do
        ---@class CUF.ColorSection: Frame
        local section = CUF:CreateFrame("ColorSection_" .. Util:ToTitleCase(which),
            self.window, self.window:GetWidth(), 1, false, true)
        section.id = which
        section.cps = {} ---@type CUF.ColorSection.ColorPicker[]

        local sectionTitle = CUF:CreateFrame(nil, section, 1, 1, true, true) --[[@as OptionTitle]]
        sectionTitle:SetPoint("TOPLEFT", sectionGap, -sectionGap)
        sectionTitle.title = sectionTitle:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
        sectionTitle.title:SetText(L[which])
        sectionTitle.title:SetScale(1.2)
        sectionTitle.title:SetPoint("TOPLEFT")

        local gridLayout = {
            maxColumns = 3,
            currentRow = 1,
            currentColumn = 1,
            currentColumnWidth = sectionGap * 2
        }

        ---@type table<string, RGBAOpt>
        local colorTable = colorTables[which]
        for _, info in ipairs(order) do
            local colorName, colorType = info[1], info[2]
            local element, elementWidth

            if colorType == "seperator" then
                element = CreateSperatorTitle(colorName, section)
                gridLayout.currentColumn = 1
                gridLayout.currentRow = gridLayout.currentRow + 1
                gridLayout.currentColumnWidth = section:GetWidth()
            elseif colorType == "rgb" then
                element, elementWidth = CreateColorPicker(which, colorName, colorTable, section)

                -- Move to the next column, or wrap to the next row if necessary
                if gridLayout.currentColumn > gridLayout.maxColumns
                    or (gridLayout.currentColumnWidth + elementWidth) > (section:GetWidth()) then
                    gridLayout.currentColumn = 1
                    gridLayout.currentRow = gridLayout.currentRow + 1
                    gridLayout.currentColumnWidth = sectionGap * 2
                end

                gridLayout.currentColumnWidth = gridLayout.currentColumnWidth + elementWidth

                tinsert(section.cps, element)
            end

            -- Position the element in the grid
            if gridLayout.currentColumn == 1 then
                -- Start of a new row
                element:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -(heightPerCp * gridLayout.currentRow))
            else
                -- Position to the right of the previous element
                element:SetPoint("TOPLEFT", section.cps[#section.cps - 1], "TOPRIGHT", cpGap, 0)
            end

            gridLayout.currentColumn = gridLayout.currentColumn + 1
        end

        section:SetHeight(40 + gridLayout.currentRow * heightPerCp)

        if not prevSection then
            self.window:SetHeight(self.importExportSection:GetHeight() + section:GetHeight() + (sectionGap * 2))
            section:SetPoint("TOPLEFT", self.importExportSection, "BOTTOMLEFT", 0, -sectionGap)
        else
            self.window:SetHeight(self.window:GetHeight() + section:GetHeight() + sectionGap)
            section:SetPoint("TOPLEFT", prevSection, "BOTTOMLEFT", 0, -sectionGap)
        end

        prevSection = section
        tinsert(self.colorSections, section)
    end
end

-------------------------------------------------
-- MARK: Show/Hide
-------------------------------------------------

function ColorTab:ShowTab()
    if not self.window then
        self:Create()
        self.init = true
    end

    self.window:Show()
end

function ColorTab:HideTab()
    if not self.window or not self.window:IsShown() then return end
    self.window:Hide()
end

function ColorTab:IsShown()
    return ColorTab.window and ColorTab.window:IsShown()
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

function ColorTab:Create()
    local sectionWidth = Menu.tabAnchor:GetWidth()

    self.window = CUF:CreateFrame("CUF_Menu_UnitFrame", Menu.window,
        sectionWidth,
        0, true)
    self.window:SetPoint("TOPLEFT", Menu.tabAnchor, "TOPLEFT")

    self:CreateImportExport()
    self:CreateSections()
end

Menu:AddTab(ColorTab)
