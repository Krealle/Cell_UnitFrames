---@class CUF
local CUF = select(2, ...)

---@class CUF.Locales
local L = Cell.L
CUF.L = L

-- Units
L.targettarget = "TargetTarget"
L.player = "Player"
L.pet = "Pet"
L.focus = "Focus"
L.target = "Target"

-- Auras
L.MaxDuration = "Maximum Duration"
L.MinDuration = "Minimum Duration"
L.HideNoDuration = "Hide No Duration"
L.UseBlacklist = "Use Blacklist"
L.UseWhitelist = "Use Whitelist"
L.Personal = "Personal"
L.NonPersonal = "Non Personal"
L.Boss = "Boss"
L.CastByPlayers = "Cast By Players"
L.CastByNPC = "Cast By NPC"
L.blacklist = "Blacklist"
L.whitelist = "Whitelist"

L.PersonalTooltip = "Show auras cast by you"
L.NonPersonalTooltip = "Show auras not cast by you"
L.BossTooltip = "Show auras cast by bosses"
L.CastByPlayersTooltip = "Show auras cast by players"
L.CastByNPCTooltip = "Show auras cast by NPCs"
L.HideNoDurationTooltip = "Hide auras with no duration"

-- Cast Bar
L.Reverse = "Reverse"
L.Spark = "Spark"
L.Interruptible = "Interruptible"
L.NonInterruptible = "Non-Interruptible"
L.Background = "Background"
L.Reverse = "Reverse"
L.UseClassColor = "Use Class Color"
L.TimerFormat = "Timer Format"
L["normal"] = "Normal"
L["remaining"] = "Remaining"
L["duration"] = "Duration"
L["duration-and-max"] = "Duration & Max"
L.ShowSpell = "Show Spell"
L.Empower = "Empower"
L.Stage = "Stage"
L.FullyCharged = "Fully Charged"
L.UseFullyCharged = "Use Fully Charged"
L.ShowEmpowerName = "Show Empower Name"
L.ShowBorder = "Show Border"
L.ShowIcon = "Show Icon"
L.Zoom = "Zoom"

L.UseFullyChargedTooltip = "Use fully charged color for the final stage"
L.ShowEmpowerNameTooltip = "Show the spell name for Empowers"

-- Name Format
L.fullName = "Full Name"
L.lastName = "Last Name"
L.firstName = "First Name"
L.firstNameLastInitial = "First Name Last Initial"
L.firstInitialLastName = "First Initial Last Name"

-- Widgets
L.Widgets = "Widgets"
L.nameText = "Name Text"
L.healthText = "Health Text"
L.powerText = "Power Text"
L.buffs = "Buffs"
L.debuffs = "Debuffs"
L.raidIcon = "Raid Icon"
L.roleIcon = "Role Icon"
L.leaderIcon = "Leader Icon"
L.combatIcon = "Combat Icon"
L.shieldBar = "Shield Bar"
L.levelText = "Level Text"
L.readyCheckIcon = "Ready Check Icon"
L.restingIcon = "Resting Icon"
L.castBar = "Cast Bar"

-- Misc
L.Frame = "Frame"
L.UnitFrames = "Unit Frames"
L.RelativeTo = "Relative To"
L.Texture = "Texture"
L["left"] = "Left"
L["right"] = "Right"

-- Custom Formats
L.ValidTags = "Valid Tags"

L["cur"] = "Displays the current amount."
L["cur:short"] = "Displays the current amount as a shortvalue."
L["cur:per"] = "Displays the current amount as a percentage."
L["cur:per-short"] = "Displays the current amount as a percentage without decimals."

L["max"] = "Displays the maximum amount."
L["max:short"] = "Displays the maximum amount as a shortvalue."

L["abs"] = "Displays the amount of absorbs."
L["abs:short"] = "Displays the amount of absorbs as a shortvalue."
L["abs:per"] = "Displays the absorbs as a percentage."
L["abs:per-short"] = "Displays the absorbs as a percentage without decimals."

L["cur:abs"] = "Displays the current amount and absorbs."
L["cur:abs-short"] = "Displays the current amount and absorbs as shortvalues."
L["cur:abs:per"] = "Displays the current amount and absorbs as percentages."
L["cur:abs:per-short"] = "Displays the current amount and absorbs as percentages without decimals."

L["cur:abs:merge"] = "Displays the sum of the current amount and absorbs."
L["cur:abs:merge:short"] = "Displays the sum of the current amount and absorbs as a shortvalue."
L["cur:abs:merge:per"] = "Displays the sum of the current amount and absorbs as a percentage."
L["cur:abs:merge:per-short"] = "Displays the sum of the current amount and absorbs as a percentage without decimals."

L["def"] = "Displays the deficit."
L["def:short"] = "Displays the deficit as a shortvalue."
L["def:per"] = "Displays the deficit as a percentage."
L["def:per-short"] = "Displays the deficit as a percentage without decimals."
