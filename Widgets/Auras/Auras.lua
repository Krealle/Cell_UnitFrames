---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs


local const = CUF.constants
local Handler = CUF.Handler
local menu = CUF.Menu
local Builder = CUF.Builder
local Util = CUF.Util

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

-------------------------------------------------
-- MARK: Menu Options
-------------------------------------------------

for _, kind in pairs({ const.WIDGET_KIND.BUFFS, const.WIDGET_KIND.DEBUFFS }) do
    ---@param button CUFUnitButton
    ---@param unit Unit
    ---@param setting AURA_OPTION_KIND
    ---@param subSetting string
    local function UpdateAuraWidget(button, unit, setting, subSetting)
        W.UpdateAuraWidget(button, unit, kind, setting, subSetting)
    end

    Handler:RegisterWidget(UpdateAuraWidget, kind)

    menu:AddWidget(kind, Util:ToTitleCase(kind),
        Builder.MenuOptions.AuraIconOptions,
        Builder.MenuOptions.AuraFilter,
        Builder.MenuOptions.AuraBlacklist,
        Builder.MenuOptions.AuraWhitelist,
        Builder.MenuOptions.AuraStackFontOptions,
        Builder.MenuOptions.AuraDurationFontOptions
    )
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

---@param icons CellAuraIcons
---@param hidePersonal boolean
local function Icons_SetHidePersonal(icons, hidePersonal)
    icons.hidePersonal = hidePersonal
end

---@param icons CellAuraIcons
---@param hideExternal boolean
local function Icons_SetHideExternal(icons, hideExternal)
    icons.hideExternal = hideExternal
end

---@param icons CellAuraIcons
---@param hideNoDuration boolean
local function Icons_SetHideNoDuration(icons, hideNoDuration)
    icons.hideNoDuration = hideNoDuration
end

---@param icons CellAuraIcons
---@param maxDuration number
local function Icons_SetMaxDuration(icons, maxDuration)
    icons.maxDuration = maxDuration ~= 0 and maxDuration or false
end

---@param icons CellAuraIcons
---@param minDuration number
local function Icons_SetMinDuration(icons, minDuration)
    icons.minDuration = minDuration ~= 0 and minDuration or false
end

---@param icons CellAuraIcons
---@param blacklist table<number>
local function Icons_SetBlacklist(icons, blacklist)
    icons.blacklist = F:ConvertTable(blacklist)
end

---@param icons CellAuraIcons
---@param whitelist table<number>
local function Icons_SetWhitelist(icons, whitelist)
    icons.whitelist = F:ConvertTable(whitelist)
end

---@param icons CellAuraIcons
---@param useBlacklist boolean
local function Icons_SetUseBlacklist(icons, useBlacklist)
    icons.useBlacklist = useBlacklist
end

---@param icons CellAuraIcons
---@param useWhitelist boolean
local function Icons_SetUseWhitelist(icons, useWhitelist)
    icons.useWhitelist = useWhitelist
end

-------------------------------------------------
-- MARK: Preview Helpers
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

-------------------------------------------------
-- MARK: Create Aura Icons
-------------------------------------------------

---@param button CUFUnitButton
---@param type "buffs" | "debuffs"
---@return CellAuraIcons auraIcons
function W:CreateAuraIcons(button, type)
    --CUF:Debug("CreateIndicators", button:GetName())
    ---@class CellAuraIcons
    local auraIcons = I.CreateAura_Icons(button:GetName() .. Util:ToTitleCase(type) .. "Icons", button, 10)

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
    auraIcons.SetHidePersonal = Icons_SetHidePersonal
    auraIcons.SetHideExternal = Icons_SetHideExternal
    auraIcons.SetHideNoDuration = Icons_SetHideNoDuration
    auraIcons.SetMaxDuration = Icons_SetMaxDuration
    auraIcons.SetMinDuration = Icons_SetMinDuration
    auraIcons.SetBlacklist = Icons_SetBlacklist
    auraIcons.SetWhitelist = Icons_SetWhitelist
    auraIcons.SetUseBlacklist = Icons_SetUseBlacklist
    auraIcons.SetUseWhitelist = Icons_SetUseWhitelist

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
---@field hidePersonal boolean
---@field hideExternal boolean
---@field hideNoDuration boolean
---@field maxDuration number|boolean
---@field minDuration number|boolean
---@field blacklist table<number, boolean>
---@field whitelist table<number, boolean>
---@field useBlacklist boolean
---@field useWhitelist boolean
