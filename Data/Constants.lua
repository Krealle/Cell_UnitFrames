---@class CUF
local CUF = select(2, ...)

---@class CUF.constants
local const = CUF.constants

local Util = CUF.Util

--- Called when the addon is loaded
---
--- Used for initializing constants that require Util functions
local function OnAddonLoaded()
    const.NameFormatArray = Util.DictionaryToArray(const.NameFormat)
end

CUF:RegisterCallback("AddonLoaded", "CUF_Constants_OnAddonLoaded", OnAddonLoaded)

---@enum Unit
const.UNIT = {
    PLAYER = "player",
    TARGET = "target",
    FOCUS = "focus",
    PET = "pet",
    TARGET_TARGET = "targettarget",
    BOSS = "boss",
}

---@enum TitleCasedUnits
-- Used for frame titles
const.TITLE_CASED_UNITS = {
    ["player"] = "Player",
    ["target"] = "Target",
    ["focus"] = "Focus",
    ["pet"] = "Pet",
    ["targettarget"] = "TargetTarget",
    ["boss"] = "Boss",
}

-- WORKAROUND https://github.com/Stanzilla/WoWUIBugs/issues/708
-- The game fires events for arenaX when it actually should be sending for boss(X+5)
---@enum BrokenUnitMap
const.BROKEN_UNIT_MAP = {
    arena1 = "boss6",
    arena2 = "boss7",
    arena3 = "boss8",
    arena4 = "boss9",
    arena5 = "boss10"
}

---@enum PowerColorType
const.PowerColorType = {
    CLASS_COLOR = "class_color",
    CUSTOM = "custom",
    POWER_COLOR = "power_color",
}

---@enum HealthColorType
const.ColorType = {
    CLASS_COLOR = "class_color",
    CUSTOM = "custom",
}

---@enum PowerTextFormat
const.PowerTextFormat = {
    PERCENTAGE = "percentage",
    NUMBER = "number",
    NUMBER_SHORT = "number-short",
    CUSTOM = "custom"
}

---@enum HealthTextFormat
const.HealthTextFormat = {
    PERCENTAGE = "percentage",
    NUMBER = "number",
    NUMBER_SHORT = "number-short",
    PERCENTAGE_ABSORBS = "percentage-absorbs",
    PERCENTAGE_ABSORBS_MERGED = "percentage-absorbs-merged",
    PERCENTAGE_DEFICIT = "percentage-deficit",
    NUMBER_ABSORBS_SHORT = "number-absorbs-short",
    NUMBER_ABSORBS_MERGED_SHORT = "number-absorbs-merged-short",
    NUMBER_DEFICIT = "number-deficit",
    NUMBER_DEFICIT_SHORT = "number-deficit-short",
    CURRENT_SHORT_PERCENTAGE = "current-short-percentage",
    ABSORBS_ONLY = "absorbs-only",
    ABSORBS_ONLY_SHORT = "absorbs-only-short",
    ABSORBS_ONLY_PERCENTAGE = "absorbs-only-percentage",
    CUSTOM = "custom",
}

---@enum WIDGET_KIND
const.WIDGET_KIND = {
    NAME_TEXT = "nameText",
    HEALTH_TEXT = "healthText",
    POWER_TEXT = "powerText",
    LEVEL_TEXT = "levelText",
    CUSTOM_TEXT = "customText",
    BUFFS = "buffs",
    DEBUFFS = "debuffs",
    RAID_ICON = "raidIcon",
    ROLE_ICON = "roleIcon",
    LEADER_ICON = "leaderIcon",
    COMBAT_ICON = "combatIcon",
    SHIELD_BAR = "shieldBar",
    READY_CHECK_ICON = "readyCheckIcon",
    RESTING_ICON = "restingIcon",
    CAST_BAR = "castBar",
    CLASS_BAR = "classBar",
    HEAL_ABSORB = "healAbsorb",
    DISPELS = "dispels",
    TOTEMS = "totems",
    FADER = "fader",
    HIGHLIGHT = "highlight",
    ALT_POWER_BAR = "altPowerBar",
    POWER_BAR = "powerBar",
    HEAL_PREDICTION = "healPrediction",
}

