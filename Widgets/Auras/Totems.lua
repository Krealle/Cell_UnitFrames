---@class CUF
local CUF = select(2, ...)

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Cell = CUF.Cell
local I = Cell.iFuncs

local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants
local DB = CUF.DB
local P = CUF.PixelPerfect

-- Blizzard has this at 4, but apparently the true max is 5
local MAX_TOTEMS = 5

-- Blizzard grabs this information each time it updates totems, but this is essentially staic information
local _, playerClass = UnitClass("player")
local priorities = playerClass == "SHAMAN" and SHAMAN_TOTEM_PRIORITIES or STANDARD_TOTEM_PRIORITIES

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.TOTEMS,
    Builder.MenuOptions.TotemOptions,
    Builder.MenuOptions.AuraDurationFontOptions,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateTotemsWidgets(button, unit, setting, subSetting)
    local totems = button.widgets.totems

    local styleTable = DB.GetCurrentWidgetTable("totems", unit) --[[@as TotemsWidgetTable]]

    if not setting or setting == const.AURA_OPTION_KIND.FONT then
        totems:SetFont(styleTable.font)
    end
    if not setting or setting == const.AURA_OPTION_KIND.ORIENTATION then
        totems:SetOrientation(styleTable.orientation)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SIZE then
        P.Size(totems, styleTable.size.width, styleTable.size.height)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_DURATION then
        totems:ShowDuration(styleTable.showDuration)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_ANIMATION then
        totems:ShowAnimation(styleTable.showAnimation)
    end
    if not setting or (setting == const.AURA_OPTION_KIND.SHOW_TOOLTIP or setting == const.AURA_OPTION_KIND.HIDE_IN_COMBAT) then
        totems:ShowTooltip(styleTable.showTooltip, styleTable.hideInCombat)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SPACING then
        totems:SetSpacing({ styleTable.spacing.horizontal, styleTable.spacing.vertical })
    end
    if not setting or setting == const.AURA_OPTION_KIND.NUM_PER_LINE then
        totems:SetNumPerLine(styleTable.numPerLine)
    end
    if not setting or setting == const.AURA_OPTION_KIND.MAX_ICONS then
        totems:SetMaxNum(styleTable.maxIcons)
    end

    if totems._isSelected then
        totems:ShowPreview()
    else
        totems.Update(button)
    end
end

Handler:RegisterWidget(W.UpdateTotemsWidgets, const.WIDGET_KIND.TOTEMS)

-------------------------------------------------
-- MARK: Setters
-------------------------------------------------

---@param self TotemsWidget
---@param fonts AuraFontOpt
local function Totems_SetFont(self, fonts)
    local fs = fonts.stacks
    local fd = fonts.duration
    for i = 1, #self do
        self[i]:SetFont(
            { fs.style, fs.size, fs.outline, fs.shadow, fs.point, fs.offsetX, fs.offsetY, fs.rgb },
            { fd.style, fd.size, fd.outline, fd.shadow, fd.point, fd.offsetX, fd.offsetY, fd.rgb })
    end
end

---@param self TotemsWidget
---@param maxNum number
local function Totems_SetMaxNum(self, maxNum)
    self._maxNum = maxNum
end

---@param self TotemsWidget
---@param show boolean
---@param hideInCombat boolean
local function Totems_ShowTooltip(self, show, hideInCombat)
    for i = 1, #self do
        local icon = self[i]
        if show then
            icon:SetScript("OnEnter", function(_self)
                -- Don't show tooltips in preview mode
                if (hideInCombat and InCombatLockdown()) or self._isSelected then return end

                GameTooltip:SetOwner(_self, "ANCHOR_TOPLEFT")
                GameTooltip:SetTotem(_self.id)
            end)

            icon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- https://warcraft.wiki.gg/wiki/API_ScriptRegion_EnableMouse
            icon:SetMouseClickEnabled(false)
        else
            icon:SetScript("OnEnter", nil)
            icon:SetScript("OnLeave", nil)
        end
    end
end

---@param self TotemsWidget
---@param val boolean
local function SetIsSelected(self, val)
    if self._isSelected ~= val then
        if val then
            self:ShowPreview()
        else
            self:HidePreview()
            self:_Update()
        end
    end
    self._isSelected = val
end

-------------------------------------------------
-- MARK: Preview Helpers
-------------------------------------------------

local placeHolderTextures = {
    136098, 135127, 136100, 136070, 136108
}

