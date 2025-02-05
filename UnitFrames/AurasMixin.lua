---@class CUF
local CUF = select(2, ...)

local LibDispel = LibStub("LibDispel")

---@class CUF.Mixin
local Mixin = CUF.Mixin

local const = CUF.constants

local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local ForEachAura = AuraUtil.ForEachAura
local wipe = table.wipe

---@class CUFUnitButton
local AurasMixin = {}
Mixin.AurasMixin = AurasMixin

AurasMixin._auraBuffCache = {}
AurasMixin._auraDebuffCache = {}
AurasMixin._auraBuffCallbacks = {}
AurasMixin._auraDebuffCallbacks = {}

AurasMixin._ignoreBuffs = true
AurasMixin._ignoreDebuffs = true

---@param dispelName string?
---@param spellID number
---@return string
local function CheckDebuffType(dispelName, spellID)
    return LibDispel:GetDispelType(spellID, dispelName)
end

function AurasMixin:ResetAuraTables()
    wipe(self._auraBuffCache)
    wipe(self._auraDebuffCache)

    if not self:HasWidget(const.WIDGET_KIND.BUFFS) then return end
    wipe(self.widgets.buffs._auraCache)
    wipe(self.widgets.debuffs._auraCache)
end

--- Processes an aura and returns the type of aura
--- Returns None if the aura should be be ignored
---@param aura AuraData
---@param ignoreBuffs boolean
---@param ignoreDebuffs boolean
---@param unit UnitToken
---@return AuraUtil.AuraUpdateChangedType
local function ProcessAura(aura, ignoreBuffs, ignoreDebuffs, unit)
    if aura == nil then
        return AuraUtil.AuraUpdateChangedType.None;
    end

    if aura.isNameplateOnly then
        return AuraUtil.AuraUpdateChangedType.None;
    end

    if aura.isHarmful and not ignoreDebuffs then
        aura.dispelName = CheckDebuffType(aura.dispelName, aura.spellId)
        aura.isDispellable = LibDispel:IsDispelable(unit, aura.spellId, aura.dispelName, true)

        if aura.dispelName ~= "" and aura.dispelName ~= "none" then
            return AuraUtil.AuraUpdateChangedType.Dispel
        end

        return AuraUtil.AuraUpdateChangedType.Debuff
    elseif aura.isHelpful and not ignoreBuffs then
        aura.dispelName = CheckDebuffType(aura.dispelName, aura.spellId)
        aura.isDispellable = LibDispel:IsDispelable(unit, aura.spellId, aura.dispelName, false)

        return AuraUtil.AuraUpdateChangedType.Buff
    end

    return AuraUtil.AuraUpdateChangedType.None;
end

--- Perform a full aura update for a unit
---@param ignoreBuffs boolean
---@param ignoreDebuffs boolean
---@param unit UnitToken
function AurasMixin:ParseAllAuras(ignoreBuffs, ignoreDebuffs, unit)
    wipe(self._auraBuffCache)
    wipe(self._auraDebuffCache)

    local batchCount = nil
    local usePackedAura = true
    ---@param aura AuraData
    local function HandleAura(aura)
        local type = ProcessAura(aura, ignoreBuffs, ignoreDebuffs, unit)
        if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
            self._auraDebuffCache[aura.auraInstanceID] = aura
        elseif type == AuraUtil.AuraUpdateChangedType.Buff then
            self._auraBuffCache[aura.auraInstanceID] = aura
        end
    end

    if not ignoreDebuffs then
        ForEachAura(self.states.unit, AuraUtil.AuraFilters.Harmful, batchCount,
            HandleAura,
            usePackedAura)
    end
    if not ignoreBuffs then
        ForEachAura(self.states.unit, AuraUtil.AuraFilters.Helpful, batchCount,
            HandleAura,
            usePackedAura)
    end
end

--- Process UNIT_AURA events and update aura caches
--- This function is called either on UNIT_AURA event or from UnitFrame_UpdateAll
--- Will only trigger if auras are not ignored
---@param event "UNIT_AURA"?
---@param unit UnitToken?
---@param unitAuraUpdateInfo UnitAuraUpdateInfo?
function AurasMixin:UpdateAurasInternal(event, unit, unitAuraUpdateInfo)
    self._auraUpdateRequired = nil
    if self._ignoreBuffs and self._ignoreDebuffs then return end
    unit = unit or self.states.unit

    local debuffsChanged = false
    local buffsChanged = false
    local dispelsChanged = false
    local stealableChanged = false
    local fullUpdate = false

    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
        self:ParseAllAuras(self._ignoreBuffs, self._ignoreDebuffs, unit)
        debuffsChanged = true
        buffsChanged = true
        dispelsChanged = true
        stealableChanged = true
        fullUpdate = true
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                local type = ProcessAura(aura, self._ignoreBuffs, self._ignoreDebuffs, unit)

                if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
                    self._auraDebuffCache[aura.auraInstanceID] = aura
                    debuffsChanged = true
                    dispelsChanged = dispelsChanged or type == AuraUtil.AuraUpdateChangedType.Dispel
                elseif type == AuraUtil.AuraUpdateChangedType.Buff then
                    self._auraBuffCache[aura.auraInstanceID] = aura
                    buffsChanged = true
                    stealableChanged = stealableChanged or aura.isDispellable
                end
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self._auraDebuffCache[auraInstanceID] ~= nil then
                    local newAura = GetAuraDataByAuraInstanceID(self.states.unit, auraInstanceID)
                    if newAura then
                        newAura.dispelName = CheckDebuffType(newAura.dispelName, newAura.spellId)
                        dispelsChanged = dispelsChanged or newAura.dispelName ~= "none"
                    else
                        dispelsChanged = dispelsChanged or self._auraDebuffCache[auraInstanceID].dispelName ~= "none"
                    end
                    self._auraDebuffCache[auraInstanceID] = newAura
                    debuffsChanged = true
                elseif self._auraBuffCache[auraInstanceID] ~= nil then
                    local newAura = GetAuraDataByAuraInstanceID(self.states.unit, auraInstanceID)
                    if newAura then
                        stealableChanged = stealableChanged or newAura.isDispellable
                    else
                        stealableChanged = stealableChanged or self._auraBuffCache[auraInstanceID].isDispellable
                    end
                    self._auraBuffCache[auraInstanceID] = newAura
                    buffsChanged = true
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self._auraDebuffCache[auraInstanceID] ~= nil then
                    dispelsChanged = dispelsChanged or self._auraDebuffCache[auraInstanceID].dispelName ~= "none"
                    self._auraDebuffCache[auraInstanceID] = nil
                    debuffsChanged = true
                elseif self._auraBuffCache[auraInstanceID] ~= nil then
                    stealableChanged = stealableChanged or self._auraBuffCache[auraInstanceID].isDispellable
                    self._auraBuffCache[auraInstanceID] = nil
                    buffsChanged = true
                end
            end
        end
    end

    self:TriggerAuraCallbacks(buffsChanged, debuffsChanged, dispelsChanged, fullUpdate, stealableChanged)
