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
                -- TODO: Abstract, for now it's fine
                local formatFn, hasAbsorb, hasHealth, hasHealAbsorb = W.ProcessCustomTextFormat(textTable.textFormat,
                    "health")
                text._showingAbsorbs = hasAbsorb
                text._showingHealth = hasHealth
                text._showingHealAbsorbs = hasHealAbsorb
                text.SetValue = function(_, current, max, totalAbsorbs, healAbsorbs)
                    text:SetText(formatFn(current, max, totalAbsorbs, healAbsorbs))
                end
            end
            if not subSetting or subSetting == const.OPTION_KIND.HIDE_IF_FULL then
                text.hideIfFull = textTable.hideIfFull
            end
            if not subSetting or subSetting == const.OPTION_KIND.HIDE_IF_EMPTY then
                text.hideIfEmpty = textTable.hideIfEmpty
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
    if not button.states.unit then return end

    local absorbEvent = event == "UNIT_ABSORB_AMOUNT_CHANGED"
    local healthEvent = event == "UNIT_HEALTH"
    local healAbsorbEvent = event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

    button.widgets.customText:IterateTexts(function(text, enabled)
        if not enabled then return end

        if absorbEvent and (not text._showingAbsorbs) then return end
        if healthEvent and (not text._showingHealth) then return end
        if healAbsorbEvent and (not text._showingHealAbsorbs) then return end

        text:UpdateValue()
    end)
end

---@param self CustomTextWidget
local function UpdateEventListeners(self)
    local healthEvents, absorbEvents, healAbsorbEvents
    self:IterateTexts(function(text, enabled)
        if not enabled then return end

        if text._showingAbsorbs then
            absorbEvents = true
        end
        if text._showingHealth then
            healthEvents = true
        end
        if text._showingHealAbsorbs then
            healAbsorbEvents = true
        end
    end)

    if healthEvents then
        self._owner:AddEventListener("UNIT_HEALTH", Update)
    else
        self._owner:RemoveEventListener("UNIT_HEALTH", Update)
    end

    if absorbEvents then
        self._owner:AddEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    else
        self._owner:RemoveEventListener("UNIT_ABSORB_AMOUNT_CHANGED", Update)
    end

    if healAbsorbEvents then
        self._owner:AddEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Update)
    else
        self._owner:RemoveEventListener("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Update)
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

-------------------------------------------------
-- MARK: CreateCustomText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateCustomText(button)
    ---@class CustomTextWidget: Frame
    ---@field [number] HealthTextWidget
    local customText = CreateFrame("Frame", button:GetName() .. "_CustomText", button)
    button.widgets.customText = customText

    customText.enabled = false
    customText.id = const.WIDGET_KIND.CUSTOM_TEXT
    customText._isSelected = false
    customText._owner = button

    ---@param func fun(text: HealthTextWidget, enabled: boolean, index: number)
    function customText:IterateTexts(func)
        for i = 1, #self do
            local text = self[i]
            func(text, text.enabled, i)
        end
    end

    for i = 1, 5 do
        customText[i] = W:CreateHealthText(button, true)
        customText[i]:SetParent(customText)
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
