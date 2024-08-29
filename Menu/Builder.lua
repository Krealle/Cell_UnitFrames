---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local F = Cell.funcs

local Handler = CUF.Handler
local const = CUF.constants
local DB = CUF.DB
local Util = CUF.Util

---@class CUF.builder
local Builder = CUF.Builder
Builder.spacingY = 50
Builder.spacingX = 25
Builder.optionWidth = 420
Builder.singleOptionHeight = 20
Builder.singleOptionWidth = 117
Builder.dualOptionWidth = 117 * 2
Builder.tripleOptionWidth = 117 * 3

---@enum MenuOptions
Builder.MenuOptions = {
    TextColor = 1,
    TextWidth = 2,
    TextColorWithPowerType = 3,
    Anchor = 4,
    Font = 5,
    HealthFormat = 6,
    PowerFormat = 7,
    AuraIconOptions = 8,
    ExtraAnchor = 9,
    Orientation = 10,
    AuraStackFontOptions = 11,
    AuraDurationFontOptions = 12,
    AuraFilter = 13,
    AuraBlacklist = 14,
    AuraWhitelist = 15,
    Size = 16,
    SingleSize = 17,
    FrameLevel = 18,
    FullAnchor = 19,
    ColorPicker = 20,
    CastBarGeneral = 21,
    CastBarColor = 22,
    CastBarTimer = 23,
    CastBarSpell = 24,
    CastBarSpark = 25,
    CastBarEmpower = 26,
    CastBarBorder = 27,
    CastBarIcon = 28,
}

-------------------------------------------------
-- MARK: Build Menu
-------------------------------------------------

---@class WidgetMenuPage.Args
---@field widgetName WIDGET_KIND
---@field menuHeight number
---@field pageName string
---@field options table<MenuOptions>

---@param settingsFrame MenuFrame.settingsFrame
---@param widgetName WIDGET_KIND
---@param ... MenuOptions
---@return WidgetMenuPage
function Builder:CreateWidgetMenuPage(settingsFrame, widgetName, ...)
    ---@class WidgetMenuPage
    ---@field height number
    ---@field _originalHeight number
    ---@field id WIDGET_KIND
    local widgetPage = {}

    ---@class WidgetsMenuPageFrame: Frame
    widgetPage.frame = CUF:CreateFrame(nil, settingsFrame.scrollFrame.content,
        settingsFrame:GetWidth(), settingsFrame:GetHeight(), true)
    widgetPage.frame:SetPoint("TOPLEFT")
    widgetPage.frame:Hide()

    widgetPage.id = widgetName
    widgetPage.height = 40

    widgetPage.frame._GetHeight = function()
        return widgetPage.height
    end
    ---@param height number
    widgetPage.frame._SetHeight = function(height)
        widgetPage.height = height
        settingsFrame.scrollFrame:SetContentHeight(height)
    end

    local enabledCheckBox = self:CreatEnabledCheckBox(widgetPage.frame, widgetName)

    local prevOption = enabledCheckBox ---@type Frame
    for _, option in pairs({ ... }) do
        --CUF:Log("|cffff7777MenuBuilder:|r", option)
        local optPage = Builder.MenuFuncs[option](self, widgetPage.frame, widgetName)
        optPage:Show()

        if option == Builder.MenuOptions.AuraWhitelist
            or option == Builder.MenuOptions.AuraBlacklist
        then
            optPage:SetPoint("TOPLEFT", prevOption, "BOTTOMLEFT", 0, -10)
            widgetPage.height = widgetPage.height + optPage:GetHeight() + 12
            prevOption = optPage
        else
            local wrapper = self:WrapOption(widgetPage.frame, optPage, widgetName)
            wrapper:SetPoint("TOPLEFT", prevOption, "BOTTOMLEFT", 0, -10)

            widgetPage.height = widgetPage.height + wrapper:GetHeight() + 12
            prevOption = wrapper
        end
    end

    widgetPage._originalHeight = widgetPage.height

    return widgetPage
end

---@class OptionsFrame: Frame
---@field optionHeight number
---@field id string
---@field wrapperFrame Frame

---@param parent WidgetsMenuPageFrame
---@param option OptionsFrame
function Builder:WrapOption(parent, option, widgetName)
    local f = CUF:CreateFrame(
        "CUFWidgetSettings_" .. Util:ToTitleCase(widgetName) .. "_" .. (option.id or "N/A"),
        parent,
        self.optionWidth,
        ((option["optionHeight"] or option:GetHeight()) + 35),
        false,
        true)

    option:SetParent(f)
    option:SetPoint("TOPLEFT", f, 10, -25)
    option.wrapperFrame = f

    return f
end

-------------------------------------------------
-- MARK: Anchors
-------------------------------------------------

---@param option Frame
---@param prevOptions Frame
---@param spacingY number?
function Builder:AnchorBelow(option, prevOptions, spacingY)
    option:SetPoint("TOPLEFT", prevOptions, 0, -(spacingY or self.spacingY))
end

---@param option Frame
---@param prevOptions Frame
function Builder:AnchorRight(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, "TOPRIGHT", self.spacingX, 0)
end

---@param option Frame
---@param prevOptions CUFCheckBox
function Builder:AnchorRightOfCB(option, prevOptions)
    local spacing = math.max(prevOptions.label:GetWidth() + 5, 117)
    option:SetPoint("TOPLEFT", prevOptions, "TOPLEFT", self.spacingX + spacing, 0)
end

---@param option Frame
---@param prevOptions Frame
function Builder:AnchorBelowCB(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, 0, -30)
end

function Builder:AnchorRightOfColorPicker(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, "TOPRIGHT", self.spacingX + prevOptions.label:GetWidth(), 0)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param widgetName WIDGET_KIND
---@param optionPath string
---@param newValue any
local function HandleWidgetOption(widgetName, optionPath, newValue)
    local widgetTable = DB.GetWidgetTable(widgetName)

    local function traversePath(tbl, pathParts, value)
        for i = 1, #pathParts - 1 do
            tbl = tbl[pathParts[i]]
            if not tbl then
                CUF:Warn("Invalid path: " .. widgetName, table.concat(pathParts, "."))
                return {} -- TODO: this should be handled better
            end
        end

        local lastKey = pathParts[#pathParts]
        if value ~= nil then
            tbl[lastKey] = value
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, unpack(pathParts))
        end

        return tbl[lastKey]
    end

    local pathParts = { strsplit(".", optionPath) }
    return traversePath(widgetTable, pathParts, newValue)
end

