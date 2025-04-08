---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local I = Cell.iFuncs

local const = CUF.constants
local Handler = CUF.Handler
local menu = CUF.Menu
local Builder = CUF.Builder
local Util = CUF.Util
local P = CUF.PixelPerfect

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local tinsert = table.insert
local wipe = table.wipe
local ceil = math.ceil

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

    menu:AddWidget(kind,
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
    for i = 1, icons._maxNum do
        icons[i]:SetFont(
            { fs.style, fs.size, fs.outline, fs.shadow, fs.point, fs.offsetX, fs.offsetY, fs.rgb },
            { fd.style, fd.size, fd.outline, fd.shadow, fd.point, fd.offsetX, fd.offsetY, fd.rgb })
    end
end

---@param self CellAuraIcons
---@param styleTable WidgetTable
local function Icons_SetPosition(self, styleTable)
    local position = styleTable.position
    P.ClearPoints(self)
    P.Point(self, position.point, self:GetParent(), position.relativePoint, position.offsetX, position.offsetY)
end

---@param icons CellAuraIcons
---@param show boolean
---@param hideInCombat boolean
local function Icons_ShowTooltip(icons, show, hideInCombat)
    for i = 1, #icons do
        if show then
            icons[i]:SetScript("OnEnter", function(self)
                -- Don't show tooltips in preview mode
                if (hideInCombat and InCombatLockdown()) or icons._isSelected then return end

                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                if icons.id == "buffs" then
                    if self.isTempEnchant then
                        GameTooltip:SetInventoryItem("player", self.auraInstanceID);
                    else
                        GameTooltip:SetUnitBuffByAuraInstanceID(icons._owner.states.displayedUnit, self.auraInstanceID,
                            icons.auraFilter);
                    end
                else
                    GameTooltip:SetUnitDebuffByAuraInstanceID(icons._owner.states.displayedUnit, self.auraInstanceID,
                        icons.auraFilter);
                end
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
    -- Prevent setting a higher than valid maxNum
    if maxNum > #icons then
        maxNum = #icons
    end
    icons._maxNum = maxNum
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
    icons.blacklist = F.ConvertTable(blacklist)
end

---@param icons CellAuraIcons
---@param whitelist table<number>
local function Icons_SetWhitelist(icons, whitelist)
    icons.whitelist = F.ConvertTable(whitelist)
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

---@param icons CellAuraIcons
---@param boss boolean
local function Icons_SetBoss(icons, boss)
    icons.boss = boss
end

---@param icons CellAuraIcons
---@param castByPlayers boolean
local function Icons_SetCastByPlayers(icons, castByPlayers)
    icons.castByPlayers = castByPlayers
end

---@param icons CellAuraIcons
---@param castByNPC boolean
local function Icons_SetCastByNPC(icons, castByNPC)
    icons.castByNPC = castByNPC
end

---@param icons CellAuraIcons
---@param nonPersonal boolean
local function Icons_SetNonPersonal(icons, nonPersonal)
    icons.nonPersonal = nonPersonal
end

---@param icons CellAuraIcons
---@param personal boolean
local function Icons_SetPersonal(icons, personal)
    icons.personal = personal
end

---@param icons CellAuraIcons
---@param dispellable boolean
local function Icons_SetUseDispellable(icons, dispellable)
    icons.dispellable = dispellable
end

---@param icons CellAuraIcons
---@param raid boolean
local function Icons_SetRaid(icons, raid)
    icons.raid = raid
end

---@param icons CellAuraIcons
---@param cellRaidDebuffs boolean
local function Icons_SetCellRaidDebuffs(icons, cellRaidDebuffs)
    icons.cellRaidDebuffs = cellRaidDebuffs
end

---@param icons CellAuraIcons
---@param priority boolean
local function Icons_SetWhiteListPriority(icons, priority)
    icons.whiteListPriority = priority
end

---@param icons CellAuraIcons
---@param show boolean
local function Icons_ShowDuration(icons, show)
    for _, icon in ipairs(icons) do
        icon._showDuration = show
        icon.duration:SetShown(show)
    end
end

---@param icons CellAuraIcons
---@param show boolean
local function Icons_SetShowTempEnchant(icons, show)
    if icons._owner._baseUnit == "player" and icons.id == "buffs" then
        icons.showTempEnchant = show
        icons:UpdateTempEnchantListener()
    end
end

-- We need to override this so we can format the duration for really long auras
local function Icon_OnUpdate(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0
        -- color
        if Cell.vars.iconDurationColors then
            if frame._remain < Cell.vars.iconDurationColors[3][4] then
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[3][1], Cell.vars.iconDurationColors[3][2],
                    Cell.vars.iconDurationColors[3][3])
            elseif frame._remain < (Cell.vars.iconDurationColors[2][4] * frame._duration) then
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[2][1], Cell.vars.iconDurationColors[2][2],
                    Cell.vars.iconDurationColors[2][3])
            else
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[1][1], Cell.vars.iconDurationColors[1][2],
                    Cell.vars.iconDurationColors[1][3])
            end
        else
            frame.duration:SetTextColor(frame.duration.r, frame.duration.g, frame.duration.b)
        end
    end

    -- format
    if frame._remain > 60 then
        frame.duration:SetFormattedText(Util.FormatDuration(frame._remain))
    else
        if Cell.vars.iconDurationRoundUp then
            frame.duration:SetFormattedText("%d", ceil(frame._remain))
        else
            if frame._remain < (Cell.vars.iconDurationDecimal or 0) then
                frame.duration:SetFormattedText("%.1f", frame._remain)
            else
                frame.duration:SetFormattedText("%d", frame._remain)
            end
        end
    end
