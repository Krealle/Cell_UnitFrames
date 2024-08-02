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
local DB = CUF.DB

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

---@param button CUFUnitButton
---@param func function
local function ForEachAuraHelper(button, func, _continuationToken, ...)
    local n = select('#', ...)
    for i = 1, n do
        local slot = select(i, ...)
        ---@class AuraData
        local auraData = GetAuraDataBySlot(button.states.unit, slot)
        auraData.index = i
        auraData.refreshing = false

        func(button, auraData, i)
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
---@param auraData AuraData?
local function HandleAura(button, auraData)
    if not auraData then return end

    local duration = auraData.duration
    if not duration or duration == 0 then return end

    -- TODO: blacklist / whitelist logic
    --local spellId = auraData.spellId

    local auraInstanceID = auraData.auraInstanceID
    local count = auraData.applications
    local expirationTime = auraData.expirationTime or 0

    local cache = auraData.isHarmful and button._debuffs_cache or button._buffs_cache
    local instanceIDCache = auraData.isHarmful and button._debuffsAuraInstanceIDs or button._buffsAuraInstanceIDs

    if Cell.vars.iconAnimation == "duration" then
        local timeIncreased = cache[auraInstanceID] and
            (expirationTime - cache[auraInstanceID]["expirationTime"] >= 0.5) or false
        local countIncreased = cache[auraInstanceID] and
            (count > cache[auraInstanceID]["applications"]) or false
        auraData.refreshing = timeIncreased or countIncreased
    elseif Cell.vars.iconAnimation == "stack" then
        auraData.refreshing = cache[auraInstanceID] and
            (count > cache[auraInstanceID]["applications"]) or false
    end

    cache[auraInstanceID] = auraData
    table.insert(instanceIDCache, auraData.auraInstanceID)
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
            if button._buffs_cache[auraInstanceID] then buffChanged = true end
            if button._debuffs_cache[auraInstanceID] then debuffChanged = true end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
            if button._buffs_cache[auraInstanceID] then
                button._buffs_cache[auraInstanceID] = nil
                buffChanged = true
            end
            if button._debuffs_cache[auraInstanceID] then
                button._debuffs_cache[auraInstanceID] = nil
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

---@param button CUFUnitButton
---@param type "buffs" | "debuffs"
local function UpdateAuraIcons(button, type)
    local auraCache = button["_" .. type .. "_cache"]
    local auraInstanceIDs = button["_" .. type .. "AuraInstanceIDs"]
    local auraCountKey = "_" .. type .. "Count"

    -- Update aura cache
    ForEachAura(button, (type == "buffs" and "HELPFUL" or "HARMFUL"), HandleAura)

    -- Sort
    table.sort(auraInstanceIDs, function(a, b)
        local aData = auraCache[a]
        local bData = auraCache[b]
        if not aData or not bData then return false end
        return aData.expirationTime < bData.expirationTime
    end)

    -- Update icons
    for i = 1, 10 do
        if button[auraCountKey] < 10 then
            local auraInstanceID = auraInstanceIDs[i]
            if not auraInstanceID then break end

            local auraData = auraCache[auraInstanceID]

            button[auraCountKey] = button[auraCountKey] + 1
            button.widgets.buffs[button[auraCountKey]]:SetCooldown(
                (auraData.expirationTime or 0) - auraData.duration,
                auraData.duration,
                nil,
                auraData.icon,
                auraData.applications,
                auraData.refreshing
            )
            button.widgets.buffs[button[auraCountKey]].index = auraData.index -- Tooltip
        end
    end
end

---@param button CUFUnitButton
---@param updateInfo UnitAuraUpdateInfo?
function U:UnitFrame_UpdateAuras(button, updateInfo)
    local unit = button.states.displayedUnit
    if not unit then return end

    local buffChanged, debuffChanged = ShouldUpdateAuras(button, updateInfo)
    if not buffChanged and not debuffChanged then return end

    if buffChanged == "full" then
        wipe(button._buffs_cache)
        wipe(button._debuffs_cache)
    end

    if buffChanged and button.widgets.buffs.enabled then
        button._buffsCount = 0
        wipe(button._buffsAuraInstanceIDs)

        UpdateAuraIcons(button, "buffs")

        button.widgets.buffs:UpdateSize(button._buffsCount)
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
                if (CellDB["general"]["hideTooltipsInCombat"] and InCombatLockdown()) then return end

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
        --auras:SetNumPerLine(numPerLine)
    end

    U:UnitFrame_UpdateAuras(button)
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
---@param type "buffs" | "debuffs"
---@param title "Buffs" | "Debuffs"
---@return CellAuraIcons auraIcons
function Auras:CreateAuraIcons(button, type, title)
    CUF:Debug("CreateIndicators", button:GetName())
    -- buffs indicator (icon)
    ---@class CellAuraIcons
    local auraIcons = I.CreateAura_Icons(button:GetName() .. title .. "Icons", button, 10)

    auraIcons.enabled = false
    auraIcons.id = type
    auraIcons.parent = button

    auraIcons.SetEnabled = W.SetEnabled
    auraIcons.SetPosition = Icons_SetPosition
    auraIcons.SetFont = Icons_SetFont
    auraIcons.ShowTooltip = Icons_ShowTooltip

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
