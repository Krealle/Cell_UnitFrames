---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
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
local Util = CUF.Util

local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack
local tinsert = table.insert

local function GetDebuffTypeColor(type)
    if type == "Enrage" then
        return 0.05, 0.85, 0.94
    end
    return I.GetDebuffTypeColor(type)
end

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.DISPELS,
    Builder.MenuOptions.DispelsOptions,
    Builder.MenuOptions.Glow,
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
        or setting == const.OPTION_KIND.ENRAGE
    then
        widget.dispelTypes = {
            Curse = styleTable.curse,
            Disease = styleTable.disease,
            Magic = styleTable.magic,
            Poison = styleTable.poison,
            Bleed = styleTable.bleed,
            Enrage = styleTable.enrage,
        }
    end

    if not setting or setting == const.OPTION_KIND.ICON_STYLE then
        widget.UpdateIconStyle(widget, styleTable.iconStyle)
    end
    if not setting or setting == const.OPTION_KIND.SIZE then
        widget.UpdateIconSize(widget, styleTable.size)
    end
    if not setting or setting == const.OPTION_KIND.GLOW then
        widget.UpdateGlowStyle(widget, styleTable.glow)
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
---@param stealableChanged boolean?
local function Update(button, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate, stealableChanged)
    local dispels = button.widgets.dispels
    if not dispels.enabled or not button:IsVisible() then return end
    --CUF:Log("DispelsUpdate", buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)

    -- Preview
    if button._isSelected then
        dispels:PreviewMode()
        return
    end

    if not dispelsChanged and not stealableChanged then
        if dispelsChanged == nil then
            -- This is nil when we are trying to do full update of this widget
            -- So we queue an update to auras
            button:QueueAuraUpdate()
        end
        return
    end

    -- TODO: Add prio? right now we just take first
    local foundDispel = false

    local isFriend = UnitIsFriend("player", button.states.unit) and not UnitCanAttack("player", button.states.unit)
    if isFriend and not dispelsChanged then return end
    if not isFriend and not stealableChanged then return end

    local type = isFriend and "debuffs" or "buffs"

    button:IterateAuras(type, function(aura)
        if not dispels:ShouldShowDispel(aura.dispelName, aura.isDispellable) then return end
        foundDispel = true

        dispels:SetDispelHighlight(aura.dispelName)
        dispels:SetDispelIcon(aura.dispelName)
        dispels:SetDispelGlow(aura.dispelName)
        dispels:Show()

        return true
    end)

    if not foundDispel then
        if dispels.activeIconType then
            dispels.icons[dispels.activeIconType]:Hide()
        end
        if dispels.activeGlowType then
            Util.GlowStop(dispels.glowLayer)
        end

        dispels.activeType = nil
        dispels.activeIconType = nil
        dispels.activeGlowType = nil

        dispels:Hide()
        return
    end
end

---@param self DispelsWidget
local function Enable(self)
    self._owner:RegisterAuraCallback("debuffs", self.Update)
    self._owner:RegisterAuraCallback("buffs", self.Update)

    return true
end

---@param self DispelsWidget
local function Disable(self)
    self._owner:UnregisterAuraCallback("debuffs", self.Update)
    self._owner:UnregisterAuraCallback("buffs", self.Update)
end

-------------------------------------------------
-- MARK: Functions
-------------------------------------------------

---@param self DispelsWidget
---@param dispelType string
---@param isDispellable boolean
---@return boolean
local function ShouldShowDispel(self, dispelType, isDispellable)
    if dispelType == "none" then return false end
    if self.onlyShowDispellable and not isDispellable then return false end

    return self.dispelTypes[dispelType]
end

---@param self DispelsWidget
---@param type string
local function SetDispelHighlight_Entire(self, type)
    if not self.showHighlight then return end
    if self.activeType == type then return end

    self.activeType = type

    local r, g, b = GetDebuffTypeColor(type)
    self.highlight:SetVertexColor(r, g, b, 0.5)
end

---@param self DispelsWidget
---@param type string
local function SetDispelHighlight_Current(self, type)
    if not self.showHighlight then return end
    if self.activeType == type then return end

    self.activeType = type

    local r, g, b = GetDebuffTypeColor(type)
    self.highlight:SetVertexColor(r, g, b, 1)
end