end

-------------------------------------------------
-- MARK: Preview Helpers
-------------------------------------------------

local placeHolderTextures = {
    135939, 237542, 135727, 463286, 132242, 1526618, 136075, 5199640, 1360764, 135988
}
local debuffTypes = { "", "Curse", "Disease", "Magic", "Poison", "none", "Bleed" }

---@param icons CellAuraIcons
local function Icons_ShowPreview(icons)
    local iconIdx = 0
    local debuffIdx = 0
    for idx, icon in ipairs(icons) do
        icon:Hide() -- Clear any existing cooldowns

        if idx <= icons._maxNum then
            iconIdx = iconIdx + 1
            if iconIdx > #placeHolderTextures then
                iconIdx = 1
            end

            debuffIdx = debuffIdx + 1
            if debuffIdx > #debuffTypes then
                debuffIdx = 1
            end

            local tex = placeHolderTextures[iconIdx]
            local debuffType = debuffTypes[debuffIdx]
            icon.preview:SetScript("OnUpdate", function(self, elapsed)
                self.elapsedTime = (self.elapsedTime or 0) + elapsed
                if self.elapsedTime >= 10 then
                    self.elapsedTime = 0
                    if icons.id == "buffs" then
                        icon:SetCooldown(GetTime(), 10, nil, tex, idx, (idx % 3 == 0))
                    else
                        icon:SetCooldown(GetTime(), 10, debuffType, tex, idx, (idx % 3 == 0))
                    end
                end
            end)

            icon.preview:SetScript("OnShow", function()
                icon.preview.elapsedTime = 0
                if icons.id == "buffs" then
                    icon:SetCooldown(GetTime(), 10, nil, tex, idx, (idx % 3 == 0))
                else
                    icon:SetCooldown(GetTime(), 10, debuffType, tex, idx, (idx % 3 == 0))
                end
            end)

            icon:Show()
            icon.preview:Show()
        end
    end

    icons:SetSpacing({ icons.spacingX, icons.spacingY })
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
-- MARK: API Functions
-------------------------------------------------

---@param icon CellAuraIcon
---@param auraDate AuraData
function Icon_PostUpdate(icon, auraDate)
end

-------------------------------------------------
-- MARK: HandleAura
-------------------------------------------------

local CELL_RAID_DEBUFFS = {}
local GetDebuffList = F.GetDebuffList

hooksecurefunc(F, "GetDebuffList", function(instanceName)
    CELL_RAID_DEBUFFS = GetDebuffList(instanceName)
end)

