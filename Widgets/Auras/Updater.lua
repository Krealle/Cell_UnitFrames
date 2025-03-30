---@class CUF
local CUF = select(2, ...)

local const = CUF.constants
local DB = CUF.DB
local P = CUF.PixelPerfect

---@class CUF.widgets
local W = CUF.widgets

---@param button CUFUnitButton
---@param unit Unit
---@param which "buffs" | "debuffs"
---@param setting AURA_OPTION_KIND
---@param subSetting string
function W.UpdateAuraWidget(button, unit, which, setting, subSetting, ...)
    ---@type CellAuraIcons
    local auras = button.widgets[which]

    local styleTable = DB.GetCurrentWidgetTable(which, unit) --[[@as AuraWidgetTable]]

    if not setting or setting == const.AURA_OPTION_KIND.FONT or const.AURA_OPTION_KIND.POSITION then
        auras:SetFont(styleTable.font)
    end
    if not setting or setting == const.AURA_OPTION_KIND.ORIENTATION then
        auras:SetOrientation(styleTable.orientation)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SIZE then
        P.Size(auras, styleTable.size.width, styleTable.size.height)
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
    if not setting or (setting == const.AURA_OPTION_KIND.SHOW_TOOLTIP or setting == const.AURA_OPTION_KIND.HIDE_IN_COMBAT) then
        auras:ShowTooltip(styleTable.showTooltip, styleTable.hideInCombat)
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
    if not setting or setting == const.AURA_OPTION_KIND.FILTER then
        if not subSetting or subSetting == "hideNoDuration" then
            auras:SetHideNoDuration(styleTable.filter.hideNoDuration)
        end
        if not subSetting or subSetting == "maxDuration" then
            auras:SetMaxDuration(styleTable.filter.maxDuration)
        end
        if not subSetting or subSetting == "minDuration" then
            auras:SetMinDuration(styleTable.filter.minDuration)
        end
        if not subSetting or subSetting == "blacklist" then
            auras:SetBlacklist(styleTable.filter.blacklist)
        end
        if not subSetting or subSetting == "whitelist" then
            auras:SetWhitelist(styleTable.filter.whitelist)
        end
        if not subSetting or subSetting == "useBlacklist" then
            auras:SetUseBlacklist(styleTable.filter.useBlacklist)
        end
        if not subSetting or subSetting == "useWhitelist" then
            auras:SetUseWhitelist(styleTable.filter.useWhitelist)
        end
        if not subSetting or subSetting == "boss" then
            auras:SetBoss(styleTable.filter.boss)
        end
        if not subSetting or subSetting == "castByPlayers" then
            auras:SetCastByPlayers(styleTable.filter.castByPlayers)
        end
        if not subSetting or subSetting == "castByNPC" then
            auras:SetCastByNPC(styleTable.filter.castByNPC)
        end
        if not subSetting or subSetting == "nonPersonal" then
            auras:SetNonPersonal(styleTable.filter.nonPersonal)
        end
        if not subSetting or subSetting == "personal" then
            auras:SetPersonal(styleTable.filter.personal)
        end
        if not subSetting or subSetting == "personal" then
            auras:SetPersonal(styleTable.filter.personal)
        end
        if not subSetting or subSetting == const.AURA_OPTION_KIND.DISPELLABLE then
            auras:SetDispellable(styleTable.filter.dispellable)
        end
        if not subSetting or subSetting == const.AURA_OPTION_KIND.RAID then
            auras:SetRaid(styleTable.filter.raid)
        end
        if not subSetting or subSetting == const.AURA_OPTION_KIND.CELL_RAID_DEBUFFS then
            auras:SetCellRaidDebuffs(styleTable.filter.cellRaidDebuffs)
        end
        if not subSetting or subSetting == const.AURA_OPTION_KIND.WHITE_LIST_PRIORITY then
            auras:SetWhiteListPriority(styleTable.filter.whiteListPriority)
        end
        if not subSetting or subSetting == const.AURA_OPTION_KIND.TEMP_ENCHANT then
            auras:SetShowTempEnchant(styleTable.filter.tempEnchant)
        end
    end

    auras.Update(button)
end
