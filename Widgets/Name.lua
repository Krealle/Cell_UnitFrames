---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.Util
local Util = CUF.Util
---@class CUF.widgets.Handler
local Handler = CUF.widgetsHandler

local menu = CUF.Menu

--! AI followers, wrong value returned by UnitClassBase
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

-------------------------------------------------
-- MARK: Button Update Name
-------------------------------------------------

---@param button CUFUnitButton
function W:UnitFrame_UpdateName(button)
    local unit = button.states.unit
    if not unit then return end

    button.states.name = UnitName(unit)
    button.states.fullName = F:UnitFullName(unit)
    button.states.class = UnitClassBase(unit)
    button.states.guid = UnitGUID(unit)
    button.states.isPlayer = UnitIsPlayer(unit)
    button.states.class = UnitClassBase(unit) --! update class or it may be nil

    button.widgets.nameText:UpdateName()
    button.widgets.nameText:UpdateTextColor()
end

-------------------------------------------------
-- MARK: CreateNameText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateNameText(button)
    ---@class NameTextWidget: FontString
    local nameText = button.widgets.healthBar:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    button.widgets.nameText = nameText
    nameText.width = CUF.defaults.fontWidth
    nameText:ClearAllPoints()
    nameText:SetPoint("CENTER", 0, 0)
    nameText:SetFont("Cell Default", 12, "Outline")

    function nameText:UpdateName()
        local name

        if CELL_NICKTAG_ENABLED and Cell.NickTag then
            name = Cell.NickTag:GetNickname(button.states.name, nil, true)
        end
        name = name or F:GetNickname(button.states.name, button.states.fullName)

        Util:UpdateTextWidth(nameText, name, nameText.width, button)
    end

    function nameText:UpdateTextColor()
        if not Cell.vars.currentLayoutTable[button.states.unit] then
            button.widgets.nameText:SetTextColor(1, 1, 1)
            return
        end

        if not UnitIsConnected(button.states.unit) then
            button.widgets.nameText:SetTextColor(F:GetClassColor(button.states.class))
        else
            if CUF.vars.selectedLayoutTable[button.states.unit].widgets.name.color.type == "class_color" then
                button.widgets.nameText:SetTextColor(F:GetClassColor(button.states.class))
            else
                button.widgets.nameText:SetTextColor(unpack(CUF.vars.selectedLayoutTable[button.states.unit].widgets
                    .name
                    .color.rgb))
            end
        end
    end
end

-------------------------------------------------
-- MARK: CreateNameWidth
-------------------------------------------------

