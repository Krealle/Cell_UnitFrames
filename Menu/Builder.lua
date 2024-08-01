---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.widgets.Handler
local Handler = CUF.widgetsHandler
---@class CUF.constants
local const = CUF.constants

---@class CUF.builder
local Builder = {}
Builder.optionBufferY = 50
Builder.optionBufferX = 25
Builder.singleOptionHeight = 20
Builder.singleOptionWidth = 117
Builder.dualOptionWidth = 117 * 2
Builder.tripleOptionWidth = 117 * 3
---@enum MenuOptions
Builder.MenuOptions = {
    TextColor = 1,
    TextColorWithWidth = 2,
    TextColorWithPowerType = 3,
    Anchor = 4,
    Font = 5,
    HealthFormat = 6,
    PowerFormat = 7,
    AuraOptions = 8,
    ExtraAnchor = 9,
    Orientation = 10,
}

CUF.Builder = Builder

-------------------------------------------------
-- MARK: Build Menu
-------------------------------------------------

---@class WidgetsMenuPageArgs
---@field widgetName WIDGET_KIND
---@field menuHeight number
---@field pageName string
---@field options table<MenuOptions>

---@param menuFrame MenuFrame
---@param widgetName WIDGET_KIND
---@param menuHeight number
---@param pageName string
---@param ... MenuOptions
---@return WidgetsMenuPage
function Builder:CreateWidgetMenuPage(menuFrame, widgetName, menuHeight, pageName, ...)
    ---@class WidgetsMenuPage
    local widgetPage = {}
    widgetPage.frame = CreateFrame("Frame", nil, menuFrame.widgetAnchor)
    widgetPage.id = widgetName
    widgetPage.height = menuHeight

    -- button
    widgetPage.button = Cell:CreateButton(menuFrame.widgetAnchor, L[pageName], "accent-hover", { 85, 17 })
    widgetPage.button.id = widgetName

    local enabledCheckBox = self:CreatEnabledCheckBox(widgetPage.frame, widgetName)
    enabledCheckBox:SetPoint("TOPLEFT", widgetPage.frame, 5, -27)

    ---@type Frame
    local prevOption = enabledCheckBox
    for _, option in pairs({ ... }) do
        --CUF:Debug("|cffff7777MenuBuilder:|r", option)
        local optPage = Builder.MenuFuncs[option](self, widgetPage.frame, widgetName)
        if option == Builder.MenuOptions.HealthFormat or option == Builder.MenuOptions.PowerFormat then
            optPage:SetPoint("TOPLEFT", prevOption, "TOPRIGHT", self.optionBufferX, 0)
        else
            optPage:SetPoint("TOPLEFT", prevOption, 0, -self.optionBufferY)
            prevOption = optPage
        end
    end

    return widgetPage
end

-------------------------------------------------
-- MARK: Builder
-------------------------------------------------

---@param option frame|table
---@param prevOptions Frame
function Builder:AnchorBelow(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, 0, -self.optionBufferY)
end

---@param option frame|table
---@param prevOptions Frame
function Builder:AnchorRight(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, "TOPRIGHT", self.optionBufferX, 0)
end

-------------------------------------------------
-- MARK: CheckBox
-------------------------------------------------

--[[ ---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CUFCheckBox
function Builder:CreatCheckBox(parent, widgetName, title, dbFn)
    ---@class CUFCheckBox: Frame
    local f = CreateFrame("Frame", nil, parent)
    P:Size(f, 117, 20)
    f:SetPoint("TOPLEFT", parent, 5, -27)

    local checkbox = Cell:CreateCheckButton(f, L[title], function(checked)
        CUF.vars.selectedWidgetTable[widgetName].enabled = checked
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.ENABLED)
    end)
    checkbox:SetPoint("TOPLEFT")
    checkbox:SetChecked(CUF.vars.selectedWidgetTable[widgetName].enabled)

    local function LoadPageDB()
        checkbox:SetChecked(CUF.vars.selectedWidgetTable[widgetName].enabled)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CheckBox")

    return f
end ]]