---@param self DispelsWidget
---@param type string
local function SetDispelHighlight_Gradient(self, type)
    if not self.showHighlight then return end
    if self.activeType == type then return end

    self.activeType = type

    local r, g, b = GetDebuffTypeColor(type)
    self.highlight:SetGradient("VERTICAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0))
end

---@param self DispelsWidget
---@param type string
local function SetDispelIcon(self, type)
    if not self.showIcons then return end

    if self.activeIconType then
        if self.activeIconType == type then return end
        self.icons[self.activeIconType]:Hide()
    end

    self.activeIconType = type

    self.icons[type]:SetDispel()
end

---@param self DispelsWidget.Icon
local function SetDispelIcon_Blizzard(self)
    self:Show()
end

---@param self DispelsWidget.Icon
local function SetDispelIcon_Rhombus(self)
    self:SetVertexColor(GetDebuffTypeColor(self.type))
    self:Show()
end

---@param self DispelsWidget
---@param type string
local function SetDispelGlow_Pixel(self, type)
    if not self.showGlow then return end
    if self.activeGlowType == type then return end

    self.activeGlowType = type

    local r, g, b = GetDebuffTypeColor(type)
    local glow = self.glow
    Util.GlowStart_Pixel(self.glowLayer, { r, g, b, 1 }, glow.lines, glow.frequency, glow.length, glow.thickness)
end

---@param self DispelsWidget
---@param type string
local function SetDispelGlow_Shine(self, type)
    if not self.showGlow then return end
    if self.activeGlowType == type then return end

    self.activeGlowType = type

    local r, g, b = GetDebuffTypeColor(type)
    local glow = self.glow
    Util.GlowStart_Shine(self.glowLayer, { r, g, b, 1 }, glow.lines, glow.frequency, (glow.scale / 100))
end

---@param self DispelsWidget
---@param type string
local function SetDispelGlow_Proc(self, type)
    if not self.showGlow then return end
    if self.activeGlowType == type then return end

    self.activeGlowType = type

    local r, g, b = GetDebuffTypeColor(type)
    Util.GlowStart_Proc(self.glowLayer, { r, g, b, 1 }, self.glow.duration)
end

---@param self DispelsWidget
---@param type string
local function SetDispelGlow_Normal(self, type)
    if not self.showGlow then return end
    if self.activeGlowType == type then return end

    self.activeGlowType = type

    local r, g, b = GetDebuffTypeColor(type)
    Util.GlowStart_Normal(self.glowLayer, { r, g, b, 1 }, self.glow.frequency)
end

---@param self DispelsWidget
local function PreviewMode(self)
    if self._isSelected then
        local types = {}
        for k, v in pairs(self.dispelTypes) do
            if v then
                tinsert(types, k)
            end
        end

        -- No types to preview
        if #types == 0 then
            self:Hide()
            self:SetScript("OnUpdate", nil)
            return
        end

        local index = 0
        self.elapsed = 1
        self:SetScript("OnUpdate", function(_self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 1 then
                self.elapsed = 0
                index = index + 1
                if index > #types then index = 1 end
                self:SetDispelHighlight(types[index])
                self:SetDispelIcon(types[index])
                self:SetDispelGlow(types[index])
            end
        end)

        self:Show()
    else
        Util.GlowStop(self.glowLayer)
        self:Hide()
        self:SetScript("OnUpdate", nil)
    end
end

-------------------------------------------------
-- MARK: Style Updaters
-------------------------------------------------

---@param self DispelsWidget
---@param type string
local function UpdateHighlightStyle(self, type)
    self.showHighlight = type ~= "none"
    self.highlight:SetBlendMode("BLEND")

    if type == "none" then
        self.highlight:Hide()
        return
    elseif type == "gradient" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar)
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetDrawLayer("ARTWORK", 0)
        self.SetDispelHighlight = SetDispelHighlight_Gradient
    elseif type == "gradient-half" then
        self.highlight:ClearAllPoints()
        self.highlight:SetPoint("BOTTOMLEFT", self.parentHealthBar)
        self.highlight:SetPoint("TOPRIGHT", self.parentHealthBar, "RIGHT")
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetDrawLayer("ARTWORK", 0)
        self.SetDispelHighlight = SetDispelHighlight_Gradient
    elseif type == "entire" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar)
        self.highlight:SetTexture(Cell.vars.whiteTexture)
        self.highlight:SetDrawLayer("ARTWORK", 0)
        self.SetDispelHighlight = SetDispelHighlight_Entire
    elseif type == "current" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar:GetStatusBarTexture())
        self.highlight:SetTexture(Cell.vars.texture)
        self.highlight:SetDrawLayer("ARTWORK", -7)
        self.SetDispelHighlight = SetDispelHighlight_Current
    elseif type == "current+" then
        self.highlight:ClearAllPoints()
        self.highlight:SetAllPoints(self.parentHealthBar:GetStatusBarTexture())
        self.highlight:SetTexture(Cell.vars.texture)
        self.highlight:SetDrawLayer("ARTWORK", -7)
        self.highlight:SetBlendMode("ADD")
        self.SetDispelHighlight = SetDispelHighlight_Current
    end
    self.highlight:Show()
