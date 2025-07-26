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
ColorTab.sectionsHeight = 0

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

    local pane = Cell.CreateTitledPane(section, L.ImportExportColors, section:GetWidth(), self.paneHeight)
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
-- MARK: Elements
-------------------------------------------------

--- Create a color picker
---@param which Defaults.Colors.Types
---@param colorName string
---@param colorTable table<string, RGBAOpt>
---@param parent Frame
---@return CUF.ColorSection.ColorPicker, number
local function CreateColorPicker(which, colorName, colorTable, parent)
    ---@class CUF.ColorSection.ColorPicker: CellColorPicker
    local cp = Cell.CreateColorPicker(parent, L[colorName], true)
    cp.id = colorName
    cp:SetColor(colorTable[colorName])
    cp.onChange = function(r, g, b, a)
        DB.SetColor(which, colorName, { r, g, b, a })
        if which == "castBar" or which == "shieldBar" or which == "healAbsorb" or which == "highlight"
            or which == "healPrediction" then
            CUF:Fire("UpdateWidget", DB.GetMasterLayout(), nil, which, const.OPTION_KIND.COLOR)
        elseif which == "essence"
            or which == "classResources"
            or which == "comboPoints"
            or which == "chi"
            or which == "runes"
            or which == "classBar" then
            CUF:Fire("UpdateWidget", DB.GetMasterLayout(), nil, "classBar", const.OPTION_KIND.COLOR)
        else
            CUF:Fire("UpdateAppearance", "color")
        end
    end
    cp.type = "colorPicker"

    local cpWidth = math.max(cp:GetWidth() + cp.label:GetWidth() + 5, (ColorTab.window:GetWidth() / 3) - 15)

    return cp, cpWidth
end

--- Create a separator title
---@param title string
---@param parent Frame
---@return Frame
local function CreateSeparatorTitle(title, parent)
    local sectionTitle = CUF:CreateFrame(nil, parent, 1, 1, true, true) --[[@as OptionTitle]]
    sectionTitle:SetPoint("TOPLEFT")
    sectionTitle.title = sectionTitle:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
    sectionTitle.title:SetText(L[title])
    sectionTitle.title:SetScale(1)
    sectionTitle.title:SetPoint("TOPLEFT")

    sectionTitle:SetHeight(sectionTitle.title:GetStringHeight())
    return sectionTitle
end

---- Create a texture dropdown
---@param which Defaults.Colors.Types
---@param colorName string
---@param colorTable table<string, RGBAOpt>
---@param parent Frame
---@return Frame
local function CreateTextureDropdown(which, colorName, colorTable, parent)
    ---@class CUF.ColorSection.Dropdown: CellDropdown
    local textureDropdown = Cell.CreateDropdown(parent, 200, "texture")
    textureDropdown:SetLabel(L[colorName])
    textureDropdown.id = colorName

    local textureDropdownItems = {}
    for name, tex in pairs(Util:GetTextures()) do
        table.insert(textureDropdownItems, {
            ["text"] = name,
            ["texture"] = tex,
            ["onClick"] = function()
                DB.SetColor(which, colorName, tex)
                CUF:Fire("UpdateWidget", DB.GetMasterLayout(), nil, which, const.OPTION_KIND.COLOR)
            end,
        })
    end
    textureDropdown:SetItems(textureDropdownItems)
    textureDropdown:SetSelected(Util.textureToName[colorTable[colorName]], colorTable[colorName])

    return textureDropdown
end

---- Create a texture dropdown
---@param which Defaults.Colors.Types
---@param colorName string
---@param colorTable table<string, RGBAOpt>
---@param parent Frame
---@param percent boolean
---@return CUF.ColorSection.Slider
local function CreateSlider(which, colorName, colorTable, parent, percent)
    ---@class CUF.ColorSection.Slider: CellSlider
    local slider = Cell.CreateSlider(L[colorName], parent, 0, 100, 200, 1, function(value)
        DB.SetColor(which, colorName, value / (percent and 100 or 1))
        CUF:Fire("UpdateAppearance", "color")
    end, nil, percent)
    slider.id = colorName
    slider.type = "slider"

    local val = colorTable[colorName] * (percent and 100 or 1) --[[@as number]]
    slider:SetValue(val)

    return slider
end

