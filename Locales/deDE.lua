if not (GAME_LOCALE or GetLocale() == "deDE") then return end
---@class CUF
local CUF = select(2, ...)

local L = CUF.L

-- Xeph did not approve so all of this needs a rewrite

-- Units
-- L.targettarget = "ZielZiel"
-- L.player = "Spieler"
-- L.pet = "Haustier"
-- L.focus = "Fokus"
-- L.target = "Ziel"

-- Auras
-- L.MaxDuration = "Maximale Dauer"
-- L.MinDuration = "Minimale Dauer"
-- L.HideNoDuration = "Keine Dauer verbergen"
-- L.UseBlacklist = "Blacklist verwenden"
-- L.UseWhitelist = "Whitelist verwenden"
-- L.Personal = "Persönlich"
-- L.NonPersonal = "Nicht Persönlich"
-- L.Boss = "Boss"
-- L.CastByPlayers = "Von Spielern abgespielt"
-- L.CastByNPC = "Von NPC abgespielt"
-- L.blacklist = "Blacklist"
-- L.whitelist = "Whitelist"

-- L.PersonalTooltip = "Zeige Aura, die von dir abgespielt wurden"
-- L.NonPersonalTooltip = "Zeige Aura, die nicht von dir abgespielt wurden"
-- L.BossTooltip = "Zeige Aura, die von Bossen abgespielt wurden"
-- L.CastByPlayersTooltip = "Zeige Aura, die von Spielern abgespielt wurden"
-- L.CastByNPCTooltip = "Zeige Aura, die von NPC abgespielt wurden"
-- L.HideNoDurationTooltip = "Verberge Aura mit keiner Dauer"

-- Widgets
-- L.Widgets = "Widgets"
-- L.nameText = "Name Text"
-- L.healthText = "Gesundheit Text"
-- L.powerText = "Kraft Text"
-- L.buffs = "Buffs"
-- L.debuffs = "Debuffs"
-- L.raidIcon = "Raid Icon"
-- L.roleIcon = "Rollen Icon"
-- L.leaderIcon = "Leader Icon"
-- L.combatIcon = "Kampf Icon"
-- L.shieldBar = "Schild Bar"
-- L.levelText = "Level Text"

-- Misc
-- L.Frame = "Frame"
-- L.UnitFrames = "Einheiten"
-- L.RelativeTo = "Relativ zu"

-- Custom Formats
-- L.ValidTags = "Gültige Tags"

-- L["cur"] = "Anzeige der aktuellen Menge."
-- L["cur:short"] = "Anzeige der aktuellen Menge als Kurzwert."
-- L["cur:per"] = "Anzeige der aktuellen Menge als Prozent."
-- L["cur:per-short"] = "Anzeige der aktuellen Menge als Prozent ohne Dezimalstellen."

-- L["max"] = "Anzeige der maximalen Menge."
-- L["max:short"] = "Anzeige der maximalen Menge als Kurzwert."

-- L["abs"] = "Anzeige der Menge an Absorbs."
-- L["abs:short"] = "Anzeige der Menge an Absorbs als Kurzwert."
-- L["abs:per"] = "Anzeige der Menge an Absorbs als Prozent."
-- L["abs:per-short"] = "Anzeige der Menge an Absorbs als Prozent ohne Dezimalstellen."

-- L["cur:abs"] = "Anzeige der aktuellen Menge und Absorbs."
-- L["cur:abs-short"] = "Anzeige der aktuellen Menge und Absorbs als Kurzwerte."
-- L["cur:abs:per"] = "Anzeige der aktuellen Menge und Absorbs als Prozent."
-- L["cur:abs:per-short"] = "Anzeige der aktuellen Menge und Absorbs als Prozent ohne Dezimalstellen."

-- L["cur:abs:merge"] = "Anzeige der Summe der aktuellen Menge und Absorbs."
-- L["cur:abs:merge:short"] = "Anzeige der Summe der aktuellen Menge und Absorbs als Kurzwert."
-- L["cur:abs:merge:per"] = "Anzeige der Summe der aktuellen Menge und Absorbs als Prozent."
-- L["cur:abs:merge:per-short"] = "Anzeige der Summe der aktuellen Menge und Absorbs als Prozent ohne Dezimalstellen."

-- L["def"] = "Anzeige des Deficits."
-- L["def:short"] = "Anzeige des Deficits als Kurzwert."
-- L["def:per"] = "Anzeige des Deficits als Prozent."
-- L["def:per-short"] = "Anzeige des Deficits als Prozent ohne Dezimalstellen."
