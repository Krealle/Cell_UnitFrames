---@class CUF
local CUF = select(2, ...)

---@class CUF.Locales
local L = Cell.L
CUF.L = L

-- Forwards from Cell
L.invertColor = L["Invert Color"]
L.dispels = L["Dispels"]

-- Tabs
L.unitFramesTab = "Unit Frames"
L.generalTab = "General"
L.colorTab = "Colors"

L.MasterLayout = "Master Layout"
L.CUFLayoutMasterNone = "|cffffb5c5None|r"
L.MasterLayoutTooltip = [[The layout to use for |cFFFFD700Cell UnitFrames|r.

Selecting a specific layout will always use that layout
regardless of |cFFFFD700Cell|r Auto Switch settings.

Selecting |cffffb5c5None|r will Auto Switch to use the
currently active layout in |cFFFFD700Cell|r.]]

L.CopyLayoutFrom = "Copy Layout From"
L.CopyFromTooltip = [[|cFFFF0000This will overwrite all settings in the current layout!|r

Copy settings from another layout]]
L.CopyFromPopUp = "Copy settings from %s to %s?"

L.CopyWidgetsFrom = "Copy Widgets From"
L.CopyWidgetsFromTooltip = "Copy widget settings from another unit"
L.Backups = "Backups"
L.RestoreBackup = "Restore Backup"
L.RestoreBackupTooltip = [[Restores a backup of Cell UnitFrame settings

%s

%s]]
L.BackupInfo = [[%s created: %s
Layouts: %s]]
L.CreateBackup = "Create Backup"
L.CreateBackupTooltip = [[Creates a backup of Cell UnitFrame settings for these layouts:
%s]]
L.CreateBackupPopup = [[Create a backup for these layouts?
%s]]
L.BackupOverwrite = [[This will overwrite your previous backup:
%s]]
L.RestoreBackupPopup = [[Restore this backup?
%s]]

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
L.WhiteListPriority = "Sort by Priority"

L.PersonalTooltip = "Show auras cast by you"
L.NonPersonalTooltip = "Show auras not cast by you"
L.BossTooltip = "Show auras cast by bosses"
L.CastByPlayersTooltip = "Show auras cast by players"
L.CastByNPCTooltip = "Show auras cast by NPCs"
L.HideNoDurationTooltip = "Hide auras with no duration"
L.HideInCombatTooltip = "Hide tooltips in combat"
L.WhiteListPriorityTooltip = [[Use priority sorting for Whitelist

The priority goes from top of the list to the bottom]]

L.OverrideImportTooltip = "Will override the current list"
L.AdditiveImportTooltip = "Will add to the current list"

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
L.hidden = "Hidden"
L.ShowSpell = "Show Spell"
L.Empower = "Empower"
L.FullyCharged = "Fully Charged"
L.UseFullyCharged = "Use Fully Charged"
L.ShowEmpowerName = "Show Empower Name"
L.ShowBorder = "Show Border"
L.ShowIcon = "Show Icon"
L.Zoom = "Zoom"

L.UseFullyChargedTooltip = "Use fully charged color for the final stage"
L.ShowEmpowerNameTooltip = "Show the spell name for Empowers"

-- Name Format
L.NameFormats = "Name Formats"

L.fullName = "Full Name"
L.lastName = "Last Name"
L.firstName = "First Name"
L.firstNameLastInitial = "First Name Last Initial"
L.firstInitialLastName = "First Initial Last Name"

L.fullName_Example = "Cleave Training Dummy"
L.lastName_Example = "Dummy"
L.firstName_Example = "Cleave"
L.firstNameLastInitial_Example = "Cleave D."
L.firstInitialLastName_Example = "C. Dummy"

-- Widgets
L.Widgets = "Widgets"
L.nameText = "Name Text"
L.healthText = "Health Text"
L.powerText = "Power Text"
L.customText = "Custom Text"
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
L.classBar = "Class Bar"
L.healthBar = "Health Bar"
L.healAbsorb = "Heal Absorb"