-------------------------------------------------
-- MARK: Enabled
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return EnabledCheckBox
function Builder:CreatEnabledCheckBox(parent, widgetName)
    ---@class EnabledCheckBox
    local f = CreateFrame("Frame", nil, parent)
    P:Size(f, 117, 20)
    f:SetPoint("TOPLEFT", parent, 5, -27)

    local checkbox = Cell:CreateCheckButton(f, L["Enabled"], function(checked)
        CUF.vars.selectedWidgetTable[widgetName].enabled = checked
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.ENABLED)
    end)
    checkbox:SetPoint("TOPLEFT")
    checkbox:SetChecked(CUF.vars.selectedWidgetTable[widgetName].enabled)

    local function LoadPageDB()
        checkbox:SetChecked(CUF.vars.selectedWidgetTable[widgetName].enabled)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "Enabled")

    return f
end

-------------------------------------------------
-- MARK: Text Width
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
function Builder:CreateTextWidthOption(parent, widgetName)
    local f = CreateFrame("Frame", nil, parent)
    P:Size(f, 117, 20)

    local dropdown, percentDropdown, lengthEB, lengthEB2

    dropdown = Cell:CreateDropdown(f, 117)
    dropdown:SetPoint("TOPLEFT")
    dropdown:SetLabel(L["Text Width"])
    dropdown:SetItems({
        {
            ["text"] = L["Unlimited"],
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.type = "unlimited"
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
                percentDropdown:Hide()
                lengthEB:Hide()
                lengthEB2:Hide()
                lengthEB.value = nil
                lengthEB2.value = nil
            end,
        },
        {
            ["text"] = L["Percentage"],
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.type = "percentage"
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.75
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
                percentDropdown:SetSelectedValue(0.75)
                percentDropdown:Show()
                lengthEB:Hide()
                lengthEB2:Hide()
                lengthEB.value = nil
                lengthEB2.value = nil
            end,
        },
        {
            ["text"] = L["Length"],
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.type = "length"
                CUF.vars.selectedWidgetTable[widgetName].width.value = 5
                CUF.vars.selectedWidgetTable[widgetName].width.auxValue = 3
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
                percentDropdown:Hide()
                lengthEB:SetText(5)
                lengthEB:Show()
                lengthEB2:SetText(3)
                lengthEB2:Show()
                lengthEB.value = 5
                lengthEB2.value = 3
            end,
        },
    })

    percentDropdown = Cell:CreateDropdown(f, 75)
    percentDropdown:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", self.optionBufferX, 0)
    Cell:SetTooltips(percentDropdown.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])
    percentDropdown:SetItems({
        {
            ["text"] = "100%",
            ["value"] = 1,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 1
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
        {
            ["text"] = "75%",
            ["value"] = 0.75,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.75
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
        {
            ["text"] = "50%",
            ["value"] = 0.5,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.5
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
        {
            ["text"] = "25%",
            ["value"] = 0.25,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.25
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
    })

    lengthEB = Cell:CreateEditBox(f, 34, 20, false, false, true)
    lengthEB:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", self.optionBufferX, 0)

    lengthEB.text = lengthEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    lengthEB.text:SetText(L["En"])
    lengthEB.text:SetPoint("BOTTOMLEFT", lengthEB, "TOPLEFT", 0, 1)

    lengthEB.confirmBtn = Cell:CreateButton(lengthEB, "OK", "accent", { 27, 20 })
    lengthEB.confirmBtn:SetPoint("TOPLEFT", lengthEB, "TOPRIGHT", -1, 0)
    lengthEB.confirmBtn:Hide()
    lengthEB.confirmBtn:SetScript("OnHide", function()
        lengthEB.confirmBtn:Hide()
    end)
    lengthEB.confirmBtn:SetScript("OnClick", function()
        local length = tonumber(lengthEB:GetText()) or 5
        lengthEB:SetText(length)
        lengthEB:ClearFocus()
        lengthEB.confirmBtn:Hide()
        lengthEB.value = length

        CUF.vars.selectedWidgetTable[widgetName].width.value = length
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND
            .TEXT_WIDTH)
    end)

    lengthEB:SetScript("OnTextChanged", function(txt, userChanged)
        if userChanged then
            local length = tonumber(txt:GetText())
            if length and length ~= lengthEB.value and length ~= 0 then
                lengthEB.confirmBtn:Show()
            else
                lengthEB.confirmBtn:Hide()
            end
        end
    end)

    lengthEB2 = Cell:CreateEditBox(f, 33, 20, false, false, true)
    lengthEB2:SetPoint("TOPLEFT", lengthEB, "TOPRIGHT", 25, 0)

    lengthEB2.text = lengthEB2:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    lengthEB2.text:SetText(L["Non-En"])
    lengthEB2.text:SetPoint("BOTTOMLEFT", lengthEB2, "TOPLEFT", 0, 1)

    lengthEB2.confirmBtn = Cell:CreateButton(lengthEB2, "OK", "accent", { 27, 20 })
    lengthEB2.confirmBtn:SetPoint("TOPLEFT", lengthEB2, "TOPRIGHT", -1, 0)
    lengthEB2.confirmBtn:Hide()
    lengthEB2.confirmBtn:SetScript("OnHide", function()
        lengthEB2.confirmBtn:Hide()
    end)
    lengthEB2.confirmBtn:SetScript("OnClick", function()
        local length = tonumber(lengthEB2:GetText()) or 3
        lengthEB2:SetText(length)
        lengthEB2:ClearFocus()
        lengthEB2.confirmBtn:Hide()
        lengthEB2.value = length

        CUF.vars.selectedWidgetTable[widgetName].width.auxValue = length
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND
            .TEXT_WIDTH)
    end)

    lengthEB2:SetScript("OnTextChanged", function(txt, userChanged)
        if userChanged then
            local length = tonumber(txt:GetText())
            if length and length ~= lengthEB2.value and length ~= 0 then
                lengthEB2.confirmBtn:Show()
            else
                lengthEB2.confirmBtn:Hide()
            end
        end
    end)

    ---@param t FontWidth
    function f:SetNameWidth(t)
        if t.type == "unlimited" then
            dropdown:SetSelectedItem(1)
            percentDropdown:Hide()
            lengthEB:Hide()
            lengthEB2:Hide()
        elseif t.type == "percentage" then
            dropdown:SetSelectedItem(2)
            percentDropdown:SetSelectedValue(t.value)
            percentDropdown:Show()
            lengthEB:Hide()
            lengthEB2:Hide()
        elseif t.type == "length" then
            dropdown:SetSelectedItem(3)
            lengthEB:SetText(t.value)
            lengthEB.value = t.value
            lengthEB:Show()
            lengthEB2:SetText(t.auxValue)
            lengthEB2.value = t.auxValue
            lengthEB2:Show()
            percentDropdown:Hide()
        end
    end

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f:SetNameWidth(pageLayoutTable.width)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "NameWidth")


    return f
end

-------------------------------------------------
-- MARK: Text Color
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param includeWidth? boolean
---@param includePowerType? boolean
---@return UnitColorOptions
function Builder:CreateTextColorOptions(parent, widgetName, includeWidth, includePowerType)
    ---@class UnitColorOptions
    local f = CreateFrame("Frame", "UnitColorOptions" .. widgetName, parent)
    P:Size(f, 117, 20)

    f.colorPicker = Cell:CreateColorPicker(f, "", false, function(r, g, b, a)
        CUF.vars.selectedWidgetTable[widgetName].color.rgb[1] = r
        CUF.vars.selectedWidgetTable[widgetName].color.rgb[2] = g
        CUF.vars.selectedWidgetTable[widgetName].color.rgb[3] = b
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND
            .TEXT_COLOR, "rgb")
    end)

    f.dropdown = Cell:CreateDropdown(f, 117)
    f.dropdown:SetPoint("TOPLEFT")
    f.dropdown:SetLabel(L["Color"])
    local items = {
        {
            ["text"] = L["Class Color"],
            ["value"] = const.ColorType.CLASS_COLOR,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].color.type = const.ColorType.CLASS_COLOR
                f.colorPicker:Hide()
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_COLOR, "type")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = const.ColorType.CUSTOM,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].color.type = const.ColorType.CUSTOM
                f.colorPicker:Show()
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_COLOR, "type")
            end,
        },
    }
    if includePowerType then
        tinsert(items, {
            ["text"] = L["Power Color"],
            ["value"] = const.PowerColorType.POWER_COLOR,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].color.type = const.PowerColorType.POWER_COLOR
                f.colorPicker:Hide()
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_COLOR, "type")
            end,
        })
    end
    f.dropdown:SetItems(items)

    f.colorPicker:SetPoint("LEFT", f.dropdown, "RIGHT", 2, 0)

    if includeWidth then
        f.nameWidth = Builder:CreateTextWidthOption(parent, widgetName)
        f.nameWidth:SetPoint("TOPLEFT", f, "TOPRIGHT", self.optionBufferX, 0)
    end

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.colorPicker:SetColor(pageLayoutTable.color.rgb[1], pageLayoutTable.color.rgb[2],
            pageLayoutTable.color.rgb[3])
        f.dropdown:SetSelectedValue(pageLayoutTable.color.type)
        if pageLayoutTable.color.type == const.ColorType.CUSTOM then
            f.colorPicker:Show()
        else
            f.colorPicker:Hide()
        end
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "UnitColorOptions")

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return UnitColorOptions
function Builder:CreateTextColorOptionsWithWidth(parent, widgetName)
    return self:CreateTextColorOptions(parent, widgetName, true)
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return UnitColorOptions
function Builder:CreateTextColorOptionsWithPowerType(parent, widgetName)
    return self:CreateTextColorOptions(parent, widgetName, false, true)