---@param icon CellAuraIcons
---@param auraData AuraData
---@return boolean show
local function CheckFilter(icon, auraData)
    --TODO: Filter prio?
    local spellId = auraData.spellId

    -- Cell Raid Debuffs
    if icon.cellRaidDebuffs and CELL_RAID_DEBUFFS[spellId] or CELL_RAID_DEBUFFS[auraData.name] then return true end

    -- Blacklist / Whitelist Check
    if icon.useBlacklist and icon.blacklist[spellId] then return false end
    if icon.useWhitelist and not icon.whitelist[spellId] then return false end

    -- Duration Check
    local duration = auraData.duration
    if icon.hideNoDuration and duration == 0 then return false end
    if icon.minDuration and duration < icon.minDuration then return false end
    if icon.maxDuration and duration > icon.maxDuration then return false end

    if icon.dispellable and auraData.isDispellable then return true end

    -- Personal / Non-Personal Check
    if icon.nonPersonal and auraData.sourceUnit ~= "player" then return true end
    if icon.personal and auraData.sourceUnit == "player" then return true end

    -- Source Unit Check
    if icon.boss and auraData.isBossAura then return true end
    if icon.raid and auraData.isRaid then return true end
    if icon.castByPlayers and auraData.isFromPlayerOrPlayerPet then return true end
    if icon.castByNPC and auraData.sourceUnit == "npc" then return true end

    return false
end

---@param auraData AuraData
---@param icon CellAuraIcons
local function HandleAura(auraData, icon)
    if not CheckFilter(icon, auraData) then return end

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

-------------------------------------------------
-- MARK: UpdateAuraIcons
-------------------------------------------------

local textureMapping = {
    [1] = 16, --Main hand
    [2] = 17, --Off-hand
    [3] = 18, --Ranged
}

---@param icons CellAuraIcons
local function UpdateTempEnchants(icons)
    if not icons.showTempEnchant then return end

    local temp = Util:GetWeaponEnchantInfo()
    if not temp then return end

    local id

    if temp.hasMainHandEnchant then
        if temp.mainHandExpiration then
            temp.mainHandExpiration = temp.mainHandExpiration / 1000;
        end
        local expirationTime = GetTime() + temp.mainHandExpiration;

        id = textureMapping[1]

        local tempAura = {
            expirationTime = expirationTime,
            duration = temp.mainHandExpiration,
            icon = GetInventoryItemTexture("player", id),
            applications = temp.mainHandCharges,
            refreshing = false,
            isTempEnchant = true,
            spellId = -id,
        }
        tinsert(icons._auraInstanceIDs, -id)
        icons._auraCache[-id] = tempAura
    end

    if temp.hasOffHandEnchant then
        if temp.offHandExpiration then
            temp.offHandExpiration = temp.offHandExpiration / 1000;
        end
        local expirationTime = GetTime() + temp.offHandExpiration;

        id = textureMapping[2]

        local tempAura = {
            expirationTime = expirationTime,
            duration = temp.offHandExpiration,
            icon = GetInventoryItemTexture("player", id),
            applications = temp.offHandCharges,
            refreshing = false,
            isTempEnchant = true,
            spellId = -id,
        }
        tinsert(icons._auraInstanceIDs, -id)
        icons._auraCache[-id] = tempAura
    end

    if temp.hasRangedEnchant then
        if temp.rangedExpiration then
            temp.rangedExpiration = temp.rangedExpiration / 1000;
        end
        local expirationTime = GetTime() + temp.rangedExpiration;

        id = textureMapping[3]

        local tempAura = {
            expirationTime = expirationTime,
            duration = temp.rangedExpiration,
            icon = GetInventoryItemTexture("player", id),
            applications = temp.rangedCharges,
            refreshing = false,
            isTempEnchant = true,
            spellId = -id,
        }
        tinsert(icons._auraInstanceIDs, -id)
        icons._auraCache[-id] = tempAura
    end
end

