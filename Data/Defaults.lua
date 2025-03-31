---@class CUF
local CUF = select(2, ...)

local Util = CUF.Util

-------------------------------------------------
-- MARK: Defaults
-------------------------------------------------

---@class CUF.defaults
local Defaults = CUF.Defaults

Defaults.Values = {
    maxAuraIcons = 20,
    maxLevel = 80,
    extraBleeds = {
        --[470632] = true, -- 撕裂 - Rend
    },
    extraEnrages = {
        --[61573] = "TEST",
    },
    -- Fallback layout to use for Master Layout
    -- Used for when Cell's layout is set to "Hide"
    fallbackLayout = "default"
}

Defaults.Options = {}
Defaults.Filters = {
    buffs = {
        blacklist = {},
        whitelist = { -- Mostly borrowed from ElvUI
            -- Haste effects
            2825,     -- [Shaman] Bloodlust
            32182,    -- [Shaman] Heroism
            80353,    -- [Mage] Time Warp
            90355,    -- [Hunter] Ancient Hysteria
            390386,   -- [Evoker] Fury of the Aspects
            -- Paladin
            1022,     -- Blessing of Protection
            1044,     -- Blessing of Freedom
            6940,     -- Blessing of Sacrifice
            31821,    -- Aura Mastery
            204018,   -- Blessing of Spellwarding
            -- Priest
            33206,    -- Pain Suppression
            47788,    -- Guardian Spirit
            62618,    -- Power Word: Barrier
            -- Monk
            116849,   -- Life Cocoon
            -- Druid
            102342,   -- Ironbark
            -- Shaman
            20608,    -- Reincarnation
            325174,   -- Spirit Link
            -- Evoker
            357170,   -- Time Dilation
            374227,   -- Zephyr
            -- Other
            97462,    -- Rallying Cry
            196718,   -- Darkness
        },
    },
    debuffs = {
        blacklist = {
            8326,   -- Ghost
            15007,  -- Ress Sickness
            25771,  -- Forbearance
            26013,  -- Deserter
            57723,  -- Exhaustion (Shaman)
            57724,  -- Sated
            71041,  -- Dungeon Deserter
            80354,  -- Temporal Displacement
            124273, -- Heavy Stagger
            124274, -- Moderate Stagger
            124275, -- Light Stagger
            374037, -- Overwhelming Rage
            390106, -- Riding Along
            390435, -- Exhaustion (Evoker)
        },
        whitelist = {},
    }
}

---@type ColorOpt
Defaults.Options.colorOpt = {
    rgb = { 1, 1, 1 },
    type = "class_color",
}
---@type SmallFontOpt
Defaults.Options.smallFontOpt = {
    size = 12,
    outline = "Outline",
    shadow = false,
    style = "Cell Default",
    justify = "CENTER",
}
---@type BigFontOpt
Defaults.Options.auraStacksFontOpt = {
    size = 12,
    outline = "Outline",
    shadow = false,
    style = "Cell Default",
    point = "BOTTOMRIGHT",
    relativePoint = "BOTTOMRIGHT",
    offsetX = 2,
    offsetY = -1,
    rgb = { 1, 1, 1 },
    justify = "CENTER",
}
---@type BigFontOpt
Defaults.Options.auraDurationFontOpt = {
    size = 12,
    outline = "Outline",
    shadow = false,
    style = "Cell Default",
    point = "CENTER",
    relativePoint = "CENTER",
    offsetX = 0,
    offsetY = 0,
    rgb = { 1, 1, 1 },
    justify = "CENTER",
}
---@type FontWidthOpt
Defaults.Options.fontWidth = {
    value = 0.75,
    type = "percentage",
    auxValue = 3,
}
---@type GlowOpt
Defaults.Options.glow = {
    type = CUF.constants.GlowType.NONE,
    color = { 1, 1, 1, 1 },
    lines = 9,
    frequency = 0.25,
    length = 8,
    thickness = 2,
    particles = 9,
    duration = 1,
    scale = 100,
}

---@alias Defaults.Colors.Types
---| "castBar"
---| "reaction"
---| "essence"
---| "classResources"
---| "comboPoints"
---| "chi"
---| "runes"
---| "shieldBar"
---| "healAbsorb"
---| "unitFrames"
---| "classBar"
---| "highlight"
---| "healPrediction"