---@param self TotemsWidget
local function Totems_ShowPreview(self)
    for idx, totem in ipairs(self) do
        totem:Hide() -- Clear any existing cooldowns

        if idx <= self._maxNum then
            totem.preview:SetScript("OnUpdate", function(_self, elapsed)
                _self.elapsedTime = (_self.elapsedTime or 0) + elapsed
                if _self.elapsedTime >= 10 then
                    _self.elapsedTime = 0
                    totem:SetCooldown(GetTime(), 10, nil, placeHolderTextures[idx], idx, false)
                end
            end)

            totem.preview:SetScript("OnShow", function()
                totem.preview.elapsedTime = 0
                totem:SetCooldown(GetTime(), 10, nil, placeHolderTextures[idx], idx, false)
            end)
        end

        totem:Show()
        totem.preview:Show()
    end

    self:UpdateSize(self._maxNum)
end

---@param self TotemsWidget
local function Totems_HidePreview(self)
    for _, totem in ipairs(self) do
        totem.preview:SetScript("OnUpdate", nil)
        totem.preview:SetScript("OnShow", nil)

        totem:Hide()
    end
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param self TotemsWidget
local function Totems_Update(self)
    self.activeTotems = 0

    local haveTotem, name, startTime, duration, icon
    local slot
    for i = 1, self._maxNum do
        -- priorities 5+ is nil so we default to the index
        slot = priorities[i] or i
        haveTotem, name, startTime, duration, icon = GetTotemInfo(slot)

        -- If you go beyond the *actual* limit of your max totems this will be nil, so we bail out
        -- Since any further totems won't be valid either
        -- This shouldn't ever be a problem, but if it ever is, it will be nice to stop iteration early
        if haveTotem == nil then break end

        if haveTotem and duration > 0 then
            self.activeTotems = self.activeTotems + 1

            self[self.activeTotems]:SetCooldown(startTime, duration, nil, icon, 1, false)
            self[self.activeTotems].id = slot
        end
    end

    self:UpdateSize(self.activeTotems)
end

-------------------------------------------------
-- MARK: Generics
-------------------------------------------------

---@param button CUFUnitButton
---@param event? "PLAYER_TOTEM_UPDATE"|"UPDATE_SHAPESHIFT_FORM"|"PLAYER_TALENT_UPDATE"|"PLAYER_SPECIALIZATION_CHANGED"
local function Update(button, event)
    if not button:IsVisible() then return end

    -- Preview
    if button.widgets.totems._isSelected then return end
    button.widgets.totems:_Update()
end

---@param self TotemsWidget
local function Enable(self)
    -- These are the events used by Blizzard for their TotemFrame
    self._owner:AddEventListener("PLAYER_TOTEM_UPDATE", Update, true)
    self._owner:AddEventListener("UPDATE_SHAPESHIFT_FORM", Update, true)
    self._owner:AddEventListener("PLAYER_TALENT_UPDATE", Update, true)
    self._owner:AddEventListener("PLAYER_SPECIALIZATION_CHANGED", Update)

    self:Show()
    self:_Update()
    return true
end

---@param self TotemsWidget
local function Disable(self)
    self._owner:RemoveEventListener("PLAYER_TOTEM_UPDATE", Update)
    self._owner:RemoveEventListener("UPDATE_SHAPESHIFT_FORM", Update)
    self._owner:RemoveEventListener("PLAYER_TALENT_UPDATE", Update)
    self._owner:RemoveEventListener("PLAYER_SPECIALIZATION_CHANGED", Update)
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateTotems(button)
    ---@class TotemsWidget: CellAuraIcons
    local totems = I.CreateAura_Icons(button:GetName() .. "_Totems", button, MAX_TOTEMS)
    button.widgets.totems = totems

    totems:ShowStack(false)

    totems:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -30)
    totems.enabled = false
    totems.id = const.WIDGET_KIND.TOTEMS
    totems._isSelected = false
    totems._owner = button

    totems._maxNum = MAX_TOTEMS
    totems.activeTotems = 0

    for _, totem in ipairs(totems) do
        ---@class TotemPreview: Frame
        totem.preview = CreateFrame("Frame", nil, totem)
        totem.preview:Hide()
        totem.preview.elapsedTime = 0
    end

    totems._Update = Totems_Update

    totems.Enable = Enable
    totems.Update = Update
    totems.Disable = Disable

    totems.SetFont = Totems_SetFont
    totems.SetMaxNum = Totems_SetMaxNum
    totems.ShowTooltip = Totems_ShowTooltip

    totems.SetEnabled = W.SetEnabled
    totems._SetIsSelected = SetIsSelected
    totems.SetPosition = W.SetRelativePosition
    totems.SetWidgetFrameLevel = W.SetWidgetFrameLevel

    totems.ShowPreview = Totems_ShowPreview
    totems.HidePreview = Totems_HidePreview
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.TOTEMS, W.CreateTotems)