end

-------------------------------------------------
-- MARK: Anchor
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return AnchorOptions
function Builder:CreateAnchorOptions(parent, widgetName)
    ---@class AnchorOptions: Frame
    local f = CreateFrame("Frame", "AnchorOptions" .. widgetName, parent)
    P:Size(f, self.tripleOptionWidth, self.singleOptionHeight)

    f.nameAnchorDropdown = Cell:CreateDropdown(parent, 117)
    f.nameAnchorDropdown:SetPoint("TOPLEFT", f)
    f.nameAnchorDropdown:SetLabel(L["Anchor Point"])

    local items = {}
    for _, v in pairs(CUF.anchorPoints) do
        tinsert(items, {
            ["text"] = L[v],
            ["value"] = v,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].position.anchor = v
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.POSITION, "anchor")
            end,
        })
    end
    f.nameAnchorDropdown:SetItems(items)

    f.nameXSlider = Cell:CreateSlider(L["X Offset"], parent, -100, 100, 117, 1)
    f.nameXSlider:SetPoint("TOPLEFT", f.nameAnchorDropdown, "TOPRIGHT", self.optionBufferX, 0)
    f.nameXSlider.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].position.offsetX = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.POSITION,
            "offsetX")
    end

    f.nameYSlider = Cell:CreateSlider(L["Y Offset"], parent, -100, 100, 117, 1)
    f.nameYSlider:SetPoint("TOPLEFT", f.nameXSlider, "TOPRIGHT", self.optionBufferX, 0)
    f.nameYSlider.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].position.offsetY = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.POSITION,
            "offsetY")
    end

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.nameAnchorDropdown:SetSelectedValue(pageLayoutTable.position.anchor)
        f.nameXSlider:SetValue(pageLayoutTable.position.offsetX)
        f.nameYSlider:SetValue(pageLayoutTable.position.offsetY)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "AnchorOptions")

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return ExtraAnchorOptions
function Builder:CreateExtraAnchorOptions(parent, widgetName)
    ---@class ExtraAnchorOptions: Frame
    local f = CreateFrame("Frame", "ExtraAnchorOptions" .. widgetName, parent)
    P:Size(f, self.singleOptionWidth, self.singleOptionHeight)

    f.extraAnchorDropdown = Cell:CreateDropdown(parent, 117)
    f.extraAnchorDropdown:SetPoint("TOPLEFT", f)
    f.extraAnchorDropdown:SetLabel(L["To UnitButton's"])

    local items = {}
    for _, v in pairs(CUF.anchorPoints) do
        tinsert(items, {
            ["text"] = L[v],
            ["value"] = v,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].position.extraAnchor = v
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.POSITION, "extraAnchor")
            end,
        })
    end
    f.extraAnchorDropdown:SetItems(items)

    local function LoadPageDB()
        ---@type PositionOpt
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName].position

        f.extraAnchorDropdown:SetSelectedValue(pageLayoutTable.extraAnchor)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "ExtraAnchorOptions")

    return f