---@enum OPTION_KIND
const.OPTION_KIND = {
    ENABLED                   = "enabled",
    POSITION                  = "position",
    FONT                      = "font",
    WIDTH                     = "width",
    TEXT_WIDTH                = "textWidth",
    HEALTH_FORMAT             = "healthFormat",
    POWER_FORMAT              = "powerFormat",
    ORIENTATION               = "orientation",
    FORMAT                    = "format",
    OUTLINE                   = "outline",
    STYLE                     = "style",
    SHADOW                    = "shadow",
    COLOR                     = "color",
    HEIGHT                    = "height",
    SIZE                      = "size",
    FRAMELEVEL                = "frameLevel",
    TEXT_FORMAT               = "textFormat",
    RGB                       = "rgb",
    RGBA                      = "rgba",
    ANCHOR_POINT              = "point",
    RELATIVE_POINT            = "relativePoint",
    OFFSET_X                  = "offsetX",
    OFFSET_Y                  = "offsetY",
    TYPE                      = "type",
    REVERSE                   = "reverse",
    SPARK                     = "spark",
    INTERRUPTIBLE             = "interruptible",
    NON_INTERRUPTIBLE         = "nonInterruptible",
    BACKGROUND                = "background",
    USE_CLASS_COLOR           = "useClassColor",
    TEXTURE                   = "texture",
    TIMER                     = "timer",
    TIMER_FORMAT              = "timerFormat",
    SPELL                     = "spell",
    SHOW_SPELL                = "showSpell",
    EMPOWER                   = "empower",
    PIP_COLORS                = "pipColors",
    USE_FULLY_CHARGED         = "useFullyCharged",
    STAGE_ZERO                = "stageZero",
    STAGE_ONE                 = "stageOne",
    STAGE_TWO                 = "stageTwo",
    STAGE_THREE               = "stageThree",
    STAGE_FOUR                = "stageFour",
    FULLY_CHARGED             = "fullyCharged",
    SHOW_EMPOWER_NAME         = "showEmpowerName",
    BORDER                    = "border",
    OFFSET                    = "offset",
    SHOW_BORDER               = "showBorder",
    ICON                      = "icon",
    ZOOM                      = "zoom",
    SPELL_WIDTH               = "spellWidth",
    HIDE_IF_EMPTY_OR_FULL     = "hideIfEmptyOrFull",
    HIDE_IF_FULL              = "hideIfFull",
    HIDE_IF_EMPTY             = "hideIfEmpty",
    SPACING                   = "spacing",
    VERTICAL_FILL             = "verticalFill",
    SAME_SIZE_AS_HEALTH_BAR   = "sameSizeAsHealthBar",
    REVERSE_FILL              = "reverseFill",
    OVER_SHIELD               = "overShield",
    SHOW_DEAD_STATUS          = "showDeadStatus",
    CUSTOM_TEXTS              = "customTexts",
    OVER_ABSORB_GLOW          = "overAbsorbGlow",
    HIGHLIGHT_TYPE            = "highlightType",
    ONLY_SHOW_DISPELLABLE     = "onlyShowDispellable",
    CURSE                     = "curse",
    DISEASE                   = "disease",
    MAGIC                     = "magic",
    POISON                    = "poison",
    BLEED                     = "bleed",
    ICON_STYLE                = "iconStyle",
    ONLY_SHOW_INTERRUPT       = "onlyShowInterrupt",
    HIDE_AT_MAX_LEVEL         = "hideAtMaxLevel",
    HIDE_OUT_OF_COMBAT        = "hideOutOfCombat",
    GLOW                      = "glow",
    SHOW_TARGET               = "showTarget",
    TARGET_SEPARATOR          = "targetSeparator",
    TIME_TO_HOLD              = "timeToHold",
    INTERRUPTED_LABEL         = "interruptedLabel",
    ICON_TEXTURE              = "iconTexture",
    TARGET                    = "target",
    HOVER                     = "hover",
    SAME_WIDTH_AS_HEALTH_BAR  = "sameWidthAsHealthBar",
    SAME_HEIGHT_AS_HEALTH_BAR = "sameHeightAsHealthBar",
    POWER_FILTER              = "powerFilter",
    ANCHOR_TO_PARENT          = "anchorToParent",
    FADE_IN_TIMER             = "fadeInTimer",
    FADE_OUT_TIMER            = "fadeOutTimer",
    ENRAGE                    = "enrage",
    OVER_HEAL                 = "overHeal",
    ANCHOR_TO_POWER_BAR       = "anchorToPowerBar"
}

---@enum AURA_OPTION_KIND
const.AURA_OPTION_KIND = {
    SIZE = "size",
    FONT = "font",
    ORIENTATION = "orientation",
    POSITION = "position",
    SHOW_DURATION = "showDuration",
    SHOW_ANIMATION = "showAnimation",
    SHOW_STACK = "showStack",
    SHOW_TOOLTIP = "showTooltip",
    SPACING = "spacing",
    NUM_PER_LINE = "numPerLine",
    FILTER = "filter",
    MAX_ICONS = "maxIcons",
    MIN_DURATION = "minDuration",
    MAX_DURATION = "maxDuration",
    HIDE_PERSONAL = "hidePersonal",
    HIDE_EXTERNAL = "hideExternal",
    HIDE_NO_DURATION = "hideNoDuration",
    BLACKLIST = "blacklist",
    WHITELIST = "whitelist",
    USE_BLACKLIST = "useBlacklist",
    USE_WHITELIST = "useWhitelist",
    HORIZONTAL = "horizontal",
    VERTICAL = "vertical",
    DURATION = "duration",
    STACKS = "stacks",
    PERSONAL = "personal",
    NON_PERSONAL = "nonPersonal",
    BOSS = "boss",
    CAST_BY_PLAYERS = "castByPlayers",
    CAST_BY_NPC = "castByNPC",
    HIDE_IN_COMBAT = "hideInCombat",
    WHITE_LIST_PRIORITY = "whiteListPriority",
    TEMP_ENCHANT = "tempEnchant",
    DISPELLABLE = "dispellable",
    RAID = "raid",
    CELL_RAID_DEBUFFS = "cellRaidDebuffs",
}

