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
    CUF:Log("DispelsUpdate", buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
    local previewMode = button._isSelected
    if not dispelsChanged and not previewMode then
        if dispelsChanged == nil then
            -- This is nil when we are trying to do full update of this widget
            -- So we queue an update to auras
            button:UpdateAurasInternal()
        end
        return
    end

    local foundDispel = false
    button:IterateAuras("debuffs", function(aura)
        if not dispels:ShouldShowDispel(aura) then return end
        foundDispel = true

        local r, g, b = I.GetDebuffTypeColor(aura.dispelName)
        CUF:Log("Found dispel:", aura.dispelName, "rgb:", r, g, b)

        if dispels.highlightType == "entire" then
            dispels.highlight:SetTexture(Cell.vars.whiteTexture)
            dispels.highlight:SetVertexColor(r, g, b, 0.5)
        elseif dispels.highlightType == "current" or dispels.highlightType == "current+" then
            dispels.highlight:SetTexture(Cell.vars.texture)
            dispels.highlight:SetVertexColor(r, g, b, 1)
        elseif dispels.highlightType == "gradient" or dispels.highlightType == "gradient-half" then
            dispels.highlight:SetTexture(Cell.vars.whiteTexture)
            dispels.highlight:SetGradient("VERTICAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0))
        end
        dispels:Show()
    end)
    CUF:Log("FoundDispel:", foundDispel)

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

-------------------------------------------------
-- MARK: CreateDispels
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateDispels(button)
    ---@class DispelsWidget: Frame, BaseWidget
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

    dispels.ShouldShowDispel = ShouldShowDispel
    dispels.UpdateHighlightStyle = UpdateHighlightStyle

    dispels.SetEnabled = W.SetEnabled
    dispels._SetIsSelected = W.SetIsSelected
    dispels.SetWidgetFrameLevel = W.SetWidgetFrameLevel

    dispels.Update = Update
    dispels.Enable = Enable
    dispels.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.DISPELS, W.CreateDispels)