end

-------------------------------------------------
-- MARK: Orientation
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return OrientationOptions
function Builder:CreateOrientationOptions(parent, widgetName)
    ---@class OrientationOptions: Frame
    local f = CreateFrame("Frame", "OrientationOptions" .. widgetName, parent)
    P:Size(f, self.singleOptionWidth, self.singleOptionHeight)

    f.orientationDropdown = Cell:CreateDropdown(parent, 117)
    f.orientationDropdown:SetPoint("TOPLEFT", f)
    f.orientationDropdown:SetLabel(L["Orientation"])

    local orientationItems = {}
    for _, v in pairs({ const.AURA_ORIENTATION.RIGHT_TO_LEFT, const.AURA_ORIENTATION.LEFT_TO_RIGHT,
        const.AURA_ORIENTATION.BOTTOM_TO_TOP, const.AURA_ORIENTATION.TOP_TO_BOTTOM }) do
        tinsert(orientationItems, {
            ["text"] = L[v],
            ["value"] = v,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].orientation = v
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.ORIENTATION)
            end,
        })
    end
    f.orientationDropdown:SetItems(orientationItems)

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.orientationDropdown:SetSelectedValue(pageLayoutTable.orientation)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "OrientationOptions")

    return f
end

-------------------------------------------------
-- MARK: Font
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return FontOptions
function Builder:CreateFontOptions(parent, widgetName)
    ---@class FontOptions: Frame
    local f = CreateFrame("Frame", "FontOptions" .. widgetName, parent)
    P:Size(f, self.tripleOptionWidth, self.singleOptionHeight)

    f.nameFontDropdown = Cell:CreateDropdown(parent, 117)
    f.nameFontDropdown:SetPoint("TOPLEFT", f)
    f.nameFontDropdown:SetLabel(L["Font"])

    local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
    f.defaultFontName = defaultFontName
    f.fonts = fonts
    for _, item in pairs(items) do
        item["onClick"] = function()
            CUF.vars.selectedWidgetTable[widgetName].font.style = item["text"]
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.FONT,
                "name")
        end
    end
    f.nameFontDropdown:SetItems(items)

    function f.nameFontDropdown:SetFont(font)
        f.nameFontDropdown:SetSelected(font, fonts[font])
    end

    f.nameOutlineDropdown = Cell:CreateDropdown(parent, 117)
    f.nameOutlineDropdown:SetPoint("TOPLEFT", f.nameFontDropdown, "TOPRIGHT", self.optionBufferX, 0)
    f.nameOutlineDropdown:SetLabel(L["Outline"])

    items = {}
    for _, v in pairs(CUF.outlines) do
        tinsert(items, {
            ["text"] = L[v],
            ["value"] = v,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].font.outline = v
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.FONT, "outline")
            end,
        })
    end
    f.nameOutlineDropdown:SetItems(items)

    f.nameSizeSilder = Cell:CreateSlider(L["Size"], parent, 5, 50, 117, 1)
    f.nameSizeSilder:SetPoint("TOPLEFT", f.nameOutlineDropdown, "TOPRIGHT", self.optionBufferX, 0)
    f.nameSizeSilder.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].font.size = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.FONT,
            "size")
    end

    f.nameShadowCB = Cell:CreateCheckButton(parent, L["Shadow"], function(checked)
        CUF.vars.selectedWidgetTable[widgetName].font.shadow = checked
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.FONT,
            "shadow")
    end)
    f.nameShadowCB:SetPoint("TOPLEFT", f.nameFontDropdown, "BOTTOMLEFT", 0, -10)

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.nameSizeSilder:SetValue(pageLayoutTable.font.size)
        f.nameOutlineDropdown:SetSelectedValue(pageLayoutTable.font.outline)
        f.nameShadowCB:SetChecked(pageLayoutTable.font.shadow)
        f.nameFontDropdown:SetSelected(pageLayoutTable.font.style, f.fonts,
            f.defaultFontName)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "FontOptions")

    return f
