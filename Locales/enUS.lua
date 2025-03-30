---@class CUF
local CUF = select(2, ...)

---@class CUF.Locales
local L = Cell.L
CUF.L = L

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
L.ColorTypeTooltip = [[|cFFFFD700Cell|r - Uses the appearance settings from |cFFFFD700Cell|r.
Custom Unit Frame colors can be changed in the |cFFFFD700Colors|r tab.]]

L.CUFFrameName = "CUF Frame Name"
L.DummyAnchorName = "Dummy Anchor Name"
L.DummyAnchors = "Dummy Anchors"
L.DummyAnchorsTooltip = [[Create custom-named anchors to match other addons.
Useful for integrating with existing UI elements like WeakAuras.]]

-- Units
L.targettarget = "TargetTarget"
L.player = "Player"
L.pet = "Pet"
L.focus = "Focus"
L.target = "Target"
L.boss = "Boss"

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

L.tempEnchant = "Temporary Enchants"
L.tempEnchantTooltip = "Show temporary enchants"
L.Dispellable = "Dispellable"
L.DispellableTooltip = "Show auras dispellable by you"
L.Raid = "Raid"
L.RaidTooltip = "Show raid auras"
L.CellRaidDebuffsTooltip = "Show Raid Debuffs enabled in Cell"

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
L["remaining-and-max"] = "Remaining & Max"
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

L.OnlyShowInterruptableCast = "Only show interruptable casts"

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
L.totems = "Totems"
L.highlight = "Highlight"
L.altPowerBar = "Alt Power Bar"
L.powerBar = "Power Bar"

-- Misc
L.Frame = "Frame"
L.UnitFrames = "Unit Frames"
L.RelativeTo = "Relative To"
L.Texture = "Texture"
L.left = "Left"
L.right = "Right"
L.top = "Top"
L.bottom = "Bottom"
L.CreatedAutomaticBackup = "New version detected. Created backups for:"
L.CreatedManualBackup = "Created manual backups for:"
L.Backup_manual = "Manual Backup"
L.Backup_automatic = "Automatic Backup"
L.HideDefaultCastBar = "Hide Default Cast Bar"
L.HideDefaultCastBarTooltip = [[Hides the default cast bar.
Reload to show it again after disabling this option.]]
L.texture = "Texture"
L.VerticalFill = "Vertical Fill"
L.HideOutOfCombat = "Hide Out of Combat"
L.SameSizeAsHealthBar = "Same Size As Health Bar"
L.SameHeightAsHealthBar = "Same Height As Health Bar"
L.SameWidthAsHealthBar = "Same Width As Health Bar"
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
L.Info = "Info"
L.NewVersion = "New Version"
L.GrowthDirection = "Growth Direction"
L.Downwards = "Downwards"
L.Upwards = "Upwards"
L.Fader = "Fader"
L.Combat = "Combat"
L.Hover = "Hover"
L.UnitTarget = "Unit Target"
L.MaxAlpha = "Max Alpha"
L.MinAlpha = "Min Alpha"
L.Range = "Range"
L.FadeDuration = "Fade Duration"
L.PlayerTarget = "Player Target"

L.AlwaysUpdate = "Always Update"
L.AlwaysUpdateUnitFrameTooltip = [[Forces an update every %ss
Can help with issues where the Unit Frame is not updating correctly]]
L.UseScaling = "Use Scaling"
L.UseScalingTooltip = [[Enable to apply the Scale set in |cFFFFD700Cell|r
Reload after toggling to fully update all frames]]
L.buffFrame = "Buff Frame"
L.debuffFrame = "Debuff Frame"
L.playerCastBar = "Player Cast Bar"
L.HideAtMaxLevel = "Hide at Max Level"
L.ShowTarget = "Show Target"
L.Separator = "Separator"
L.TimeToHold = "Time to Hold"
L.TimeToHoldTooltip = "Time in seconds to hold the Cast Bar after the spell has failed or been interrupted"
L.Label = "Label"
L.InterruptedLabelTooltip = [[%s - Type (%s or %s)
%s - Spell Name]]
L.DetachedAnchorEditMode = [[Detached positioning changed in Edit Mode]]
L.FadeInTimer = "Fade In Timer"
L.FadeOutTimer = "Fade Out Timer"
L.Enrage = "Enrage"
L.overHeal = "Over Heal"
L.healthBarTexture = "Health Bar Texture"
L.healthLossTexture = "Health Loss Texture"
L.powerBarTexture = "Power Bar Texture"
L.powerLossTexture = "Power Loss Texture"
L.TextureOverwriteTooltip = "Enable to overwrite texture set in Cell"
L.reverseHealthFill = "Reverse Health Fill"
L.AnchorToPowerBar = "Anchor to Power Bar"
L.Alignment = "Alignment"

