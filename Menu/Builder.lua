---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local F = Cell.funcs
local I = Cell.iFuncs

local Handler = CUF.Handler
local const = CUF.constants
local DB = CUF.DB
local Util = CUF.Util
local W = CUF.widgets
local Defaults = CUF.Defaults

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
    ClassBarOptions = 22,
    CastBarTimer = 23,
    CastBarSpell = 24,
    CastBarSpark = 25,
    CastBarEmpower = 26,
    CastBarBorder = 27,
    CastBarIcon = 28,
    NameFormat = 29,
    ShieldBarOptions = 30,
    CustomText = 31,
    DispelsOptions = 32,
    TrueSingleSizeOptions = 33,
    TotemOptions = 34,
    HideAtMaxLevel = 35,
    HideOutOfCombat = 36,
    Glow = 37,
    IconTexture = 38,
    Highlight = 39,
    AltPower = 40,
    PowerBar = 41,
    DetachedAnchor = 42,
    HealPredictionOptions = 43,
    PowerTextAnchorOptions = 44,
}

local FAILED = FAILED or "Failed"
local INTERRUPTED = INTERRUPTED or "Interrupted"

-------------------------------------------------
-- MARK: Build Menu
-------------------------------------------------

---@class WidgetMenuPage.Args
---@field widgetName WIDGET_KIND
---@field menuHeight number
---@field pageName string
---@field options table<MenuOptions>

---@param settingsFrame UnitsFramesTab.settingsFrame
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

    local enabledCheckBox = self:CreateEnabledCheckBox(widgetPage.frame, widgetName)

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
    local widgetTable = DB.GetSelectedWidgetTable(widgetName)

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
    local checkbox = Cell.CreateCheckButton(parent, L[title], function(checked, cb)
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
function Builder:CreateEnabledCheckBox(parent, widgetName)
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
---@param percentage boolean?
---@param step number?
---@return CUFSlider
function Builder:CreateSlider(parent, widgetName, title, width, minVal, maxVal, path, percentage, step)
    ---@class CUFSlider: CellSlider
    local slider = Cell.CreateSlider(L[title], parent, minVal, maxVal, width or 117, step or 1, nil, nil, percentage)
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
---@param postUpdate? fun(val)
---@return CUFDropdown
function Builder:CreateDropdown(parent, widgetName, title, width, items, path, postUpdate)
    ---@class CUFDropdown: CellDropdown
    local dropdown = Cell.CreateDropdown(parent, width or 117)
    dropdown.optionHeight = 20
    dropdown.id = "Dropdown"
    dropdown:SetLabel(L[title])

    dropdown.Set_DB = HandleWidgetOption
    dropdown.Get_DB = HandleWidgetOption

    local dropDownItems = {}
    for _, item in ipairs(items) do
        local text = type(item) == "string" and item or item[1]
        local value = type(item) == "string" and item or item[2]

        table.insert(dropDownItems, {
            ["text"] = L[text],
            ["value"] = value,
            ["onClick"] = function()
                dropdown.Set_DB(widgetName, path, value)
                if postUpdate then
                    postUpdate(value)
                end
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
    local colorPicker = Cell.CreateColorPicker(parent, title or L["Color"], true)
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

    dropdown = Cell.CreateDropdown(f, 117)
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
    Cell.SetTooltips(percentDropdown.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])

    lengthEB = Cell.CreateEditBox(f, 34, 20, false, false, true)
    lengthEB:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", self.spacingX, 0)

    lengthEB.text = lengthEB:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
    lengthEB.text:SetText(L["En"])
    lengthEB.text:SetPoint("BOTTOMLEFT", lengthEB, "TOPLEFT", 0, 1)

    lengthEB.confirmBtn = Cell.CreateButton(lengthEB, "OK", "accent", { 27, 20 })
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

    lengthEB2 = Cell.CreateEditBox(f, 33, 20, false, false, true)
    lengthEB2:SetPoint("TOPLEFT", lengthEB, "TOPRIGHT", 25, 0)

    lengthEB2.text = lengthEB2:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
    lengthEB2.text:SetText(L["Non-En"])
    lengthEB2.text:SetPoint("BOTTOMLEFT", lengthEB2, "TOPLEFT", 0, 1)

    lengthEB2.confirmBtn = Cell.CreateButton(lengthEB2, "OK", "accent", { 27, 20 })
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
        table.insert(items, { L["Power Color"], const.PowerColorType.POWER_COLOR })
    end

    f.dropdown = self:CreateDropdown(f, widgetName, L["Color"], nil, items,
        const.OPTION_KIND.COLOR .. "." .. const.OPTION_KIND.TYPE)
    f.dropdown:SetPoint("TOPLEFT", f)

    f.dropdown.Set_DB = function(...)
        HandleWidgetOption(...)
        if DB.GetSelectedWidgetTable(widgetName).color.type == const.ColorType.CUSTOM then
            f.colorPicker:Show()
        else
            f.colorPicker:Hide()
        end
    end

    f.colorPicker = Cell.CreateColorPicker(f, "", false, function(r, g, b, a)
        HandleWidgetOption(widgetName, "color.rgb", { r, g, b })
    end)
    f.colorPicker:SetPoint("LEFT", f.dropdown, "RIGHT", 2, 0)

    local function LoadPageDB()
        f.colorPicker:SetColor(unpack(HandleWidgetOption(widgetName, "color.rgb")))
        if DB.GetSelectedWidgetTable(widgetName).color.type == const.ColorType.CUSTOM then
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
        (path or const.OPTION_KIND.POSITION) .. "." .. const.OPTION_KIND.RELATIVE_POINT)
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
        (path or const.OPTION_KIND.POSITION) .. "." .. const.OPTION_KIND.RELATIVE_POINT)
    self:AnchorBelow(anchorOpt.relativeDropdown, anchorOpt.anchorDropdown)

    return anchorOpt
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string?
---@param minVal number?
---@param maxVal number?
---@return DetachedAnchorOptions
function Builder:CreateDetachedAnchorOptions(parent, widgetName, path, minVal, maxVal)
    ---@class DetachedAnchorOptions: FullAnchorOptions
    local anchorOpt = self:CreateFullAnchorOptions(parent, widgetName, path, minVal, maxVal)
    anchorOpt.id = "DetachedAnchor"

    local anchorToParent = self:CreateCheckBox(anchorOpt, widgetName, L["Anchor To"] .. " " .. L["Unit Button"],
        const.OPTION_KIND.ANCHOR_TO_PARENT, L.DetachedAnchorEditMode)
    self:AnchorRight(anchorToParent, anchorOpt.relativeDropdown)

    local function toggleOptions(anchored)
        anchorOpt.anchorDropdown:SetEnabled(anchored)
        anchorOpt.relativeDropdown:SetEnabled(anchored)
        anchorOpt.sliderX:SetEnabled(anchored)
        anchorOpt.sliderY:SetEnabled(anchored)
    end

    anchorToParent:HookScript("OnClick", function()
        toggleOptions(anchorToParent:GetChecked())
    end)

    local function LoadPageDB()
        toggleOptions(DB.GetSelectedWidgetTable(widgetName).anchorToParent)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "DetachedAnchor_AnchorToggle")

    return anchorOpt
