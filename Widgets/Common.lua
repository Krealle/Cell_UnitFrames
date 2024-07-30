---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.widgets.builder
local Builder = {}
Builder.optionBufferY = 50
Builder.optionBufferX = 30
Builder.singleOptionHeight = 20
Builder.singleOptionWidth = 117
Builder.dualOptionWidth = 117 * 2
Builder.tripleOptionWidth = 117 * 3

W.Builder = Builder

---@class CUF.Util
local Util = CUF.Util
---@class CUF.widgets.Handler
local Handler = CUF.widgetsHandler

-------------------------------------------------
-- MARK: Builder
-------------------------------------------------

---@param option frame|table
---@param parent Frame
---@param prevOptions? Frame
function Builder:AnchorBelow(option, parent, prevOptions)
    if prevOptions then
        option:SetPoint("TOPLEFT", prevOptions, 0, -self.optionBufferY)
    else
        option:SetPoint("TOPLEFT", parent, 5, -42)
    end
end

---@param parent Frame
---@param widgetName Widgets
---@return EnabledCheckBox
function Builder:CreatEnabledCheckBox(parent, widgetName)
    ---@class EnabledCheckBox
    local f = CreateFrame("Frame", nil, parent)
    P:Size(f, 117, 20)
    f:SetPoint("TOPLEFT", parent, 5, -27)

    local checkbox = Cell:CreateCheckButton(f, L["Enabled"], function(checked)
        CUF.vars.selectedWidgetTable[widgetName].enabled = checked
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
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
-- MARK: CreateNameWidth
-------------------------------------------------

---@param parent Frame
---@param widgetName Widgets
function Builder:CreateNameWidthOption(parent, widgetName)
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
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
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
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
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
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
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
    percentDropdown:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", 30, 0)
    Cell:SetTooltips(percentDropdown.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])
    percentDropdown:SetItems({
        {
            ["text"] = "100%",
            ["value"] = 1,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 1
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        },
        {
            ["text"] = "75%",
            ["value"] = 0.75,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.75
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        },
        {
            ["text"] = "50%",
            ["value"] = 0.5,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.5
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        },
        {
            ["text"] = "25%",
            ["value"] = 0.25,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].width.value = 0.25
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        },
    })

    lengthEB = Cell:CreateEditBox(f, 34, 20, false, false, true)
    lengthEB:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", 30, 0)

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
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
    end)

    lengthEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            local length = tonumber(self:GetText())
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
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
    end)

    lengthEB2:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            local length = tonumber(self:GetText())
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
-- MARK: CreateUnitColorOptions
-------------------------------------------------

---@param parent Frame
---@param widgetName Widgets
---@param prevOptions? Frame
---@return UnitColorOptions
function Builder:CreateUnitColorOptions(parent, widgetName, prevOptions)
    ---@class UnitColorOptions
    local f = CreateFrame("Frame", "UnitColorOptions" .. widgetName, parent)
    P:Size(f, 117, 20)
    Builder:AnchorBelow(f, parent, prevOptions)

    f.colorPicker = Cell:CreateColorPicker(f, "", false, function(r, g, b, a)
        CUF.vars.selectedWidgetTable[widgetName].color.rgb[1] = r
        CUF.vars.selectedWidgetTable[widgetName].color.rgb[2] = g
        CUF.vars.selectedWidgetTable[widgetName].color.rgb[3] = b
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
    end)

    f.dropdown = Cell:CreateDropdown(f, 117)
    f.dropdown:SetPoint("TOPLEFT")
    f.dropdown:SetLabel(L["Color"])
    f.dropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["value"] = "class_color",
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].color.type = "class_color"
                f.colorPicker:Hide()
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = "custom",
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].color.type = "custom"
                f.colorPicker:Show()
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        },
    })
    f.colorPicker:SetPoint("LEFT", f.dropdown, "RIGHT", 2, 0)

    local function LoadPageDB()
        local pageLayoutTable = CUF.vars.selectedWidgetTable[widgetName]

        f.colorPicker:SetColor(pageLayoutTable.color.rgb[1], pageLayoutTable.color.rgb[2],
            pageLayoutTable.color.rgb[3])
        f.dropdown:SetSelectedValue(pageLayoutTable.color.type)
        if pageLayoutTable.color.type == "custom" then
            f.colorPicker:Show()
        else
            f.colorPicker:Hide()
        end
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "UnitColorOptions")

    return f
