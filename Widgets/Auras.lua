---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations


local const = CUF.constants
local Handler = CUF.widgetsHandler

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.auras
local Auras = {}
CUF.auras = Auras

local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot

-------------------------------------------------
-- MARK: ForEachAura
-------------------------------------------------

---@param button CUFUnitButton
---@param func function
local function ForEachAuraHelper(button, func, _continuationToken, ...)
    local n = select('#', ...)
    for i = 1, n do
        local slot = select(i, ...)
        local auraInfo = GetAuraDataBySlot(button.states.unit, slot)
        local done = func(button, auraInfo, i)
        if done then
            -- if func returns true then no further slots are needed, so don't return continuationToken
            return nil
        end
    end
end

---@param button CUFUnitButton
---@param filter string
local function ForEachAura(button, filter, func)
    ForEachAuraHelper(button, func, GetAuraSlots(button.states.unit, filter))
end

-------------------------------------------------
-- MARK: Aura Handling
-------------------------------------------------

---@param button CUFUnitButton
---@param auraInfo AuraData?
local function HandleBuff(button, auraInfo)
    if not auraInfo then return end

    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    -- local debuffType = auraInfo.isHarmful and auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId
    -- local attribute = auraInfo.points[1] -- UnitAura:arg16

    local refreshing = false

    if duration then
        if Cell.vars.iconAnimation == "duration" then
            local timeIncreased = button._buffs_cache[auraInstanceID] and
                (expirationTime - button._buffs_cache[auraInstanceID] >= 0.5) or false
            local countIncreased = button._buffs_count_cache[auraInstanceID] and
                (count > button._buffs_count_cache[auraInstanceID]) or false
            refreshing = timeIncreased or countIncreased
        elseif Cell.vars.iconAnimation == "stack" then
            refreshing = button._buffs_count_cache[auraInstanceID] and
                (count > button._buffs_count_cache[auraInstanceID]) or
                false
        else
            refreshing = false
        end

        --[[         if (source == "player" and (myBuffs_icon[name] or myBuffs_bar[name])) or offensiveBuffs[spellId] then ]]
        button._buffs_cache[auraInstanceID] = expirationTime
        button._buffs_count_cache[auraInstanceID] = count
        --[[ end ]]

        if --[[ myBuffs_icon[name] and source == "player" and ]] button._buffIconsFound < 5 then
            button._buffIconsFound = button._buffIconsFound + 1
            button.widgets.buffs[button._buffIconsFound]:SetCooldown(start, duration, nil, icon, count, refreshing)
        end
    end
end

---@param button CUFUnitButton
---@param updateInfo UnitAuraUpdateInfo?
function Auras:UpdateAuras(button, updateInfo)
    local unit = button.states.unit
    --CUF:Debug("UpdateAuras", button:GetName(), unit, updateInfo and "has info" or "no info")
    if not unit then return end

    local buffsChanged

    if not updateInfo or updateInfo.isFullUpdate then
        wipe(button._buffs_cache)
        wipe(button._buffs_count_cache)
        buffsChanged = true
    else
        if updateInfo.addedAuras then
            for _, aura in pairs(updateInfo.addedAuras) do
                if aura.isHelpful then buffsChanged = true end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceID in pairs(updateInfo.updatedAuraInstanceIDs) do
                if button._buffs_cache[auraInstanceID] then buffsChanged = true end
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
                if button._buffs_cache[auraInstanceID] then
                    button._buffs_cache[auraInstanceID] = nil
                    button._buffs_count_cache[auraInstanceID] = nil
                    buffsChanged = true
                end
            end
        end

        if Cell.loaded then
            if CellDB["general"]["alwaysUpdateBuffs"] then buffsChanged = true end
        end
    end

    if buffsChanged then
        button._buffIconsFound = 0

        ForEachAura(button, "HELPFUL", HandleBuff)
        button.widgets.buffs:UpdateSize(button._buffIconsFound)
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
    ---@type AuraWidgetTable
    local styleTable = CUF.vars.selectedWidgetTable[which]

    if not setting or setting == const.AURA_OPTION_KIND.FONT then
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
        --auras:ShowTooltips(styleTable.showTooltip)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SPACING then
        --auras:SetSpacing(spacing {styleTable.spacing.horizontal, styleTable.spacing.vertical})
    end
    if not setting or setting == const.AURA_OPTION_KIND.NUM_PER_LINE then
        --auras:SetNumPerLine(numPerLine)
    end
end

---@param button CUFUnitButton
---@param unit Unit
---@param setting AURA_OPTION_KIND
---@param subSetting string
local function UpdateBuffs(button, unit, setting, subSetting)
    W.UpdateAuraWidget(button, unit, const.WIDGET_KIND.BUFFS, setting, subSetting)
end

Handler:RegisterWidget(UpdateBuffs, const.WIDGET_KIND.BUFFS)

-------------------------------------------------
-- MARK: Aura Indicators
-------------------------------------------------

---@param button CUFUnitButton
function Auras:CreateIndicators(button)
    CUF:Debug("CreateIndicators", button:GetName())
    -- buffs indicator (icon)
    ---@class CellAuraIcons
    local buffIcons = I.CreateAura_Icons(button:GetName() .. "BuffIcons", button, 5)
    button.widgets.buffs = buffIcons
    buffIcons.SetFont = Icons_SetFont
    buffIcons.enabled = false
    buffIcons.id = const.WIDGET_KIND.BUFFS

    buffIcons.SetEnabled = W.SetEnabled
    buffIcons.SetPosition = Icons_SetPosition

    buffIcons:ShowDuration(true)
    buffIcons:ShowAnimation(true)
    buffIcons:ShowStack(true)

    --[[ buffIcons:Show() ]]
    -- point
    --P:ClearPoints(buffIcons)
    --P:Point(buffIcons, "TOPLEFT", button, "TOPLEFT", 0, 30)
    -- size
    -- indicator color
    --[[ for i = 1, 5 do
        if buffIcons[i].cooldown:IsObjectType("StatusBar") then
            buffIcons[i].cooldown:GetStatusBarTexture():SetAlpha(1)
            buffIcons[i].tex = buffIcons[i]:CreateTexture(nil, "OVERLAY")
            buffIcons[i].tex:SetAllPoints(buffIcons[i].icon)

            hooksecurefunc(buffIcons[i], "SetCooldown", function(self, _, _, _, _, _, _, color, glow)
                self.tex:SetColorTexture(unpack(color))
                -- self.spark:SetColorTexture(color[1], color[2], color[3], 1) -- ignore alpha
                -- elseif self.cooldown:IsObjectType("Cooldown") then
                --     self.cooldown:SetSwipeTexture(0)
                --     self.cooldown:SetSwipeColor(unpack(color))
                ShowGlow(self, glow, color)
            end)
        end
    end ]]
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

---@class CellAuraIcons
---@field indicatorType "icons"
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