---@param which Defaults.Colors.Types
---@param colorName string
---@param colorTable table<string, RGBAOpt>
---@param parent Frame
---@return CUF.ColorSection.Checkbox, number
local function CreateCheckbox(which, colorName, colorTable, parent)
    ---@class CUF.ColorSection.Checkbox: CellCheckButton
    local cb = Cell.CreateCheckButton(parent, L[colorName], function(checked)
        DB.SetColor(which, colorName, checked)
        CUF:Fire("UpdateAppearance", "color")
        CUF:Fire("UpdateWidget", DB.GetMasterLayout())
    end)

    local val = colorTable[colorName] --[[@as boolean]]
    cb:SetChecked(val)
    cb.type = "toggle"

    return cb, math.max(cb:GetWidth() + cb.label:GetWidth() + 5, (ColorTab.window:GetWidth() / 3) - 15)
end

-------------------------------------------------
-- MARK: Sections
-------------------------------------------------

--- Update all elements with the current color table
---
--- This is called when a new color table is imported
function ColorTab:UpdateColors()
    for _, section in pairs(self.colorSections) do
        local colorTable = DB.GetColors()[section.id]
        for _, cp in pairs(section.cps) do
            if cp.type == "toggle" then
                cp:SetChecked(colorTable[cp.id])
            elseif cp.type == "colorPicker" then
                ---@cast cp CUF.ColorSection.ColorPicker
                cp:SetColor(colorTable[cp.id])
            end
        end
        for _, dropdown in pairs(section.dropdowns) do
            dropdown:SetSelected(Util.textureToName[colorTable[dropdown.id]], colorTable[dropdown.id])
        end
        for _, slider in pairs(section.sliders) do
            slider:SetValue(colorTable[slider.id])
        end
    end
end