end

-------------------------------------------------
-- MARK: CreateAnchorOptions
-------------------------------------------------

---@param parent Frame
---@param widgetName Widgets
---@param prevOptions? Frame
---@return AnchorOptions
function Builder:CreateAnchorOptions(parent, widgetName, prevOptions)
    ---@class AnchorOptions
    local f = CreateFrame("Frame", "AnchorOptions" .. widgetName, parent)
    P:Size(f, self.tripleOptionWidth, self.singleOptionHeight)
    Builder:AnchorBelow(f, parent, prevOptions)

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
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        })
    end
    f.nameAnchorDropdown:SetItems(items)

    f.nameXSlider = Cell:CreateSlider(L["X Offset"], parent, -100, 100, 117, 1)
    f.nameXSlider:SetPoint("TOPLEFT", f.nameAnchorDropdown, "TOPRIGHT", self.optionBufferX, 0)
    f.nameXSlider.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].position.offsetX = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
    end

    f.nameYSlider = Cell:CreateSlider(L["Y Offset"], parent, -100, 100, 117, 1)
    f.nameYSlider:SetPoint("TOPLEFT", f.nameXSlider, "TOPRIGHT", self.optionBufferX, 0)
    f.nameYSlider.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].position.offsetY = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
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

-------------------------------------------------
-- MARK: CreateFontOptions
-------------------------------------------------

---@param parent Frame
---@param widgetName Widgets
---@param prevOptions? Frame
---@return FontOptions
function Builder:CreateFontOptions(parent, widgetName, prevOptions)
    ---@class FontOptions
    local f = CreateFrame("Frame", "FontOptions" .. widgetName, parent)
    P:Size(f, self.tripleOptionWidth, self.singleOptionHeight)
    Builder:AnchorBelow(f, parent, prevOptions)

    f.nameFontDropdown = Cell:CreateDropdown(parent, 117)
    f.nameFontDropdown:SetPoint("TOPLEFT", f)
    f.nameFontDropdown:SetLabel(L["Font"])

    local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
    f.defaultFontName = defaultFontName
    f.fonts = fonts
    for _, item in pairs(items) do
        item["onClick"] = function()
            CUF.vars.selectedWidgetTable[widgetName].font.style = item["text"]
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
        end
    end
    f.nameFontDropdown:SetItems(items)

    function f.nameFontDropdown:SetFont(font)
        f.nameFontDropdown:SetSelected(font, fonts[font])
    end

    f.nameOutlineDropdown = Cell:CreateDropdown(parent, 117)
    f.nameOutlineDropdown:SetPoint("TOPLEFT", f.nameFontDropdown, "TOPRIGHT", 30, 0)
    f.nameOutlineDropdown:SetLabel(L["Outline"])

    items = {}
    for _, v in pairs(CUF.outlines) do
        tinsert(items, {
            ["text"] = L[v],
            ["value"] = v,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable[widgetName].font.outline = v
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
            end,
        })
    end
    f.nameOutlineDropdown:SetItems(items)

    f.nameSizeSilder = Cell:CreateSlider(L["Size"], parent, 5, 50, 117, 1)
    f.nameSizeSilder:SetPoint("TOPLEFT", f.nameOutlineDropdown, "TOPRIGHT", 30, 0)
    f.nameSizeSilder.afterValueChangedFn = function(value)
        CUF.vars.selectedWidgetTable[widgetName].font.size = value
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
    end

    f.nameShadowCB = Cell:CreateCheckButton(parent, L["Shadow"], function(checked)
        CUF.vars.selectedWidgetTable[widgetName].font.shadow = checked
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName)
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