end

---@param self DispelsWidget
---@param style string
local function UpdateIconStyle(self, style)
    self.showIcons = style ~= "none"
    -- Reset active icon, makes for a better preview mode
    self.activeIconType = nil

    for _, icon in pairs(self.icons) do
        if style == "rhombus" then
            icon.SetDispel = SetDispelIcon_Rhombus
            icon:SetTexture("Interface\\AddOns\\Cell\\Media\\Debuffs\\Rhombus")
        elseif style == "blizzard" then
            icon.SetDispel = SetDispelIcon_Blizzard
            icon:SetTexture("Interface\\AddOns\\Cell\\Media\\Debuffs\\" .. icon.type)
            icon:SetVertexColor(1, 1, 1, 1)
        end
        icon:Hide()
    end
end

---@param self DispelsWidget
---@param size number
local function UpdateIconSize(self, size)
    for _, icon in pairs(self.icons) do
        icon:SetSize(size, size)
    end
end

---@param self DispelsWidget
---@param styleTable DispelsWidgetTable
local function UpdateIconPosition(self, styleTable)
    local positionOpt = styleTable.position
    for _, icon in pairs(self.icons) do
        icon:ClearAllPoints()
        icon:SetPoint(positionOpt.point, self._owner, positionOpt.relativePoint, positionOpt.offsetX, positionOpt
            .offsetY)
    end
end

---@param self DispelsWidget
---@param glowOpt GlowOpt
local function UpdateGlowStyle(self, glowOpt)
    self.glow = glowOpt
    self.showGlow = glowOpt.type ~= const.GlowType.NONE
    self.activeGlowType = nil

    if glowOpt.type == const.GlowType.NONE then
        Util.GlowStop(self.glowLayer)
        self.glowLayer:Hide()
        return
    elseif glowOpt.type == const.GlowType.PIXEL then
        self.SetDispelGlow = SetDispelGlow_Pixel
    elseif glowOpt.type == const.GlowType.SHINE then
        self.SetDispelGlow = SetDispelGlow_Shine
    elseif glowOpt.type == const.GlowType.PROC then
        self.SetDispelGlow = SetDispelGlow_Proc
    elseif glowOpt.type == const.GlowType.NORMAL then
        self.SetDispelGlow = SetDispelGlow_Normal
    end

    self.glowLayer:Show()
end

-------------------------------------------------
-- MARK: CreateDispels
-------------------------------------------------

local DebuffTypes = { "Magic", "Curse", "Disease", "Poison", "Bleed", "Enrage" }

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
    dispels.showIcons = false
    dispels.showHighlight = false

    dispels.activeType = nil
    dispels.activeIconType = nil
    dispels.activeGlowType = nil

    dispels.glow = CUF.Defaults.Options.glow
    dispels.showGlow = false

    dispels:Hide()

    dispels.highlight = dispels:CreateTexture(button:GetName() .. "_DispelHighlight")

    dispels.glowLayer = CreateFrame("Frame", nil, dispels) --[[@as GlowFrame]]
    dispels.glowLayer:SetAllPoints(dispels.parentHealthBar)

    -- Icons
    ---@type table<string, DispelsWidget.Icon>
    dispels.icons = {}
    for _, type in ipairs(DebuffTypes) do
        ---@class DispelsWidget.Icon: Texture
        local icon = dispels:CreateTexture(button:GetName() .. "_Dispel_" .. type, "ARTWORK")
        icon:Hide()

        icon.type = type
        icon.SetDispel = SetDispelIcon_Blizzard

        dispels.icons[type] = icon
    end

    dispels.SetDispelIcon = SetDispelIcon
    dispels.ShouldShowDispel = ShouldShowDispel
    dispels.SetDispelHighlight = SetDispelHighlight_Current
    dispels.SetDispelGlow = SetDispelGlow_Pixel

    dispels.PreviewMode = PreviewMode
    dispels.UpdateIconSize = UpdateIconSize
    dispels.UpdateIconStyle = UpdateIconStyle
    dispels.UpdateGlowStyle = UpdateGlowStyle
    dispels.UpdateHighlightStyle = UpdateHighlightStyle

    dispels.SetPosition = UpdateIconPosition
    dispels.SetEnabled = W.SetEnabled
    dispels._SetIsSelected = W.SetIsSelected
    dispels.SetWidgetFrameLevel = W.SetWidgetFrameLevel

    dispels._OnIsSelected = PreviewMode

    dispels.Update = Update
    dispels.Enable = Enable
    dispels.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.DISPELS, W.CreateDispels)