--- Create sections with color pickers for each color type
function ColorTab:CreateSections()
    local cpGap = (self.window:GetWidth() / 3) * 0.80
    local sectionGap = 10

    ---@class ColorTab.colorSection: Frame
    ---@field scrollFrame CellScrollFrame
    local colorSection = CUF:CreateFrame("CUF_Menu_ColorSection", self.window,
        self.window:GetWidth(),
        self.window:GetHeight() - self.importExportSection:GetHeight() - (sectionGap * 2), true, true)
    colorSection:SetPoint("TOPLEFT", self.importExportSection, "BOTTOMLEFT", 0, -sectionGap)

    Cell.CreateScrollFrame(colorSection)
    colorSection.scrollFrame:SetScrollStep(50)

    self.colorSections = {} ---@type CUF.ColorSection[]

    local prevSection
    local colorTables = DB.GetColors()
    local colorOrder = CUF.Defaults.ColorsMenuOrder

    for which, order in pairs(colorOrder) do
        ---@class CUF.ColorSection: Frame
        local section = CUF:CreateFrame(colorSection:GetName() .. "_" .. Util:ToTitleCase(which),
            colorSection.scrollFrame.content, self.window:GetWidth() - 10, 1, false, true)
        section.id = which
        section.cps = {} ---@type (CUF.ColorSection.ColorPicker|CUF.ColorSection.Checkbox)[]
        section.dropdowns = {} ---@type CUF.ColorSection.Dropdown[]
        section.sliders = {} ---@type CUF.ColorSection.Slider[]

        local sectionTitle = CUF:CreateFrame(nil, section, 1, 1, true, true) --[[@as OptionTitle]]
        sectionTitle:SetPoint("TOPLEFT", sectionGap, -sectionGap)
        sectionTitle.title = sectionTitle:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
        sectionTitle.title:SetText(L[which])
        sectionTitle.title:SetScale(1.2)
        sectionTitle.title:SetPoint("TOPLEFT")
        sectionTitle:SetHeight(sectionTitle.title:GetStringHeight())

        local gridLayout = {
            maxColumns = 3,
            currentRow = 1,
            currentColumn = 1,
            currentColumnWidth = sectionGap * 2,
            firstInRow = nil
        }
        local baseHeight = 35

        ---@type table<string, RGBAOpt>
        local colorTable = colorTables[which]
        for _, info in ipairs(order) do
            local colorName, colorType = info[1], info[2]
            local element, elementWidth

            if colorType == "separator" then
                element = CreateSeparatorTitle(colorName, section)
                gridLayout.currentColumn = 1
                gridLayout.currentColumnWidth = section:GetWidth()
                gridLayout.currentRow = gridLayout.currentRow + 1

                element:SetPoint("TOPLEFT", gridLayout.firstInRow, "BOTTOMLEFT", 0, -sectionGap)
                gridLayout.firstInRow = element
                baseHeight = baseHeight + element:GetHeight() + sectionGap
            elseif colorType == "newline" then
                gridLayout.currentColumn = 0
                gridLayout.currentRow = gridLayout.currentRow + 1
                gridLayout.currentColumnWidth = 0
            elseif colorType == "texture" then
                element = CreateTextureDropdown(which, colorName, colorTable, section)
                gridLayout.currentColumn = 1
                gridLayout.currentColumnWidth = section:GetWidth()

                if gridLayout.currentRow > 1 then
                    gridLayout.currentRow = gridLayout.currentRow + 1
                end

                -- Start of a new row
                if not gridLayout.firstInRow then
                    element:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -sectionGap * 2.5)
                else
                    element:SetPoint("TOPLEFT", gridLayout.firstInRow, "BOTTOMLEFT", 0, -sectionGap * 2.5)
                end
                gridLayout.firstInRow = element

                baseHeight = baseHeight + element:GetHeight() + sectionGap * 2.5

                table.insert(section.dropdowns, element)
            elseif colorType:match("slider") then
                element = CreateSlider(which, colorName, colorTable, section, colorType:match("percent"))
                gridLayout.currentColumn = 1
                gridLayout.currentColumnWidth = section:GetWidth()

                if gridLayout.currentRow > 1 then
                    gridLayout.currentRow = gridLayout.currentRow + 1
                end

                -- Start of a new row
                if not gridLayout.firstInRow then
                    element:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -sectionGap * 2.5)
                    baseHeight = baseHeight + element:GetHeight() + sectionGap * 3
                else
                    if gridLayout.firstInRow.type == "slider" then
                        element:SetPoint("TOPLEFT", gridLayout.firstInRow, "BOTTOMLEFT", 0, -sectionGap * 4.5)
                        baseHeight = baseHeight + element:GetHeight() * 3 + sectionGap * 3
                    else
                        element:SetPoint("TOPLEFT", gridLayout.firstInRow, "BOTTOMLEFT", 0, -sectionGap * 2.5)
                        baseHeight = baseHeight + element:GetHeight() + sectionGap * 3
                    end
                end
                gridLayout.firstInRow = element

                table.insert(section.sliders, element)
            elseif colorType == "rgb" or colorType == "toggle" then
                if colorType == "toggle" then
                    element, elementWidth = CreateCheckbox(which, colorName, colorTable, section)
                else
                    element, elementWidth = CreateColorPicker(which, colorName, colorTable, section)
                end

                -- Move to the next column, or wrap to the next row if necessary
                if gridLayout.currentColumn > gridLayout.maxColumns
                    or (gridLayout.currentColumnWidth + elementWidth) > (section:GetWidth()) then
                    gridLayout.currentColumn = 1
                    gridLayout.currentRow = gridLayout.currentRow + 1
                    gridLayout.currentColumnWidth = sectionGap * 2
                end

                gridLayout.currentColumnWidth = gridLayout.currentColumnWidth + elementWidth
                table.insert(section.cps, element)

                -- Position the element in the grid
                if gridLayout.currentColumn == 1 then
                    -- Start of a new row
                    if not gridLayout.firstInRow then
                        element:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -sectionGap)
                    else
                        element:SetPoint("TOPLEFT", gridLayout.firstInRow, "BOTTOMLEFT", 0, -sectionGap)
                    end
                    gridLayout.firstInRow = element
                    baseHeight = baseHeight + element:GetHeight() + sectionGap
                else
                    -- Position to the right of the previous element
                    element:SetPoint("TOPLEFT", section.cps[#section.cps - 1], "TOPRIGHT", cpGap, 0)
                end
            end

            gridLayout.currentColumn = gridLayout.currentColumn + 1
        end

        section:SetHeight(baseHeight)
        self.sectionsHeight = self.sectionsHeight + baseHeight + sectionGap

        if not prevSection then
            section:SetPoint("TOPLEFT", colorSection.scrollFrame.content)
        else
            section:SetPoint("TOPLEFT", prevSection, "BOTTOMLEFT", 0, -sectionGap)
        end

        prevSection = section
        table.insert(self.colorSections, section)
    end

    self.colorSection = colorSection
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

    self.colorSection.scrollFrame:SetContentHeight(self.sectionsHeight)
    self.colorSection.scrollFrame:ResetScroll()
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

    self.window = CUF:CreateFrame("CUF_Menu_Color", Menu.window,
        sectionWidth,
        400, true)
    self.window:SetPoint("TOPLEFT", Menu.tabAnchor, "TOPLEFT")

    self:CreateImportExport()
    self:CreateSections()
end

Menu:AddTab(ColorTab)