-------------------------------------------------
-- MARK: CheckBox
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string
---@param path string
---@param tooltip? string
---@return CUFCheckBox
function Builder:CreateCheckBox(parent, widgetName, title, path, tooltip)
    ---@class CUFCheckBox: CellCheckButton
    local checkbox = Cell:CreateCheckButton(parent, L[title], function(checked, cb)
        cb.Set_DB(widgetName, path, checked)
    end, tooltip)

    checkbox.Set_DB = HandleWidgetOption
    checkbox.Get_DB = HandleWidgetOption

    checkbox:SetPoint("TOPLEFT")
    checkbox:SetChecked(Util:ToBool(checkbox.Get_DB(widgetName, path)))

    local function LoadPageDB()
        checkbox:SetChecked(Util:ToBool(checkbox.Get_DB(widgetName, path)))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CheckBox_" .. path)

    return checkbox
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return EnabledCheckBox
function Builder:CreatEnabledCheckBox(parent, widgetName)
    ---@class EnabledCheckBox: Frame
    local f = CUF:CreateFrame(nil, parent, self.optionWidth, 30)
    f:SetPoint("TOPLEFT", parent, 5, -5)
    f:Show()

    local enabledCheckBox = self:CreateCheckBox(f, widgetName, L["Enabled"], const.OPTION_KIND.ENABLED)
    enabledCheckBox:ClearAllPoints()
    enabledCheckBox:SetPoint("LEFT", f, 10, 0)

    return f
end

-------------------------------------------------
-- MARK: Slider
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string
---@param width number? Default: 117
---@param minVal number
---@param maxVal number
---@param path string
---@return CUFSlider
function Builder:CreateSlider(parent, widgetName, title, width, minVal, maxVal, path)
    ---@class CUFSlider: CellSlider
    local slider = Cell:CreateSlider(L[title], parent, minVal, maxVal, width or 117, 1)
    slider.id = "Slider"

    slider.Set_DB = HandleWidgetOption
    slider.Get_DB = HandleWidgetOption

    slider.afterValueChangedFn = function(value)
        slider.Set_DB(widgetName, path, value)
    end

    local function LoadPageDB()
        slider:SetValue(Util:ToNumber(slider.Get_DB(widgetName, path)))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "Slider_" .. path)

    return slider
end

-------------------------------------------------
-- MARK: Dropdown
-------------------------------------------------

---@class DropdownItem
---@field [1] string # Text
---@field [2] any # Value

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string
---@param width number? Default: 117
---@param items DropdownItem[] | string[]
---@param path string
---@return CUFDropdown
function Builder:CreateDropdown(parent, widgetName, title, width, items, path)
    ---@class CUFDropdown: CellDropdown
    local dropdown = Cell:CreateDropdown(parent, width or 117)
    dropdown.optionHeight = 20
    dropdown.id = "Dropdown"
    dropdown:SetLabel(L[title])

    dropdown.Set_DB = HandleWidgetOption
    dropdown.Get_DB = HandleWidgetOption

    local dropDownItems = {}
    for _, item in ipairs(items) do
        local text = type(item) == "string" and item or item[1]
        local value = type(item) == "string" and item or item[2]

        tinsert(dropDownItems, {
            ["text"] = L[text],
            ["value"] = value,
            ["onClick"] = function()
                dropdown.Set_DB(widgetName, path, value)
            end,
        })
    end
    dropdown:SetItems(dropDownItems)

    local function LoadPageDB()
        dropdown:SetSelectedValue(dropdown.Get_DB(widgetName, path))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "Dropdown_" .. path)

    return dropdown
end

-------------------------------------------------
-- MARK: EditBox
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string
---@param width number? Default: 117
---@param path string
---@return CUFEditBox
function Builder:CreateEditBox(parent, widgetName, title, width, path)
    ---@class CUFEditBox: EditBox, OptionsFrame
    local editBox = CUF:CreateEditBox(parent, width or 117, 20, L[title])
    editBox.id = "EditBox"
    editBox.optionHeight = 20

    editBox.Set_DB = HandleWidgetOption
    editBox.Get_DB = HandleWidgetOption


    editBox:SetScript("OnEnterPressed", function()
        editBox:ClearFocus()
        local value = editBox:GetText()
        editBox.Set_DB(widgetName, path, value)
    end)

    local function LoadPageDB()
        editBox:SetText(Util:ToString(editBox.Get_DB(widgetName, path)))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "EditBox_" .. path)

    return editBox
end

-----------------------------------------------
-- MARK: Color Picker
-----------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string?
---@param path string?
---@return CUFColorPicker
function Builder:CreateColorPickerOptions(parent, widgetName, title, path)
    ---@class CUFColorPicker: CellColorPicker, OptionsFrame
    local colorPicker = Cell:CreateColorPicker(parent, title or L["Color"], true)
    colorPicker.id = "ColorPicker"
    colorPicker.optionHeight = 25

    colorPicker.onChange = function(r, g, b, a)
        HandleWidgetOption(widgetName, path or const.OPTION_KIND.RGBA, { r, g, b, a })
    end

    local function LoadPageDB()
        local r, g, b, a = unpack(HandleWidgetOption(widgetName, path or const.OPTION_KIND.RGBA))
        colorPicker:SetColor(r, g, b, a)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "ColorPicker_" .. widgetName)

    return colorPicker
end

-----------------------------------------------
-- MARK: Option Title
-----------------------------------------------

---@param parent Frame
---@param txt string
---@return OptionTitle
function Builder:CreateOptionTitle(parent, txt)
    ---@class OptionTitle: Frame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f:SetPoint("TOPLEFT", 0, 10)

    f.title = f:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
    f.title:SetText(L[txt])
    f.title:SetScale(1.2)
    f.title:SetPoint("TOPLEFT")

    return f
end

