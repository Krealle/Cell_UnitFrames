---@class CUF
local CUF = select(2, ...)

---@class CUF.constants
local const = CUF.constants

---@enum Unit
const.UNIT = {
    PLAYER = "player",
    TARGET = "target",
    FOCUS = "focus",
    PET = "pet",
    TARGET_TARGET = "targettarget",
}


---@enum TitleCasedUnits
-- Used for frame titles
const.TITLE_CASED_UNITS = {
    ["player"] = "Player",
    ["target"] = "Target",
    ["focus"] = "Focus",
    ["pet"] = "Pet",
    ["targettarget"] = "TargetTarget",
}

---@enum PowerColorType
const.PowerColorType = {
    CLASS_COLOR = "class_color",
    CUSTOM = "custom",
    POWER_COLOR = "power_color",
}

---@enum ColorType
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
    BUFFS = "buffs",
    DEBUFFS = "debuffs",
    RAID_ICON = "raidIcon",
    ROLE_ICON = "roleIcon",
    LEADER_ICON = "leaderIcon",
    COMBAT_ICON = "combatIcon",
    SHIELD_BAR = "shieldBar",
}

---@enum OPTION_KIND
const.OPTION_KIND = {
    ENABLED = "enabled",
    POSITION = "position",
    FONT = "font",
    WIDTH = "width",
    TEXT_WIDTH = "textWidth",
    HEALTH_FORMAT = "healthFormat",
    POWER_FORMAT = "powerFormat",
    ORIENTATION = "orientation",
    FORMAT = "format",
    OUTLINE = "outline",
    STYLE = "style",
    SHADOW = "shadow",
    COLOR = "color",
    HEIGHT = "height",
    SIZE = "size",
    FRAMELEVEL = "frameLevel",
    TEXT_FORMAT = "textFormat",
    RGB = "rgb",
    RGBA = "rgba",
    ANCHOR_POINT = "point",
    RELATIVE_POINT = "relativePoint",
    OFFSET_X = "offsetX",
    OFFSET_Y = "offsetY",
    TYPE = "type",
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
}

---@enum AuraOrientation
const.AURA_ORIENTATION = {
    RIGHT_TO_LEFT = "right-to-left",
    LEFT_TO_RIGHT = "left-to-right",
    TOP_TO_BOTTOM = "top-to-bottom",
    BOTTOM_TO_TOP = "bottom-to-top",
}

---@enum FontKind
const.FONTS = {
    CELL_WIGET = "CELL_FONT_WIDGET",
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

const.COLORS = {
    HOSTILE = { 0.78, 0.25, 0.25 },
    FRIENDLY = { 0.29, 0.69, 0.3, },
    NEUTRAL = { 0.85, 0.77, 0.36 },
    PET = { 0.5, 0.5, 1 },
}