end

--- Queues an aura update
--- Used to prevent aura update spam
--- Mostly relevant when full updating widgets since they will all ask for aura update
function AurasMixin:QueueAuraUpdate()
    if not self:IsVisible() then return end
    if self._ignoreBuffs and self._ignoreDebuffs then return end
    self._auraUpdateRequired = true
end

--- Triggers aura callbacks
---@param buffsChanged boolean
---@param debuffsChanged boolean
---@param dispelsChanged boolean
---@param fullUpdate boolean
---@param stealableChanged boolean
function AurasMixin:TriggerAuraCallbacks(buffsChanged, debuffsChanged, dispelsChanged, fullUpdate, stealableChanged)
    --CUF:Log("TriggerAuraCallbacks", self.states.unit, buffsChanged, debuffsChanged, fullUpdate)
    if not buffsChanged and not debuffsChanged and not fullUpdate then
        return
    end

    if buffsChanged then
        for _, callback in pairs(self._auraBuffCallbacks) do
            callback(self, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate, stealableChanged)
        end
    end
    if debuffsChanged then
        for _, callback in pairs(self._auraDebuffCallbacks) do
            callback(self, buffsChanged, debuffsChanged, dispelsChanged, fullUpdate, stealableChanged)
        end
    end
end

--- Iterates over all auras of a specific type
--- Return true to stop iteration
---@param type "buffs" | "debuffs"
---@param fn fun(aura: AuraData, ...): true?
function AurasMixin:IterateAuras(type, fn, ...)
    if type == "buffs" then
        for _, aura in pairs(self._auraBuffCache) do
            if fn(aura, ...) then return end
        end
    elseif type == "debuffs" then
        for _, aura in pairs(self._auraDebuffCache) do
            if fn(aura, ...) then return end
        end
    end
end

--- Registers a callback for auras of a specific type
--- This function will automatically add UNIT_AURA event listener if it is not already added
---@param type "buffs" | "debuffs"
---@param callback UnitAuraCallbackFn
function AurasMixin:RegisterAuraCallback(type, callback)
    local listenerActive = #self._auraBuffCallbacks > 0 or #self._auraDebuffCallbacks > 0
    if not listenerActive then
        self:AddEventListener("UNIT_AURA", self.UpdateAurasInternal)
    end

    if type == "buffs" then
        table.insert(self._auraBuffCallbacks, callback)
        self._ignoreBuffs = false
    elseif type == "debuffs" then
        table.insert(self._auraDebuffCallbacks, callback)
        self._ignoreDebuffs = false
    end

    self:UpdateAurasInternal("UNIT_AURA", self.states.unit)
end

--- Unregister a callback for auras of a specific type
--- This function will automatically remove UNIT_AURA event listener if no more callbacks are registered
---@param type "buffs" | "debuffs"
---@param callback function
function AurasMixin:UnregisterAuraCallback(type, callback)
    if type == "buffs" then
        for i, cb in ipairs(self._auraBuffCallbacks) do
            if cb == callback then
                table.remove(self._auraBuffCallbacks, i)
                break
            end
        end
    elseif type == "debuffs" then
        for i, cb in ipairs(self._auraDebuffCallbacks) do
            if cb == callback then
                table.remove(self._auraDebuffCallbacks, i)
                break
            end
        end
    end

    self._ignoreBuffs = #self._auraBuffCallbacks == 0
    self._ignoreDebuffs = #self._auraDebuffCallbacks == 0

    if self._ignoreBuffs then
        wipe(self._auraBuffCache)
    end
    if self._ignoreDebuffs then
        wipe(self._auraDebuffCache)
    end

    -- If no more callbacks are registered, remove the event listener
    if self._ignoreBuffs and self._ignoreDebuffs then
        self:RemoveEventListener("UNIT_AURA", self.UpdateAurasInternal)
    end
end

---@alias UnitAuraCallbackFn fun(self: CUFUnitButton, buffsChanged: boolean, debuffsChanged: boolean, dispelsChanged: boolean, fullUpdate: boolean, stealableChanged: boolean)
