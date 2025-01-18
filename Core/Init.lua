---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.version = 15

CUF.Cell = Cell

---@class CUF.widgets
CUF.widgets = {}
---@class CUF.uFuncs
CUF.uFuncs = {}
---@class CUF.Util
CUF.Util = {}
---@class CUF.database
CUF.DB = {}
---@class CUF.constants
CUF.constants = {}
---@class CUF.defaults
CUF.Defaults = {}
---@class CFU.Debug
CUF.Debug = {}
---@class CUF.builder
CUF.Builder = {}
---@class CUF.API
CUF.API = {}
---@class CUF.PixelPerfect
CUF.PixelPerfect = {}
---@class CUF.Compat
CUF.Compat = {}

---@class CUF.vars
---@field selectedLayout string
---@field selectedUnit Unit
---@field selectedWidget WIDGET_KIND
---@field testMode boolean
---@field isMenuOpen boolean
---@field isRetail boolean
---@field selectedTab string
---@field selectedSubTab string
---@field inEditMode boolean
---@field customPositioning boolean
---@field useScaling boolean
CUF.vars = {}

-- Borrowed from DBM https://github.com/DeadlyBossMods/DeadlyBossMods/blob/716071c1e561174a1f60b3cd36a000bac267027b/DBM-Core/modules/objects/GameVersion.lua#
CUF.vars.isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)
CUF.vars.isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
CUF.vars.isHardcoreServer = C_GameRules and C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive()
--[[ CUF.vars.currentSeason = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2) and C_Seasons and C_Seasons.HasActiveSeason() and
C_Seasons.GetActiveSeason() ]]
CUF.vars.isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
CUF.vars.isWrath = WOW_PROJECT_ID == (WOW_PROJECT_WRATH_CLASSIC or 11)
CUF.vars.isCata = WOW_PROJECT_ID == (WOW_PROJECT_CATACLYSM_CLASSIC or 14)

---@class CUF.unitButtons
---@field [Unit] CUFUnitButton
---@field boss table<string, CUFUnitButton>
CUF.unitButtons = {}
