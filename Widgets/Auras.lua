---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations


local const = CUF.constants
local Handler = CUF.Handler
local DB = CUF.DB
local menu = CUF.Menu
local Builder = CUF.Builder

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs
---@class CUF.auras
local Auras = {}
CUF.auras = Auras

local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot

-------------------------------------------------
-- MARK: ForEachAura
-------------------------------------------------

---@param icons CellAuraIcons
---@param func function
local function ForEachAuraHelper(icons, func, _continuationToken, ...)
    local n = select('#', ...)
    for i = 1, n do
        local slot = select(i, ...)
        ---@class AuraData
        local auraData = GetAuraDataBySlot(icons.parent.states.unit, slot)
        auraData.index = i
        auraData.refreshing = false

        func(icons, auraData)
    end
end

---@param icons CellAuraIcons
---@param filter string
local function ForEachAura(icons, filter, func)
    ForEachAuraHelper(icons, func, GetAuraSlots(icons.parent.states.unit, filter))
end

-------------------------------------------------
-- MARK: Aura Handling
-------------------------------------------------

---@param icon CellAuraIcons
---@param auraData AuraData?
local function HandleAura(icon, auraData)
    if not auraData then return end

    local duration = auraData.duration
    if not duration or duration == 0 then return end

    -- TODO: blacklist / whitelist logic
    --local spellId = auraData.spellId

    local auraInstanceID = auraData.auraInstanceID
    local count = auraData.applications
    local expirationTime = auraData.expirationTime or 0

    if Cell.vars.iconAnimation == "duration" then
        local timeIncreased = icon._auraCache[auraInstanceID] and
            (expirationTime - icon._auraCache[auraInstanceID]["expirationTime"] >= 0.5) or false
        local countIncreased = icon._auraCache[auraInstanceID] and
            (count > icon._auraCache[auraInstanceID]["applications"]) or false
        auraData.refreshing = timeIncreased or countIncreased
    elseif Cell.vars.iconAnimation == "stack" then
        auraData.refreshing = icon._auraCache[auraInstanceID] and
            (count > icon._auraCache[auraInstanceID]["applications"]) or false
    end

    icon._auraCache[auraInstanceID] = auraData
    table.insert(icon._auraInstanceIDs, auraData.auraInstanceID)
end

---@param button CUFUnitButton
---@param updateInfo UnitAuraUpdateInfo?
---@return "full" | boolean buffChanged
---@return boolean debuffChanged
local function ShouldUpdateAuras(button, updateInfo)
    if not updateInfo or updateInfo.isFullUpdate then return "full", true end

    local buffChanged = false
    local debuffChanged = false

    if updateInfo.addedAuras then
        for _, aura in pairs(updateInfo.addedAuras) do
            if aura.isHelpful then buffChanged = true end
            if aura.isHarmful then debuffChanged = true end
        end
    end

    if updateInfo.updatedAuraInstanceIDs then
        for _, auraInstanceID in pairs(updateInfo.updatedAuraInstanceIDs) do
            if button.widgets.buffs._auraCache[auraInstanceID] then buffChanged = true end
            if button.widgets.debuffs._auraCache[auraInstanceID] then debuffChanged = true end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
            if button.widgets.buffs._auraCache[auraInstanceID] then
                button.widgets.buffs._auraCache[auraInstanceID] = nil
                buffChanged = true
            end
            if button.widgets.debuffs._auraCache[auraInstanceID] then
                button.widgets.debuffs._auraCache[auraInstanceID] = nil
                debuffChanged = true
            end
        end
    end

    if Cell.loaded then
        if CellDB["general"]["alwaysUpdateBuffs"] then buffChanged = true end
        if CellDB["general"]["alwaysUpdateDebuffs"] then debuffChanged = true end
    end

    return buffChanged, debuffChanged
end