---@param icons CellAuraIcons
local function UpdateAuraIcons(icons)
    -- Preview
    if icons._isSelected then
        icons:ShowPreview()
        return
    end

    -- Reset
    icons._auraCount = 0
    wipe(icons._auraInstanceIDs)

    -- Update aura cache
    icons._owner:IterateAuras(icons.id, HandleAura, icons)

    UpdateTempEnchants(icons)

    -- Sort
    table.sort(icons._auraInstanceIDs, function(a, b)
        local aData = icons._auraCache[a]
        local bData = icons._auraCache[b]
        if not aData or not bData then return false end

        if icons.useWhitelist and icons.whiteListPriority then
            local aIdx = icons.whitelist[aData.spellId]
            local bIdx = icons.whitelist[bData.spellId]

            if aIdx or bIdx then
                if not aIdx and bIdx then return false end
                if not bIdx then return true end
                return aIdx < bIdx
            end
        end

        return aData.expirationTime > bData.expirationTime
    end)

    -- Update icons
    for i = 1, icons._maxNum do
        local auraInstanceID = icons._auraInstanceIDs[i]
        if not auraInstanceID then break end

        local auraData = icons._auraCache[auraInstanceID]
        local dispelType = auraData.isHarmful and (auraData.dispelName or "") or nil

        icons._auraCount = icons._auraCount + 1
        icons[icons._auraCount]:SetCooldown(
            (auraData.expirationTime or 0) - auraData.duration,
            auraData.duration,
            dispelType,
            auraData.icon,
            auraData.applications,
            auraData.refreshing
        )

        -- Tooltip
        ---@diagnostic disable-next-line: undefined-field
        if auraData.isTempEnchant then
            icons[icons._auraCount].auraInstanceID = math.abs(auraInstanceID)
            icons[icons._auraCount].isTempEnchant = true
        else
            icons[icons._auraCount].auraInstanceID = auraInstanceID
            icons[icons._auraCount].isTempEnchant = false
        end

        icons[icons._auraCount]:PostUpdate(auraData)
    end

    -- Resize
    icons:UpdateSize(icons._auraCount)
end

-------------------------------------------------
-- MARK: UpdateAuras
-------------------------------------------------