-------------------------------------------------
-- MARK: Text Width
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string?
---@return TextWidthOption
function Builder:CreateTextWidthOption(parent, widgetName, path)
    ---@class TextWidthOption: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20
    f.id = "TextWidth"

    local dropdown, percentDropdown, lengthEB, lengthEB2

    dropdown = Cell:CreateDropdown(f, 117)
    dropdown:SetPoint("TOPLEFT", f)
    dropdown:SetLabel(L["Text Width"])
    dropdown:SetItems({
        {
            ["text"] = L["Unlimited"],
            ["onClick"] = function()
                HandleWidgetOption(widgetName, path or const.OPTION_KIND.WIDTH, { type = "unlimited" })
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
                HandleWidgetOption(widgetName, path or const.OPTION_KIND.WIDTH, { type = "percentage", value = 0.75 })
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
                HandleWidgetOption(widgetName, path or const.OPTION_KIND.WIDTH,
                    { type = "length", value = 5, auxValue = 3 })
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

    local percentItems = {
        { "100%", 1 },
        { "75%",  0.75 },
        { "50%",  0.5 },
        { "25%",  0.25 },
    }
    percentDropdown = self:CreateDropdown(f, widgetName, "", 75, percentItems,
        (path or const.OPTION_KIND.WIDTH) .. ".value")
    percentDropdown:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", self.spacingX, 0)
    Cell:SetTooltips(percentDropdown.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])

    lengthEB = Cell:CreateEditBox(f, 34, 20, false, false, true)
    lengthEB:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", self.spacingX, 0)

    lengthEB.text = lengthEB:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
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

        HandleWidgetOption(widgetName, (path or const.OPTION_KIND.WIDTH) .. ".value", length)
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

    lengthEB2.text = lengthEB2:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
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

        HandleWidgetOption(widgetName, (path or const.OPTION_KIND.WIDTH) .. ".auxValue", length)
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

    ---@param t FontWidthOpt
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
        f:SetNameWidth(HandleWidgetOption(widgetName, path or const.OPTION_KIND.WIDTH))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "NameWidth")


    return f
end

-------------------------------------------------
-- MARK: Text Color
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param includePowerType? boolean
---@return UnitColorOptions
function Builder:CreateTextColorOptions(parent, widgetName, includePowerType)
    ---@class UnitColorOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20
    f.id = "TextColor"

    local items = {
        { L["Class Color"],  const.ColorType.CLASS_COLOR },
        { L["Custom Color"], const.ColorType.CUSTOM },
    }
    if includePowerType then
        tinsert(items, { L["Power Color"], const.PowerColorType.POWER_COLOR })
    end

    f.dropdown = self:CreateDropdown(f, widgetName, L["Color"], nil, items,
        const.OPTION_KIND.COLOR .. "." .. const.OPTION_KIND.TYPE)
    f.dropdown:SetPoint("TOPLEFT", f)

    f.dropdown.Set_DB = function(...)
        HandleWidgetOption(...)
        if DB.GetWidgetTable(widgetName).color.type == const.ColorType.CUSTOM then
            f.colorPicker:Show()
        else
            f.colorPicker:Hide()
        end
    end

    f.colorPicker = Cell:CreateColorPicker(f, "", false, function(r, g, b, a)
        HandleWidgetOption(widgetName, "color.rgb", { r, g, b })
    end)
    f.colorPicker:SetPoint("LEFT", f.dropdown, "RIGHT", 2, 0)

    local function LoadPageDB()
        f.colorPicker:SetColor(unpack(HandleWidgetOption(widgetName, "color.rgb")))
        if DB.GetWidgetTable(widgetName).color.type == const.ColorType.CUSTOM then
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
function Builder:CreateTextColorOptionsWithPowerType(parent, widgetName)
    return self:CreateTextColorOptions(parent, widgetName, true)
end

-------------------------------------------------
-- MARK: Anchor
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string?
---@param minVal number?
---@param maxVal number?
---@return AnchorOptions
function Builder:CreateAnchorOptions(parent, widgetName, path, minVal, maxVal)
    ---@class AnchorOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20
    f.id = "Anchor"

    path = path or const.OPTION_KIND.POSITION
    minVal = minVal or -100
    maxVal = maxVal or 100

    f.anchorDropdown = self:CreateDropdown(parent, widgetName, L["Anchor Point"], nil, const.ANCHOR_POINTS,
        path .. "." .. const.OPTION_KIND.ANCHOR_POINT)
    f.anchorDropdown:SetPoint("TOPLEFT", f)

    f.sliderX = self:CreateSlider(f, widgetName, L["X Offset"], nil, minVal, maxVal,
        path .. "." .. "offsetX")
    self:AnchorRight(f.sliderX, f.anchorDropdown)

    f.sliderY = self:CreateSlider(f, widgetName, L["Y Offset"], nil, minVal, maxVal,
        path .. "." .. "offsetY")
    self:AnchorRight(f.sliderY, f.sliderX)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string?
---@return ExtraAnchorOptions
function Builder:CreateExtraAnchorOptions(parent, widgetName, path)
    ---@class ExtraAnchorOptions: AnchorOptions
    return self:CreateDropdown(parent, widgetName, L["To UnitButton's"], nil, const.ANCHOR_POINTS,
        path or const.OPTION_KIND.POSITION .. "." .. const.OPTION_KIND.RELATIVE_POINT)
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string?
---@param minVal number?
---@param maxVal number?
---@return FullAnchorOptions
function Builder:CreateFullAnchorOptions(parent, widgetName, path, minVal, maxVal)
    ---@class FullAnchorOptions: AnchorOptions
    local anchorOpt = self:CreateAnchorOptions(parent, widgetName, path, minVal, maxVal)
    anchorOpt.optionHeight = 70
    anchorOpt.id = "FullAnchor"

    anchorOpt.relativeDropdown = self:CreateDropdown(parent, widgetName, L.RelativeTo, nil, const.ANCHOR_POINTS,
        path or const.OPTION_KIND.POSITION .. "." .. const.OPTION_KIND.RELATIVE_POINT)
    self:AnchorBelow(anchorOpt.relativeDropdown, anchorOpt.anchorDropdown)

    return anchorOpt
end

-------------------------------------------------
-- MARK: Orientation
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return OrientationOptions
function Builder:CreateOrientationOptions(parent, widgetName)
    local orientationItems = { const.AURA_ORIENTATION.RIGHT_TO_LEFT, const.AURA_ORIENTATION.LEFT_TO_RIGHT,
        const.AURA_ORIENTATION.BOTTOM_TO_TOP, const.AURA_ORIENTATION.TOP_TO_BOTTOM }

    ---@class OrientationOptions: CUFDropdown, OptionsFrame
    return self:CreateDropdown(parent, widgetName, "Orientation", nil, orientationItems, const.OPTION_KIND.ORIENTATION)
end

-------------------------------------------------
-- MARK: Font
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string?
---@return FontOptions
function Builder:CreateFontOptions(parent, widgetName, path)
    ---@class FontOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 45
    f.id = "Font"

    local fontItems = Util:GetFontItems()
    path = path or const.OPTION_KIND.FONT

    f.styleDropdown = self:CreateDropdown(parent, widgetName, "Font", nil, fontItems,
        path .. ".style")
    f.styleDropdown:SetPoint("TOPLEFT", f)

    f.outlineDropdown = self:CreateDropdown(parent, widgetName, "Outline", nil, const.OUTLINES,
        path .. ".outline")
    self:AnchorRight(f.outlineDropdown, f.styleDropdown)

    f.sizeSlider = self:CreateSlider(f, widgetName, L["Size"], nil, 5, 50,
        path .. ".size")
    self:AnchorRight(f.sizeSlider, f.outlineDropdown)

    f.shadowCB = self:CreateCheckBox(f, widgetName, L["Shadow"], path .. ".shadow")
    f.shadowCB:SetPoint("TOPLEFT", f.styleDropdown, "BOTTOMLEFT", 0, -10)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string?
---@param path string
---@return BigFontOptions
function Builder:CreateBigFontOptions(parent, widgetName, title, path)
    ---@class BigFontOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "BigFontOptions"
    f.optionHeight = 160

    -- Title
    f.title = self:CreateOptionTitle(f, title .. " Font")

    --- Top Options
    f.anchorOptions = self:CreateAnchorOptions(f, widgetName, path)
    self:AnchorBelow(f.anchorOptions, f.title)

    f.fontOptions = self:CreateFontOptions(f, widgetName, path)
    self:AnchorBelow(f.fontOptions, f.anchorOptions)
    self:AnchorBelow(f.fontOptions.shadowCB, f.fontOptions.outlineDropdown)

    f.colorPicker = Cell:CreateColorPicker(f, L["Color"], false, function(r, g, b, a)
        HandleWidgetOption(widgetName, path .. ".rgb", { r, g, b })
    end)
    self:AnchorBelow(f.colorPicker, f.fontOptions.sizeSlider)

    local function LoadPageDB()
        local r, g, b = unpack(HandleWidgetOption(widgetName, path .. ".rgb"))
        f.colorPicker:SetColor(r, g, b)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "FontOptions_" .. path)

    return f
