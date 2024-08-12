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
local Builder = {}
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

---@param settingsFrame MenuFrame.settingsFrame
---@param widgetName WIDGET_KIND
---@param ... MenuOptions
---@return WidgetsMenuPage
function Builder:CreateWidgetMenuPage(settingsFrame, widgetName, ...)
    ---@class WidgetsMenuPage
    local widgetPage = {}

    ---@class WidgetsMenuPageFrame: Frame
    widgetPage.frame = CUF:CreateFrame(nil, settingsFrame.scrollFrame.content,
        settingsFrame:GetWidth(), settingsFrame:GetHeight(), true)
    widgetPage.frame:SetPoint("TOPLEFT")
    widgetPage.frame:Hide()

    widgetPage.id = widgetName
    widgetPage.height = 40 -- enabledCheckBox + spacingY

    widgetPage.frame._GetHeight = function()
        return widgetPage.height
    end
    widgetPage.frame._SetHeight = function(height)
        widgetPage.height = height
        settingsFrame.scrollFrame:SetContentHeight(height)
    end

    local enabledCheckBox = self:CreatEnabledCheckBox(widgetPage.frame, widgetName)

    ---@type Frame
    local prevOption = enabledCheckBox
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
-- MARK: Builder
-------------------------------------------------

---@param option Frame
---@param prevOptions Frame
function Builder:AnchorBelow(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, 0, -self.spacingY)
end

---@param option Frame
---@param prevOptions Frame
function Builder:AnchorRight(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, "TOPRIGHT", self.spacingX, 0)
end

---@param option Frame
---@param prevOptions Frame
function Builder:AnchorRightOfCB(option, prevOptions)
    option:SetPoint("TOPLEFT", prevOptions, "TOPLEFT", self.spacingX + 117, 0)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param widgetName WIDGET_KIND
---@param kind OPTION_KIND | AURA_OPTION_KIND
---@param value any
---@param keys? (OPTION_KIND | AURA_OPTION_KIND)[]
local function Set_DB(widgetName, kind, value, keys)
    local widgetTable = DB.GetWidgetTable(widgetName)

    if not keys or #keys == 0 then
        widgetTable[kind] = value
        return
    end

    local t = widgetTable[kind]
    local lastKey = keys[#keys]
    for _, v in pairs(keys) do
        if v == lastKey then break end
        t = t[v]
    end
    t[lastKey] = value
end

---@param widgetName WIDGET_KIND
---@param kind OPTION_KIND | AURA_OPTION_KIND
---@param keys? (OPTION_KIND | AURA_OPTION_KIND)[]
local function Get_DB(widgetName, kind, keys)
    local result = DB.GetWidgetProperty(widgetName, kind)

    if not keys then return result end

    for _, v in pairs(keys) do
        result = result[v]
    end
    return result
end

-------------------------------------------------
-- MARK: CheckBox
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string
---@param kind OPTION_KIND | AURA_OPTION_KIND Which property to set
---@param keys? (OPTION_KIND | AURA_OPTION_KIND)[] Keys to traverse to the property
---@return CUFCheckBox
function Builder:CreateCheckBox(parent, widgetName, title, kind, keys)
    ---@class CUFCheckBox: CheckButton
    local checkbox = Cell:CreateCheckButton(parent, L[title], function(checked, cb)
        cb.Set_DB(widgetName, kind, checked, keys)
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, kind, keys and unpack(keys))
    end)

    checkbox.Set_DB = Set_DB
    checkbox.Get_DB = Get_DB

    checkbox:SetPoint("TOPLEFT")
    checkbox:SetChecked(checkbox.Get_DB(widgetName, kind, keys))

    local function LoadPageDB()
        checkbox:SetChecked(checkbox.Get_DB(widgetName, kind, keys))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "CheckBox_" .. kind)

    return checkbox
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return EnabledCheckBox
function Builder:CreatEnabledCheckBox(parent, widgetName)
    ---@class EnabledCheckBox
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
---@param kind OPTION_KIND | AURA_OPTION_KIND Which property to set
---@param ... OPTION_KIND | AURA_OPTION_KIND Keys to traverse to the property
---@return CUFSlider
function Builder:CreateSlider(parent, widgetName, title, width, minVal, maxVal, kind, ...)
    ---@class CUFSlider: CellSlider
    local slider = Cell:CreateSlider(L[title], parent, minVal, maxVal, width or 117, 1)
    slider.id = kind

    slider.Set_DB = Set_DB
    slider.Get_DB = Get_DB

    local keys = { ... }
    slider.afterValueChangedFn = function(value)
        slider.Set_DB(widgetName, kind, value, keys)
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, kind)
    end

    local function LoadPageDB()
        slider:SetValue(slider.Get_DB(widgetName, kind, keys))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "Slider_" .. kind)

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
---@param kind OPTION_KIND | AURA_OPTION_KIND Which property to set
---@param ... OPTION_KIND | AURA_OPTION_KIND Keys to traverse to the property
---@return CUFDropdown
function Builder:CreateDropdown(parent, widgetName, title, width, items, kind, ...)
    ---@class CUFDropdown: CellDropdown
    local dropdown = Cell:CreateDropdown(parent, width or 117)
    dropdown.optionHeight = 20
    dropdown.id = kind
    dropdown:SetLabel(L[title])

    dropdown.Set_DB = Set_DB
    dropdown.Get_DB = Get_DB

    local keys = { ... }

    local dropDownItems = {}
    for _, item in ipairs(items) do
        local text = type(item) == "string" and item or item[1]
        local value = type(item) == "string" and item or item[2]

        tinsert(dropDownItems, {
            ["text"] = L[text],
            ["value"] = value,
            ["onClick"] = function()
                dropdown.Set_DB(widgetName, kind, value, keys)
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, kind)
            end,
        })
    end
    dropdown:SetItems(dropDownItems)

    local function LoadPageDB()
        dropdown:SetSelectedValue(dropdown.Get_DB(widgetName, kind, keys))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "Dropdown_" .. kind)

    return dropdown