end

-------------------------------------------------
-- MARK: Orientation
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return OrientationOptions
function Builder:CreateOrientationOptions(parent, widgetName)
    local orientationItems = { const.GROWTH_ORIENTATION.RIGHT_TO_LEFT, const.GROWTH_ORIENTATION.LEFT_TO_RIGHT,
        const.GROWTH_ORIENTATION.BOTTOM_TO_TOP, const.GROWTH_ORIENTATION.TOP_TO_BOTTOM }

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
    f.optionHeight = 70
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

    f.justifyDropdown = self:CreateDropdown(parent, widgetName, L.Alignment, nil, const.TEXT_JUSTIFY,
        path .. ".justify")
    self:AnchorBelow(f.justifyDropdown, f.styleDropdown)

    f.shadowCB = self:CreateCheckBox(f, widgetName, L["Shadow"], path .. ".shadow")
    self:AnchorRight(f.shadowCB, f.justifyDropdown)
    --f.shadowCB:SetPoint("TOPLEFT", f.styleDropdown, "BOTTOMLEFT", 0, -10)

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
    f.optionHeight = 210

    -- Title
    f.title = self:CreateOptionTitle(f, title .. " Font")

    --- Top Options
    f.anchorOptions = self:CreateFullAnchorOptions(f, widgetName, path)
    self:AnchorBelow(f.anchorOptions, f.title)

    f.fontOptions = self:CreateFontOptions(f, widgetName, path)
    self:AnchorBelow(f.fontOptions, f.anchorOptions.relativeDropdown)
    self:AnchorBelow(f.fontOptions.shadowCB, f.fontOptions.outlineDropdown)

    f.colorPicker = Cell.CreateColorPicker(f, L["Color"], false, function(r, g, b, a)
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
        { F.FormatNumber(21377),
            const.HealthTextFormat.NUMBER_SHORT },
        { F.FormatNumber(21377) .. "+" .. F.FormatNumber(16384) .. " |cFFA7A7A7+" .. L["shields"],
            const.HealthTextFormat.NUMBER_ABSORBS_SHORT },
        { F.FormatNumber(21377 + 16384) .. " |cFFA7A7A7+" .. L["shields"],
            const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT },
        { "-44158",
            const.HealthTextFormat.NUMBER_DEFICIT },
        { F.FormatNumber(-44158),
            const.HealthTextFormat.NUMBER_DEFICIT_SHORT },
        { F.FormatNumber(21377) .. " 32% |cFFA7A7A7HP",
            const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE },
        { "16384 |cFFA7A7A7" .. L["shields"],
            const.HealthTextFormat.ABSORBS_ONLY },
        { F.FormatNumber(16384) .. " |cFFA7A7A7" .. L["shields"],
            const.HealthTextFormat.ABSORBS_ONLY_SHORT },
        { "25% |cFFA7A7A7" .. L["shields"],
            const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE },
        { L["Custom"], const.HealthTextFormat.CUSTOM }
    }

    ---@class HealthFormatOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 120
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
                unpack(CUF.widgets:GetTagTooltips("Health")))
        else
            CUF:ClearTooltips(f.formatEditBox)
        end
    end

    hooksecurefunc(f.formatDropdown, "SetSelected", function(_, text)
        SetEnabled(text == L["Custom"])
    end)

    f.hideIfEmpty = self:CreateCheckBox(f, widgetName, L.HideIfEmpty,
        const.OPTION_KIND.HIDE_IF_EMPTY)
    self:AnchorBelowCB(f.hideIfEmpty, f.formatEditBox)
    f.hideIfFull = self:CreateCheckBox(f, widgetName, L.HideIfFull,
        const.OPTION_KIND.HIDE_IF_FULL)
    self:AnchorRightOfCB(f.hideIfFull, f.hideIfEmpty)
    f.showDeadStatus = self:CreateCheckBox(f, widgetName, L.ShowDeadStatus,
        const.OPTION_KIND.SHOW_DEAD_STATUS, L.ShowDeadStatusTooltip)
    self:AnchorBelowCB(f.showDeadStatus, f.hideIfEmpty)

    f.hideIfEmpty:HookScript("OnClick", function(...)
        f.showDeadStatus:SetEnabled(not f.hideIfEmpty:GetChecked())
    end)

    local function LoadPageDB()
        SetEnabled(HandleWidgetOption(widgetName, const.OPTION_KIND.FORMAT) == const.HealthTextFormat.CUSTOM)
        f.showDeadStatus:SetEnabled(not HandleWidgetOption(widgetName, const.OPTION_KIND.HIDE_IF_EMPTY))
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
        { F.FormatNumber(21377), const.PowerTextFormat.NUMBER_SHORT, },
        { L["Custom"],           const.PowerTextFormat.CUSTOM }
    }

    ---@class PowerFormatOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 100
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
                unpack(CUF.widgets:GetTagTooltips("Power")))
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

    f.powerFilter = self:CreateCheckBox(f, widgetName, L.PowerFilter,
        const.OPTION_KIND.POWER_FILTER, L.PowerFilterTooltip)
    self:AnchorRightOfCB(f.powerFilter, f.hideIfEmptyOrFull)

    local function LoadPageDB()
        SetEnabled(HandleWidgetOption(widgetName, const.OPTION_KIND.FORMAT) == const.PowerTextFormat.CUSTOM)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "PowerFormatOptions")

    return f
end

