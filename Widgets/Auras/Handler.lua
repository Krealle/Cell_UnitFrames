---@class CUF
local CUF = select(2, ...)

---@class CUF.uFuncs
local U = CUF.uFuncs

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
-- MARK: HandleAura
-------------------------------------------------

---@param icon CellAuraIcons
---@param auraData AuraData?
local function HandleAura(icon, auraData)
    if not auraData then return end

    --TODO: Filter prio?

    -- Blacklist / Whitelist Check
    local spellId = auraData.spellId

    if icon.useBlacklist and icon.blacklist[spellId] then return end
    if icon.useWhitelist and not icon.whitelist[spellId] then return end

    -- Duration Check
    local duration = auraData.duration

    if icon.hideNoDuration and duration == 0 then return end
    if icon.minDuration and duration < icon.minDuration then return end
    if icon.maxDuration and duration > icon.maxDuration then return end

    -- Personal / External Check
    if icon.hidePersonal and auraData.sourceUnit == "player" then return end
    if icon.hideExternal and auraData.sourceUnit ~= "player" then return end

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
-- MARK: ShouldUpdateAuras
-------------------------------------------------

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

-------------------------------------------------
-- MARK: UpdateAuraIcons
-------------------------------------------------

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

-------------------------------------------------
-- MARK: UnitFrame_UpdateAuras
-------------------------------------------------

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
