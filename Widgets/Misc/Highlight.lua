---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
local W = CUF.widgets

local DB = CUF.DB
local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants
local P = CUF.PixelPerfect

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.HIGHLIGHT,
    Builder.MenuOptions.Highlight)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.HighlightWidget(button, unit, setting, subSetting)
    local widget = button.widgets.highlight
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.HIGHLIGHT, unit) --[[@as HighlightWidgetTable]]

    if not setting or setting == const.OPTION_KIND.SIZE then
        widget:SetSize(styleTable.size)
    end
    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:SetColor()
    end
    if not setting or setting == const.OPTION_KIND.TARGET then
        widget:SetTarget(styleTable.target)
    end
    if not setting or setting == const.OPTION_KIND.HOVER then
        widget:SetHover(styleTable.hover)
    end
    if not setting or setting == const.OPTION_KIND.COLOR then
        widget:SetColor()
    end

    widget.Update(button)
end

Handler:RegisterWidget(W.HighlightWidget, const.WIDGET_KIND.HIGHLIGHT)

-------------------------------------------------
-- MARK: Checks
-------------------------------------------------

---@param button CUFUnitButton
local function HoverHook(button)
    local highlight = button.widgets.highlight
    if highlight.hover then
        highlight.Update(button)
    end
end

---@param frame Frame
local function IsFrameFocused(frame)
    local focusedFrames = GetMouseFoci()
    return focusedFrames and focusedFrames[1] == frame
end

---@param self HighlightWidget
local function TargetCheck(self)
    if self.target and UnitIsUnit(self._owner.states.unit, "target") then
        self.targetGlow:Show()
    else
        self.targetGlow:Hide()
    end
end

---@param self HighlightWidget
local function MouseOverCheck(self)
    if self.hover and IsFrameFocused(self._owner) then
        self.mouseoverGlow:Show()
    else
        self.mouseoverGlow:Hide()
    end
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param button CUFUnitButton
---@param event? string
local function Update(button, event)
    if not button:IsVisible() then return end

    local highlight = button.widgets.highlight

    highlight:TargetCheck()
    highlight:MouseOverCheck()
end

---@param self HighlightWidget
local function Enable(self)
    self:UpdateListeners(true)

    return true
end

---@param self HighlightWidget
local function Disable(self)
    self:UpdateListeners(false)
end

---@param self HighlightWidget
---@param enabled boolean?
local function UpdateListeners(self, enabled)
    if enabled == nil then
        enabled = self._isEnabled
    end
    enabled = enabled and self.size ~= 0

    local owner = self._owner

    if self.target and enabled then
        owner:AddEventListener("PLAYER_TARGET_CHANGED", Update, true)
    else
        owner:RemoveEventListener("PLAYER_TARGET_CHANGED", Update)
    end

    if self.hover and enabled then
        if not self.hoverHooked then
            owner:HookScript("OnEnter", HoverHook)
            owner:HookScript("OnLeave", HoverHook)

            self.hoverHooked = true
        end
    end

    if enabled then
        self:Show()
    else
        self:Hide()
    end
end

-------------------------------------------------
-- MARK: Setters
-------------------------------------------------

---@param self HighlightWidget
---@param size number
local function SetSize(self, size)
    self.size = size

    P.ClearPoints(self.targetGlow)
    P.ClearPoints(self.mouseoverGlow)

    if size < 0 then
        size = math.abs(size)
        P.Point(self.targetGlow, "TOPLEFT", self._owner, "TOPLEFT")
        P.Point(self.targetGlow, "BOTTOMRIGHT", self._owner, "BOTTOMRIGHT")
        P.Point(self.mouseoverGlow, "TOPLEFT", self._owner, "TOPLEFT")
        P.Point(self.mouseoverGlow, "BOTTOMRIGHT", self._owner, "BOTTOMRIGHT")
    else
        P.Point(self.targetGlow, "TOPLEFT", self._owner, "TOPLEFT", -size, size)
        P.Point(self.targetGlow, "BOTTOMRIGHT", self._owner, "BOTTOMRIGHT", size, -size)
        P.Point(self.mouseoverGlow, "TOPLEFT", self._owner, "TOPLEFT", -size, size)
        P.Point(self.mouseoverGlow, "BOTTOMRIGHT", self._owner, "BOTTOMRIGHT", size, -size)
    end

    self.targetGlow:SetBackdrop({ edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(size) })
    self.mouseoverGlow:SetBackdrop({ edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(size) })
    self:SetColor()

    self:UpdateListeners()
end

---@param self HighlightWidget
local function SetColor(self)
    local colors = DB.GetColors().highlight
    self.targetGlow:SetBackdropBorderColor(unpack(colors.target))
    self.mouseoverGlow:SetBackdropBorderColor(unpack(colors.hover))
end

---@param self HighlightWidget
---@param enabled boolean
local function SetTarget(self, enabled)
    self.target = enabled
    self:UpdateListeners()
end

---@param self HighlightWidget
---@param enabled boolean
local function SetHover(self, enabled)
    self.hover = enabled
    self:UpdateListeners()
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateHighlight(button)
    ---@class HighlightWidget: Frame, BaseWidget
    local highlight = CreateFrame("Frame", nil, button)
    button.widgets.highlight = highlight

    local targetGlow = CreateFrame("Frame", nil, highlight, "BackdropTemplate")
    targetGlow:SetIgnoreParentAlpha(true)
    targetGlow:SetFrameLevel(button:GetFrameLevel() + 2)
    targetGlow:Hide()
    highlight.targetGlow = targetGlow

    local mouseoverGlow = CreateFrame("Frame", nil, highlight, "BackdropTemplate")
    mouseoverGlow:SetIgnoreParentAlpha(true)
    mouseoverGlow:SetFrameLevel(button:GetFrameLevel() + 4)
    mouseoverGlow:Hide()
    highlight.mouseoverGlow = mouseoverGlow

    highlight.enabled = false
    highlight.id = const.WIDGET_KIND.HIGHLIGHT
    highlight._isSelected = false
    highlight._owner = button

    highlight.hover = true
    highlight.target = true
    highlight.size = 1

    highlight.hoverHooked = false

    highlight.TargetCheck = TargetCheck
    highlight.MouseOverCheck = MouseOverCheck

    highlight.Update = Update
    highlight.Enable = Enable
    highlight.Disable = Disable
    highlight.UpdateListeners = UpdateListeners

    highlight.SetSize = SetSize
    highlight.SetColor = SetColor
    highlight.SetHover = SetHover
    highlight.SetTarget = SetTarget
    highlight.SetEnabled = W.SetEnabled
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.HIGHLIGHT, W.CreateHighlight)