-------------------------------------------------
-- MARK: Name Format
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return NameFormatOptions
function Builder:CreateNameFormatOptions(parent, widgetName)
    ---@class NameFormatOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20
    f.id = "NameFormatOptions"

    local tooltips = {}
    for _, format in ipairs(const.NameFormatArray) do
        local tooltip = L[format] .. ": " .. L[format .. "_Example"]
        table.insert(tooltips, tooltip)
    end

    f.formatDropdown = self:CreateDropdown(f, widgetName, "Format", 200, const.NameFormatArray,
        const.OPTION_KIND.FORMAT)
    f.formatDropdown:SetPoint("TOPLEFT", f)

    Cell.SetTooltips(f.formatDropdown, "ANCHOR_TOPLEFT", 0, 3, L.NameFormats, unpack(tooltips))

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
---@param width number?
---@return SizeOptions
function Builder:CreateSizeOptions(parent, widgetName, minVal, maxVal, path, width)
    ---@class SizeOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20

    minVal = minVal or 0
    maxVal = maxVal or 100

    f.sizeWidthSlider = self:CreateSlider(f, widgetName, L["Width"], width, minVal, maxVal,
        (path or const.AURA_OPTION_KIND.SIZE) .. "." .. const.OPTION_KIND.WIDTH)
    f.sizeWidthSlider:SetPoint("TOPLEFT", f)

    f.sizeHeightSlider = self:CreateSlider(f, widgetName, L["Height"], width, minVal, maxVal,
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
---@return TrueSingleSizeOptions
function Builder:CreateTrueSingleSizeOptions(parent, widgetName)
    ---@class TrueSingleSizeOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20

    f.sizeSlider = self:CreateSlider(f, widgetName, L["Size"], nil, 0, 100,
        const.AURA_OPTION_KIND.SIZE)
    f.sizeSlider:SetPoint("TOPLEFT", f)

    f.sizeSlider.Set_DB = function(_which, _kind, value)
        HandleWidgetOption(widgetName, const.AURA_OPTION_KIND.SIZE, value)
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

-------------------------------------------------
-- MARK: Max Level
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return FrameLevelOptions
function Builder:CreateHideAtMaxLevel(parent, widgetName)
    ---@class FrameLevelOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "FrameLevelOptions"
    f.optionHeight = 20

    f.hideAtMaxLevelCB = self:CreateCheckBox(f, widgetName, L.HideAtMaxLevel,
        const.OPTION_KIND.HIDE_AT_MAX_LEVEL)
    f.hideAtMaxLevelCB:SetPoint("TOPLEFT", f)

    return f
end

-------------------------------------------------
-- MARK: Out Of Combat
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return FrameLevelOptions
function Builder:CreateHideOutOfCombat(parent, widgetName)
    ---@class FrameLevelOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "FrameLevelOptions"
    f.optionHeight = 20

    f.hideOutOfCombatCB = self:CreateCheckBox(f, widgetName, L.HideOutOfCombat,
        const.OPTION_KIND.HIDE_OUT_OF_COMBAT)
    f.hideOutOfCombatCB:SetPoint("TOPLEFT", f)

    return f
end

-----------------------------------------------
-- MARK: Texture Dropdown
-----------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param path string
---@return TextureDropdown
function Builder:CreateTextureDropdown(parent, widgetName, path)
    ---@class TextureDropdown: CUFDropdown
    local textureDropdown = Cell.CreateDropdown(parent, 160, "texture")

    textureDropdown.optionHeight = 20
    textureDropdown.id = "TextureDropdown"
    textureDropdown:SetLabel(L["Texture"])

    textureDropdown.Set_DB = HandleWidgetOption
    textureDropdown.Get_DB = HandleWidgetOption

    local textureDropdownItems = {}
    for name, tex in pairs(Util:GetTextures()) do
        table.insert(textureDropdownItems, {
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
        textureDropdown:SetSelected(Util.textureToName[tex], tex)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "TextureDropdown_" .. path)

    return textureDropdown
end

-------------------------------------------------
-- MARK: Glow
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return GlowOptions
function Builder:CreateGlowOptions(parent, widgetName)
    ---@class GlowOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "GlowOptions"
    f.optionHeight = 120

    local glowTypeItems = { "none", "normal", "pixel", "shine", "proc" }
    local glowTypeDropdown = self:CreateDropdown(f, widgetName, L["Glow Type"], nil, glowTypeItems, "glow.type",
        function(val) f.updateMenu(val) end)
    glowTypeDropdown:SetPoint("TOPLEFT")

    if widgetName ~= const.WIDGET_KIND.DISPELS then
        local glowColor = self:CreateColorPickerOptions(f, widgetName, L["Glow Color"], "glow.color")
        self:AnchorRight(glowColor, glowTypeDropdown)
    end

    local lines = self:CreateSlider(f, widgetName, L["Lines"], nil, 1, 30, "glow.lines")
    self:AnchorBelow(lines, glowTypeDropdown)

    local frequency = self:CreateSlider(f, widgetName, L["Frequency"], nil, -2, 2, "glow.frequency")
    self:AnchorRight(frequency, lines)

    local length = self:CreateSlider(f, widgetName, L["Length"], nil, 1, 50, "glow.length")
    self:AnchorRight(length, frequency)

    local thickness = self:CreateSlider(f, widgetName, L["Thickness"], nil, 1, 20, "glow.thickness")
    self:AnchorBelow(thickness, lines)

    local particles = self:CreateSlider(f, widgetName, L["Particles"], nil, 1, 30, "glow.particles")
    self:AnchorRight(particles, thickness)

    local duration = self:CreateSlider(f, widgetName, L["Duration"], nil, 0.1, 4, "glow.duration")
    self:AnchorRight(duration, particles)

    local scale = self:CreateSlider(f, widgetName, L["Scale"], nil, 50, 500, "glow.scale", true)
    self:AnchorBelow(scale, duration)

    ---@param type GlowType
    f.updateMenu = function(type)
        lines:Hide()
        frequency:Hide()
        length:Hide()
        length:Hide()
        thickness:Hide()
        particles:Hide()
        duration:Hide()
        scale:Hide()

        lines:ClearAllPoints()
        frequency:ClearAllPoints()
        length:ClearAllPoints()
        length:ClearAllPoints()
        thickness:ClearAllPoints()
        particles:ClearAllPoints()
        duration:ClearAllPoints()
        scale:ClearAllPoints()

        if type == const.GlowType.NONE or type == const.GlowType.NORMAL then
            f.wrapperFrame:SetHeight(55)
        elseif type == const.GlowType.PIXEL then
            lines:Show()
            self:AnchorBelow(lines, glowTypeDropdown)

            frequency:Show()
            self:AnchorRight(frequency, lines)

            length:Show()
            self:AnchorBelow(length, lines)

            thickness:Show()
            self:AnchorRight(thickness, length)

            f.wrapperFrame:SetHeight(f.optionHeight + 40)
        elseif type == const.GlowType.SHINE then
            particles:Show()
            self:AnchorBelow(particles, glowTypeDropdown)

            frequency:Show()
            self:AnchorRight(frequency, particles)

            scale:Show()
            self:AnchorBelow(scale, particles)
            f.wrapperFrame:SetHeight(f.optionHeight + 40)
        elseif type == const.GlowType.PROC then
            duration:Show()
            self:AnchorBelow(duration, glowTypeDropdown)
            f.wrapperFrame:SetHeight(110)
        end
    end

    local function LoadPageDB()
        local glow = HandleWidgetOption(widgetName, const.OPTION_KIND.GLOW) --[[@as GlowOpt]]
        f.updateMenu(glow.type)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "GlowOptions")

    return f
end

function Builder:CreateIconTextureOptions(parent, widgetName)
    ---@class IconTextureOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "IconTextureOptions"
    f.optionHeight = 20

    local texturePath = self:CreateEditBox(f, widgetName, L["Texture"], 350, const.OPTION_KIND.ICON_TEXTURE)
    texturePath:SetPoint("TOPLEFT")

    return f
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
    f.optionHeight = 285

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

    f.maxIconsSlider = self:CreateSlider(f, widgetName, L["Max Icons"], nil, 1, Defaults.Values.maxAuraIcons,
        const.AURA_OPTION_KIND.MAX_ICONS)
    self:AnchorBelow(f.maxIconsSlider, f.anchorOptions.sliderY)

    -- Third Row
    f.sizeOptions = self:CreateSizeOptions(f, widgetName)
    Builder:AnchorBelow(f.sizeOptions, f.extraAnchorDropdown)

    f.numPerLineSlider = self:CreateSlider(f, widgetName, L["Per Row"], nil, 2, Defaults.Values.maxAuraIcons,
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

    -- Sixth Row
    f.showTooltip = self:CreateCheckBox(f, widgetName, L["Show Tooltips"], const.AURA_OPTION_KIND.SHOW_TOOLTIP)
    self:AnchorBelowCB(f.showTooltip, f.showAnimation)

    f.hideInCombat = self:CreateCheckBox(f, widgetName, L["Hide in Combat"], const.AURA_OPTION_KIND.HIDE_IN_COMBAT,
        L.HideInCombatTooltip)
    self:AnchorRightOfCB(f.hideInCombat, f.showTooltip)

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
    f.optionHeight = 210

    -- Title
    f.title = self:CreateOptionTitle(f, titleKind .. " Font")

    --- Top Options
    f.anchorOptions = self:CreateAnchorOptions(f, widgetName, const.OPTION_KIND.FONT .. "." .. kind)
    self:AnchorBelow(f.anchorOptions, f.title)

    f.fontOptions = self:CreateFontOptions(f, widgetName, const.OPTION_KIND.FONT .. "." .. kind)
    self:AnchorBelow(f.fontOptions, f.anchorOptions)
    self:AnchorBelow(f.fontOptions.shadowCB, f.fontOptions.outlineDropdown)

    f.colorPicker = Cell.CreateColorPicker(f, L["Color"], false, function(r, g, b, a)
        DB.GetSelectedWidgetTable(widgetName).font[kind].rgb[1] = r
        DB.GetSelectedWidgetTable(widgetName).font[kind].rgb[2] = g
        DB.GetSelectedWidgetTable(widgetName).font[kind].rgb[3] = b
    end)
    self:AnchorBelow(f.colorPicker, f.fontOptions.sizeSlider)

    local function LoadPageDB()
        f.colorPicker:SetColor(DB.GetSelectedWidgetTable(widgetName).font[kind].rgb[1],
            DB.GetSelectedWidgetTable(widgetName).font[kind].rgb[2],
            DB.GetSelectedWidgetTable(widgetName).font[kind].rgb[3])
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
    self:AnchorBelow(f.showStacksCB, f.fontOptions.justifyDropdown)

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
    self:AnchorBelow(f.iconDurationDropdown, f.fontOptions.justifyDropdown)

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
    f.optionHeight = 230

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
    f.dispellableCB = self:CreateCheckBox(f, widgetName, L.Dispellable,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.DISPELLABLE,
        L.DispellableTooltip)
    self:AnchorBelowCB(f.dispellableCB, f.boss)

    f.raidCB = self:CreateCheckBox(f, widgetName, L.Raid,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.RAID,
        L.RaidTooltip)
    self:AnchorRightOfCB(f.raidCB, f.dispellableCB)

    if widgetName == const.WIDGET_KIND.DEBUFFS then
        f.cellRaidDebuffsCB = self:CreateCheckBox(f, widgetName, L["Raid Debuffs"],
            const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.CELL_RAID_DEBUFFS,
            L.CellRaidDebuffsTooltip)
        self:AnchorRightOfCB(f.cellRaidDebuffsCB, f.raidCB)
    end

    -- Fifth Row
    f.useBlacklistCB = self:CreateCheckBox(f, widgetName, L.UseBlacklist,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.USE_BLACKLIST)
    self:AnchorBelowCB(f.useBlacklistCB, f.dispellableCB)

    f.useWhitelistCB = self:CreateCheckBox(f, widgetName, L.UseWhitelist,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.USE_WHITELIST)
    self:AnchorRightOfCB(f.useWhitelistCB, f.useBlacklistCB)

    f.whiteListPriority = self:CreateCheckBox(f, widgetName, L.WhiteListPriority,
        const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.WHITE_LIST_PRIORITY,
        L.WhiteListPriorityTooltip)
    self:AnchorBelowCB(f.whiteListPriority, f.useBlacklistCB)

    if widgetName == const.WIDGET_KIND.BUFFS then
        f.tempEnchant = self:CreateCheckBox(f, widgetName, L.tempEnchant,
            const.AURA_OPTION_KIND.FILTER .. "." .. const.AURA_OPTION_KIND.TEMP_ENCHANT,
            L.tempEnchantTooltip)
        self:AnchorRightOfCB(f.tempEnchant, f.whiteListPriority)

        local function LoadPageDB()
            if CUF.vars.selectedUnit == const.UNIT.PLAYER then
                f.tempEnchant:Show()
            else
                f.tempEnchant:Hide()
            end
        end
        Handler:RegisterOption(LoadPageDB, widgetName, "AuraFilterOptions")
    end

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
    f.optionHeight = 245

    -- Title
    f.title = self:CreateOptionTitle(f, "General")

    -- Second Row
    f.sizeOptions = self:CreateSizeOptions(f, widgetName, 0, 1800, nil, 150)
    self:AnchorBelow(f.sizeOptions, f.title)

    -- Third Row
    f.orientation = self:CreateOrientationOptions(f, widgetName)
    self:AnchorBelow(f.orientation, f.sizeOptions.sizeWidthSlider)

    f.classColorCB = self:CreateCheckBox(f, widgetName, L.UseClassColor, const.OPTION_KIND.USE_CLASS_COLOR)
    self:AnchorRight(f.classColorCB, f.orientation)

    f.onlyShowInterruptableCB = self:CreateCheckBox(f, widgetName, L.OnlyShowInterruptableCast,
        const.OPTION_KIND.ONLY_SHOW_INTERRUPT)
    self:AnchorBelowCB(f.onlyShowInterruptableCB, f.orientation)

    -- Fourth Row
    f.timeToHoldSlider = self:CreateSlider(f, widgetName, L.TimeToHold, nil, 0, 10, const.OPTION_KIND.TIME_TO_HOLD, false,
        0.1)
    self:AnchorBelow(f.timeToHoldSlider, f.onlyShowInterruptableCB)
    CUF:SetTooltips(f.timeToHoldSlider, "ANCHOR_TOPLEFT", 0, 3, L.TimeToHold, L.TimeToHoldTooltip)

    f.interruptedLabelEditBox = self:CreateEditBox(f, widgetName, L.Label, nil, const.OPTION_KIND.INTERRUPTED_LABEL)
    self:AnchorRight(f.interruptedLabelEditBox, f.timeToHoldSlider)
    CUF:SetTooltips(f.interruptedLabelEditBox, "ANCHOR_TOPLEFT", 0, 3, L.Label,
        string.format(L.InterruptedLabelTooltip, "%t", INTERRUPTED, FAILED, "%s"))

    -- Fifth Row
    f.fadeIn = self:CreateSlider(f, widgetName, L.FadeInTimer, nil, 0, 10, const.OPTION_KIND.FADE_IN_TIMER, false,
        0.1)
    self:AnchorBelow(f.fadeIn, f.timeToHoldSlider)

    f.fadeOut = self:CreateSlider(f, widgetName, L.FadeOutTimer, nil, 0, 10, const.OPTION_KIND.FADE_OUT_TIMER, false,
        0.1)
    self:AnchorRight(f.fadeOut, f.fadeIn)

    local function LoadPageDB()
        f.onlyShowInterruptableCB:SetEnabled(CUF.vars.selectedUnit ~= const.UNIT.PLAYER)
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CheckBox_CastBarGeneralOptions_OnlyShowInterruptableCast")

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarTimerFontOptions
function Builder:CreateCastBarTimerFontOptions(parent, widgetName)
    ---@class CastBarTimerFontOptions: BigFontOptions
    local f = Builder:CreateBigFontOptions(parent, widgetName, "Timer", const.OPTION_KIND.TIMER)

    f.optionHeight = f.optionHeight + 50

    local items = {
        const.CastBarTimerFormat.HIDDEN,
        const.CastBarTimerFormat.NORMAL,
        const.CastBarTimerFormat.REMAINING,
        const.CastBarTimerFormat.REMAINING_AND_MAX,
        const.CastBarTimerFormat.DURATION,
        const.CastBarTimerFormat.DURATION_AND_MAX,
    }
    f.timerFormat = self:CreateDropdown(f, widgetName, L.TimerFormat, 140,
        items, const.OPTION_KIND.TIMER_FORMAT)
    self:AnchorBelow(f.timerFormat, f.fontOptions.justifyDropdown)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarSpellFontOptions
function Builder:CreateCastBarSpellFontOptions(parent, widgetName)
    ---@class CastBarSpellFontOptions: BigFontOptions
    local f = Builder:CreateBigFontOptions(parent, widgetName, "Spell", const.OPTION_KIND.SPELL)
    f.optionHeight = f.optionHeight + 100

    f.spellCB = self:CreateCheckBox(f, widgetName, L.ShowSpell, const.OPTION_KIND.SHOW_SPELL)
    self:AnchorBelow(f.spellCB, f.fontOptions.justifyDropdown)

    f.showTarget = self:CreateCheckBox(f, widgetName, L.ShowTarget, const.OPTION_KIND.SHOW_TARGET)
    self:AnchorRightOfCB(f.showTarget, f.spellCB)

    f.targetSeparator = self:CreateEditBox(f, widgetName, L.Separator, nil, const.OPTION_KIND.TARGET_SEPARATOR)
    self:AnchorRightOfCB(f.targetSeparator, f.showTarget)

    f.spellWidth = self:CreateTextWidthOption(f, widgetName, const.OPTION_KIND.SPELL_WIDTH)
    self:AnchorBelow(f.spellWidth, f.spellCB)

    local function LoadPageDB()
        if CUF.vars.selectedUnit == const.UNIT.PLAYER then
            f.showTarget:Show()
            f.targetSeparator:Show()
        else
            f.showTarget:Hide()
            f.targetSeparator:Hide()
        end
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CastBarSpellFontOptions")

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
    f.optionHeight = 60

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

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CastBarBorderOptions
function Builder:CreateCastBarBorderOptions(parent, widgetName)
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
        { "left", "right", "top", "bottom" }, iconPath .. const.OPTION_KIND.POSITION)
    self:AnchorRight(f.position, f.zoom)

    return f
end

-------------------------------------------------
-- MARK: Class Bar
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return ClassBarOptions
function Builder:CreateClassBarOptions(parent, widgetName)
    ---@class ClassBarOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "ClassBarOptions"
    f.optionHeight = 120

    -- First Row
    f.anchorOptions = self:CreateAnchorOptions(f, widgetName, nil, -1000, 1000)
    f.anchorOptions:SetPoint("TOPLEFT", 0, -5)

    -- Second Row
    f.sizeOptions = self:CreateSizeOptions(f, widgetName, 0, 500)
    self:AnchorBelow(f.sizeOptions, f.anchorOptions.anchorDropdown)

    f.spacing = self:CreateSlider(f, widgetName, L["Spacing"], nil, -1, 50,
        const.OPTION_KIND.SPACING)
    self:AnchorRight(f.spacing, f.sizeOptions.sizeHeightSlider)

    -- Third Row
    f.verticalFill = self:CreateCheckBox(f, widgetName, L.VerticalFill, const.OPTION_KIND.VERTICAL_FILL)
    self:AnchorBelow(f.verticalFill, f.sizeOptions.sizeWidthSlider)

    f.sameSizeAsHealthBar = self:CreateCheckBox(f, widgetName, L.SameSizeAsHealthBar,
        const.OPTION_KIND.SAME_SIZE_AS_HEALTH_BAR)
    self:AnchorRightOfCB(f.sameSizeAsHealthBar, f.verticalFill)

    return f
end

-------------------------------------------------
-- MARK: Shield Bar
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return ShieldBarOptions
function Builder:CreateShieldBarOptions(parent, widgetName)
    ---@class ShieldBarOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "ShieldBarOptions"
    f.optionHeight = 25

    -- First Row
    local anchorItems = {
        "RIGHT",
        "LEFT",
        "healthBar"
    }
    f.anchorOptions = self:CreateDropdown(f, widgetName, L["Anchor Point"], 117, anchorItems,
        const.OPTION_KIND.ANCHOR_POINT)
    f.anchorOptions:SetPoint("TOPLEFT", 0, -5)

    f.reverseFill = self:CreateCheckBox(f, widgetName, L["Reverse Fill"],
        const.OPTION_KIND.REVERSE_FILL)
    self:AnchorRight(f.reverseFill, f.anchorOptions)

    f.overShield = self:CreateCheckBox(f, widgetName, L["Over Shield"],
        const.OPTION_KIND.OVER_SHIELD)
    self:AnchorRightOfCB(f.overShield, f.reverseFill)

    -- Dirty hook, should be made generic really
    hooksecurefunc(f.anchorOptions.text, "SetText", function(_, text)
        f.reverseFill:SetEnabled(text == L.healthBar)
        f.overShield:SetEnabled(text == L.healthBar)
    end)

    return f
end

-------------------------------------------------
-- MARK: Custom Text
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CustomTextOptions
function Builder:CreateCustomTextOptions(parent, widgetName)
    ---@class CustomTextOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 325
    f.id = "CustomTextOptions"
    f.selectedIndex = 1

    local function Set_DB(_, path, value)
        HandleWidgetOption(widgetName, "texts.text" .. f.selectedIndex .. "." .. path, value)
    end
    local function Get_DB(_, path)
        return HandleWidgetOption(widgetName, "texts.text" .. f.selectedIndex .. "." .. path)
    end

    ---@type CellDropdown
    local textDropdown = Cell.CreateDropdown(parent, 200)
    textDropdown:SetLabel(L.customText)
    textDropdown:SetPoint("TOPLEFT", f)

    local enableCB = self:CreateCheckBox(parent, widgetName, L["Enabled"], const.OPTION_KIND.ENABLED)
    self:AnchorRight(enableCB, textDropdown)
    enableCB.Set_DB = Set_DB
    enableCB.Get_DB = Get_DB

    -- Format
    local formatEditBox = self:CreateEditBox(parent, widgetName, L["Text Format"], 375, const.OPTION_KIND.TEXT_FORMAT)
    self:AnchorBelow(formatEditBox, textDropdown)
    formatEditBox.Set_DB = Set_DB
    formatEditBox.Get_DB = Get_DB

    ---@class TagHint: CellButton
    local tagHint = CUF:CreateButton(parent, nil, { 20, 20 }, nil, nil, nil, nil, nil, nil, nil,
        L.TagHintButtonTooltip)
    tagHint:SetPoint("LEFT", formatEditBox, "RIGHT", 5, 0)
    tagHint.tex = tagHint:CreateTexture(nil, "ARTWORK")
    tagHint.tex:SetAllPoints(tagHint)
    tagHint.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info2.tga")

    tagHint:SetScript("OnClick", function()
        W.ShowTooltipFrame()
        CUF.HelpTips:Acknowledge(tagHint, L.HelpTip_TagHintButton)
    end)

    CUF.HelpTips:Show(tagHint, {
        text = L.HelpTip_TagHintButton,
        dbKey = "tagHintButton_Builder",
        buttonStyle = HelpTip.ButtonStyle.None,
        alignment = HelpTip.Alignment.Center,
        targetPoint = HelpTip.Point.LeftEdgeCenter,
    })

    -- Color
    local items = {
        { L["Class Color"],  const.ColorType.CLASS_COLOR },
        { L["Custom Color"], const.ColorType.CUSTOM },
    }

    ---@type CellDropdown
    local colorDropdown = Cell.CreateDropdown(parent, 200)
    colorDropdown:SetLabel(L["Color"])
    self:AnchorBelow(colorDropdown, formatEditBox)

    local colorPicker = Cell.CreateColorPicker(f, "", false, function(r, g, b, a)
        Set_DB(widgetName, "color.rgb", { r, g, b })
    end)
    colorPicker:SetPoint("LEFT", colorDropdown, "RIGHT", 2, 0)

    for _, item in pairs(items) do
        colorDropdown:AddItem({
            ["text"] = item[1],
            ["value"] = item[2],
            ["onClick"] = function()
                if item[2] == const.ColorType.CUSTOM then
                    colorPicker:Show()
                else
                    colorPicker:Hide()
                end

                Set_DB(widgetName, "color.type", item[2])
            end,
        })
    end

    -- Anchor
    local anchorOptions = self:CreateFullAnchorOptions(parent, widgetName)
    self:AnchorBelow(anchorOptions, colorDropdown)

    anchorOptions.anchorDropdown.Set_DB = Set_DB
    anchorOptions.anchorDropdown.Get_DB = Get_DB
    anchorOptions.relativeDropdown.Set_DB = Set_DB
    anchorOptions.relativeDropdown.Get_DB = Get_DB
    anchorOptions.sliderX.Set_DB = Set_DB
    anchorOptions.sliderX.Get_DB = Get_DB
    anchorOptions.sliderY.Set_DB = Set_DB
    anchorOptions.sliderY.Get_DB = Get_DB

    -- Font
    local fontItems = Util:GetFontItems()

    local styleDropdown = self:CreateDropdown(parent, widgetName, "Font", nil, fontItems, "font.style")
    self:AnchorBelow(styleDropdown, anchorOptions.relativeDropdown)

    local outlineDropdown = self:CreateDropdown(parent, widgetName, "Outline", nil, const.OUTLINES, "font.outline")
    self:AnchorRight(outlineDropdown, styleDropdown)

    local sizeSlider = self:CreateSlider(f, widgetName, L["Size"], nil, 5, 50, "font.size")
    self:AnchorRight(sizeSlider, outlineDropdown)

    local justifyDropdown = self:CreateDropdown(parent, widgetName, "Alignment", nil, const.TEXT_JUSTIFY, "font.justify")
    self:AnchorBelow(justifyDropdown, styleDropdown)

    local shadowCB = Cell.CreateCheckButton(parent, L["Shadow"], function(checked, cb)
        Set_DB(widgetName, "font.shadow", checked)
    end)
    self:AnchorRight(shadowCB, justifyDropdown)
    --shadowCB:SetPoint("TOPLEFT", styleDropdown, "BOTTOMLEFT", 0, -10)

    styleDropdown.Set_DB = Set_DB
    styleDropdown.Get_DB = Get_DB
    outlineDropdown.Set_DB = Set_DB
    outlineDropdown.Get_DB = Get_DB
    sizeSlider.Set_DB = Set_DB
    sizeSlider.Get_DB = Get_DB
    justifyDropdown.Set_DB = Set_DB
    justifyDropdown.Get_DB = Get_DB

    local function LoadText()
        ---@type HealthTextWidgetTable
        local widgetTable = HandleWidgetOption(widgetName, "texts.text" .. f.selectedIndex)

        textDropdown:SetSelectedValue(f.selectedIndex)
        enableCB:SetChecked(widgetTable.enabled)

        -- Format
        formatEditBox:SetText(widgetTable.textFormat)

        -- Color
        colorDropdown:SetSelectedValue(widgetTable.color.type)
        local r, g, b, a = unpack(widgetTable.color.rgb)
        colorPicker:SetColor(r, g, b, a)

        if widgetTable.color.type == const.ColorType.CUSTOM then
            colorPicker:Show()
        else
            colorPicker:Hide()
        end

        -- Anchor
        anchorOptions.anchorDropdown:SetSelectedValue(widgetTable.position.point)
        anchorOptions.relativeDropdown:SetSelectedValue(widgetTable.position.relativePoint)
        anchorOptions.sliderX:SetValue(widgetTable.position.offsetX)
        anchorOptions.sliderY:SetValue(widgetTable.position.offsetY)

        -- Font
        styleDropdown:SetSelectedValue(widgetTable.font.style)
        outlineDropdown:SetSelectedValue(widgetTable.font.outline)
        sizeSlider:SetValue(widgetTable.font.size)
        shadowCB:SetChecked(widgetTable.font.shadow)
    end

    for i = 1, 5 do
        textDropdown:AddItem({
            ["text"] = "Text " .. i,
            ["value"] = i,
            ["onClick"] = function()
                f.selectedIndex = i
                LoadText()
            end,
        })
    end

    local function LoadPageDB()
        f.selectedIndex = 1
        LoadText()
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CustomTextOptions")

    return f
end

-------------------------------------------------
-- MARK: Dispels
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return DispelsOptions
function Builder:CreateDispelsOptions(parent, widgetName)
    ---@class DispelsOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "DispelsOptions"
    f.optionHeight = 185

    -- First Row
    local highlightTypeItems = {
        { L["None"],                                                               "none" },
        { L["Gradient"] .. " - " .. L["Health Bar"] .. " (" .. L["Entire"] .. ")", "gradient" },
        { L["Gradient"] .. " - " .. L["Health Bar"] .. " (" .. L["Half"] .. ")",   "gradient-half" },
        { L["Solid"] .. " - " .. L["Health Bar"] .. " (" .. L["Entire"] .. ")",    "entire" },
        { L["Solid"] .. " - " .. L["Health Bar"] .. " (" .. L["Current"] .. ")",   "current" },
        { L["Solid"] .. " - " .. L["Health Bar"] .. " (" .. L["Current"] .. "+)",  "current+" },
    }
    local highLightType = self:CreateDropdown(f, widgetName, L["Highlight Type"], 250, highlightTypeItems,
        const.OPTION_KIND.HIGHLIGHT_TYPE)
    highLightType:SetPoint("TOPLEFT", 0, -5)

    -- Filter
    local dispellableByMe = self:CreateCheckBox(f, widgetName, L["dispellableByMe"],
        const.OPTION_KIND.ONLY_SHOW_DISPELLABLE)
    self:AnchorBelow(dispellableByMe, highLightType)

    local curse = self:CreateCheckBox(f, widgetName, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Curse:0|t" .. L
        ["Curse"], const.OPTION_KIND.CURSE)
    self:AnchorBelowCB(curse, dispellableByMe)

    local disease = self:CreateCheckBox(f, widgetName,
        "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Disease:0|t" .. L["Disease"], const.OPTION_KIND.DISEASE)
    self:AnchorRightOfCB(disease, curse)

    local magic = self:CreateCheckBox(f, widgetName, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Magic:0|t" .. L
        ["Magic"], const.OPTION_KIND.MAGIC)
    self:AnchorRightOfCB(magic, disease)

    local poison = self:CreateCheckBox(f, widgetName,
        "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Poison:0|t" .. L["Poison"], const.OPTION_KIND.POISON)
    self:AnchorBelowCB(poison, curse)

    local bleed = self:CreateCheckBox(f, widgetName, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Bleed:0|t" .. L
        ["Bleed"], const.OPTION_KIND.BLEED)
    self:AnchorRightOfCB(bleed, poison)

    local enrage = self:CreateCheckBox(f, widgetName, L.Enrage, const.OPTION_KIND.ENRAGE)
    self:AnchorRightOfCB(enrage, bleed)

    -- Icon Style
    local blizzard = ""
    local blizzard_icon = "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\%s:0|t"

    local rhombus = ""
    local rhombus_icon = "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Rhombus:0:0:0:0:16:16:0:16:0:16:%s:%s:%s|t"

    local types = { "Magic", "Curse", "Disease", "Poison", "Bleed" }
    for _, t in pairs(types) do
        blizzard = blizzard .. blizzard_icon:format(t) .. " "

        local r, g, b = F.ConvertRGB_256(I.GetDebuffTypeColor(t))
        rhombus = rhombus .. rhombus_icon:format(r, g, b) .. " "
    end

    local iconStyleItems = {
        { L["None"], "none" },
        { blizzard,  "blizzard" },
        { rhombus,   "rhombus" },
    }
    local iconStyle = self:CreateDropdown(f, widgetName, L["Icon Style"], 250, iconStyleItems,
        const.OPTION_KIND.ICON_STYLE)
    self:AnchorBelow(iconStyle, poison)

    return f
end

-------------------------------------------------
-- MARK: Totems
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return TotemOptions
function Builder:CreateTotemOptions(parent, widgetName)
    ---@class TotemOptions: AuraIconOptions
    local f = self:CreateAuraIconOptions(parent, widgetName)
    f.id = "TotemOptions"

    f.maxIconsSlider:UpdateMinMaxValues(1, 5)
    f.numPerLineSlider:UpdateMinMaxValues(2, 5)

    return f
end

-------------------------------------------------
-- MARK: Highlight
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return HighlightOptions
function Builder:CreateHighlightOptions(parent, widgetName)
    ---@class HighlightOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "HighlightOptions"
    f.optionHeight = 65

    local targetCB = self:CreateCheckBox(f, widgetName, L.target, const.OPTION_KIND.TARGET)
    targetCB:SetPoint("TOPLEFT", 0, 10)
    local hoverCB = self:CreateCheckBox(f, widgetName, L.Hover, const.OPTION_KIND.HOVER)
    self:AnchorRightOfCB(hoverCB, targetCB)

    local sizeSlider = self:CreateSlider(f, widgetName, L["Highlight Size"], nil, -5, 5,
        const.OPTION_KIND.SIZE)
    self:AnchorBelow(sizeSlider, targetCB)

    return f
end

-------------------------------------------------
-- MARK: Alt Power
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return AltPowerOptions
function Builder:CreateAltPowerOptions(parent, widgetName)
    ---@class AltPowerOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 130
    f.id = "AltPowerOptions"

    f.sizeOptions = self:CreateSizeOptions(f, widgetName, 1, 500)
    f.sizeOptions:SetPoint("TOPLEFT", 0, -5)

    f.sameSizeAsHealthBar = self:CreateCheckBox(f, widgetName, L.SameSizeAsHealthBar,
        const.OPTION_KIND.SAME_SIZE_AS_HEALTH_BAR)
    self:AnchorBelow(f.sameSizeAsHealthBar, f.sizeOptions)

    f.hideIfEmpty = self:CreateCheckBox(f, widgetName, L.HideIfEmpty,
        const.OPTION_KIND.HIDE_IF_EMPTY)
    self:AnchorBelowCB(f.hideIfEmpty, f.sameSizeAsHealthBar)

    f.hideIfFull = self:CreateCheckBox(f, widgetName, L.HideIfFull,
        const.OPTION_KIND.HIDE_IF_FULL)
    self:AnchorRightOfCB(f.hideIfFull, f.hideIfEmpty)

    f.hideOutOfCombat = self:CreateCheckBox(f, widgetName, L.HideOutOfCombat,
        const.OPTION_KIND.HIDE_OUT_OF_COMBAT)
    self:AnchorBelowCB(f.hideOutOfCombat, f.hideIfEmpty)

    return f
end

-------------------------------------------------
-- MARK: Power Bar
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return PowerBarOptions
function Builder:CreatePowerBarOptions(parent, widgetName)
    ---@class PowerBarOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 190
    f.id = "PowerBarOptions"

    f.sizeOptions = self:CreateSizeOptions(f, widgetName, 1, 500)
    f.sizeOptions:SetPoint("TOPLEFT", 0, -5)

    f.sameWidthAsHealthBar = self:CreateCheckBox(f, widgetName, L.SameWidthAsHealthBar,
        const.OPTION_KIND.SAME_WIDTH_AS_HEALTH_BAR)
    self:AnchorBelow(f.sameWidthAsHealthBar, f.sizeOptions)
    f.sameHeightAsHealthBar = self:CreateCheckBox(f, widgetName, L.SameHeightAsHealthBar,
        const.OPTION_KIND.SAME_HEIGHT_AS_HEALTH_BAR)
    self:AnchorBelowCB(f.sameHeightAsHealthBar, f.sameWidthAsHealthBar)

    f.hideIfEmpty = self:CreateCheckBox(f, widgetName, L.HideIfEmpty,
        const.OPTION_KIND.HIDE_IF_EMPTY)
    self:AnchorBelowCB(f.hideIfEmpty, f.sameHeightAsHealthBar)

    f.hideIfFull = self:CreateCheckBox(f, widgetName, L.HideIfFull,
        const.OPTION_KIND.HIDE_IF_FULL)
    self:AnchorRightOfCB(f.hideIfFull, f.hideIfEmpty)

    f.hideOutOfCombat = self:CreateCheckBox(f, widgetName, L.HideOutOfCombat,
        const.OPTION_KIND.HIDE_OUT_OF_COMBAT)
    self:AnchorBelowCB(f.hideOutOfCombat, f.hideIfEmpty)

    f.powerFilter = self:CreateCheckBox(f, widgetName, L.PowerFilter,
        const.OPTION_KIND.POWER_FILTER, L.PowerFilterTooltip)
    self:AnchorBelowCB(f.powerFilter, f.hideOutOfCombat)

    return f
end

-------------------------------------------------
-- MARK: Heal Prediction
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return HealPredictionOptions
function Builder:CreateHealPredictionOptions(parent, widgetName)
    ---@class HealPredictionOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.id = "HealPredictionOptions"
    f.optionHeight = 25

    -- First Row
    local anchorItems = {
        "RIGHT",
        "LEFT",
        "healthBar"
    }
    f.anchorOptions = self:CreateDropdown(f, widgetName, L["Anchor Point"], 117, anchorItems,
        const.OPTION_KIND.ANCHOR_POINT)
    f.anchorOptions:SetPoint("TOPLEFT", 0, -5)

    f.reverseFill = self:CreateCheckBox(f, widgetName, L["Reverse Fill"],
        const.OPTION_KIND.REVERSE_FILL)
    self:AnchorRight(f.reverseFill, f.anchorOptions)

    f.overHeal = self:CreateCheckBox(f, widgetName, L["Over Heal"],
        const.OPTION_KIND.OVER_HEAL)
    self:AnchorRightOfCB(f.overHeal, f.reverseFill)

    -- Dirty hook, should be made generic really
    hooksecurefunc(f.anchorOptions.text, "SetText", function(_, text)
        f.reverseFill:SetEnabled(text == L.healthBar)
        f.overHeal:SetEnabled(text == L.healthBar)
    end)

    return f
end

-------------------------------------------------
-- MARK: Power Text Anchor
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return PowerTextAnchorOptions
function Builder:CreatePowerTextAnchorOptions(parent, widgetName)
    ---@class PowerTextAnchorOptions: FullAnchorOptions
    local anchorOpt = self:CreateFullAnchorOptions(parent, widgetName)
    anchorOpt.optionHeight = 70
    anchorOpt.id = "PowerTextAnchor"

    anchorOpt.anchorToPowerBarCB = self:CreateCheckBox(parent, widgetName, L.AnchorToPowerBar,
        const.OPTION_KIND.ANCHOR_TO_POWER_BAR)
    self:AnchorRight(anchorOpt.anchorToPowerBarCB, anchorOpt.relativeDropdown)

    return anchorOpt
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
    [Builder.MenuOptions.DetachedAnchor] = Builder.CreateDetachedAnchorOptions,
    [Builder.MenuOptions.Font] = Builder.CreateFontOptions,
    [Builder.MenuOptions.HealthFormat] = Builder.CreateHealthFormatOptions,
    [Builder.MenuOptions.PowerFormat] = Builder.CreatePowerFormatOptions,
    [Builder.MenuOptions.NameFormat] = Builder.CreateNameFormatOptions,
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
    [Builder.MenuOptions.CastBarTimer] = Builder.CreateCastBarTimerFontOptions,
    [Builder.MenuOptions.CastBarSpell] = Builder.CreateCastBarSpellFontOptions,
    [Builder.MenuOptions.CastBarSpark] = Builder.CreateCastBarSparkOptions,
    [Builder.MenuOptions.CastBarEmpower] = Builder.CreateCastBarEmpowerOptions,
    [Builder.MenuOptions.CastBarBorder] = Builder.CreateCastBarBorderOptions,
    [Builder.MenuOptions.CastBarIcon] = Builder.CreateCastBarIconOptions,
    [Builder.MenuOptions.ClassBarOptions] = Builder.CreateClassBarOptions,
    [Builder.MenuOptions.ShieldBarOptions] = Builder.CreateShieldBarOptions,
    [Builder.MenuOptions.CustomText] = Builder.CreateCustomTextOptions,
    [Builder.MenuOptions.DispelsOptions] = Builder.CreateDispelsOptions,
    [Builder.MenuOptions.TrueSingleSizeOptions] = Builder.CreateTrueSingleSizeOptions,
    [Builder.MenuOptions.TotemOptions] = Builder.CreateTotemOptions,
    [Builder.MenuOptions.HideAtMaxLevel] = Builder.CreateHideAtMaxLevel,
    [Builder.MenuOptions.HideOutOfCombat] = Builder.CreateHideOutOfCombat,
    [Builder.MenuOptions.Glow] = Builder.CreateGlowOptions,
    [Builder.MenuOptions.IconTexture] = Builder.CreateIconTextureOptions,
    [Builder.MenuOptions.Highlight] = Builder.CreateHighlightOptions,
    [Builder.MenuOptions.AltPower] = Builder.CreateAltPowerOptions,
    [Builder.MenuOptions.PowerBar] = Builder.CreatePowerBarOptions,
    [Builder.MenuOptions.HealPredictionOptions] = Builder.CreateHealPredictionOptions,
    [Builder.MenuOptions.PowerTextAnchorOptions] = Builder.CreatePowerTextAnchorOptions,
}