---@class Defaults.Colors
Defaults.Colors = {
    castBar = {
        texture = CUF.constants.Textures.SOLID,
        interruptible = { 0.2, 0.57, 0.5, 1 },
        nonInterruptible = { 0.43, 0.43, 0.43, 1 },
        background = { 0, 0, 0, 0.8 },
        stageZero = { 0.2, 0.57, 0.5, 1 },
        stageOne = { 0.3, 0.47, 0.45, 1 },
        stageTwo = { 0.4, 0.4, 0.4, 1 },
        stageThree = { 0.54, 0.3, 0.3, 1 },
        stageFour = { 0.65, 0.2, 0.3, 1 },
        fullyCharged = { 0.77, 0.1, 0.2, 1 },
    },
    reaction = {
        friendly = { 0.29, 0.69, 0.3, 1 },
        hostile = { 0.78, 0.25, 0.25, 1 },
        neutral = { 0.85, 0.77, 0.36, 1 },
        pet = { 0.29, 0.69, 0.3, 1 },
        useClassColorForPet = false,
        swapHostileHealthAndLossColors = false,
    },
    essence = {
        ["1"] = { 0.2, 0.57, 0.5, 1 },
        ["2"] = { 0.2, 0.57, 0.5, 1 },
        ["3"] = { 0.2, 0.57, 0.5, 1 },
        ["4"] = { 0.2, 0.57, 0.5, 1 },
        ["5"] = { 0.2, 0.57, 0.5, 1 },
        ["6"] = { 0.2, 0.57, 0.5, 1 },
    },
    classResources = {
        holyPower = { 0.9, 0.89, 0.04, 1 },
        arcaneCharges = { 0, 0.62, 1, 1 },
        soulShards = { 0.58, 0.51, 0.8, 1 },
    },
    comboPoints = {
        ["1"] = { 0.76, 0.3, 0.3, 1 },
        ["2"] = { 0.79, 0.56, 0.3, 1 },
        ["3"] = { 0.82, 0.82, 0.3, 1 },
        ["4"] = { 0.56, 0.79, 0.3, 1 },
        ["5"] = { 0.43, 0.77, 0.3, 1 },
        ["6"] = { 0.3, 0.76, 0.3, 1 },
        ["7"] = { 0.36, 0.82, 0.54, 1 },
        charged = { 0.15, 0.64, 1, 1 },
    },
    chi = {
        ["1"] = { 0.72, 0.77, 0.31, 1 },
        ["2"] = { 0.58, 0.74, 0.36, 1 },
        ["3"] = { 0.49, 0.72, 0.38, 1 },
        ["4"] = { 0.38, 0.7, 0.42, 1 },
        ["5"] = { 0.26, 0.67, 0.46, 1 },
        ["6"] = { 0.13, 0.64, 0.5, 1 },
    },
    runes = {
        bloodRune = { 1.0, 0.24, 0.24, 1 },
        frostRune = { 0.24, 1.0, 1.0, 1 },
        unholyRune = { 0.24, 1.0, 0.24, 1 },
    },
    shieldBar = {
        shieldTexture = CUF.constants.Textures.SOLID,
        overshieldTexture = CUF.constants.Textures.CELL_OVERSHIELD,
        overlayTexture = CUF.constants.Textures.BLIZZARD_SHIELD_OVERLAY,
        shieldColor = { 1, 1, 0, 0.25 },
        overshieldColor = { 1, 1, 1, 1 },
        overlayColor = { 1, 1, 1, 1 },
        useOverlay = false,
        overshieldOffset = 4,
        overshieldReverseOffset = 0,
        overshieldSize = 4,
    },
    healAbsorb = {
        absorbTexture = CUF.constants.Textures.CELL_SHIELD,
        overabsorbTexture = CUF.constants.Textures.CELL_OVERABSORB,
        absorbColor = { 1, 0.1, 0.1, 1 },
        overabsorbColor = { 1, 1, 1, 1 },
        invertColor = false,
    },
    unitFrames = {
        barColor = { 0.06, 0.07, 0.07, 1 },
        lossColor = { 0.52, 0.21, 0.19, 1 },
        fullColor = { 0.2, 0.2, 1, 1 },
        deathColor = { 0.47, 0.47, 0.47, 1 },
        useFullColor = false,
        useDeathColor = false,
        barAlpha = 1,
        lossAlpha = 1,
        backgroundAlpha = 1,
        powerBarAlpha = 1,
        powerLossAlpha = 1,
    },
    classBar = {
        texture = CUF.constants.Textures.SOLID,
    },
    highlight = {
        target = { 1, 0.3, 0.3, 1 },
        hover = { 1, 1, 1, 1 }
    },
    healPrediction = {
        texture = CUF.constants.Textures.SOLID,
        color = { 0, 1, 0.5, 0.25 },
        overHeal = { 1, 1, 1, 1 },
    },
}

