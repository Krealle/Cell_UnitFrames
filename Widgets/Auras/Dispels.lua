---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local I = Cell.iFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local menu = CUF.Menu
local DB = CUF.DB
local Builder = CUF.Builder
local Handler = CUF.Handler

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.DISPELS,
    Builder.MenuOptions.DispelsOptions,
    Builder.MenuOptions.Orientation,
    Builder.MenuOptions.TrueSingleSizeOptions,
    Builder.MenuOptions.FullAnchor,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string?
---@param subSetting string?
function W.UpdateDispelsWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.dispels
    local styleTable = DB.GetCurrentWidgetTable(const.WIDGET_KIND.DISPELS, unit) --[[@as DispelsWidgetTable]]

    if not setting or setting == const.OPTION_KIND.HIGHLIGHT_TYPE then
        widget:UpdateHighlightStyle(styleTable.highlightType)
    end
    if not setting or setting == const.OPTION_KIND.ONLY_SHOW_DISPELLABLE then
        widget.onlyShowDispellable = styleTable.onlyShowDispellable
    end
    if not setting
        or setting == const.OPTION_KIND.CURSE
        or setting == const.OPTION_KIND.DISEASE
        or setting == const.OPTION_KIND.MAGIC
        or setting == const.OPTION_KIND.POISON
        or setting == const.OPTION_KIND.BLEED
    then
        widget.dispelTypes = {
            Curse = styleTable.curse,
            Disease = styleTable.disease,
            Magic = styleTable.magic,
            Poison = styleTable.poison,
            Bleed = styleTable.bleed,
        }
    end

    widget.Update(button)
end

Handler:RegisterWidget(W.UpdateDispelsWidget, const.WIDGET_KIND.DISPELS)

-------------------------------------------------
-- MARK: UpdateDispels
-------------------------------------------------

---@param button CUFUnitButton
---@param buffsChanged boolean?
---@param debuffsChanged boolean?
---@param dispelsChanged boolean?
---@param fullUpdate boolean?
local function Update(button, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
    local dispels = button.widgets.dispels
    if not dispels.enabled or not button:IsVisible() then return end
    --CUF:Log("DispelsUpdate", buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)

    -- Preview
    if button._isSelected then
        dispels:PreviewMode()
        return
    end

    if not dispelsChanged then
        if dispelsChanged == nil then
            -- This is nil when we are trying to do full update of this widget
            -- So we queue an update to auras
            button:QueueAuraUpdate()
        end
        return
    end

    -- TODO: Add prio? right now we just take first
    local foundDispel = false
    button:IterateAuras("debuffs", function(aura)
        if not dispels:ShouldShowDispel(aura) then return end
        foundDispel = true
        dispels:SetDispel(aura.dispelName)
        return true
    end)
    --CUF:Log("FoundDispel:", foundDispel)

    if not foundDispel then
        dispels:Hide()
        return
    end
end

---@param self DispelsWidget
local function Enable(self)
    self._owner:RegisterAuraCallback("debuffs", self.Update)

    self:UpdateHighlightStyle("current+")
    return true
end

---@param self DispelsWidget
local function Disable(self)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param self DispelsWidget
---@param type string
local function UpdateHighlightStyle(self, type)
    self.highlightType = type
    self.highlight:SetBlendMode("BLEND")

    if type == "none" then
        self.highlight:Hide()
        return
    elseif type == "gradient" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar)
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetDrawLayer("ARTWORK", 0)
    elseif type == "gradient-half" then
        self.highlight:ClearAllPoints()
        self.highlight:SetPoint("BOTTOMLEFT", self.parentHealthBar)
        self.highlight:SetPoint("TOPRIGHT", self.parentHealthBar, "RIGHT")
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetDrawLayer("ARTWORK", 0)
    elseif type == "entire" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar)
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetDrawLayer("ARTWORK", 0)
    elseif type == "current" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar:GetStatusBarTexture())
        self.highlight:SetTexture(Cell.vars.texture)
        self.highlight:SetDrawLayer("ARTWORK", -7)
    elseif type == "current+" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar:GetStatusBarTexture())
        self.highlight:SetTexture(Cell.vars.texture)
        self.highlight:SetDrawLayer("ARTWORK", -7)
        self.highlight:SetBlendMode("ADD")
    end
    self.highlight:Show()
end

---@param self DispelsWidget
---@param aura AuraData
---@return boolean
local function ShouldShowDispel(self, aura)
    local dispelType = aura.dispelName
    if not dispelType then return false end
    if self.onlyShowDispellable and not I.CanDispel(dispelType) then return false end

    return self.dispelTypes[dispelType]
end

---@param self DispelsWidget
---@param type string
local function SetDispel(self, type)
    local r, g, b = I.GetDebuffTypeColor(type)
    --CUF:Log("Found dispel:", type, "rgb:", r, g, b)

    if self.highlightType == "entire" then
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetVertexColor(r, g, b, 0.5)
    elseif self.highlightType == "current" or self.highlightType == "current+" then
        self.highlight:SetTexture(Cell.vars.texture)
        self.highlight:SetVertexColor(r, g, b, 1)
    elseif self.highlightType == "gradient" or self.highlightType == "gradient-half" then
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetGradient("VERTICAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0))
    end
    self:Show()
end

---@param self DispelsWidget
local function PreviewMode(self)
    if self._isSelected then
        self:Show()

        local types = {}
        for k, v in pairs(self.dispelTypes) do
            if v then
                tinsert(types, k)
            end
        end
        local index = 0
        self.elapsed = 1
        self:SetScript("OnUpdate", function(_self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 1 then
                self.elapsed = 0
                index = index + 1
                if index > #types then index = 1 end
                self:SetDispel(types[index])
            end
        end)
    else
        self:Hide()
        self:SetScript("OnUpdate", nil)
    end
end

-------------------------------------------------
-- MARK: CreateDispels
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateDispels(button)
    ---@class DispelsWidget: Frame, BaseWidget
    ---@field elapsed number
    local dispels = CreateFrame("Frame", button:GetName() .. "_DispelParent", button)
    button.widgets.dispels = dispels

    dispels.id = const.WIDGET_KIND.DISPELS
    dispels.enabled = false
    dispels._isSelected = false
    dispels.parentHealthBar = button.widgets.healthBar
    dispels._owner = button

    dispels.highlightType = "current"
    dispels.onlyShowDispellable = true
    dispels.dispelTypes = {}

    dispels:Hide()

    dispels.highlight = dispels:CreateTexture(button:GetName() .. "_DispelHighlight")

    dispels.SetDispel = SetDispel
    dispels.PreviewMode = PreviewMode
    dispels.ShouldShowDispel = ShouldShowDispel
    dispels.UpdateHighlightStyle = UpdateHighlightStyle

    dispels.SetEnabled = W.SetEnabled
    dispels._SetIsSelected = W.SetIsSelected
    dispels.SetWidgetFrameLevel = W.SetWidgetFrameLevel

    dispels._OnIsSelected = PreviewMode

    dispels.Update = Update
    dispels.Enable = Enable
    dispels.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.DISPELS, W.CreateDispels)