end

-------------------------------------------------
-- MARK: Health Format
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return HealthFormatOptions
function Builder:CreateHealthFormatOptions(parent, widgetName)
    local healthFormats = {
        { "32%",
            const.HealthTextFormat.PERCENTAGE, },
        { "32+25% |cFFA7A7A7+" .. L["shields"],
            const.HealthTextFormat.PERCENTAGE_ABSORBS },
        { "57% |cFFA7A7A7+" .. L["shields"],
            const.HealthTextFormat.PERCENTAGE_ABSORBS_MERGED },
        { "-67%",
            const.HealthTextFormat.PERCENTAGE_DEFICIT },
        { "21377",
            const.HealthTextFormat.NUMBER },
        { F:FormatNumber(21377),
            const.HealthTextFormat.NUMBER_SHORT },
        { F:FormatNumber(21377) .. "+" .. F:FormatNumber(16384) .. " |cFFA7A7A7+" .. L["shields"],
            const.HealthTextFormat.NUMBER_ABSORBS_SHORT },
        { F:FormatNumber(21377 + 16384) .. " |cFFA7A7A7+" .. L["shields"],
            const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT },
        { "-44158",
            const.HealthTextFormat.NUMBER_DEFICIT },
        { F:FormatNumber(-44158),
            const.HealthTextFormat.NUMBER_DEFICIT_SHORT },
        { F:FormatNumber(21377) .. " 32% |cFFA7A7A7HP",
            const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE },
        { "16384 |cFFA7A7A7" .. L["shields"],
            const.HealthTextFormat.ABSORBS_ONLY },
        { F:FormatNumber(16384) .. " |cFFA7A7A7" .. L["shields"],
            const.HealthTextFormat.ABSORBS_ONLY_SHORT },
        { "25% |cFFA7A7A7" .. L["shields"],
            const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE },
        { L["Custom"], const.HealthTextFormat.CUSTOM }
    }

    ---@class HealthFormatOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 100
    f.id = "HealthFormatOptions"

    f.formatDropdown = self:CreateDropdown(parent, widgetName, "Format", 200,
        healthFormats, const.OPTION_KIND.FORMAT)
    f.formatDropdown:SetPoint("TOPLEFT", f)

    f.formatEditBox = self:CreateEditBox(parent, widgetName, L["Text Format"], 300, const.OPTION_KIND.TEXT_FORMAT)
    self:AnchorBelow(f.formatEditBox, f.formatDropdown)

    local function SetEnabled(enabled)
        f.formatEditBox:SetEnabled(enabled)
        if enabled then
            CUF:SetTooltips(f.formatEditBox, "ANCHOR_TOPLEFT", 0, 3, L.ValidTags,
                unpack(CUF.widgets.CustomHealtFormatsTooltip))
        else
            CUF:ClearTooltips(f.formatEditBox)
        end
    end

    hooksecurefunc(f.formatDropdown, "SetSelected", function(_, text)
        SetEnabled(text == L["Custom"])
    end)

    f.hideIfEmptyOrFull = self:CreateCheckBox(f, widgetName, L["hideIfEmptyOrFull"],
        const.OPTION_KIND.HIDE_IF_EMPTY_OR_FULL)
    self:AnchorBelow(f.hideIfEmptyOrFull, f.formatEditBox, 35)

    local function LoadPageDB()
        SetEnabled(HandleWidgetOption(widgetName, const.OPTION_KIND.FORMAT) == const.HealthTextFormat.CUSTOM)
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
    local powerFormatItems = {
        { "32%",                 const.PowerTextFormat.PERCENTAGE, },
        { "21377",               const.PowerTextFormat.NUMBER, },
        { F:FormatNumber(21377), const.PowerTextFormat.NUMBER_SHORT, },
        { L["Custom"],           const.PowerTextFormat.CUSTOM }
    }

    ---@class PowerFormatOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 70
    f.id = "PowerFormatOptions"

    f.formatDropdown = self:CreateDropdown(parent, widgetName, "Format", 200,
        powerFormatItems, const.OPTION_KIND.FORMAT)
    f.formatDropdown:SetPoint("TOPLEFT", f)

    f.formatEditBox = self:CreateEditBox(parent, widgetName, L["Text Format"], 300, const.OPTION_KIND.TEXT_FORMAT)
    self:AnchorBelow(f.formatEditBox, f.formatDropdown)

    local function SetEnabled(enabled)
        f.formatEditBox:SetEnabled(enabled)
        if enabled then
            CUF:SetTooltips(f.formatEditBox, "ANCHOR_TOPLEFT", 0, 3, L.ValidTags,
                unpack(CUF.widgets.CustomPowerFormatsTooltip))
        else
            CUF:ClearTooltips(f.formatEditBox)
        end
    end

    hooksecurefunc(f.formatDropdown, "SetSelected", function(_, text)
        SetEnabled(text == L["Custom"])
    end)

    local function LoadPageDB()
        SetEnabled(HandleWidgetOption(widgetName, const.OPTION_KIND.FORMAT) == const.PowerTextFormat.CUSTOM)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "PowerFormatOptions")

    return f
end