Defaults.ColorsMenuOrder = {
    castBar = {
        { "texture",          "texture" },
        { "background",       "rgb" },
        { "interruptible",    "rgb" },
        { "nonInterruptible", "rgb" },
        { "Empowers",         "separator" },
        { "stageZero",        "rgb" },
        { "stageOne",         "rgb" },
        { "stageTwo",         "rgb" },
        { "stageThree",       "rgb" },
        { "stageFour",        "rgb" },
        { "fullyCharged",     "rgb" }
    },
    reaction = {
        { "friendly",                       "rgb" },
        { "hostile",                        "rgb" },
        { "neutral",                        "rgb" },
        { "pet",                            "rgb" },
        { "useClassColorForPet",            "toggle" },
        { "hostileUnits",                   "separator" },
        { "swapHostileHealthAndLossColors", "toggle" }
    },
    essence = {
        { "1", "rgb" },
        { "2", "rgb" },
        { "3", "rgb" },
        { "4", "rgb" },
        { "5", "rgb" },
        { "6", "rgb" },
    },
    classResources = {
        { "holyPower",     "rgb" },
        { "soulShards",    "rgb" },
        { "arcaneCharges", "rgb" },
    },
    comboPoints = {
        { "1",       "rgb" },
        { "2",       "rgb" },
        { "3",       "rgb" },
        { "4",       "rgb" },
        { "5",       "rgb" },
        { "6",       "rgb" },
        { "7",       "rgb" },
        { "charged", "rgb" },
    },
    chi = {
        { "1", "rgb" },
        { "2", "rgb" },
        { "3", "rgb" },
        { "4", "rgb" },
        { "5", "rgb" },
        { "6", "rgb" },
    },
    runes = {
        { "bloodRune",  "rgb" },
        { "frostRune",  "rgb" },
        { "unholyRune", "rgb" },
    },
    shieldBar = {
        { "shieldTexture",           "texture" },
        { "overshieldTexture",       "texture" },
        { "overlayTexture",          "texture" },
        { "shieldColor",             "rgb" },
        { "overshieldColor",         "rgb" },
        { "",                        "newline" },
        { "overlayColor",            "rgb" },
        { "useOverlay",              "toggle" },
        { "overshieldOffset",        "slider" },
        { "overshieldReverseOffset", "slider" },
        { "overshieldSize",          "slider" },
    },
    healPrediction = {
        { "texture",  "texture" },
        { "color",    "rgb" },
        { "overHeal", "rgb" },
    },
    healAbsorb = {
        { "absorbTexture",     "texture" },
        { "overabsorbTexture", "texture" },
        { "absorbColor",       "rgb" },
        { "overabsorbColor",   "rgb" },
        { "",                  "newline" },
        { "invertColor",       "toggle" },
    },
    unitFrames = {
        { "barColor",        "rgb" },
        { "",                "newline" },
        { "lossColor",       "rgb" },
        { "",                "newline" },
        { "fullColor",       "rgb" },
        { "useFullColor",    "toggle" },
        { "",                "newline" },
        { "deathColor",      "rgb" },
        { "useDeathColor",   "toggle" },
        { "barAlpha",        "slider-percent" },
        { "lossAlpha",       "slider-percent" },
        { "backgroundAlpha", "slider-percent" },
        { "powerBarAlpha",   "slider-percent" },
        { "powerLossAlpha",  "slider-percent" },
    },
    classBar = {
        { "texture", "texture" },
    },
    highlight = {
        { "target", "rgb" },
        { "hover",  "rgb" },
    }
}

---@class Defaults.BlizzardFrames
Defaults.BlizzardFrames = {}
for _, unit in pairs(CUF.constants.BlizzardFrameTypes) do
    Defaults.BlizzardFrames[unit] = false
end

---@type CustomTextWidgetTable
Defaults.CustomText = {
    enabled = false,
    textFormat = "",
    color = {
        type = "custom",
        rgb = { 1, 1, 1 },
    },
    position = {
        point = "CENTER",
        offsetY = 0,
        offsetX = 0,
        relativePoint = "CENTER",
    },
    font = Defaults.Options.smallFontOpt,
}

-------------------------------------------------
-- MARK: Widgets (Text)
-------------------------------------------------