-- Misc
L.Frame = "Frame"
L.UnitFrames = "Unit Frames"
L.RelativeTo = "Relative To"
L.Texture = "Texture"
L["left"] = "Left"
L["right"] = "Right"
L.CreatedAutomaticBackup = "New version detected. Created backups for:"
L.CreatedManualBackup = "Created manual backups for:"
L.Backup_manual = "Manual Backup"
L.Backup_automatic = "Automatic Backup"
L.HideDefaultCastBar = "Hide Default Cast Bar"
L.HideDefaultCastBarTooltip = [[Hides the default cast bar.
Reload to show it again after disabling this option.]]
L.texture = "Texture"
L.VerticalFill = "Vertical Fill"
L.SameSizeAsHealthBar = "Same Size As Health Bar"
L.EditingLayout = "Editing Layout"
L.MirrorPlayer = "Mirror Player"
L.Positioning = "Positioning"
L.EditMode = "Edit Mode"
L.ToggleEditMode = "Toggle Edit Mode"
L.EditModeButtonTooltip = [[Edit mode allows you to position the Unit Frames.

Clicking on a Unit Frame will bring up more options.

"/cuf edit" will also toggle this mode.]]
L.HideIfEmpty = "Hide if Empty"
L.HideIfFull = "Hide if Full"
L.ShowDeadStatus = "Show Dead Status"
L.ShowDeadStatusTooltip = [[Show "Dead" instead of 0.]]

L.CellEditMode = "Cell Frames"
L.CellEditModeTip = "(Previews won't dynamically update)"
L.Override = "Override"
L.Additive = "Additive"
L.PowerFilter = "Power Filter"
L.PowerFilterTooltip = "Enable to use 'Power Bar Filters' from Cell"

-- Custom Formats
L.ValidTags = "Valid Tags"
L.TagHintButtonTooltip = "Click to see available tags"
L.TagTooltipsTitle = "Available Tags"

L.rare = "Rare"
L.rareelite = "Rare Elite"
L.elite = "Elite"
L.worldboss = "Boss"

L["tag_curhp"] = "Displays the current HP."
L["tag_curhp:short"] = "Displays the current HP as a shortvalue."
L["tag_perhp"] = "Displays the current HP as a percentage."
L["tag_perhp:short"] = "Displays the current HP percentage without decimals."

L["tag_maxhp"] = "Displays the maximum HP."
L["tag_maxhp:short"] = "Displays the maximum HP as a shortvalue."

L["tag_abs"] = "Displays the current amount of absorbs."
L["tag_abs:short"] = "Displays absorbs as a shortvalue."
L["tag_perabs"] = "Displays absorbs as a percentage."
L["tag_perabs:short"] = "Displays absorb percentage without decimals."

L["tag_curhp:abs"] = "Displays current HP and absorbs."
L["tag_curhp:abs:short"] = "Displays current HP and absorbs as shortvalue."
L["tag_perhp:perabs"] = "Displays current HP and absorbs as percentages."
L["tag_perhp:perabs:short"] = "Displays HP and absorbs as percentages without decimals."

L["tag_curhp:abs:merge"] = "Displays the sum of current HP and absorbs."
L["tag_curhp:abs:merge:short"] = "Displays summed HP and absorbs as a shortvalue."
L["tag_perhp:perabs:merge"] = "Displays the total HP and absorbs as a percentage."
L["tag_perhp:perabs:merge:short"] = "Displays total HP and absorbs as a percentage without decimals."

L["tag_defhp"] = "Displays the current HP deficit."
L["tag_defhp:short"] = "Displays HP deficit as a shortvalue."
L["tag_perdefhp"] = "Displays the HP deficit as a percentage."
L["tag_perdefhp:short"] = "Displays HP deficit percentage without decimals."

L["tag_healabs"] = "Displays the amount of heal absorbs."
L["tag_healabs:short"] = "Displays heal absorbs as a shortvalue."
L["tag_perhealabs"] = "Displays heal absorbs as a percentage."
L["tag_perhealabs:short"] = "Displays heal absorb percentage without decimals."

L["tag_curpp"] = "Displays the current power."
L["tag_curpp:short"] = "Displays the current power as a shortvalue."
L["tag_perpp"] = "Displays the current power as a percentage."
L["tag_perpp:short"] = "Displays power percentage without decimals."

