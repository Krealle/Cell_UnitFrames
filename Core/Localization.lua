---@class CUF
local CUF = select(2, ...)

---@class CUF.Locales
local L = Cell.L
CUF.L = L

local locale = GAME_LOCALE or GetLocale()

-- Units
L["targettarget"] = "TargetTarget"
L["player"] = "Player"
L["pet"] = "Pet"
L["focus"] = "Focus"
L["target"] = "Target"

-- Auras
L.MaxDuration = "Maximum Duration"
L.MinDuration = "Minimum Duration"
L.HideNoDuration = "Hide No Duration"
L.HidePersonal = "Hide Personal"
L.HideExternal = "Hide External"
L.UseBlacklist = "Use Blacklist"
L.UseWhitelist = "Use Whitelist"

-- Widgets
L.Widgets = "Widgets"
L["nameText"] = "Name Text"
L["healthText"] = "Health Text"
L["powerText"] = "Power Text"
L["buffs"] = "Buffs"
L["debuffs"] = "Debuffs"
L["raidIcon"] = "Raid Icon"
L["roleIcon"] = "Role Icon"
L["leaderIcon"] = "Leader Icon"
L["combatIcon"] = "Combat Icon"
L["shieldBar"] = "Shield Bar"

-- Misc
L.Frame = "Frame"
L["Unit Frames"] = "Unit Frames"