end

-------------------------------------------------
-- MARK: Health Format
-------------------------------------------------

local healthFormats = {
    [const.HealthTextFormat.PERCENTAGE] = "32%",
    [const.HealthTextFormat.PERCENTAGE_ABSORBS] = "32+25% |cFFA7A7A7+" .. L["shields"],
    [const.HealthTextFormat.PERCENTAGE_ABSORBS_MERGED] = "57% |cFFA7A7A7+" .. L["shields"],
    [const.HealthTextFormat.PERCENTAGE_DEFICIT] = "-67%",
    [const.HealthTextFormat.NUMBER] = "21377",
    [const.HealthTextFormat.NUMBER_SHORT] = F:FormatNumber(21377),
    [const.HealthTextFormat.NUMBER_ABSORBS_SHORT] = F:FormatNumber(21377) ..
        "+" .. F:FormatNumber(16384) .. " |cFFA7A7A7+" .. L["shields"],
    [const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT] = F:FormatNumber(21377 + 16384) ..
        " |cFFA7A7A7+" .. L["shields"],
    [const.HealthTextFormat.NUMBER_DEFICIT] = "-44158",
    [const.HealthTextFormat.NUMBER_DEFICIT_SHORT] = F:FormatNumber(-44158),
    [const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE] = F:FormatNumber(21377) .. " 32% |cFFA7A7A7HP",
    [const.HealthTextFormat.ABSORBS_ONLY] = "16384 |cFFA7A7A7" .. L["shields"],
    [const.HealthTextFormat.ABSORBS_ONLY_SHORT] = F:FormatNumber(16384) .. " |cFFA7A7A7" .. L["shields"],
    [const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE] = "25% |cFFA7A7A7" .. L["shields"],
}

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return HealthFormatOptions
function Builder:CreateHealthFormatOptions(parent, widgetName)
    ---@class HealthFormatOptions
    local f = CreateFrame("Frame", "HealthFormatOptions" .. widgetName, parent)
    P:Size(f, self.singleOptionHeight, self.singleOptionHeight)

    f.format = Cell:CreateDropdown(parent, self.dualOptionWidth)
    f.format:SetPoint("TOPLEFT", f)
    f.format:SetLabel(L["Format"])

    f.format:SetItems({
        {
            ["text"] = "32%",
            ["value"] = const.HealthTextFormat.PERCENTAGE,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.PERCENTAGE
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "32%+25% |cFFA7A7A7+" .. L["shields"],
            ["value"] = const.HealthTextFormat.PERCENTAGE_ABSORBS,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.PERCENTAGE_ABSORBS
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "57% |cFFA7A7A7+" .. L["shields"],
            ["value"] = const.HealthTextFormat.PERCENTAGE_ABSORBS_MERGED,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.PERCENTAGE_ABSORBS_MERGED
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "-67%",
            ["value"] = const.HealthTextFormat.PERCENTAGE_DEFICIT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.PERCENTAGE_DEFICIT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "21377",
            ["value"] = const.HealthTextFormat.NUMBER,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.NUMBER
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(21377),
            ["value"] = const.HealthTextFormat.NUMBER_SHORT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.NUMBER_SHORT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(21377) .. "+" .. F:FormatNumber(16384) .. " |cFFA7A7A7+" .. L["shields"],
            ["value"] = const.HealthTextFormat.NUMBER_ABSORBS_SHORT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.NUMBER_ABSORBS_SHORT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(21377 + 16384) .. " |cFFA7A7A7+" .. L["shields"],
            ["value"] = const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "-44158",
            ["value"] = const.HealthTextFormat.NUMBER_DEFICIT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.NUMBER_DEFICIT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(-44158),
            ["value"] = const.HealthTextFormat.NUMBER_DEFICIT_SHORT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.NUMBER_DEFICIT_SHORT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(21377) .. " 32% |cFFA7A7A7HP",
            ["value"] = const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "16384 |cFFA7A7A7" .. L["shields"],
            ["value"] = const.HealthTextFormat.ABSORBS_ONLY,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.ABSORBS_ONLY
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(16384) .. " |cFFA7A7A7" .. L["shields"],
            ["value"] = const.HealthTextFormat.ABSORBS_ONLY_SHORT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.ABSORBS_ONLY_SHORT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
        {
            ["text"] = "25% |cFFA7A7A7" .. L["shields"],
            ["value"] = const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.HEALTH_FORMAT)
            end,
        },
    })

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.format:SetSelectedValue(pageLayoutTable.format)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "HealthFormatOptions")

    return f