---@enum GrowthOrientation
const.GROWTH_ORIENTATION = {
    RIGHT_TO_LEFT = "right-to-left",
    LEFT_TO_RIGHT = "left-to-right",
    TOP_TO_BOTTOM = "top-to-bottom",
    BOTTOM_TO_TOP = "bottom-to-top",
}

---@enum FontKind
const.FONTS = {
    CELL_WIDGET = "CELL_FONT_WIDGET",
    CELL_SPECIAL = "CELL_FONT_SPECIAL",
    CLASS_TITLE = "CELL_FONT_CLASS_TITLE",
}

---@enum FontWidthType
const.FontWidthType = {
    UNLIMITED = "unlimited",
    PERCENTAGE = "percentage",
    LENGTH = "length",
}

const.UNIT_ANCHOR_POINTS = { "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT" }
const.ANCHOR_POINTS = { "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT" }
const.OUTLINES = { "None", "Outline", "Monochrome" }
const.TEXT_JUSTIFY = { "CENTER", "LEFT", "RIGHT" }

const.COLORS = {
    HOSTILE = { 0.78, 0.25, 0.25 },
    FRIENDLY = { 0.29, 0.69, 0.3, },
    NEUTRAL = { 0.85, 0.77, 0.36 },
    PET = { 0.5, 0.5, 1 },
}

---@enum CastBarTimerFormat
const.CastBarTimerFormat = {
    NORMAL = "normal",
    REMAINING = "remaining",
    REMAINING_AND_MAX = "remaining-and-max",
    DURATION = "duration",
    DURATION_AND_MAX = "duration-and-max",
    HIDDEN = "hidden",
}

---@enum NameFormat
const.NameFormat = {
    FULL_NAME = "fullName",
    LAST_NAME = "lastName",
    FIRST_NAME = "firstName",
    FIRST_NAME_LAST_INITIAL = "firstNameLastInitial",
    FIRST_INITIAL_LAST_NAME = "firstInitialLastName",
}

---@alias FormatColorType
---| "red"
---| "green"
---| "blue"
---| "white"
---| "black"
---| "yellow"
---| "cyan"
---| "magenta"
---| "orange"
---| "purple"
---| "gray"
---| "pink"
---| "brown"
---| "gold"
---| "WARRIOR"
---| "PALADIN"
---| "HUNTER"
---| "ROGUE"
---| "PRIEST"
---| "DEATHKNIGHT"
---| "SHAMAN"
---| "MAGE"
---| "WARLOCK"
---| "MONK"
---| "DRUID"
---| "DEMONHUNTER"
---| "EVOKER"

---@enum FormatColors
const.FormatColors = {
    red = "ffff0000",
    green = "ff00ff00",
    blue = "ff0000ff",
    white = "ffffffff",
    black = "ff000000",
    yellow = "ffffff00",
    cyan = "ff00ffff",
    magenta = "ffff00ff",
    orange = "ffffa500",
    purple = "ff800080",
    gray = "ff808080",
    pink = "ffffc0cb",
    brown = "ffa52a2a",
    gold = "ffffd700",
}

---@enum UnitButtonColorType
const.UnitButtonColorType = {
    CELL = "cell",
    CLASS_COLOR = "class_color",
    CLASS_COLOR_DARK = "class_color_dark",
    CUSTOM = "custom",
}

const.BlizzardFrameTypes = {
    CUF.constants.UNIT.PLAYER,
    CUF.constants.UNIT.TARGET,
    CUF.constants.UNIT.TARGET_TARGET,
    CUF.constants.UNIT.FOCUS,
    CUF.constants.UNIT.PET,
    CUF.constants.UNIT.BOSS,
    "playerCastBar",
    "buffFrame",
    "debuffFrame",
}

---@enum GlowType
const.GlowType = {
    NONE = "none",
    NORMAL = "normal",
    PIXEL = "pixel",
    SHINE = "shine",
    PROC = "proc",
}

---@enum Textures
const.Textures = {
    SOLID = "Interface\\Buttons\\WHITE8X8",
    CELL_SHIELD = "Interface\\AddOns\\Cell\\Media\\shield",
    CELL_OVERSHIELD = "Interface\\AddOns\\Cell\\Media\\overshield",
    CELL_OVERABSORB = "Interface\\AddOns\\Cell\\Media\\overabsorb",
    BLIZZARD_SHIELD_FILL = "Interface\\RaidFrame\\Shield-Fill",
    BLIZZARD_SHIELD_OVERLAY = "Interface\\RaidFrame\\Shield-Overlay",
    BLIZZARD_OVERSHIELD = "Interface\\RaidFrame\\Shield-Overshield",
    BLIZZARD_ABSORB_FILL = "Interface\\RaidFrame\\Absorb-Fill",
    BLIZZARD_OVERABSORB = "Interface\\RaidFrame\\Absorb-Overabsorb",
}