L["tag_maxpp"] = "Displays the maximum power."
L["tag_maxpp:short"] = "Displays the maximum power as a shortvalue."

L["tag_defpp"] = "Displays the power deficit."
L["tag_defpp:short"] = "Displays power deficit as a shortvalue."
L["tag_perdefpp"] = "Displays the power deficit as a percentage."
L["tag_perdefpp:short"] = "Displays power deficit percentage without decimals."

L["tag_classification"] = "Displays the classification of the unit."

L["tag_group"] = "Displays the subgroup of the unit."
L["tag_group:raid"] = "Displays the subgroup of the unit. Only shows in raid."

L["tag_name"] = "Displays the name of the unit."
L["tag_name:veryshort"] = "Displays the name of the unit (max 5 characters)"
L["tag_name:short"] = "Displays the name of the unit (max 10 characters)"
L["tag_name:medium"] = "Displays the name of the unit (max 15 characters)"
L["tag_name:long"] = "Displays the name of the unit (max 20 characters)"
L["tag_name:abbrev"] = "Displays the name of the unit with abbreviations."
L["tag_name:abbrev:veryshort"] = "Displays the name of the unit with abbreviations (max 5 characters)"
L["tag_name:abbrev:short"] = "Displays the name of the unit with abbreviations (max 10 characters)"
L["tag_name:abbrev:medium"] = "Displays the name of the unit with abbreviations (max 15 characters)"
L["tag_name:abbrev:long"] = "Displays the name of the unit with abbreviations (max 20 characters)"

L["tag_target"] = "Displays the name of the unit's target."
L["tag_target:veryshort"] = "Displays the name of the unit's target (max 5 characters)"
L["tag_target:short"] = "Displays the name of the unit's target (max 10 characters)"
L["tag_target:medium"] = "Displays the name of the unit's target (max 15 characters)"
L["tag_target:long"] = "Displays the name of the unit's target (max 20 characters)"
L["tag_target:abbrev"] = "Displays the name of the unit's target with abbreviations."
L["tag_target:abbrev:veryshort"] = "Displays the name of the unit's target with abbreviations (max 5 characters)"
L["tag_target:abbrev:short"] = "Displays the name of the unit's target with abbreviations (max 10 characters)"
L["tag_target:abbrev:medium"] = "Displays the name of the unit's target with abbreviations (max 15 characters)"
L["tag_target:abbrev:long"] = "Displays the name of the unit's target with abbreviations (max 20 characters)"

L["tag_classcolor"] = "Set the text color to the class color of the unit."
L["tag_classcolor:target"] = "Set the text color to the class color of the unit's target."

-- Colors
L.color = "Color"
L.stageZero = "Stage 0"
L.stageOne = "Stage 1"
L.stageTwo = "Stage 2"
L.stageThree = "Stage 3"
L.stageFour = "Stage 4"
L.fullyCharged = "Fully Charged"
L.background = "Background"
L.interruptible = "Interruptible"
L.nonInterruptible = "Non-Interruptible"
L.holyPower = "Holy Power"
L.arcaneCharges = "Arcane Charges"
L.soulShards = "Soul Shards"
L.runes = "Runes"
L.bloodRune = "Blood Rune"
L.frostRune = "Frost Rune"
L.unholyRune = "Unholy Rune"
L.charged = "Charged"
L.comboPoints = "Combo Points"
L.chi = "Chi"
L.essence = "Essence"
L.classResources = "Class Resources"
L.useClassColorForPet = "Use Class Color for Pet"
L.overShield = "Overshield"
L.overAbsorb = "Overabsorb"
L.hostileUnits = "Hostile Units"
L.swapHostileHealthAndLossColors = "Swap Health and Health Loss Colors"

L.reaction = "Reaction"
L.friendly = "Friendly"
L.hostile = "Hostile"
L.neutral = "Neutral"

L.ImportExportColors = "Import & Export Color Settings"

-- Help Tips
L.HelpTip_EditModeToggle = "Click here to position Unit Frames"
L.HelpTip_EditModeOverlay = [[Drag to reposition the Unit Frame.

Click for more options.]]
L.HelpTip_TagHintButton = "Click here to see available tags"