end

-------------------------------------------------
-- MARK: Power Format
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return PowerFormatOptions
function Builder:CreatePowerFormatOptions(parent, widgetName)
    ---@class PowerFormatOptions: Frame
    local f = CreateFrame("Frame", "PowerFormatOptions" .. widgetName, parent)
    P:Size(f, self.singleOptionHeight, self.singleOptionHeight)

    f.format = Cell:CreateDropdown(parent, self.dualOptionWidth)
    f.format:SetPoint("TOPLEFT", f)
    f.format:SetLabel(L["Format"])

    f.format:SetItems({
        {
            ["text"] = "32%",
            ["value"] = const.PowerTextFormat.PERCENTAGE,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.PowerTextFormat.PERCENTAGE
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.POWER_FORMAT)
            end,
        },
        {
            ["text"] = "21377",
            ["value"] = const.PowerTextFormat.NUMBER,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.PowerTextFormat.NUMBER
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.POWER_FORMAT)
            end,
        },
        {
            ["text"] = F:FormatNumber(21377),
            ["value"] = const.PowerTextFormat.NUMBER_SHORT,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].format = const.PowerTextFormat.NUMBER_SHORT
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.POWER_FORMAT)
            end,
        },
    })

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.format:SetSelectedValue(pageLayoutTable.format)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "PowerFormatOptions")

    return f