---@param button CUFUnitButton
---@param buffsChanged boolean?
---@param debuffsChanged boolean?
---@param dispelsChanged boolean?
---@param fullUpdate boolean?
local function UpdateAuras_Buffs(button, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
    if not button.widgets.buffs.enabled or not button:IsVisible() then return end

    local previewMode = button._isSelected
    if not buffsChanged and not previewMode then
        if buffsChanged == nil then
            -- This is nil when we are trying to do full update of this widget
            -- So we queue an update to auras
            button:QueueAuraUpdate()
        end
        return
    end

    if fullUpdate then
        wipe(button.widgets.buffs._auraCache)
    end

    UpdateAuraIcons(button.widgets.buffs)
end

---@param button CUFUnitButton
---@param buffsChanged boolean?
---@param debuffsChanged boolean?
---@param dispelsChanged boolean?
---@param fullUpdate boolean?
local function UpdateAuras_Debuffs(button, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate)
    if not button.widgets.debuffs.enabled or not button:IsVisible() then return end

    local previewMode = button._isSelected
    if not debuffsChanged and not previewMode then
        if debuffsChanged == nil then
            -- This is nil when we are trying to do full update of this widget
            -- So we queue an update to auras
            button:QueueAuraUpdate()
        end
        return
    end

    if fullUpdate then
        wipe(button.widgets.debuffs._auraCache)
    end

    UpdateAuraIcons(button.widgets.debuffs)
end

-------------------------------------------------
-- MARK: Update
-------------------------------------------------

---@param self CellAuraIcons
local function UpdateTempEnchantListener(self)
    if self.showTempEnchant then
        self._owner:AddEventListener("WEAPON_ENCHANT_CHANGED", self.Update, true)
        self._owner:AddEventListener("WEAPON_SLOT_CHANGED", self.Update, true)
    else
        self._owner:RemoveEventListener("WEAPON_ENCHANT_CHANGED", self.Update)
        self._owner:RemoveEventListener("WEAPON_SLOT_CHANGED", self.Update)
    end
end

---@param self CellAuraIcons
local function Enable(self)
    self._owner:RegisterAuraCallback(self.id, self.Update)

    self:UpdateTempEnchantListener()

    self:Show()
    return true
end

---@param self CellAuraIcons
local function Disable(self)
    self._owner:UnregisterAuraCallback(self.id, self.Update)
end

-------------------------------------------------
-- MARK: Create Aura Icons
-------------------------------------------------

---@param button CUFUnitButton
---@param type "buffs" | "debuffs"
---@return CellAuraIcons auraIcons
function W:CreateAuraIcons(button, type)
    ---@class CellAuraIcons
    local auraIcons = I.CreateAura_Icons(button:GetName() .. "_" .. Util:ToTitleCase(type), button,
        CUF.Defaults.Values.maxAuraIcons)

    auraIcons.enabled = false
    auraIcons.id = type
    auraIcons._owner = button
    auraIcons.auraFilter = type == "buffs" and "HELPFUL" or "HARMFUL"
    auraIcons._maxNum = CUF.Defaults.Values.maxAuraIcons
    auraIcons._isSelected = false
    auraIcons.showTempEnchant = false

    ---@type table<number, AuraData>
    auraIcons._auraCache = {}
    ---@type number[]
    auraIcons._auraInstanceIDs = {}
    auraIcons._auraCount = 0

    for _, icon in ipairs(auraIcons) do
        -- Make background transparent
        if CELL_BORDER_SIZE > 0 then
            icon:SetBackdrop({
                edgeFile = Cell.vars.whiteTexture,
                edgeSize = P.Scale(CELL_BORDER_SIZE)
            })
        else
            icon:SetBackdrop({
                edgeFile = Cell.vars.whiteTexture,
                edgeSize = P.Scale(1)
            })
        end
        icon:SetBackdropBorderColor(0, 0, 0, 1)
        -- Dirty workaround to make sure that borders are colored properly for debuffs
        -- TODO: Change this
        icon.SetBackdropColor = icon.SetBackdropBorderColor

        ---@class CellAuraIcon.preview: Frame
        icon.preview = CreateFrame("Frame", nil, icon)
        icon.preview:Hide()
        icon.preview.elapsedTime = 0

        -- Set to false so Cell doesn't try to format the duration
        icon.showDuration = false

        -- Hook SetCooldown so we can show custom formatting
        hooksecurefunc(icon, "SetCooldown", function(frame, start, duration, ...)
            if duration == 0 then return end

            if not frame._showDuration then
                frame.duration:Hide()
            else
                if frame._showDuration == true then
                    frame._threshold = duration
                elseif frame._showDuration >= 1 then
                    frame._threshold = frame._showDuration
                else -- < 1
                    frame._threshold = frame._showDuration * duration
                end
                frame.duration:Show()
            end

            if frame._showDuration then
                frame._start = start
                frame._duration = duration
                frame._elapsed = 0.1 -- update immediately
                frame:SetScript("OnUpdate", Icon_OnUpdate)
            end
        end)

        icon:HookScript("OnHide", function()
            Util.GlowStop(icon)
        end)

        icon.PostUpdate = Icon_PostUpdate
    end

    auraIcons.SetEnabled = W.SetEnabled
    auraIcons.SetPosition = Icons_SetPosition
    auraIcons.SetFont = Icons_SetFont
    auraIcons.ShowTooltip = Icons_ShowTooltip
    auraIcons.SetMaxNum = Icons_SetMaxNum
    auraIcons.SetHideNoDuration = Icons_SetHideNoDuration
    auraIcons.SetMaxDuration = Icons_SetMaxDuration
    auraIcons.SetMinDuration = Icons_SetMinDuration
    auraIcons.SetBlacklist = Icons_SetBlacklist
    auraIcons.SetWhitelist = Icons_SetWhitelist
    auraIcons.SetUseBlacklist = Icons_SetUseBlacklist
    auraIcons.SetUseWhitelist = Icons_SetUseWhitelist
    auraIcons.SetWhiteListPriority = Icons_SetWhiteListPriority
    auraIcons.SetShowTempEnchant = Icons_SetShowTempEnchant

    auraIcons.SetBoss = Icons_SetBoss
    auraIcons.SetCastByPlayers = Icons_SetCastByPlayers
    auraIcons.SetCastByNPC = Icons_SetCastByNPC
    auraIcons.SetNonPersonal = Icons_SetNonPersonal
    auraIcons.SetPersonal = Icons_SetPersonal
    auraIcons.SetDispellable = Icons_SetUseDispellable
    auraIcons.SetRaid = Icons_SetRaid
    auraIcons.SetCellRaidDebuffs = Icons_SetCellRaidDebuffs
    auraIcons.ShowDuration = Icons_ShowDuration

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

        icons.Update(button)
    end

    auraIcons:ShowDuration(true)
    auraIcons:ShowAnimation(true)
    auraIcons:ShowStack(true)

    auraIcons.Enable = Enable
    auraIcons.Disable = Disable
    if type == "buffs" then
        auraIcons.Update = UpdateAuras_Buffs
    else
        auraIcons.Update = UpdateAuras_Debuffs
    end
    auraIcons.UpdateTempEnchantListener = UpdateTempEnchantListener

    return auraIcons
end

---@param button CUFUnitButton
function W:CreateBuffs(button)
    button.widgets.buffs = W:CreateAuraIcons(button, const.WIDGET_KIND.BUFFS)
end

---@param button CUFUnitButton
function W:CreateDebuffs(button)
    button.widgets.debuffs = W:CreateAuraIcons(button, const.WIDGET_KIND.DEBUFFS)
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.BUFFS, W.CreateBuffs)
W:RegisterCreateWidgetFunc(const.WIDGET_KIND.DEBUFFS, W.CreateDebuffs)