-------------------------------------------------
-- MARK: Size
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param minVal number?
---@param maxVal number?
---@param path string?
---@return SizeOptions
function Builder:CreateSizeOptions(parent, widgetName, minVal, maxVal, path)
    ---@class SizeOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    minVal = minVal or 0
    maxVal = maxVal or 100

    f.sizeWidthSlider = self:CreateSlider(f, widgetName, L["Width"], nil, minVal, maxVal,
        (path or const.AURA_OPTION_KIND.SIZE) .. "." .. const.OPTION_KIND.WIDTH)
    f.sizeWidthSlider:SetPoint("TOPLEFT", f)

    f.sizeHeightSlider = self:CreateSlider(f, widgetName, L["Height"], nil, minVal, maxVal,
        (path or const.AURA_OPTION_KIND.SIZE) .. "." .. const.OPTION_KIND.HEIGHT)
    f.sizeHeightSlider:SetPoint("TOPLEFT", f.sizeWidthSlider, "TOPRIGHT", self.spacingX, 0)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return SingleSizeOptions
function Builder:CreateSingleSizeOptions(parent, widgetName)
    ---@class SingleSizeOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20

    f.sizeSlider = self:CreateSlider(f, widgetName, L["Size"], nil, 0, 100,
        const.AURA_OPTION_KIND.SIZE .. "." .. const.OPTION_KIND.WIDTH)
    f.sizeSlider:SetPoint("TOPLEFT", f)

    f.sizeSlider.Set_DB = function(_which, _kind, value)
        HandleWidgetOption(widgetName, const.AURA_OPTION_KIND.SIZE, { width = value, height = value })
    end

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param minVal number?
---@param maxVal number?
---@param path string?
---@return WidthOptions
function Builder:CreateWidthOptions(parent, widgetName, minVal, maxVal, path)
    ---@class WidthOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20

    f.sizeSlider = self:CreateSlider(f, widgetName, L["Width"], nil, (minVal or 0), (maxVal or 100),
        (path or const.OPTION_KIND.WIDTH))
    f.sizeSlider:SetPoint("TOPLEFT", f)

    return f
end

-------------------------------------------------
-- MARK: FrameLevel
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return FrameLevelOptions
function Builder:CreateFrameLevelOptions(parent, widgetName)
    ---@class FrameLevelOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "FrameLevelOptions"
    f.optionHeight = 20

    f.frameLevelSlider = self:CreateSlider(f, widgetName, L["Frame Level"], nil, 0, 100, const.OPTION_KIND.FRAMELEVEL)
    f.frameLevelSlider:SetPoint("TOPLEFT", f)

    return f
end

-----------------------------------------------
-- MARK: Texture Dropdown
-----------------------------------------------

local LSM = LibStub("LibSharedMedia-3.0", true)
local textures
local textureToName = {}

---@class TextureDropdownItem
---@field [1] string
---@field [2] Texture

---@return TextureDropdownItem[]
local function GetTextures()
    if textures then return textures end

    textures = F:Copy(LSM:HashTable("statusbar"))
    for name, texture in pairs(textures) do
        textureToName[texture] = name
    end

    return textures
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string
---@return TextureDropdown
function Builder:CreateTextureDropdown(parent, widgetName, path)
    ---@class TextureDropdown: CUFDropdown
    local textureDropdown = Cell:CreateDropdown(parent, 160, "texture")

    textureDropdown.optionHeight = 20
    textureDropdown.id = "TextureDropdown"
    textureDropdown:SetLabel(L["Texture"])

    textureDropdown.Set_DB = HandleWidgetOption
    textureDropdown.Get_DB = HandleWidgetOption

    local textureDropdownItems = {}
    for name, tex in pairs(GetTextures()) do
        tinsert(textureDropdownItems, {
            ["text"] = name,
            ["texture"] = tex,
            ["onClick"] = function()
                HandleWidgetOption(widgetName, path, tex)
            end,
        })
    end
    textureDropdown:SetItems(textureDropdownItems)

    local function LoadPageDB()
        local tex = textureDropdown.Get_DB(widgetName, path)
        textureDropdown:SetSelected(textureToName[tex], tex)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "TextureDropdown_" .. path)

    return textureDropdown
end

-------------------------------------------------
-- MARK: Aura Icon
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return AuraIconOptions
function Builder:CreateAuraIconOptions(parent, widgetName)
    ---@class AuraIconOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "AuraIconOptions"
    f.optionHeight = 260

    -- Title
    f.title = self:CreateOptionTitle(f, "Icon")

    --- Top Row
    f.anchorOptions = self:CreateAnchorOptions(f, widgetName)
    self:AnchorBelow(f.anchorOptions, f.title)

    -- Second Row
    f.extraAnchorDropdown = self:CreateExtraAnchorOptions(f, widgetName)
    self:AnchorBelow(f.extraAnchorDropdown, f.anchorOptions)

    f.orientationDropdown = self:CreateOrientationOptions(f, widgetName)
    self:AnchorRight(f.orientationDropdown, f.extraAnchorDropdown)

    f.maxIconsSlider = self:CreateSlider(f, widgetName, L["Max Icons"], nil, 1, 10,
        const.AURA_OPTION_KIND.MAX_ICONS)
    self:AnchorBelow(f.maxIconsSlider, f.anchorOptions.sliderY)

    -- Third Row
    f.sizeOptions = self:CreateSizeOptions(f, widgetName)
    Builder:AnchorBelow(f.sizeOptions, f.extraAnchorDropdown)

    f.numPerLineSlider = self:CreateSlider(f, widgetName, L["Per Row"], nil, 1, 10,
        const.AURA_OPTION_KIND.NUM_PER_LINE)
    self:AnchorBelow(f.numPerLineSlider, f.maxIconsSlider)

    -- Fourth Row
    f.spacingHorizontalSlider = self:CreateSlider(f, widgetName, L["X Spacing"], nil, 0, 50,
        const.AURA_OPTION_KIND.SPACING .. "." .. "horizontal")
    self:AnchorBelow(f.spacingHorizontalSlider, f.sizeOptions)

    f.spacingVerticalSlider = self:CreateSlider(f, widgetName, L["Y Spacing"], nil, 0, 50,
        const.AURA_OPTION_KIND.SPACING .. "." .. "vertical")
    self:AnchorBelow(f.spacingVerticalSlider, f.sizeOptions.sizeHeightSlider)

    -- Fifth Row
    f.showAnimation = self:CreateCheckBox(f, widgetName, L["Show Animation"], const.AURA_OPTION_KIND.SHOW_ANIMATION)
    self:AnchorBelow(f.showAnimation, f.spacingHorizontalSlider)

    f.showTooltip = self:CreateCheckBox(f, widgetName, L["Show Tooltips"], const.AURA_OPTION_KIND.SHOW_TOOLTIP)
    self:AnchorBelow(f.showTooltip, f.spacingVerticalSlider)

    return f
end

-------------------------------------------------
-- MARK: Aura Font
-------------------------------------------------