---@class WidgetTables
Defaults.Widgets = {
    ---@type NameTextWidgetTable
    nameText = {
        enabled = true,
        frameLevel = 10,
        font = Defaults.Options.smallFontOpt,
        color = Defaults.Options.colorOpt,
        width = {
            value = 0.75,
            type = "percentage",
            auxValue = 3,
        },
        position = {
            point = "TOPLEFT",
            offsetY = 8,
            offsetX = 2,
            relativePoint = "CENTER",
        },
        format = CUF.constants.NameFormat.FULL_NAME,
    },
    ---@type HealthTextWidgetTable
    healthText = {
        enabled = true,
        font = Defaults.Options.smallFontOpt,
        color = Defaults.Options.colorOpt,
        format = "percentage",
        textFormat = "",
        hideIfFull = false,
        hideIfEmpty = false,
        showDeadStatus = false,
        frameLevel = 10,
        position = {
            point = "RIGHT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type PowerTextWidgetTable
    powerText = {
        enabled = true,
        font = Defaults.Options.smallFontOpt,
        color = Defaults.Options.colorOpt,
        format = "percentage",
        hideIfEmptyOrFull = false,
        anchorToPowerBar = false,
        powerFilter = false,
        textFormat = "",
        frameLevel = 10,
        position = {
            point = "BOTTOMRIGHT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type LevelTextWidgetTable
    levelText = {
        enabled = false,
        font = Defaults.Options.smallFontOpt,
        color = Defaults.Options.colorOpt,
        frameLevel = 10,
        position = {
            point = "TOPLEFT",
            offsetY = 8,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type CustomTextMainWidgetTable
    customText = {
        enabled = false,
        frameLevel = 11,
        texts = {
            text1 = Util:CopyDeep(Defaults.CustomText),
            text2 = Util:CopyDeep(Defaults.CustomText),
            text3 = Util:CopyDeep(Defaults.CustomText),
            text4 = Util:CopyDeep(Defaults.CustomText),
            text5 = Util:CopyDeep(Defaults.CustomText)
        }
    }, -- MARK: Widgets (Auras)
    ---@type AuraWidgetTable
    buffs = {
        enabled = false,
        orientation = CUF.constants.GROWTH_ORIENTATION.LEFT_TO_RIGHT,
        showStack = true,
        showDuration = true,
        showAnimation = true,
        showTooltip = true,
        hideInCombat = false,
        numPerLine = 5,
        maxIcons = 10,
        spacing = {
            horizontal = 1,
            vertical = 1,
        },
        font = {
            stacks = Defaults.Options.auraStacksFontOpt,
            duration = Defaults.Options.auraDurationFontOpt,
        },
        size = {
            width = 25,
            height = 25,
        },
        filter = {
            useBlacklist = false,
            blacklist = Defaults.Filters.buffs.blacklist,
            useWhitelist = false,
            whitelist = Defaults.Filters.buffs.whitelist,
            whiteListPriority = false,
            minDuration = 0,
            maxDuration = 0,
            hideNoDuration = false,
            castByPlayers = false,
            nonPersonal = true,
            castByNPC = false,
            personal = true,
            boss = false,
            tempEnchant = false,
            dispellable = false,
            raid = false,
        },
        position = {
            point = "BOTTOMLEFT",
            offsetY = 20,
            offsetX = 0,
            relativePoint = "TOPLEFT",
        },
    },
    ---@type AuraWidgetTable
    debuffs = {
        enabled = false,
        orientation = CUF.constants.GROWTH_ORIENTATION.RIGHT_TO_LEFT,
        showStack = true,
        showDuration = true,
        showAnimation = true,
        showTooltip = true,
        hideInCombat = false,
        numPerLine = 4,
        maxIcons = 4,
        spacing = {
            horizontal = 0,
            vertical = 0,
        },
        font = {
            stacks = Defaults.Options.auraStacksFontOpt,
            duration = Defaults.Options.auraDurationFontOpt,
        },
        size = {
            width = 25,
            height = 25,
        },
        filter = {
            useBlacklist = false,
            blacklist = Defaults.Filters.debuffs.blacklist,
            useWhitelist = false,
            whitelist = Defaults.Filters.debuffs.whitelist,
            whiteListPriority = false,
            minDuration = 0,
            maxDuration = 0,
            hideNoDuration = false,
            castByPlayers = false,
            nonPersonal = true,
            castByNPC = false,
            personal = true,
            boss = false,
            tempEnchant = false,
            dispellable = false,
            raid = false,
            cellRaidDebuffs = false,
        },
        position = {
            point = "BOTTOMRIGHT",
            offsetY = 20,
            offsetX = 0,
            relativePoint = "TOPRIGHT",
        },
    },
    ---@type DispelsWidgetTable
    dispels = {
        enabled = false,
        frameLevel = 10,
        highlightType = "current",
        onlyShowDispellable = true,
        curse = true,
        disease = true,
        magic = true,
        poison = true,
        bleed = true,
        enrage = true,
        iconStyle = "none",
        size = 12,
        position = {
            point = "BOTTOMRIGHT",
            offsetY = 4,
            offsetX = -4,
            relativePoint = "BOTTOMRIGHT",
        },
        glow = Defaults.Options.glow
    },
    ---@type TotemsWidgetTable
    totems = {
        enabled = false,
        frameLevel = 10,
        orientation = CUF.constants.GROWTH_ORIENTATION.LEFT_TO_RIGHT,
        showDuration = true,
        showAnimation = true,
        showTooltip = true,
        hideInCombat = false,
        numPerLine = 5,
        maxIcons = 5,
        spacing = {
            horizontal = 0,
            vertical = 0,
        },
        font = {
            stacks = Defaults.Options.auraStacksFontOpt,
            duration = Defaults.Options.auraDurationFontOpt,
        },
        size = {
            width = 40,
            height = 40,
        },
        position = {
            point = "TOPLEFT",
            offsetY = -30,
            offsetX = 0,
            relativePoint = "BOTTOMLEFT",
        },
    }, -- MARK: Widgets (Icons)
    ---@type RaidIconWidgetTable
    raidIcon = {
        enabled = false,
        frameLevel = 10,
        size = {
            width = 20,
            height = 20,
        },
        position = {
            point = "TOP",
            offsetY = 12,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type RoleIconWidgetTable
    roleIcon = {
        enabled = false,
        frameLevel = 10,
        size = {
            width = 20,
            height = 20,
        },
        position = {
            point = "TOPRIGHT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type LeaderIconWidgetTable
    leaderIcon = {
        enabled = false,
        frameLevel = 10,
        size = {
            width = 20,
            height = 20,
        },
        position = {
            point = "TOPRIGHT",
            offsetY = 14,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type CombatIconWidgetTable
    combatIcon = {
        enabled = false,
        frameLevel = 10,
        size = {
            width = 20,
            height = 20,
        },
        position = {
            point = "CENTER",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type ReadyCheckIconWidgetTable
    readyCheckIcon = {
        enabled = false,
        frameLevel = 10,
        size = {
            width = 20,
            height = 20,
        },
        position = {
            point = "CENTER",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "CENTER",
        },
    },
    ---@type RestingIconWidgetTable
    restingIcon = {
        enabled = false,
        frameLevel = 10,
        hideAtMaxLevel = false,
        iconTexture = "",
        size = {
            width = 20,
            height = 20,
        },
        position = {
            point = "TOPLEFT",
            offsetY = 10,
            offsetX = -15,
            relativePoint = "CENTER",
        },
    }, -- MARK: Widgets (Bars)
    ---@type ShieldBarWidgetTable
    shieldBar = {
        enabled = false,
        frameLevel = 9,
        point = "RIGHT",
        reverseFill = false,
        overShield = false,
    },
    ---@type CastBarWidgetTable
    castBar = {
        enabled = false,
        useClassColor = true,
        frameLevel = 10,
        onlyShowInterrupt = false,
        anchorToParent = true,
        timeToHold = 0,
        interruptedLabel = "%t",
        showInterruptedSpell = false,
        orientation = CUF.constants.GROWTH_ORIENTATION.LEFT_TO_RIGHT,
        fadeInTimer = 0,
        fadeOutTimer = 0,
        position = {
            point = "TOPLEFT",
            offsetY = -30,
            offsetX = 0,
            relativePoint = "BOTTOMLEFT",
        },
        detachedPosition = {
            point = "CENTER",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "CENTER",
        },
        size = {
            width = 200,
            height = 30,
        },
        timer = {
            enabled = true,
            size = 16,
            outline = "Outline",
            shadow = true,
            style = "Cell Default",
            point = "RIGHT",
            relativePoint = "RIGHT",
            offsetY = -3,
            offsetX = 0,
            rgb = { 1, 1, 1 },
            justify = "CENTER",
        },
        timerFormat = "normal",
        spell = {
            enabled = true,
            size = 16,
            outline = "Outline",
            shadow = true,
            style = "Cell Default",
            point = "LEFT",
            relativePoint = "LEFT",
            offsetY = 0,
            offsetX = 4,
            rgb = { 1, 1, 1 },
            justify = "CENTER",
        },
        spellWidth = Defaults.Options.fontWidth,
        showSpell = true,
        showTarget = false,
        targetSeparator = "->",
        spark = {
            enabled = true,
            width = 2,
            color = { 1, 1, 1, 1 },
        },
        empower = {
            useFullyCharged = true,
            showEmpowerName = false,
        },
        border = {
            showBorder = true,
            offset = 0,
            size = 1,
            color = { 0, 0, 0, 1 }
        },
        icon = {
            enabled = true,
            position = "left",
            zoom = 0,
        }
    },
    ---@type ClassBarWidgetTable
    classBar = {
        enabled = false,
        spacing = 5,
        frameLevel = 10,
        verticalFill = false,
        sameSizeAsHealthBar = true,
        hideOutOfCombat = false,
        size = {
            width = 200,
            height = 8,
        },
        position = {
            point = "BOTTOMLEFT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "TOPLEFT",
        },
    },
    ---@type AltPowerBarWidgetTable
    altPowerBar = {
        enabled = false,
        frameLevel = 10,
        size = {
            width = 200,
            height = 5,
        },
        sameSizeAsHealthBar = true,
        hideIfEmpty = false,
        hideIfFull = false,
        hideOutOfCombat = false,
        position = {
            point = "TOPLEFT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "TOPLEFT",
        },
    },
    ---@type PowerBarWidgetTable
    powerBar = {
        enabled = true,
        frameLevel = 15,
        powerFilter = false,
        hideIfEmpty = false,
        hideIfFull = false,
        hideOutOfCombat = false,
        orientation = CUF.constants.GROWTH_ORIENTATION.LEFT_TO_RIGHT,
        size = {
            width = 200,
            height = 5,
        },
        sameWidthAsHealthBar = true,
        sameHeightAsHealthBar = false,
        position = {
            point = "BOTTOMLEFT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "BOTTOMLEFT",
        },
        anchorToParent = true,
        detachedPosition = {
            point = "BOTTOMLEFT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "BOTTOMLEFT",
        },
    },
    ---@type HealPredictionWidgetTable
    healPrediction = {
        enabled = false,
        frameLevel = 9,
        point = "healthBar",
        reverseFill = false,
        overHeal = false,
    },
    ---@type HealAbsorbWidgetTable
    healAbsorb = {
        enabled = false,
        frameLevel = 10,
    }, -- MARK: Widgets (Misc)
    ---@type FaderWidgetTable
    fader = {
        enabled = true,
        range = true,
        combat = false,
        hover = false,
        target = false,
        unitTarget = false,
        fadeDuration = 0.25,
        maxAlpha = 1,
        minAlpha = 0.35,
    },
    ---@type HighlightWidgetTable
    highlight = {
        enabled = false,
        hover = true,
        target = true,
        size = 1,
    },
}

-- Boss Widgets
Defaults.Widgets_Boss = {
    ---@type AuraWidgetTable
    buffs = Util:CopyDeep(Defaults.Widgets.buffs),
    ---@type AuraWidgetTable
    debuffs = Util:CopyDeep(Defaults.Widgets.debuffs),
    ---@type CastBarWidgetTable
    castBar = Util:CopyDeep(Defaults.Widgets.castBar),
}

Defaults.Widgets_Boss.debuffs.position = {
    point = "LEFT",
    relativePoint = "RIGHT",
    offsetX = 0,
    offsetY = 0,
}
Defaults.Widgets_Boss.debuffs.orientation = CUF.constants.GROWTH_ORIENTATION.LEFT_TO_RIGHT
Defaults.Widgets_Boss.debuffs.filter.blacklist = {}
Defaults.Widgets_Boss.debuffs.filter.boss = true
Defaults.Widgets_Boss.debuffs.filter.castByNPC = true
Defaults.Widgets_Boss.debuffs.filter.personal = false
Defaults.Widgets_Boss.debuffs.filter.nonPersonal = false

Defaults.Widgets_Boss.buffs.position = {
    point = "BOTTOMLEFT",
    relativePoint = "TOPLEFT",
    offsetX = 0,
    offsetY = 8,
}
Defaults.Widgets_Boss.buffs.filter.blacklist = {}
Defaults.Widgets_Boss.buffs.filter.whitelist = {}
Defaults.Widgets_Boss.buffs.filter.boss = true
Defaults.Widgets_Boss.buffs.filter.castByNPC = true
Defaults.Widgets_Boss.buffs.filter.castByPlayers = true
Defaults.Widgets_Boss.buffs.maxIcons = 5

Defaults.Widgets_Boss.castBar.position = {
    point = "BOTTOMRIGHT",
    relativePoint = "BOTTOMLEFT",
    offsetX = -5,
    offsetY = 0,
}
Defaults.Widgets_Boss.castBar.size = {
    width = 150,
    height = 20,
}
Defaults.Widgets_Boss.castBar.timer.size = 12
Defaults.Widgets_Boss.castBar.timer.offsetY = 0
Defaults.Widgets_Boss.castBar.spell.size = 12
Defaults.Widgets_Boss.castBar.spell.offsetX = 0

-------------------------------------------------
-- MARK: Units
-------------------------------------------------

---@class Size
---@field [1] number
---@field [2] number

---@class Position
---@field [1] number
---@field [2] number

---@class ParentAnchor
---@field point FramePoint
---@field relativePoint FramePoint
---@field offsetX number
---@field offsetY number

---@class UnitLayout
---@field enabled boolean
---@field size Size
---@field position Position
---@field widgets WidgetTables
---@field sameSizeAsPlayer boolean?
---@field clickCast boolean
---@field mirrorPlayer boolean?
---@field parent Unit?
---@field anchorToParent boolean?
---@field anchorPosition ParentAnchor?
---@field barOrientation string
---@field spacing number?
---@field growthDirection GrowthOrientation?
---@field alwaysUpdate boolean?
---@field healthBarColorType UnitButtonColorType
---@field healthLossColorType UnitButtonColorType
---@field visibility string
---@field healthBarTexture string
---@field useHealthBarTexture boolean
---@field healthLossTexture string
---@field useHealthLossTexture boolean
---@field powerBarTexture string
---@field usePowerBarTexture boolean
---@field powerLossTexture string
---@field usePowerLossTexture boolean
---@field reverseHealthFill boolean

---@alias UnitLayoutTable table<Unit, UnitLayout>
---@type UnitLayoutTable
Defaults.Layouts = {
    player = {
        enabled = false,
        size = { 200, 40 },
        position = { -300, -250 },
        widgets = Util:CopyDeep(Defaults.Widgets),
        clickCast = false,
        barOrientation = "horizontal",
        healthBarColorType = CUF.constants.UnitButtonColorType.CELL,
        healthLossColorType = CUF.constants.UnitButtonColorType.CUSTOM,
        visibility = "[petbattle] hide;show",
        healthBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthBarTexture = false,
        healthLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthLossTexture = false,
        powerBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerBarTexture = false,
        powerLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerLossTexture = false,
        reverseHealthFill = false,
    },
    target = {
        enabled = false,
        size = { 200, 40 },
        position = { 300, -250 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            customText = Defaults.Widgets.customText,
            buffs = Defaults.Widgets.buffs,
            debuffs = Defaults.Widgets.debuffs,
            raidIcon = Defaults.Widgets.raidIcon,
            roleIcon = Defaults.Widgets.roleIcon,
            leaderIcon = Defaults.Widgets.leaderIcon,
            combatIcon = Defaults.Widgets.combatIcon,
            readyCheckIcon = Defaults.Widgets.readyCheckIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            castBar = Defaults.Widgets.castBar,
            healAbsorb = Defaults.Widgets.healAbsorb,
            dispels = Defaults.Widgets.dispels,
            fader = Defaults.Widgets.fader,
            highlight = Defaults.Widgets.highlight,
            powerBar = Defaults.Widgets.powerBar,
        },
        sameSizeAsPlayer = false,
        clickCast = false,
        mirrorPlayer = false,
        barOrientation = "horizontal",
        healthBarColorType = CUF.constants.UnitButtonColorType.CELL,
        healthLossColorType = CUF.constants.UnitButtonColorType.CUSTOM,
        visibility = "",
        healthBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthBarTexture = false,
        healthLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthLossTexture = false,
        powerBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerBarTexture = false,
        powerLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerLossTexture = false,
        reverseHealthFill = false,
    },
    focus = {
        enabled = false,
        size = { 100, 30 },
        position = { -300, 125 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            customText = Defaults.Widgets.customText,
            buffs = Defaults.Widgets.buffs,
            debuffs = Defaults.Widgets.debuffs,
            raidIcon = Defaults.Widgets.raidIcon,
            roleIcon = Defaults.Widgets.roleIcon,
            leaderIcon = Defaults.Widgets.leaderIcon,
            combatIcon = Defaults.Widgets.combatIcon,
            readyCheckIcon = Defaults.Widgets.readyCheckIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            castBar = Defaults.Widgets.castBar,
            healAbsorb = Defaults.Widgets.healAbsorb,
            dispels = Defaults.Widgets.dispels,
            fader = Defaults.Widgets.fader,
            highlight = Defaults.Widgets.highlight,
            powerBar = Defaults.Widgets.powerBar,
        },
        anchorToParent = false,
        parent = CUF.constants.UNIT.PLAYER,
        anchorPosition = {
            point = "BOTTOMLEFT",
            relativePoint = "TOPLEFT",
            offsetX = 0,
            offsetY = 10
        },
        sameSizeAsPlayer = false,
        clickCast = false,
        barOrientation = "horizontal",
        healthBarColorType = CUF.constants.UnitButtonColorType.CELL,
        healthLossColorType = CUF.constants.UnitButtonColorType.CUSTOM,
        visibility = "",
        healthBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthBarTexture = false,
        healthLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthLossTexture = false,
        powerBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerBarTexture = false,
        powerLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerLossTexture = false,
        reverseHealthFill = false,
    },
    targettarget = {
        enabled = false,
        size = { 200, 40 },
        position = { 500, -250 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            raidIcon = Defaults.Widgets.raidIcon,
            fader = Defaults.Widgets.fader,
            highlight = Defaults.Widgets.highlight,
            powerBar = Defaults.Widgets.powerBar,
        },
        sameSizeAsPlayer = false,
        clickCast = false,
        anchorToParent = true,
        parent = CUF.constants.UNIT.TARGET,
        anchorPosition = {
            point = "BOTTOMLEFT",
            relativePoint = "BOTTOMRIGHT",
            offsetX = 2,
            offsetY = 0
        },
        barOrientation = "horizontal",
        alwaysUpdate = true,
        healthBarColorType = CUF.constants.UnitButtonColorType.CELL,
        healthLossColorType = CUF.constants.UnitButtonColorType.CUSTOM,
        visibility = "",
        healthBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthBarTexture = false,
        healthLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthLossTexture = false,
        powerBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerBarTexture = false,
        powerLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerLossTexture = false,
        reverseHealthFill = false,
    },
    pet = {
        enabled = false,
        size = { 200, 30 },
        position = { -300, -300 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            customText = Defaults.Widgets.customText,
            buffs = Defaults.Widgets.buffs,
            debuffs = Defaults.Widgets.debuffs,
            raidIcon = Defaults.Widgets.raidIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            castBar = Defaults.Widgets.castBar,
            healAbsorb = Defaults.Widgets.healAbsorb,
            dispels = Defaults.Widgets.dispels,
            fader = Defaults.Widgets.fader,
            highlight = Defaults.Widgets.highlight,
            powerBar = Defaults.Widgets.powerBar,
        },
        sameSizeAsPlayer = false,
        clickCast = false,
        anchorToParent = true,
        parent = CUF.constants.UNIT.PLAYER,
        anchorPosition = {
            point = "TOPLEFT",
            relativePoint = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = -5
        },
        barOrientation = "horizontal",
        healthBarColorType = CUF.constants.UnitButtonColorType.CELL,
        healthLossColorType = CUF.constants.UnitButtonColorType.CUSTOM,
        visibility = "",
        healthBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthBarTexture = false,
        healthLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthLossTexture = false,
        powerBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerBarTexture = false,
        powerLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerLossTexture = false,
        reverseHealthFill = false,
    },
    boss = {
        enabled = false,
        spacing = 50,
        size = { 160, 40 },
        position = { 600, 300 },
        sameSizeAsPlayer = false,
        clickCast = false,
        barOrientation = "horizontal",
        growthDirection = CUF.constants.GROWTH_ORIENTATION.TOP_TO_BOTTOM,
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            customText = Defaults.Widgets.customText,
            raidIcon = Defaults.Widgets.raidIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            buffs = Defaults.Widgets_Boss.buffs,
            debuffs = Defaults.Widgets_Boss.debuffs,
            castBar = Defaults.Widgets_Boss.castBar,
            fader = Defaults.Widgets.fader,
            highlight = Defaults.Widgets.highlight,
            powerBar = Defaults.Widgets.powerBar,
        },
        healthBarColorType = CUF.constants.UnitButtonColorType.CELL,
        healthLossColorType = CUF.constants.UnitButtonColorType.CUSTOM,
        visibility = "",
        healthBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthBarTexture = false,
        healthLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        useHealthLossTexture = false,
        powerBarTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerBarTexture = false,
        powerLossTexture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga",
        usePowerLossTexture = false,
        reverseHealthFill = false,
    }
}

Defaults.Layouts[CUF.constants.UNIT.PLAYER].widgets.fader.enabled = false
Defaults.Layouts[CUF.constants.UNIT.PLAYER].widgets.fader.range = false
