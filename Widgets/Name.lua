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
---@class CUF.widgets.builder
local Builder = CUF.widgets.Builder

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
        CUF:DevAdd(Cell.vars.currentLayoutTable[button.states.unit], "UpdateTextColor" .. button.states.unit)
        if not Cell.vars.currentLayoutTable[button.states.unit] then
            button.widgets.nameText:SetTextColor(1, 1, 1)
            return
        end

        if not UnitIsConnected(button.states.unit) then
            button.widgets.nameText:SetTextColor(F:GetClassColor(button.states.class))
        else
            if Cell.vars.currentLayoutTable[button.states.unit].widgets["nameText"].color.type == "class_color" then
                button.widgets.nameText:SetTextColor(F:GetClassColor(button.states.class))
            else
                button.widgets.nameText:SetTextColor(unpack(Cell.vars.currentLayoutTable[button.states.unit].widgets
                    ["nameText"]
                    .color.rgb))
            end
        end
    end
end

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------
---@param parent MenuFrame
local function CreateNamePage(parent)
    ---@class WidgetsMenuPage
    local widget = {}
    widget.frame = CreateFrame("Frame", nil, parent.widgetAnchor)
    widget.id = "nameText"
    widget.height = 250

    -- button
    widget.button = Cell:CreateButton(parent.widgetAnchor, L["Name"], "accent-hover", { 85, 17 })
    widget.button.id = "nameText"

    local enabledCheckBox = Builder:CreatEnabledCheckBox(widget.frame, "nameText")

    local colorPicker = Builder:CreateUnitColorOptions(widget.frame, "nameText", enabledCheckBox)
    local nameWidth = Builder:CreateNameWidthOption(widget.frame, "nameText")
    nameWidth:SetPoint("TOPLEFT", colorPicker, "TOPRIGHT", 30, 0)

    local anchorOptions = Builder:CreateAnchorOptions(widget.frame, "nameText", colorPicker)
    local nameOptions = Builder:CreateFontOptions(widget.frame, "nameText", anchorOptions)

    return widget
end
menu:AddWidget(CreateNamePage)

---@param button CUFUnitButton
---@param unit Units
---@param widgetName Widgets
function W.UpdateNameTextWidget(button, unit, widgetName)
    --CUF:Debug("UpdateTextWidget", unit, widgetName)

    local styleTable = CUF.vars.selectedLayoutTable[unit].widgets[widgetName]

    if not styleTable.enabled then
        button.widgets[widgetName]:Hide()
        return
    else
        button.widgets[widgetName]:Show()
    end

    button.widgets[widgetName]:ClearAllPoints()
    button.widgets[widgetName]:SetPoint(styleTable.position.anchor, button,
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

    button.widgets[widgetName]:SetFont(font, styleTable.font.size, fontFlags)

    if styleTable.font.shadow then
        button.widgets[widgetName]:SetShadowOffset(1, -1)
        button.widgets[widgetName]:SetShadowColor(0, 0, 0, 1)
    else
        button.widgets[widgetName]:SetShadowOffset(0, 0)
        button.widgets[widgetName]:SetShadowColor(0, 0, 0, 0)
    end

    button.widgets[widgetName].width = styleTable.width
    button.widgets[widgetName]:UpdateName()
    button.widgets[widgetName]:UpdateTextColor()
end

Handler:RegisterWidget(W.UpdateNameTextWidget, "nameText")