---@param icons CellAuraIcons
local function UpdateAuraIcons(icons)
    -- Preview
    if icons._isSelected then
        icons:ShowPreview()
        icons:UpdateSize(icons._maxNum)
        return
    end

    -- Reset
    icons._auraCount = 0
    wipe(icons._auraInstanceIDs)

    -- Update aura cache
    ForEachAura(icons, icons.auraFilter, HandleAura)

    -- Sort
    table.sort(icons._auraInstanceIDs, function(a, b)
        local aData = icons._auraCache[a]
        local bData = icons._auraCache[b]
        if not aData or not bData then return false end
        return aData.expirationTime > bData.expirationTime
    end)

    -- Update icons
    for i = 1, icons._maxNum do
        local auraInstanceID = icons._auraInstanceIDs[i]
        if not auraInstanceID then break end

        local auraData = icons._auraCache[auraInstanceID]

        icons._auraCount = icons._auraCount + 1
        icons[icons._auraCount]:SetCooldown(
            (auraData.expirationTime or 0) - auraData.duration,
            auraData.duration,
            nil,
            auraData.icon,
            auraData.applications,
            auraData.refreshing
        )
        icons[icons._auraCount].index = auraData.index -- Tooltip
    end

    -- Resize
    icons:UpdateSize(icons._auraCount)
end

---@param button CUFUnitButton
---@param updateInfo UnitAuraUpdateInfo?
function U:UnitFrame_UpdateAuras(button, updateInfo)
    local unit = button.states.displayedUnit
    if not unit then return end

    local buffChanged, debuffChanged = ShouldUpdateAuras(button, updateInfo)
    local previewMode = CUF.vars.testMode and button._isSelected

    if not buffChanged and not debuffChanged and not previewMode then return end

    if buffChanged == "full" then
        wipe(button.widgets.buffs._auraCache)
        wipe(button.widgets.debuffs._auraCache)
    end

    if button.widgets.buffs.enabled and (buffChanged or previewMode) then
        UpdateAuraIcons(button.widgets.buffs)
    end

    if button.widgets.debuffs.enabled and (debuffChanged or previewMode) then
        UpdateAuraIcons(button.widgets.debuffs)
    end
end

-------------------------------------------------
-- MARK: Aura Setters
-------------------------------------------------

---@param icons CellAuraIcons
---@param fonts AuraFontOpt
local function Icons_SetFont(icons, fonts)
    local fs = fonts.stacks
    local fd = fonts.duration
    for i = 1, icons.maxNum do
        icons[i]:SetFont(
            { fs.style, fs.size, fs.outline, fs.shadow, fs.anchor, fs.offsetX, fs.offsetY, fs.rgb },
            { fd.style, fd.size, fd.outline, fd.shadow, fd.anchor, fd.offsetX, fd.offsetY, fd.rgb })
    end
end

---@param widget Widget
---@param unit Unit
local function Icons_SetPosition(widget, unit)
    ---@type PositionOpt
    local position = CUF.vars.selectedLayoutTable[unit].widgets[widget.id].position
    P:ClearPoints(widget)
    P:Point(widget, position.anchor, widget:GetParent(), position.extraAnchor, position.offsetX, position.offsetY)
end