-------------------------------------------------
-- MARK: Cell typing
-------------------------------------------------
---@class CellAuraIcon: Frame, BackdropTemplate
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
---@field PostUpdate fun(self: CellAuraIcon, auraDate: AuraData) Icon_PostUpdate
---@field cooldown StatusBar
---@field GetCooldownDuration function
---@field ShowCooldown function
---@field tex Texture
---@field index number
---@field preview CellAuraIcon.preview
---@field showDuration boolean
---@field _showDuration boolean
---@field __glowing string?

---@class CellAuraIcons: Frame
---@field indicatorType "icons"
---@field numPerLine number
---@field spacingX number
---@field spacingY number
---@field _SetSize function
---@field SetSize fun(icons: CellAuraIcons, width: number, height: number) Icons_SetSize
---@field _Hide function
---@field Hide fun(icons: CellAuraIcons, hideAll: boolean?) Icons_Hide
---@field UpdateSize fun(icons: CellAuraIcons, numAuras: number) Icons_UpdateSize
---@field SetOrientation fun(icons: CellAuraIcons, orientation: GrowthOrientation) Icons_SetOrientation
---@field SetSpacing fun(icons: CellAuraIcons, spacing: CellSizeOpt) Icons_SetSpacing
---@field SetNumPerLine fun(icons: CellAuraIcons, numPerLine: number) Icons_SetNumPerLine
---@field ShowDuration fun(icons: CellAuraIcons, show: boolean) Icons_ShowDuration
---@field ShowStack fun(icons: CellAuraIcons, show: boolean) Icons_ShowStack
---@field ShowAnimation fun(icons: CellAuraIcons, show: boolean) Icons_ShowAnimation
---@field UpdatePixelPerfect function
---@field [number] CellAuraIcon
---@field hidePersonal boolean
---@field hideExternal boolean
---@field hideNoDuration boolean
---@field maxDuration number|boolean
---@field minDuration number|boolean
---@field blacklist table<number, boolean>
---@field whitelist table<number, boolean>
---@field whiteListPriority boolean
---@field useBlacklist boolean
---@field useWhitelist boolean
---@field boss boolean
---@field castByPlayers boolean
---@field castByNPC boolean
---@field notDispellable boolean
---@field Dispellable boolean
---@field nonPersonal boolean
---@field personal boolean
---@field dispellable boolean
---@field raid boolean
---@field cellRaidDebuffs boolean?