end

-------------------------------------------------
-- MARK: EditBox
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param title string
---@param width number? Default: 117
---@param kind OPTION_KIND | AURA_OPTION_KIND Which property to set
---@param ... OPTION_KIND | AURA_OPTION_KIND Keys to traverse to the property
---@return CUFEditBox
function Builder:CreateEditBox(parent, widgetName, title, width, kind, ...)
    ---@class CUFEditBox: EditBox, OptionsFrame
    local editBox = CUF:CreateEditBox(parent, width or 117, 20, L[title])
    editBox.id = kind
    editBox.optionHeight = 20

    editBox.Set_DB = Set_DB
    editBox.Get_DB = Get_DB

    local keys = { ... }

    editBox:SetScript("OnEnterPressed", function()
        editBox:ClearFocus()
        local value = editBox:GetText()
        editBox.Set_DB(widgetName, kind, value, keys)
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, kind)
    end)

    local function LoadPageDB()
        editBox:SetText(editBox.Get_DB(widgetName, kind, keys))
    end
    Handler:RegisterOption(LoadPageDB, widgetName, "EditBox_" .. kind)

    return editBox
end

-----------------------------------------------
-- MARK: Color Picker
-----------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return CUFColorPicker
function Builder:CreateColorPickerOptions(parent, widgetName)
    ---@class CUFColorPicker: CellColorPicker, OptionsFrame
    local colorPicker = Cell:CreateColorPicker(parent, L["Color"], true)
    colorPicker.id = "ColorPicker"
    colorPicker.optionHeight = 25

    colorPicker.Set_DB = Set_DB
    colorPicker.Get_DB = Get_DB

    colorPicker.onChange = function(r, g, b, a)
        colorPicker.Set_DB(widgetName, const.OPTION_KIND.RGBA, { r, g, b, a })
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND
            .COLOR, const.OPTION_KIND.RGBA)
    end

    local function LoadPageDB()
        local r, g, b, a = unpack(colorPicker.Get_DB(widgetName, const.OPTION_KIND.RGBA))
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
---@return TextWidthOption
function Builder:CreateTextWidthOption(parent, widgetName)
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
                DB.GetWidgetTable(widgetName).width.type = "unlimited"
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
                DB.GetWidgetTable(widgetName).width.type = "percentage"
                DB.GetWidgetTable(widgetName).width.value = 0.75
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
                DB.GetWidgetTable(widgetName).width.type = "length"
                DB.GetWidgetTable(widgetName).width.value = 5
                DB.GetWidgetTable(widgetName).width.auxValue = 3
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
    percentDropdown:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", self.spacingX, 0)
    Cell:SetTooltips(percentDropdown.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])
    percentDropdown:SetItems({
        {
            ["text"] = "100%",
            ["value"] = 1,
            ["onClick"] = function()
                DB.GetWidgetTable(widgetName).width.value = 1
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
        {
            ["text"] = "75%",
            ["value"] = 0.75,
            ["onClick"] = function()
                DB.GetWidgetTable(widgetName).width.value = 0.75
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
        {
            ["text"] = "50%",
            ["value"] = 0.5,
            ["onClick"] = function()
                DB.GetWidgetTable(widgetName).width.value = 0.5
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
        {
            ["text"] = "25%",
            ["value"] = 0.25,
            ["onClick"] = function()
                DB.GetWidgetTable(widgetName).width.value = 0.25
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName,
                    const.OPTION_KIND.TEXT_WIDTH)
            end,
        },
    })

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

        DB.GetWidgetTable(widgetName).width.value = length
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

        DB.GetWidgetTable(widgetName).width.auxValue = length
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
        f:SetNameWidth(DB.GetWidgetTable(widgetName).width)
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
        const.OPTION_KIND.COLOR, "type")
    f.dropdown:SetPoint("TOPLEFT", f)

    f.dropdown.Set_DB = function(...)
        Set_DB(...)
        if DB.GetWidgetTable(widgetName).color.type == const.ColorType.CUSTOM then
            f.colorPicker:Show()
        else
            f.colorPicker:Hide()
        end
    end

    f.colorPicker = Cell:CreateColorPicker(f, "", false, function(r, g, b, a)
        DB.GetWidgetTable(widgetName).color.rgb[1] = r
        DB.GetWidgetTable(widgetName).color.rgb[2] = g
        DB.GetWidgetTable(widgetName).color.rgb[3] = b
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND
            .TEXT_COLOR, "rgb")
    end)
    f.colorPicker:SetPoint("LEFT", f.dropdown, "RIGHT", 2, 0)

    local function LoadPageDB()
        f.colorPicker:SetColor(DB.GetWidgetTable(widgetName).color.rgb[1], DB.GetWidgetTable(widgetName).color.rgb[2],
            DB.GetWidgetTable(widgetName).color.rgb[3])
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
---@param altKind? OPTION_KIND | AURA_OPTION_KIND
---@param ... OPTION_KIND|AURA_OPTION_KIND Extra keys to traverse to the property
---@return AnchorOptions
function Builder:CreateAnchorOptions(parent, widgetName, altKind, ...)
    ---@class AnchorOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 20
    f.id = "Anchor"

    f.anchorDropdown = self:CreateDropdown(parent, widgetName, "Anchor", nil, const.ANCHOR_POINTS,
        altKind or const.OPTION_KIND.POSITION, ..., "anchor")
    f.anchorDropdown:SetPoint("TOPLEFT", f)

    f.sliderX = self:CreateSlider(f, widgetName, L["X Offset"], nil, -100, 100, altKind or const.OPTION_KIND
        .POSITION,
        ..., "offsetX")
    self:AnchorRight(f.sliderX, f.anchorDropdown)

    f.sliderY = self:CreateSlider(f, widgetName, L["Y Offset"], nil, -100, 100, altKind or const.OPTION_KIND
        .POSITION,
        ..., "offsetY")
    self:AnchorRight(f.sliderY, f.sliderX)

    return f
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return ExtraAnchorOptions
function Builder:CreateExtraAnchorOptions(parent, widgetName, altKind, ...)
    ---@class ExtraAnchorOptions: AnchorOptions
    return self:CreateDropdown(parent, widgetName, "To UnitButton's", nil, const.ANCHOR_POINTS,
        altKind or const.OPTION_KIND.POSITION, ..., "extraAnchor")