---@param icons CellAuraIcons
---@param show boolean
local function Icons_ShowTooltip(icons, show)
    for i = 1, #icons do
        if show then
            icons[i]:SetScript("OnEnter", function(self)
                -- Don't show tooltips in preview mode
                if (CellDB["general"]["hideTooltipsInCombat"] and InCombatLockdown()) or icons._isSelected then return end

                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                GameTooltip:SetUnitAura(icons.parent.states.displayedUnit, self.index, icons.auraFilter)
            end)

            icons[i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- https://warcraft.wiki.gg/wiki/API_ScriptRegion_EnableMouse
            icons[i]:SetMouseClickEnabled(false)
        else
            icons[i]:SetScript("OnEnter", nil)
            icons[i]:SetScript("OnLeave", nil)
        end
    end
end

---@param icons CellAuraIcons
---@param maxNum number
local function Icons_SetMaxNum(icons, maxNum)
    icons._maxNum = maxNum
end

-------------------------------------------------
-- MARK: Aura Update
-------------------------------------------------

---@param button CUFUnitButton
---@param unit Unit
---@param which "buffs" | "debuffs"
---@param setting AURA_OPTION_KIND
---@param subSetting string
function W.UpdateAuraWidget(button, unit, which, setting, subSetting)
    ---@type CellAuraIcons
    local auras = button.widgets[which]

    local styleTable = DB.GetWidgetTable(which, unit) --[[@as AuraWidgetTable]]

    if not setting or setting == const.AURA_OPTION_KIND.FONT or const.AURA_OPTION_KIND.POSITION then
        auras:SetFont(styleTable.font)
    end
    if not setting or setting == const.AURA_OPTION_KIND.ORIENTATION then
        auras:SetOrientation(styleTable.orientation)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SIZE then
        P:Size(auras, styleTable.size.width, styleTable.size.height)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_DURATION then
        auras:ShowDuration(styleTable.showDuration)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_ANIMATION then
        auras:ShowAnimation(styleTable.showAnimation)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_STACK then
        auras:ShowStack(styleTable.showStack)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_TOOLTIP then
        auras:ShowTooltip(styleTable.showTooltip)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SPACING then
        auras:SetSpacing({ styleTable.spacing.horizontal, styleTable.spacing.vertical })
    end
    if not setting or setting == const.AURA_OPTION_KIND.NUM_PER_LINE then
        auras:SetNumPerLine(styleTable.numPerLine)
    end
    if not setting or setting == const.AURA_OPTION_KIND.MAX_ICONS then
        auras:SetMaxNum(styleTable.maxIcons)
    end

    U:UnitFrame_UpdateAuras(button)
end

-------------------------------------------------
-- MARK: Buff & Debuff
-------------------------------------------------

---@param button CUFUnitButton
---@param unit Unit
---@param setting AURA_OPTION_KIND
---@param subSetting string
local function UpdateBuffs(button, unit, setting, subSetting)
    W.UpdateAuraWidget(button, unit, const.WIDGET_KIND.BUFFS, setting, subSetting)
end

Handler:RegisterWidget(UpdateBuffs, const.WIDGET_KIND.BUFFS)

menu:AddWidget(const.WIDGET_KIND.BUFFS, 250, "Buffs",
    Builder.MenuOptions.AuraIconOptions,
    Builder.MenuOptions.AuraStackFontOptions,
    Builder.MenuOptions.AuraDurationFontOptions
)

---@param button CUFUnitButton
---@param unit Unit
---@param setting AURA_OPTION_KIND
---@param subSetting string
local function UpdateDebuffs(button, unit, setting, subSetting)
    W.UpdateAuraWidget(button, unit, const.WIDGET_KIND.DEBUFFS, setting, subSetting)
end

Handler:RegisterWidget(UpdateDebuffs, const.WIDGET_KIND.DEBUFFS)

menu:AddWidget(const.WIDGET_KIND.DEBUFFS, 250, "Debuffs",
    Builder.MenuOptions.AuraIconOptions,
    Builder.MenuOptions.AuraStackFontOptions,
    Builder.MenuOptions.AuraDurationFontOptions
)

-------------------------------------------------
-- MARK: Create Aura Icons
-------------------------------------------------

local placeHolderTextures = {
    135939, 237542, 135727, 463286, 132242, 1526618, 136075, 5199640, 1360764, 135988
}

---@param icons CellAuraIcons
local function Icons_ShowPreview(icons)
    for idx, icon in ipairs(icons) do
        icon:Hide() -- Clear any existing cooldowns

        icon.preview:SetScript("OnUpdate", function(self, elapsed)
            self.elapsedTime = (self.elapsedTime or 0) + elapsed
            if self.elapsedTime >= 10 then
                self.elapsedTime = 0
                icon:SetCooldown(GetTime(), 10, nil, placeHolderTextures[idx], idx, (idx % 3 == 0))
            end
        end)

        icon.preview:SetScript("OnShow", function()
            icon.preview.elapsedTime = 0
            icon:SetCooldown(GetTime(), 10, nil, placeHolderTextures[idx], idx, (idx % 3 == 0))
        end)

        icon:Show()
        icon.preview:Show()
    end

    icons:UpdateSize(icons._maxNum)
end

---@param icons CellAuraIcons
local function Icons_HidePreview(icons)
    for _, icon in ipairs(icons) do
        icon.preview:SetScript("OnUpdate", nil)
        icon.preview:SetScript("OnShow", nil)

        icon:Hide()
    end
end

---@param button CUFUnitButton
---@param type "buffs" | "debuffs"
---@param title "Buffs" | "Debuffs"
---@return CellAuraIcons auraIcons
function Auras:CreateAuraIcons(button, type, title)
    --CUF:Debug("CreateIndicators", button:GetName())
    ---@class CellAuraIcons
    local auraIcons = I.CreateAura_Icons(button:GetName() .. title .. "Icons", button, 10)

    auraIcons.enabled = false
    auraIcons.id = type
    auraIcons.parent = button
    auraIcons.auraFilter = type == "buffs" and "HELPFUL" or "HARMFUL"
    auraIcons._maxNum = 10
    auraIcons._isSelected = false

    auraIcons._auraCache = {}
    auraIcons._auraInstanceIDs = {}
    auraIcons._auraCount = 0

    for _, icon in ipairs(auraIcons) do
        ---@class CellAuraIcon.preview: Frame
        icon.preview = CreateFrame("Frame", nil, icon)
        icon.preview:Hide()
        icon.preview.elapsedTime = 0
    end

    auraIcons.SetEnabled = W.SetEnabled
    auraIcons.SetPosition = Icons_SetPosition
    auraIcons.SetFont = Icons_SetFont
    auraIcons.ShowTooltip = Icons_ShowTooltip
    auraIcons.SetMaxNum = Icons_SetMaxNum

    auraIcons.ShowPreview = Icons_ShowPreview
    auraIcons.HidePreview = Icons_HidePreview

    ---@param icons CellAuraIcons
    ---@param val boolean
    auraIcons._SetIsSelected = function(icons, val)
        if icons._isSelected ~= val then
            if val then
                icons:ShowPreview()
            else
                icons:HidePreview()
            end
        end
        icons._isSelected = val

        U:UnitFrame_UpdateAuras(button)
    end

    auraIcons:ShowDuration(true)
    auraIcons:ShowAnimation(true)
    auraIcons:ShowStack(true)

    return auraIcons
end

-------------------------------------------------
-- MARK: Cell typing
-------------------------------------------------
---@class CellAuraIcon
---@field icon Texture
---@field stack FontString
---@field duration FontString
---@field ag AnimationGroup
---@field SetFont fun(frame, font1, font2) Shared_SetFont
---@field SetCooldown fun(frame: self, start: number, duration: number, debuffType: any, texture: TextureAsset, count: number, refreshing: boolean) BarIcon_SetCooldown
---@field ShowDuration fun(frame, show) Shared_ShowDuration
---@field ShowStack fun(frame, show) Shared_ShowStack
---@field ShowAnimation fun(frame, show) BarIcon_ShowAnimation
---@field UpdatePixelPerfect fun(frame) BarIcon_UpdatePixelPerfect
---@field cooldown StatusBar
---@field GetCooldownDuration function
---@field ShowCooldown function
---@field tex Texture
---@field index number
---@field preview CellAuraIcon.preview

---@class CellAuraIcons
---@field enabled boolean
---@field id "buffs" | "debuffs"
---@field indicatorType "icons"
---@field auraFilter "HELPFUL" | "HARMFUL"
---@field maxNum number
---@field numPerLine number
---@field spacingX number
---@field spacingY number
---@field _SetSize function
---@field SetSize function
---@field _Hide function
---@field Hide function
---@field UpdateSize fun(icons: any, numAuras: any) Icons_UpdateSize
---@field SetOrientation fun(icons: any, orientation: any) Icons_SetOrientation
---@field SetSpacing fun(icons: any, spacing: any) Icons_SetSpacing
---@field SetNumPerLine fun(icons: any, numPerLine: any) Icons_SetNumPerLine
---@field ShowDuration fun(icons: any, show: any) Icons_ShowDuration
---@field ShowStack fun(icons: any, show: any) Icons_ShowStack
---@field ShowAnimation fun(icons: any, show: any) Icons_ShowAnimation
---@field UpdatePixelPerfect function
---@field [number] CellAuraIcon
---@field parent CUFUnitButton
---@field _isSelected boolean
---@field _auraCache table<number, AuraData>
---@field _auraInstanceIDs table<number>
---@field _auraCount number