-- Custom Formats
L.ValidTags = "Valid Tags"
L.TagHintButtonTooltip = "Click to see available tags"
L.TagTooltipsTitle = "Available Tags"

L.rare = "Rare"
L.rareelite = "Rare Elite"
L.elite = "Elite"
L.worldboss = "Boss"

L.AFK = "AFK"

-- MARK: Tags

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
L["tag_abs:healabs:merge"] = "Displays the current amount of absorbs minus heal absorbs."
L["tag_abs:healabs:merge:short"] = "Displays the current amount of absorbs minus heal absorbs as a shortvalue."

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

L["tag_curmana"] = "Displays the current mana."
L["tag_curmana:short"] = "Displays the current mana as a shortvalue."
L["tag_permana"] = "Displays the current mana as a percentage."
L["tag_permana:short"] = "Displays mana percentage without decimals."

L["tag_maxmana"] = "Displays the maximum mana."
L["tag_maxmana:short"] = "Displays the maximum mana as a shortvalue."

L["tag_defmana"] = "Displays the mana deficit."
L["tag_defmana:short"] = "Displays mana deficit as a shortvalue."
L["tag_perdefmana"] = "Displays the mana deficit as a percentage."
L["tag_perdefmana:short"] = "Displays mana deficit percentage without decimals."

L["tag_curaltmana"] = "Displays the current alt mana."
L["tag_curaltmana:short"] = "Displays the current alt mana as a shortvalue."
L["tag_peraltmana"] = "Displays the current alt mana as a percentage."
L["tag_peraltmana:short"] = "Displays alt mana percentage without decimals."

L["tag_maxaltmana"] = "Displays the maximum alt mana."
L["tag_maxaltmana:short"] = "Displays the maximum alt mana as a shortvalue."

L["tag_defaltmana"] = "Displays the alt mana deficit."
L["tag_defaltmana:short"] = "Displays alt mana deficit as a shortvalue."
L["tag_perdefaltmana"] = "Displays the alt mana deficit as a percentage."
L["tag_perdefaltmana:short"] = "Displays alt mana deficit percentage without decimals."

L["tag_classification"] = "Displays the classification of the unit."
L["tag_classification:icon"] = "Displays the classification of the unit as an icon."

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

L["tag_afk"] = "Displays 'AFK' if the unit is AFK."
L["tag_dead"] = "Displays 'Dead' if the unit is dead."

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
L.overlayTexture = "Overlay Texture"
L.shieldColor = "Shield Color"
L.overshieldColor = "Overshield Color"
L.overlayColor = "Overlay Color"
L.useOverlay = "Use Overlay"
L.overshieldOffset = "Overshield Offset"
L.overshieldReverseOffset = "Overshield Reverse Offset"
L.overshieldSize = "Overshield Size"
L.overAbsorb = "Overabsorb"
L.absorbTexture = "Absorb Texture"
L.overabsorbTexture = "Overabsorb Texture"
L.absorbColor = "Absorb Color"
L.overabsorbColor = "Overabsorb Color"
L.hostileUnits = "Hostile Units"
L.swapHostileHealthAndLossColors = "Swap Health and Health Loss Colors"
L.deathColor = "Death Color"
L.fullColor = "Full Color"
L.powerBarAlpha = "Power Bar Alpha"
L.powerLossAlpha = "Power Loss Alpha"

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
L.HelpTip_BossFramePreview = "When editing %s frames, they will display the %s."
L.HelpTip_BlizzardFramesToggle = "Click here to toggle Blizzard Frames"