---@param parent Frame
---@param widgetName "buffs" | "debuffs"
---@param kind "stacks" | "duration"
---@return AuraFontOptions
function Builder:CreateAuraFontOptions(parent, widgetName, kind)
    local titleKind = Util:ToTitleCase(kind)
    ---@class AuraFontOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "Aura" .. titleKind .. "FontOptions"
    f.optionHeight = 160

    -- Title
    f.title = self:CreateOptionTitle(f, titleKind .. " Font")

    --- Top Options
    f.anchorOptions = self:CreateAnchorOptions(f, widgetName, const.OPTION_KIND.FONT .. "." .. kind)
    self:AnchorBelow(f.anchorOptions, f.title)

    f.fontOptions = self:CreateFontOptions(f, widgetName, const.OPTION_KIND.FONT .. "." .. kind)
    self:AnchorBelow(f.fontOptions, f.anchorOptions)
    self:AnchorBelow(f.fontOptions.shadowCB, f.fontOptions.outlineDropdown)

    f.colorPicker = Cell:CreateColorPicker(f, L["Color"], false, function(r, g, b, a)
        DB.GetWidgetTable(widgetName).font[kind].rgb[1] = r
        DB.GetWidgetTable(widgetName).font[kind].rgb[2] = g
        DB.GetWidgetTable(widgetName).font[kind].rgb[3] = b
    end)
    self:AnchorBelow(f.colorPicker, f.fontOptions.sizeSlider)

    local function LoadPageDB()
        f.colorPicker:SetColor(DB.GetWidgetTable(widgetName).font[kind].rgb[1],
            DB.GetWidgetTable(widgetName).font[kind].rgb[2],
            DB.GetWidgetTable(widgetName).font[kind].rgb[3])
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CheckBox")

    return f
end

---@param parent Frame
---@param widgetName "buffs" | "debuffs"
---@return AuraStackFontOptions
function Builder:CreateAuraStackFontOptions(parent, widgetName)
    ---@class AuraStackFontOptions: AuraFontOptions
    local f = Builder:CreateAuraFontOptions(parent, widgetName, "stacks")

    f.showStacksCB = self:CreateCheckBox(f, widgetName, L["Show stacks"], const.AURA_OPTION_KIND.SHOW_STACK)
    self:AnchorBelow(f.showStacksCB, f.fontOptions.styleDropdown)

    return f
end

---@param parent Frame
---@param widgetName "buffs" | "debuffs"
---@return AuraDurationFontOptions
function Builder:CreateAuraDurationFontOptions(parent, widgetName)
    ---@class AuraDurationFontOptions: AuraFontOptions
    local f = Builder:CreateAuraFontOptions(parent, widgetName, "duration")

    local items = {
        { L["Never"],          false },
        { L["Always"],         true },
        { "< 75%",             0.75 },
        { "< 50%",             0.5 },
        { "< 25%",             0.25 },
        { "< 15 " .. L["sec"], 15 },
        { "< 10 " .. L["sec"], 10 },
        { "< 5 " .. L["sec"],  5 },
    }
    f.iconDurationDropdown = self:CreateDropdown(f, widgetName, L["showDuration"], nil,
        items, const.AURA_OPTION_KIND.SHOW_DURATION)
    self:AnchorBelow(f.iconDurationDropdown, f.fontOptions.styleDropdown)

    return f
end

-------------------------------------------------
-- MARK: Aura Filter
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return AuraFilterOptions
function Builder:CreateAuraFilterOptions(parent, widgetName)
    ---@class AuraFilterOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "AuraFilterOptions"
    f.optionHeight = 165

    -- Title
    f.title = self:CreateOptionTitle(f, "Filter")

    --- First Row
    f.maxDurationSlider = self:CreateSlider(f, widgetName, L.MaxDuration, 165, 0, 10800,
        const.AURA_OPTION_KIND.FILTER .. "." .. "maxDuration")
    self:AnchorBelow(f.maxDurationSlider, f.title)
    f.maxDurationSlider.currentEditBox:SetWidth(60)

    f.minDurationSlider = self:CreateSlider(f, widgetName, L.MinDuration, 165, 0, 10800,
        const.AURA_OPTION_KIND.FILTER .. "." .. "minDuration")
    self:AnchorRight(f.minDurationSlider, f.maxDurationSlider)
    f.minDurationSlider.currentEditBox:SetWidth(60)

    -- Second Row
    f.hideNoDuration = self:CreateCheckBox(f, widgetName, L.HideNoDuration,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.HIDE_NO_DURATION,
        L.HideNoDurationTooltip)
    self:AnchorBelow(f.hideNoDuration, f.maxDurationSlider)

    f.personal = self:CreateCheckBox(f, widgetName, L.Personal,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.PERSONAL,
        L.PersonalTooltip)
    self:AnchorRightOfCB(f.personal, f.hideNoDuration)

    f.nonPersonal = self:CreateCheckBox(f, widgetName, L.NonPersonal,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.NON_PERSONAL,
        L.NonPersonalTooltip)
    self:AnchorRightOfCB(f.nonPersonal, f.personal)

    -- Third Row
    f.boss = self:CreateCheckBox(f, widgetName, L.Boss,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.BOSS,
        L.BossTooltip)
    self:AnchorBelowCB(f.boss, f.hideNoDuration)

    f.castByPlayers = self:CreateCheckBox(f, widgetName, L.CastByPlayers,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.CAST_BY_PLAYERS,
        L.CastByPlayersTooltip)
    self:AnchorRightOfCB(f.castByPlayers, f.boss)

    f.castByNPC = self:CreateCheckBox(f, widgetName, L.CastByNPC,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.CAST_BY_NPC,
        L.CastByNPCTooltip)
    self:AnchorRightOfCB(f.castByNPC, f.castByPlayers)

    -- Fourth Row
    f.useBlacklistCB = self:CreateCheckBox(f, widgetName, L.UseBlacklist,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.USE_BLACKLIST)
    self:AnchorBelowCB(f.useBlacklistCB, f.boss)

    f.useWhitelistCB = self:CreateCheckBox(f, widgetName, L.UseWhitelist,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.USE_WHITELIST)
    self:AnchorRightOfCB(f.useWhitelistCB, f.useBlacklistCB)

    return f
end

-------------------------------------------------
-- MARK: Aura Black-/whitelist
-------------------------------------------------

---@param parent WidgetsMenuPageFrame
---@param widgetName "buffs" | "debuffs"
---@return Cell.SettingsAuras
function Builder:CreateAuraBlacklistOptions(parent, widgetName)
    return Builder.CreateSetting_Auras(parent, widgetName, "blacklist")
end