local function CreateNameWidth(parent)
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
                CUF.vars.selectedWidgetTable.name.width.type = "unlimited"
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
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
                CUF.vars.selectedWidgetTable.name.width.type = "percentage"
                CUF.vars.selectedWidgetTable.name.width.value = 0.75
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
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
                CUF.vars.selectedWidgetTable.name.width.type = "length"
                CUF.vars.selectedWidgetTable.name.width.value = 5
                CUF.vars.selectedWidgetTable.name.width.auxValue = 3
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
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
                CUF.vars.selectedWidgetTable.name.width.value = 1
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
            end,
        },
        {
            ["text"] = "75%",
            ["value"] = 0.75,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable.name.width.value = 0.75
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
            end,
        },
        {
            ["text"] = "50%",
            ["value"] = 0.5,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable.name.width.value = 0.5
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
            end,
        },
        {
            ["text"] = "25%",
            ["value"] = 0.25,
            ["onClick"] = function()
                CUF.vars.selectedWidgetTable.name.width.value = 0.25
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
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

        CUF.vars.selectedWidgetTable.name.width.value = length
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
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

        CUF.vars.selectedWidgetTable.name.width.auxValue = length
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
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

    return f
end

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(
---@param parent MenuFrame
    function(parent)
        local widget = {}
        widget.frame = CreateFrame("Frame", nil, parent.widgetAnchor)
        widget.id = "name"
        widget.height = 200

        -- button
        widget.button = Cell:CreateButton(parent.widgetAnchor, L["Name"], "accent-hover", { 85, 17 })
        widget.button.id = "name"

        local nameCP = Cell:CreateColorPicker(widget.frame, "", false, function(r, g, b, a)
            CUF.vars.selectedWidgetTable.name.color.rgb[1] = r
            CUF.vars.selectedWidgetTable.name.color.rgb[2] = g
            CUF.vars.selectedWidgetTable.name.color.rgb[3] = b
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
        end)

        local nameColorDropdown = Cell:CreateDropdown(widget.frame, 117)
        nameColorDropdown:SetPoint("TOPLEFT", widget.frame, 5, -42)
        nameColorDropdown:SetLabel(L["Color"])
        nameColorDropdown:SetItems({
            {
                ["text"] = L["Class Color"],
                ["value"] = "class_color",
                ["onClick"] = function()
                    CUF.vars.selectedWidgetTable.name.color.type = "class_color"
                    nameCP:Hide()
                    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "custom",
                ["onClick"] = function()
                    CUF.vars.selectedWidgetTable.name.color.type = "custom"
                    nameCP:Show()
                    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
                end,
            },
        })
        nameCP:SetPoint("LEFT", nameColorDropdown, "RIGHT", 2, 0)

        local nameWidth = CreateNameWidth(widget.frame)
        nameWidth:SetPoint("TOPLEFT", nameColorDropdown, "TOPRIGHT", 30, 0)

        local nameAnchorDropdown = Cell:CreateDropdown(widget.frame, 117)
        nameAnchorDropdown:SetPoint("TOPLEFT", nameColorDropdown, 0, -50)
        nameAnchorDropdown:SetLabel(L["Anchor Point"])

        local items = {}
        for _, v in pairs(CUF.anchorPoints) do
            tinsert(items, {
                ["text"] = L[v],
                ["value"] = v,
                ["onClick"] = function()
                    CUF.vars.selectedWidgetTable.name.position.anchor = v
                    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
                end,
            })
        end
        nameAnchorDropdown:SetItems(items)

        local nameXSlider = Cell:CreateSlider(L["X Offset"], widget.frame, -100, 100, 117, 1)
        nameXSlider:SetPoint("TOPLEFT", nameAnchorDropdown, "TOPRIGHT", 30, 0)
        nameXSlider.afterValueChangedFn = function(value)
            CUF.vars.selectedWidgetTable.name.position.offsetX = value
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
        end

        local nameYSlider = Cell:CreateSlider(L["Y Offset"], widget.frame, -100, 100, 117, 1)
        nameYSlider:SetPoint("TOPLEFT", nameXSlider, "TOPRIGHT", 30, 0)
        nameYSlider.afterValueChangedFn = function(value)
            CUF.vars.selectedWidgetTable.name.position.offsetY = value
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
        end

        local nameFontDropdown = Cell:CreateDropdown(widget.frame, 117)
        nameFontDropdown:SetPoint("TOPLEFT", nameAnchorDropdown, 0, -50)
        nameFontDropdown:SetLabel(L["Font"])

        local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
        for _, item in pairs(items) do
            item["onClick"] = function()
                CUF.vars.selectedWidgetTable.name.font.style = item["text"]
                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
            end
        end
        nameFontDropdown:SetItems(items)

        function nameFontDropdown:SetFont(font)
            nameFontDropdown:SetSelected(font, fonts[font])
        end

        local nameOutlineDropdown = Cell:CreateDropdown(widget.frame, 117)
        nameOutlineDropdown:SetPoint("TOPLEFT", nameFontDropdown, "TOPRIGHT", 30, 0)
        nameOutlineDropdown:SetLabel(L["Outline"])

        items = {}
        for _, v in pairs(CUF.outlines) do
            tinsert(items, {
                ["text"] = L[v],
                ["value"] = v,
                ["onClick"] = function()
                    CUF.vars.selectedWidgetTable.name.font.outline = v
                    CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
                end,
            })
        end
        nameOutlineDropdown:SetItems(items)

        local nameSizeSilder = Cell:CreateSlider(L["Size"], widget.frame, 5, 50, 117, 1)
        nameSizeSilder:SetPoint("TOPLEFT", nameOutlineDropdown, "TOPRIGHT", 30, 0)
        nameSizeSilder.afterValueChangedFn = function(value)
            CUF.vars.selectedWidgetTable.name.font.size = value
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
        end

        local nameShadowCB = Cell:CreateCheckButton(widget.frame, L["Shadow"], function(checked, self)
            CUF.vars.selectedWidgetTable.name.font.shadow = checked
            CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit, "name")
        end)
        nameShadowCB:SetPoint("TOPLEFT", nameFontDropdown, "BOTTOMLEFT", 0, -10)

        -- Load page from DB
        ---@param page string
        local function LoadPageDB(page, subPage)
            if not page and subPage ~= "name" then return end

            local pageLayoutTable = CUF.vars.selectedWidgetTable.name

            nameCP:SetColor(pageLayoutTable.color.rgb[1], pageLayoutTable.color.rgb[2], pageLayoutTable.color.rgb[3])
            nameColorDropdown:SetSelectedValue(pageLayoutTable.color.type)
            if pageLayoutTable.color.type == "custom" then
                nameCP:Show()
            else
                nameCP:Hide()
            end

            nameWidth:SetNameWidth(pageLayoutTable.width)

            nameAnchorDropdown:SetSelectedValue(pageLayoutTable.position.anchor)
            nameXSlider:SetValue(pageLayoutTable.position.offsetX)
            nameYSlider:SetValue(pageLayoutTable.position.offsetY)

            nameSizeSilder:SetValue(pageLayoutTable.font.size)
            nameOutlineDropdown:SetSelectedValue(pageLayoutTable.font.outline)
            nameShadowCB:SetChecked(pageLayoutTable.font.shadow)
            nameFontDropdown:SetSelected(pageLayoutTable.font.style, fonts, defaultFontName)
        end
        CUF:RegisterCallback("LoadPageDB", "Name_LoadPageDB", LoadPageDB)

        return widget
    end)

-------------------------------------------------
-- MARK: Callback
-------------------------------------------------

---@param button CUFUnitButton
local function UpdateButtonText(button, unit)
    CUF:Debug("UpdateButtonText", unit)

    local styleTable = CUF.vars.selectedLayoutTable[unit].widgets.name

    button.widgets.nameText:ClearAllPoints()
    button.widgets.nameText:SetPoint(styleTable.position.anchor, button,
        styleTable.position.offsetX,
        styleTable.position.offsetY)

    local font = F:GetFont(styleTable.font.style)

    local fontFlags
    if styleTable.font.outline == "None" then
        fontFlags = ""
    elseif styleTable.font.outline == "Outline" then
        fontFlags = "OUTLINE"
    else
        fontFlags = "OUTLINE,MONOCHROME"
    end

    button.widgets.nameText:SetFont(font, styleTable.font.size, fontFlags)

    if styleTable.font.shadow then
        button.widgets.nameText:SetShadowOffset(1, -1)
        button.widgets.nameText:SetShadowColor(0, 0, 0, 1)
    else
        button.widgets.nameText:SetShadowOffset(0, 0)
        button.widgets.nameText:SetShadowColor(0, 0, 0, 0)
    end

    button.widgets.nameText.width = styleTable.width
    button.widgets.nameText:UpdateName()
    button.widgets.nameText:UpdateTextColor()
end
Handler:RegisterWidget(UpdateButtonText, "name")
