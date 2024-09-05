---@class CUF
local CUF = select(2, ...)

-------------------------------------------------
-- MARK: Defaults
-------------------------------------------------

---@class CUF.defaults
local Defaults = CUF.Defaults
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
}
---@type BigFontOpt
Defaults.Options.auraStacksFontOpt = {
    size = 12,
    outline = "Outline",
    shadow = false,
    style = "Cell Default",
    point = "BOTTOMRIGHT",
    offsetX = 2,
    offsetY = -1,
    rgb = { 1, 1, 1 },
}
---@type BigFontOpt
Defaults.Options.auraDurationFontOpt = {
    size = 12,
    outline = "Outline",
    shadow = false,
    style = "Cell Default",
    point = "CENTER",
    offsetX = 0,
    offsetY = 0,
    rgb = { 1, 1, 1 },
}
---@type FontWidthOpt
Defaults.Options.fontWidth = {
    value = 0.75,
    type = "percentage",
    auxValue = 3,
}

---@alias Defaults.Colors.Types
---| "castBar"
---| "reaction"
---| "essence"
---| "classResources"
---| "comboPoints"

---@class Defaults.Colors
Defaults.Colors = {
    castBar = {
        texture = "Interface\\Buttons\\WHITE8X8",
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
    rune = {
        bloodRune = { 1.0, 0.24, 0.24, 1 },
        frostRune = { 0.24, 1.0, 1.0, 1 },
        unholyRune = { 0.24, 1.0, 0.24, 1 },
    }
}

Defaults.ColorsMenuOrder = {
    castBar = {
        { "texture",          "texture" },
        { "background",       "rgb" },
        { "interruptible",    "rgb" },
        { "nonInterruptible", "rgb" },
        { "Empowers",         "seperator" },
        { "stageZero",        "rgb" },
        { "stageOne",         "rgb" },
        { "stageTwo",         "rgb" },
        { "stageThree",       "rgb" },
        { "stageFour",        "rgb" },
        { "fullyCharged",     "rgb" }
    },
    reaction = {
        { "friendly", "rgb" },
        { "hostile",  "rgb" },
        { "neutral",  "rgb" },
        { "pet",      "rgb" },
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
    rune = {
        { "bloodRune",  "rgb" },
        { "frostRune",  "rgb" },
        { "unholyRune", "rgb" },
    }
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
        hideIfEmptyOrFull = false,
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
    }, -- MARK: Widgets (Auras)
    ---@type AuraWidgetTable
    buffs = {
        enabled = false,
        orientation = CUF.constants.AURA_ORIENTATION.LEFT_TO_RIGHT,
        showStack = true,
        showDuration = true,
        showAnimation = true,
        showTooltip = true,
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
            minDuration = 0,
            maxDuration = 0,
            hideNoDuration = false,
            castByPlayers = false,
            nonPersonal = true,
            castByNPC = false,
            personal = true,
            boss = false,
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
        orientation = CUF.constants.AURA_ORIENTATION.RIGHT_TO_LEFT,
        showStack = true,
        showDuration = true,
        showAnimation = true,
        showTooltip = true,
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
            minDuration = 0,
            maxDuration = 0,
            hideNoDuration = false,
            castByPlayers = false,
            nonPersonal = true,
            castByNPC = false,
            personal = true,
            boss = false,
        },
        position = {
            point = "BOTTOMRIGHT",
            offsetY = 20,
            offsetX = 0,
            relativePoint = "TOPRIGHT",
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
        frameLevel = 10,
        rgba = { 1, 1, 0, 0.25 },
        position = {
            point = "BOTTOMRIGHT",
            offsetY = 0,
            offsetX = 0,
            relativePoint = "BOTTOMRIGHT",
        },
    },
    ---@type CastBarWidgetTable
    castBar = {
        enabled = false,
        useClassColor = true,
        frameLevel = 10,
        position = {
            point = "TOPLEFT",
            offsetY = -30,
            offsetX = 0,
            relativePoint = "BOTTOMLEFT",
        },
        size = {
            width = 200,
            height = 30,
        },
        reverse = false,
        timer = {
            enabled = true,
            size = 16,
            outline = "Outline",
            shadow = true,
            style = "Cell Default",
            point = "RIGHT",
            offsetY = -3,
            offsetX = 0,
            rgb = { 1, 1, 1 },
        },
        timerFormat = "normal",
        spell = {
            enabled = true,
            size = 16,
            outline = "Outline",
            shadow = true,
            style = "Cell Default",
            point = "LEFT",
            offsetY = 0,
            offsetX = 4,
            rgb = { 1, 1, 1 },
        },
        spellWidth = Defaults.Options.fontWidth,
        showSpell = true,
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
        enabled = true,
        spacing = 5,
        frameLevel = 10,
        verticalFill = false,
        sameSizeAsHealthBar = true,
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
    }
}

-------------------------------------------------
-- MARK: Units
-------------------------------------------------

---@class Size
---@field [1] number
---@field [2] number

---@class Position
---@field [1] number
---@field [2] number

---@class TooltipPosition
---@field [1] FramePoint
---@field [2] FramePoint
---@field [3] number
---@field [4] number

---@class UnitLayout
---@field enabled boolean
---@field powerSize number
---@field size Size
---@field point FramePoint
---@field position Position
---@field widgets WidgetTables
---@field tooltipPosition TooltipPosition
---@field sameSizeAsPlayer boolean?
---@field hideBlizzardCastBar boolean?
---@field clickCast boolean

---@alias UnitLayoutTable table<Unit, UnitLayout>
---@type UnitLayoutTable
Defaults.Layouts = {
    player = {
        enabled = false,
        powerSize = 2,
        size = { 200, 40 },
        point = "BOTTOMLEFT",
        position = { 800, 500 },
        widgets = Defaults.Widgets,
        tooltipPosition = { "BOTTOMLEFT", "BOTTOMLEFT", -3, 0, },
        hideBlizzardCastBar = false,
        clickCast = false,
    },
    target = {
        enabled = false,
        powerSize = 2,
        size = { 200, 40 },
        point = "BOTTOMLEFT",
        position = { 1400, 500 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            buffs = Defaults.Widgets.buffs,
            debuffs = Defaults.Widgets.debuffs,
            raidIcon = Defaults.Widgets.raidIcon,
            roleIcon = Defaults.Widgets.roleIcon,
            leaderIcon = Defaults.Widgets.leaderIcon,
            combatIcon = Defaults.Widgets.combatIcon,
            readyCheckIcon = Defaults.Widgets.readyCheckIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            castBar = Defaults.Widgets.castBar,
        },
        tooltipPosition = { "BOTTOMLEFT", "BOTTOMLEFT", -3, 0, },
        sameSizeAsPlayer = false,
        clickCast = false,
    },
    focus = {
        enabled = false,
        powerSize = 2,
        size = { 100, 30 },
        point = "BOTTOMLEFT",
        position = { 800, 700 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            buffs = Defaults.Widgets.buffs,
            debuffs = Defaults.Widgets.debuffs,
            raidIcon = Defaults.Widgets.raidIcon,
            roleIcon = Defaults.Widgets.roleIcon,
            leaderIcon = Defaults.Widgets.leaderIcon,
            combatIcon = Defaults.Widgets.combatIcon,
            readyCheckIcon = Defaults.Widgets.readyCheckIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            castBar = Defaults.Widgets.castBar,
        },
        tooltipPosition = { "BOTTOMLEFT", "BOTTOMLEFT", -3, 0, },
        sameSizeAsPlayer = false,
        clickCast = false,
    },
    targettarget = {
        enabled = false,
        powerSize = 2,
        size = { 200, 40 },
        point = "BOTTOMLEFT",
        position = { 1620, 500 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            raidIcon = Defaults.Widgets.raidIcon,
        },
        tooltipPosition = { "BOTTOMLEFT", "BOTTOMLEFT", -3, 0, },
        sameSizeAsPlayer = false,
        clickCast = false,
    },
    pet = {
        enabled = false,
        powerSize = 2,
        size = { 200, 30 },
        point = "BOTTOMLEFT",
        position = { 800, 460 },
        widgets = {
            nameText = Defaults.Widgets.nameText,
            healthText = Defaults.Widgets.healthText,
            powerText = Defaults.Widgets.powerText,
            levelText = Defaults.Widgets.levelText,
            buffs = Defaults.Widgets.buffs,
            debuffs = Defaults.Widgets.debuffs,
            raidIcon = Defaults.Widgets.raidIcon,
            shieldBar = Defaults.Widgets.shieldBar,
            castBar = Defaults.Widgets.castBar,
        },
        tooltipPosition = { "BOTTOMLEFT", "BOTTOMLEFT", -3, 0, },
        sameSizeAsPlayer = false,
        clickCast = false,
    },
}
