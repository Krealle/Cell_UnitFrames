---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants
local DB = CUF.DB

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.CUSTOM_TEXT,
    Builder.MenuOptions.CustomText,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param which string
---@param subSetting string
function W.UpdateCustomTextWidget(button, unit, setting, which, subSetting, ...)
    local widget = button.widgets.customText
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.CUSTOM_TEXT, unit) --[[@as CustomTextMainWidgetTable]]

    if not setting or setting == "texts" then
        -- which in the format of "text1", "text2", etc
        local whichIndex
        if which then
            whichIndex = tonumber(string.match(which, "text(%d+)"))
        end

        widget:IterateTexts(function(text, enabled, index)
            if whichIndex and whichIndex ~= index then return end
            local textTable = styleTable.texts[which or ("text" .. index)]

            if not subSetting or subSetting == const.OPTION_KIND.TEXT_FORMAT then
                text:UpdateFormat(textTable.textFormat)
            end
            if not subSetting or subSetting == const.OPTION_KIND.HIDE_IF_FULL then
                --text.hideIfFull = textTable.hideIfFull
            end
            if not subSetting or subSetting == const.OPTION_KIND.HIDE_IF_EMPTY then
                --text.hideIfEmpty = textTable.hideIfEmpty
            end
            if not subSetting or subSetting == const.OPTION_KIND.FONT then
                text:SetFontStyle(textTable)
                text:SetFontColor(textTable)
            end
            if not subSetting or subSetting == const.OPTION_KIND.COLOR then
                text:SetFontColor(textTable)
            end
            if not subSetting or subSetting == const.OPTION_KIND.POSITION then
                text:SetPosition(textTable)
            end
            if not subSetting or subSetting == const.OPTION_KIND.ENABLED then
                text.enabled = textTable.enabled
            end
        end)
    end

    if widget.enabled and button:IsVisible() then
        widget:FullUpdate()
    end
end

Handler:RegisterWidget(W.UpdateCustomTextWidget, const.WIDGET_KIND.CUSTOM_TEXT)

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event ("UNIT_HEALTH" | "UNIT_ABSORB_AMOUNT_CHANGED"|"UNIT_HEAL_ABSORB_AMOUNT_CHANGED")?
local function Update(button, event)
    local unit = button.states.unit
    if not unit then return end
    local customText = button.widgets.customText

    --print("Update", event)

    customText:IterateTexts(function(text, enabled, idx)
        if not enabled then return end
        --if not customText._textsToUpdate[idx] then return end
        if event and not text._events[event] then return end

        text:UpdateValue()
    end)
end

---@param self CustomTextWidget
local function UpdateEventListeners(self)
    local newEventListeners = {}
    self:IterateTexts(function(text, enabled)
        if not enabled then return end
        for event, _ in pairs(text._events) do
            newEventListeners[event] = true
        end
    end)

    -- Remove no longer needed event listeners
    for event, _ in pairs(self._activeEventListeners) do
        if not newEventListeners[event] then
            self._owner:RemoveEventListener(event, Update)
            self._activeEventListeners[event] = nil
        end
    end
    -- Add new event listeners
    for event, _ in pairs(newEventListeners) do
        if not self._activeEventListeners[event] then
            self._owner:AddEventListener(event, Update)
            self._activeEventListeners[event] = true
        end
    end
end

---@param self CustomTextWidget
local function FullUpdate(self)
    self:IterateTexts(function(text, enabled, index)
        if not enabled then
            text:Hide()
            return
        end

        text:UpdateTextColor()
        text:UpdateValue()
        text:Show()
    end)

    UpdateEventListeners(self)
end

---@param self CustomTextWidget
local function Enable(self)
    self:FullUpdate()

    self:Show()
    return true
end

---@param self CustomTextWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    self._owner:RemoveEventListener("UNIT_HEALTH", Update)

    self:IterateTexts(function(text, enabled)
        text:Hide()
    end)

    self:Hide()
end

---@param self CustomText
---@param format string
local function UpdateFormat(self, format)
    if not format or format == "" then
        self.FormatFunc = function() end
        return
    end
    local formatFn, events = W.GetTagFunction(format)

    self.FormatFunc = formatFn
    self._events = events

    --CUF:DevAdd(events, format)
end

-------------------------------------------------
-- MARK: CreateCustomText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateCustomText(button)
    ---@class CustomTextWidget: Frame
    ---@field [number] CustomText
    local customText = CreateFrame("Frame", button:GetName() .. "_CustomText", button)
    button.widgets.customText = customText

    customText.enabled = false
    customText.id = const.WIDGET_KIND.CUSTOM_TEXT
    customText._isSelected = false
    customText._owner = button

    customText._textsToUpdate = {}
    customText._activeEventListeners = {}

    ---@param func fun(text: CustomText, enabled: boolean, index: number)
    function customText:IterateTexts(func)
        for i = 1, #self do
            local text = self[i]
            func(text, text.enabled, i)
        end
    end

    for i = 1, 5 do
        ---@class CustomText: TextWidget
        local text = W.CreateBaseTextWidget(button, const.WIDGET_KIND.CUSTOM_TEXT)
        text:SetParent(customText)
        customText[i] = text

        ---@type table<WowEvent, boolean>
        text._events = {}

        function text:UpdateValue()
            text:SetText(text:FormatFunc(button.states.unit))
        end

        text.UpdateFormat = UpdateFormat
        ---@param unit UnitToken
        text.FormatFunc = function(_self, unit) end
    end

    customText.Update = Update
    customText.Enable = Enable
    customText.Disable = Disable
    customText.FullUpdate = FullUpdate

    -- Implement common methods
    customText.SetEnabled = W.SetEnabled
    customText._SetIsSelected = W.SetIsSelected
    customText.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.CUSTOM_TEXT, W.CreateCustomText)