end

---@param parent Frame
---@param widgetName WIDGET_KIND
---@param altKind? OPTION_KIND | AURA_OPTION_KIND
---@param ... OPTION_KIND|AURA_OPTION_KIND Extra keys to traverse to the property
---@return FullAnchorOptions
function Builder:CreateFullAnchorOptions(parent, widgetName, altKind, ...)
    ---@class FullAnchorOptions: AnchorOptions
    local anchorOpt = self:CreateAnchorOptions(parent, widgetName, altKind, ...)
    anchorOpt.optionHeight = 70
    anchorOpt.id = "FullAnchor"

    anchorOpt.relativeDropdown = self:CreateDropdown(parent, widgetName, "Relative To", nil, const.ANCHOR_POINTS,
        altKind or const.OPTION_KIND.POSITION, ..., "extraAnchor")
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
---@param ... OPTION_KIND|AURA_OPTION_KIND Extra keys to traverse to the property
---@return FontOptions
function Builder:CreateFontOptions(parent, widgetName, ...)
    ---@class FontOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)
    f.optionHeight = 45
    f.id = "Font"

    local fontItems = Util:GetFontItems()

    f.styleDropdown = self:CreateDropdown(parent, widgetName, "Font", nil, fontItems,
        const.OPTION_KIND.FONT, ..., "style")
    f.styleDropdown:SetPoint("TOPLEFT", f)

    f.outlineDropdown = self:CreateDropdown(parent, widgetName, "Outline", nil, const.OUTLINES,
        const.OPTION_KIND.FONT, ..., "outline")
    self:AnchorRight(f.outlineDropdown, f.styleDropdown)

    f.sizeSlider = self:CreateSlider(f, widgetName, L["Size"], nil, 5, 50,
        const.OPTION_KIND.FONT, ..., "size")
    self:AnchorRight(f.sizeSlider, f.outlineDropdown)

    f.shadowCB = self:CreateCheckBox(f, widgetName, L["Shadow"], const.OPTION_KIND.FONT,
        { ..., "shadow" })
    f.shadowCB:SetPoint("TOPLEFT", f.styleDropdown, "BOTTOMLEFT", 0, -10)

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
    f.optionHeight = 70
    f.id = "HealthFormatOptions"

    f.formatDropdown = self:CreateDropdown(parent, widgetName, "Format", 200,
        healthFormats, const.OPTION_KIND.FORMAT)
    f.formatDropdown:SetPoint("TOPLEFT", f)

    f.formatEditBox = self:CreateEditBox(parent, widgetName, L["Text Format"], 300, const.OPTION_KIND.TEXT_FORMAT)
    self:AnchorBelow(f.formatEditBox, f.formatDropdown)

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

    return f
