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
                text:Enable()
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
---@param event WowEvent?
local function Update(button, event)
    local unit = button.states.unit
    if not unit then return end

    local customText = button.widgets.customText

    if not event then
        customText:FullUpdate()
        return
    end

    customText:IterateActiveTexts(function(text)
        if not text._events[event] then return end

        text:UpdateValue()
    end)
end

---@param self CustomText
---@param elapsed number
local function OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= self._onUpdateTimer then
        self:UpdateValue()
        self.elapsed = 0
    end
end

---@param self CustomTextWidget
local function UpdateEventListeners(self)
    local newEventListeners = {}
    self:IterateActiveTexts(function(text)
        for event, _ in pairs(text._events) do
            newEventListeners[event] = true
        end

        if text._onUpdateTimer then
            text:SetScript("OnUpdate", OnUpdate)
        else
            text:SetScript("OnUpdate", nil)
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
        if not enabled or not text._validFormat then
            text:Disable()
            return
        end
        text:Enable()

        text:UpdateTextColor()
        text:UpdateValue()
    end)

    self:UpdateEventListeners()
end

---@param self CustomTextWidget
local function Enable(self)
    self:FullUpdate()

    self:Show()
    return true
end

---@param self CustomTextWidget
local function Disable(self)
    table.wipe(self.activeTexts)
    self:IterateTexts(function(text)
        text:Disable()
    end)

    self:UpdateEventListeners()

    self:Hide()
end

---@param self CustomText
---@param format string
local function UpdateFormat(self, format)
    if not format or format == "" then
        self.FormatFunc = function() end
        self._validFormat = false
        self:Disable()
        return
    end
    local formatFn, events, onUpdateTimer = W.GetTagFunction(format)

    self._validFormat = true
    self.FormatFunc = formatFn
    self._events = events
    self._onUpdateTimer = onUpdateTimer
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

    ---@type CustomText[]
    customText.activeTexts = {}

    ---@param func fun(text: CustomText, enabled: boolean, index: number)
    function customText:IterateTexts(func)
        for i = 1, #self do
            local text = self[i]
            func(text, text.enabled, i)
        end
    end

    ---@param func fun(text: CustomText)
    function customText:IterateActiveTexts(func)
        for i = 1, #self.activeTexts do
            local text = self.activeTexts[i]
            func(text)
        end
    end

    ---@param text CustomText
    function customText:EnableText(text)
        if not text.enabled or not text._validFormat then return end

        -- Check if it's already added
        for _, txt in pairs(customText.activeTexts) do
            if txt._index == text._index then return end
        end

        table.insert(customText.activeTexts, text)
        text:Show()
    end

    ---@param text CustomText
    function customText:DisableText(text)
        text:Hide()
        text:SetScript("OnUpdate", nil)

        for i, txt in ipairs(customText.activeTexts) do
            if txt._index == text._index then
                table.remove(customText.activeTexts, i)
                return
            end
        end
    end

    for i = 1, 5 do
        ---@class CustomText: TextWidget
        ---@field elapsed number
        local text = W.CreateBaseTextWidget(button, const.WIDGET_KIND.CUSTOM_TEXT)
        text:SetParent(customText)
        customText[i] = text
        text._index = i
        text._validFormat = false

        text.Enable = function() customText:EnableText(text) end
        text.Disable = function() customText:DisableText(text) end

        ---@type table<WowEvent, boolean>
        text._events = {}
        text._onUpdateTimer = nil

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
    customText.UpdateEventListeners = UpdateEventListeners

    -- Implement common methods
    customText.SetEnabled = W.SetEnabled
    customText._SetIsSelected = W.SetIsSelected
    customText.SetWidgetFrameLevel = W.SetWidgetFrameLevel
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.CUSTOM_TEXT, W.CreateCustomText)