---@param parent WidgetsMenuPageFrame
---@param widgetName "buffs" | "debuffs"
---@return Cell.SettingsAuras
function Builder:CreateAuraWhitelistOptions(parent, widgetName)
    return Builder.CreateSetting_Auras(parent, widgetName, "whitelist")
end

-------------------------------------------------
-- MARK: Cast Bar
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarOptions
function Builder:CreateCastBarGeneralOptions(parent, widgetName)
    ---@class CastBarOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "CastBarOptions"
    f.optionHeight = 165

    -- Title
    f.title = self:CreateOptionTitle(f, "General")

    -- First Row
    f.anchorOptions = self:CreateFullAnchorOptions(f, widgetName, nil, -1000, 1000)
    self:AnchorBelow(f.anchorOptions, f.title)

    -- Second Row
    f.sizeOptions = self:CreateSizeOptions(f, widgetName, 0, 500)
    self:AnchorBelow(f.sizeOptions, f.anchorOptions.sliderX)

    -- Third Row
    f.reverseCB = self:CreateCheckBox(f, widgetName, L.Reverse, const.OPTION_KIND.REVERSE)
    self:AnchorBelow(f.reverseCB, f.anchorOptions.relativeDropdown)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarColorOptions
function Builder:CreateCastBarColorOptions(parent, widgetName)
    ---@class CastBarColorOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "CastBarColorOptions"
    f.optionHeight = 110

    -- Title
    f.title = self:CreateOptionTitle(f, "Colors")
    local path = const.OPTION_KIND.COLOR .. "."

    -- First Row
    f.texture = self:CreateTextureDropdown(f, widgetName, path .. const.OPTION_KIND.TEXTURE)
    self:AnchorBelow(f.texture, f.title)

    f.classColorCB = self:CreateCheckBox(f, widgetName, L.UseClassColor,
        path .. const.OPTION_KIND.USE_CLASS_COLOR)
    self:AnchorRight(f.classColorCB, f.texture)

    -- Second Row
    f.interruptible = self:CreateColorPickerOptions(f, widgetName, L.Interruptible,
        path .. const.OPTION_KIND.INTERRUPTIBLE)
    self:AnchorBelow(f.interruptible, f.texture)

    f.nonInterruptible = self:CreateColorPickerOptions(f, widgetName, L.NonInterruptible,
        path .. const.OPTION_KIND.NON_INTERRUPTIBLE)
    self:AnchorRightOfColorPicker(f.nonInterruptible, f.interruptible)

    f.background = self:CreateColorPickerOptions(f, widgetName, L.Background,
        path .. const.OPTION_KIND.BACKGROUND)
    self:AnchorRightOfColorPicker(f.background, f.nonInterruptible)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarTimerFontOptions
function Builder:CreateCastBarTimerFontOptions(parent, widgetName)
    ---@class CastBarTimerFontOptions: BigFontOptions
    local f = Builder:CreateBigFontOptions(parent, widgetName, "Timer", const.OPTION_KIND.TIMER)

    local items = {
        const.CastBarTimerFormat.NORMAL,
        const.CastBarTimerFormat.REMAINING,
        const.CastBarTimerFormat.DURATION,
        const.CastBarTimerFormat.DURATION_AND_MAX,
    }
    f.timerFormat = self:CreateDropdown(f, widgetName, L.TimerFormat, nil,
        items, const.OPTION_KIND.TIMER_FORMAT)
    self:AnchorBelow(f.timerFormat, f.fontOptions.styleDropdown)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarSpellFontOptions
function Builder:CreateCastBarSpellFontOptions(parent, widgetName)
    ---@class CastBarSpellFontOptions: BigFontOptions
    local f = Builder:CreateBigFontOptions(parent, widgetName, "Spell", const.OPTION_KIND.SPELL)

    f.spellCB = self:CreateCheckBox(f, widgetName, L.ShowSpell, const.OPTION_KIND.SHOW_SPELL)
    self:AnchorBelow(f.spellCB, f.fontOptions.styleDropdown)

    f.spellWidth = self:CreateTextWidthOption(f, widgetName, const.OPTION_KIND.SPELL_WIDTH)
    self:AnchorBelow(f.spellWidth, f.spellCB)

    f.optionHeight = f.optionHeight + 50

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarSparkOptions
function Builder:CreateCastBarSparkOptions(parent, widgetName)
    ---@class CastBarSparkOptions: BigFontOptions
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "CastBarSparkOptions"
    f.optionHeight = 60

    -- Title
    f.title = self:CreateOptionTitle(f, "Spark")

    -- First Row
    f.enabled = self:CreateCheckBox(f, widgetName, L["Enabled"],
        const.OPTION_KIND.SPARK .. "." .. const.OPTION_KIND.ENABLED)
    self:AnchorBelow(f.enabled, f.title)

    f.color = self:CreateColorPickerOptions(f, widgetName, nil,
        const.OPTION_KIND.SPARK .. "." .. const.OPTION_KIND.COLOR)
    self:AnchorRightOfCB(f.color, f.enabled)

    f.sizeOptions = self:CreateWidthOptions(f, widgetName, nil, nil,
        const.OPTION_KIND.SPARK .. "." .. const.OPTION_KIND.WIDTH)
    self:AnchorRightOfColorPicker(f.sizeOptions, f.color)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarEmpowerOptions
function Builder:CreateCastBarEmpowerOptions(parent, widgetName)
    ---@class CastBarEmpowerOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "CastBarEmpowerOptions"
    f.optionHeight = 170

    -- Title
    f.title = self:CreateOptionTitle(f, "Empower")

    -- First Row
    f.useFullyCharged = self:CreateCheckBox(f, widgetName, L.UseFullyCharged,
        const.OPTION_KIND.EMPOWER .. "." .. const.OPTION_KIND.USE_FULLY_CHARGED,
        L.UseFullyChargedTooltip)
    self:AnchorBelow(f.useFullyCharged, f.title)

    f.showEmpowerName = self:CreateCheckBox(f, widgetName, L.ShowEmpowerName,
        const.OPTION_KIND.EMPOWER .. "." .. const.OPTION_KIND.SHOW_EMPOWER_NAME,
        L.ShowEmpowerNameTooltip)
    f.showEmpowerName:SetPoint("TOPLEFT", f.useFullyCharged, "TOPLEFT",
        (self.spacingX * 1.5) + f.useFullyCharged.label:GetWidth(), 0)

    -- Second Row
    local colorPath = const.OPTION_KIND.EMPOWER .. "." .. const.OPTION_KIND.PIP_COLORS .. "."

    f.stageZero = self:CreateColorPickerOptions(f, widgetName,
        L.Stage .. " " .. 0 .. " " .. L["Color"],
        colorPath .. const.OPTION_KIND.STAGE_ZERO)
    self:AnchorBelow(f.stageZero, f.useFullyCharged)

    f.stageOne = self:CreateColorPickerOptions(f, widgetName,
        L.Stage .. " " .. 1 .. " " .. L["Color"],
        colorPath .. const.OPTION_KIND.STAGE_ONE)
    self:AnchorRightOfColorPicker(f.stageOne, f.stageZero)

    f.stageTwo = self:CreateColorPickerOptions(f, widgetName,
        L.Stage .. " " .. 2 .. " " .. L["Color"],
        colorPath .. const.OPTION_KIND.STAGE_TWO)
    self:AnchorRightOfColorPicker(f.stageTwo, f.stageOne)

    -- Third Row
    f.stageThree = self:CreateColorPickerOptions(f, widgetName,
        L.Stage .. " " .. 3 .. " " .. L["Color"],
        colorPath .. const.OPTION_KIND.STAGE_THREE)
    self:AnchorBelowCB(f.stageThree, f.stageZero)

    f.stageFour = self:CreateColorPickerOptions(f, widgetName,
        L.Stage .. " " .. 4 .. " " .. L["Color"],
        colorPath .. const.OPTION_KIND.STAGE_FOUR)
    self:AnchorRightOfColorPicker(f.stageFour, f.stageThree)

    -- Fourth Row
    f.fullyCharged = self:CreateColorPickerOptions(f, widgetName,
        L.FullyCharged .. " " .. L["Color"],
        colorPath .. const.OPTION_KIND.FULLY_CHARGED)
    self:AnchorBelowCB(f.fullyCharged, f.stageThree)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarBorderOptions
function Builder:CreatCastBarBorderOptions(parent, widgetName)
    ---@class CastBarBorderOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "CastBarBorderOptions"
    f.optionHeight = 120

    -- Title
    f.title = self:CreateOptionTitle(f, "Border")

    local borderPath = const.OPTION_KIND.BORDER .. "."
    -- First Row
    f.showBorder = self:CreateCheckBox(f, widgetName, L.ShowBorder,
        borderPath .. const.OPTION_KIND.SHOW_BORDER)
    self:AnchorBelow(f.showBorder, f.title)

    f.color = self:CreateColorPickerOptions(f, widgetName, nil,
        borderPath .. const.OPTION_KIND.COLOR)
    self:AnchorRightOfCB(f.color, f.showBorder)

    -- Second Row
    f.size = self:CreateSlider(f, widgetName, L["Size"], nil, 0, 64,
        borderPath .. const.OPTION_KIND.SIZE)
    self:AnchorBelow(f.size, f.showBorder)

    f.offset = self:CreateSlider(f, widgetName, L["Offset"], nil, 0, 32,
        borderPath .. const.OPTION_KIND.OFFSET)
    self:AnchorRight(f.offset, f.size)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarIconOptions
function Builder:CreateCastBarIconOptions(parent, widgetName)
    ---@class CastBarIconOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "CastBarIconOptions"
    f.optionHeight = 65

    -- Title
    f.title = self:CreateOptionTitle(f, "Icon")

    local iconPath = const.OPTION_KIND.ICON .. "."
    -- First Row
    f.showIcon = self:CreateCheckBox(f, widgetName, L.ShowIcon,
        iconPath .. const.OPTION_KIND.ENABLED)
    self:AnchorBelow(f.showIcon, f.title)

    f.zoom = self:CreateSlider(f, widgetName, L.Zoom, nil, 0, 100,
        iconPath .. const.OPTION_KIND.ZOOM)
    self:AnchorRightOfCB(f.zoom, f.showIcon)

    f.position = self:CreateDropdown(f, widgetName, L["Position"], nil,
        { "left", "right" }, iconPath .. const.OPTION_KIND.POSITION)
    self:AnchorRight(f.position, f.zoom)

    return f
end

-------------------------------------------------
-- MARK: MenuBuilder.MenuFuncs
-- Down here because of annotations
-------------------------------------------------

Builder.MenuFuncs = {
    [Builder.MenuOptions.TextColor] = Builder.CreateTextColorOptions,
    [Builder.MenuOptions.TextColorWithPowerType] = Builder.CreateTextColorOptionsWithPowerType,
    [Builder.MenuOptions.TextWidth] = Builder.CreateTextWidthOption,
    [Builder.MenuOptions.Anchor] = Builder.CreateAnchorOptions,
    [Builder.MenuOptions.ExtraAnchor] = Builder.CreateExtraAnchorOptions,
    [Builder.MenuOptions.FullAnchor] = Builder.CreateFullAnchorOptions,
    [Builder.MenuOptions.Font] = Builder.CreateFontOptions,
    [Builder.MenuOptions.HealthFormat] = Builder.CreateHealthFormatOptions,
    [Builder.MenuOptions.PowerFormat] = Builder.CreatePowerFormatOptions,
    [Builder.MenuOptions.AuraIconOptions] = Builder.CreateAuraIconOptions,
    [Builder.MenuOptions.Orientation] = Builder.CreateOrientationOptions,
    [Builder.MenuOptions.AuraStackFontOptions] = Builder.CreateAuraStackFontOptions,
    [Builder.MenuOptions.AuraDurationFontOptions] = Builder.CreateAuraDurationFontOptions,
    [Builder.MenuOptions.AuraFilter] = Builder.CreateAuraFilterOptions,
    [Builder.MenuOptions.AuraBlacklist] = Builder.CreateAuraBlacklistOptions,
    [Builder.MenuOptions.AuraWhitelist] = Builder.CreateAuraWhitelistOptions,
    [Builder.MenuOptions.Size] = Builder.CreateSizeOptions,
    [Builder.MenuOptions.SingleSize] = Builder.CreateSingleSizeOptions,
    [Builder.MenuOptions.FrameLevel] = Builder.CreateFrameLevelOptions,
    [Builder.MenuOptions.ColorPicker] = Builder.CreateColorPickerOptions,
    [Builder.MenuOptions.CastBarGeneral] = Builder.CreateCastBarGeneralOptions,
    [Builder.MenuOptions.CastBarColor] = Builder.CreateCastBarColorOptions,
    [Builder.MenuOptions.CastBarTimer] = Builder.CreateCastBarTimerFontOptions,
    [Builder.MenuOptions.CastBarSpell] = Builder.CreateCastBarSpellFontOptions,
    [Builder.MenuOptions.CastBarSpark] = Builder.CreateCastBarSparkOptions,
    [Builder.MenuOptions.CastBarEmpower] = Builder.CreateCastBarEmpowerOptions,
    [Builder.MenuOptions.CastBarBorder] = Builder.CreatCastBarBorderOptions,
    [Builder.MenuOptions.CastBarIcon] = Builder.CreateCastBarIconOptions,
}