end

-------------------------------------------------
-- MARK: Size
-------------------------------------------------

---@param parent Frame
---@param widgetName WIDGET_KIND
---@return SizeOptions
function Builder:CreateSizeOptions(parent, widgetName)
    ---@class SizeOptions: OptionsFrame
    local f = CUF:CreateFrame(nil, parent, 1, 1, true, true)

    f.sizeWidthSlider = self:CreateSlider(f, widgetName, L["Width"], nil, 0, 100,
        const.AURA_OPTION_KIND.SIZE,
        "width")
    f.sizeWidthSlider:SetPoint("TOPLEFT", f)

    f.sizeHeightSlider = self:CreateSlider(f, widgetName, L["Height"], nil, 0, 100,
        const.AURA_OPTION_KIND.SIZE,
        "height")
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
        const.AURA_OPTION_KIND.SIZE, const.OPTION_KIND.WIDTH)
    f.sizeSlider:SetPoint("TOPLEFT", f)

    f.sizeSlider.Set_DB = function(_which, _kind, value)
        Set_DB(widgetName, const.AURA_OPTION_KIND.SIZE, value, { const.OPTION_KIND.WIDTH })
        Set_DB(widgetName, const.AURA_OPTION_KIND.SIZE, value, { const.OPTION_KIND.HEIGHT })
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.AURA_OPTION_KIND.SIZE)
    end

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
        const.AURA_OPTION_KIND.SPACING, "horizontal")
    self:AnchorBelow(f.spacingHorizontalSlider, f.sizeOptions)

    f.spacingVerticalSlider = self:CreateSlider(f, widgetName, L["Y Spacing"], nil, 0, 50,
        const.AURA_OPTION_KIND.SPACING, "vertical")
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
    f.anchorOptions = self:CreateAnchorOptions(f, widgetName, const.OPTION_KIND.FONT, kind)
    self:AnchorBelow(f.anchorOptions, f.title)

    f.fontOptions = self:CreateFontOptions(f, widgetName, kind)
    self:AnchorBelow(f.fontOptions, f.anchorOptions)
    self:AnchorBelow(f.fontOptions.shadowCB, f.fontOptions.outlineDropdown)

    f.colorPicker = Cell:CreateColorPicker(f, L["Color"], false, function(r, g, b, a)
        DB.GetWidgetTable(widgetName).font[kind].rgb[1] = r
        DB.GetWidgetTable(widgetName).font[kind].rgb[2] = g
        DB.GetWidgetTable(widgetName).font[kind].rgb[3] = b
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, widgetName, const.OPTION_KIND
            .TEXT_COLOR, "rgb")
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
    f.optionHeight = 135

    -- Title
    f.title = self:CreateOptionTitle(f, "Filter")

    --- First Row
    f.maxDurationSlider = self:CreateSlider(f, widgetName, L.MaxDuration, 165, 0, 10800,
        const.AURA_OPTION_KIND.FILTER, "maxDuration")
    self:AnchorBelow(f.maxDurationSlider, f.title)
    f.maxDurationSlider.currentEditBox:SetWidth(60)

    f.minDurationSlider = self:CreateSlider(f, widgetName, L.MinDuration, 165, 0, 10800,
        const.AURA_OPTION_KIND.FILTER, "minDuration")
    self:AnchorRight(f.minDurationSlider, f.maxDurationSlider)
    f.minDurationSlider.currentEditBox:SetWidth(60)

    -- Second Row
    f.hideNoDuration = self:CreateCheckBox(f, widgetName, L.HideNoDuration, const.AURA_OPTION_KIND.FILTER,
        { "hideNoDuration" })
    self:AnchorBelow(f.hideNoDuration, f.maxDurationSlider)

    f.hidePersonalCB = self:CreateCheckBox(f, widgetName, L.HidePersonal, const.AURA_OPTION_KIND.FILTER,
        { "hidePersonal" })
    self:AnchorRightOfCB(f.hidePersonalCB, f.hideNoDuration)

    f.hideExternalCB = self:CreateCheckBox(f, widgetName, L.HideExternal, const.AURA_OPTION_KIND.FILTER,
        { "hideExternal" })
    self:AnchorRightOfCB(f.hideExternalCB, f.hidePersonalCB)

    -- Third Row
    f.useBlacklistCB = self:CreateCheckBox(f, widgetName, L.UseBlacklist, const.AURA_OPTION_KIND.FILTER,
        { "useBlacklist" })
    f.useBlacklistCB:SetPoint("TOPLEFT", f.hideNoDuration, 0, -30)

    f.useWhitelistCB = self:CreateCheckBox(f, widgetName, L.UseWhitelist, const.AURA_OPTION_KIND.FILTER,
        { "useWhitelist" })
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
}