end

-------------------------------------------------
-- MARK: Size
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return SizeOptions
function Builder:CreateSizeOptions(parent, widgetName)
    ---@class SizeOptions: Frame
    local f = CreateFrame("Frame", "AnchorOptions" .. widgetName, parent)
    P:Size(f, self.tripleOptionWidth, self.singleOptionHeight)

    f.sizeWidthSlider = Cell:CreateSlider(L["Width"], parent, -100, 100, 117, 1)
    f.sizeWidthSlider:SetPoint("TOPLEFT", f)
    f.sizeWidthSlider.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].size.width = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.SIZE,
            "width")
    end

    f.sizeHeightSlider = Cell:CreateSlider(L["Height"], parent, -100, 100, 117, 1)
    f.sizeHeightSlider:SetPoint("TOPLEFT", f.sizeWidthSlider, "TOPRIGHT", self.optionBufferX, 0)
    f.sizeHeightSlider.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].size.height = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND.SIZE,
            "height")
    end

    local function LoadPageDB()
        ---@type SizeOpt
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName].size

        f.sizeWidthSlider:SetValue(pageLayoutTable.width)
        f.sizeHeightSlider:SetValue(pageLayoutTable.height)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "SizeOptions")

    return f
end

-------------------------------------------------
-- MARK: Aura Menu
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return AuraOptions
function Builder:CreateAuraOptions(parent, widgetName)
    ---@class AuraOptions: Frame
    local f = CreateFrame("Frame", "AuraOptions" .. widgetName, parent)
    P:Size(f, self.tripleOptionWidth, self.singleOptionHeight)

    --- Top Options
    f.anchorOptions = self:CreateAnchorOptions(parent, widgetName)
    f.anchorOptions:SetPoint("TOPLEFT", f)

    -- Middle Options
    f.extraAnchorDropdown = self:CreateExtraAnchorOptions(parent, widgetName)
    self:AnchorBelow(f.extraAnchorDropdown, f.anchorOptions)

    f.orientationDropdown = self:CreateOrientationOptions(parent, widgetName)
    self:AnchorRight(f.orientationDropdown, f.extraAnchorDropdown)

    -- Bottom Options
    f.sizeOptions = self:CreateSizeOptions(parent, widgetName)
    Builder:AnchorBelow(f.sizeOptions, f.extraAnchorDropdown)

    --[[ local function LoadPageDB()
        ---@type AuraWidgetTable
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.extraAnchorDropdown:SetSelectedValue(pageLayoutTable.position.extraAnchor)
        f.orientationAnchorDropdown:SetSelectedValue(pageLayoutTable.orientation)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "AuraOptions") ]]

    return f
end

-------------------------------------------------
-- MARK: MenuBuilder.MenuFuncs
-- Down here because of annotations
-------------------------------------------------

Builder.MenuFuncs = {
    [Builder.MenuOptions.TextColor] = Builder.CreateTextColorOptions,
    [Builder.MenuOptions.TextColorWithWidth] = Builder.CreateTextColorOptionsWithWidth,
    [Builder.MenuOptions.TextColorWithPowerType] = Builder.CreateTextColorOptionsWithPowerType,
    [Builder.MenuOptions.Anchor] = Builder.CreateAnchorOptions,
    [Builder.MenuOptions.ExtraAnchor] = Builder.CreateExtraAnchorOptions,
    [Builder.MenuOptions.Font] = Builder.CreateFontOptions,
    [Builder.MenuOptions.HealthFormat] = Builder.CreateHealthFormatOptions,
    [Builder.MenuOptions.PowerFormat] = Builder.CreatePowerFormatOptions,
    [Builder.MenuOptions.AuraOptions] = Builder.CreateAuraOptions,
    [Builder.MenuOptions.Orientation] = Builder.CreateOrientationOptions,
}
