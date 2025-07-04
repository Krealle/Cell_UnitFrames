---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.version = 24

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
---@class CUF.Debug
CUF.Debug = {}
---@class CUF.builder
CUF.Builder = {}
---@class CUF.API
CUF.API = {}
---@class CUF.PixelPerfect
CUF.PixelPerfect = {}
---@class CUF.Compat
CUF.Compat = {}
---@class CUF.Mixin
CUF.Mixin = {}

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

---@class CUF.unitButtons
---@field [Unit] CUFUnitButton
---@field boss table<string, CUFUnitButton>
CUF.unitButtons = {}

-- Borrowed from DBM: https://github.com/DeadlyBossMods/DeadlyBossMods/blob/171258b10cd053a3fbb34f5f9fe93a238f4cfaad/DBM-Core/modules/objects/GameVersion.lua
CUF.vars.wowTOC = (select(4, GetBuildInfo()))
CUF.vars.isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)
CUF.vars.isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
CUF.vars.isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
CUF.vars.isWrath = WOW_PROJECT_ID == (WOW_PROJECT_WRATH_CLASSIC or 11)
CUF.vars.isCata = WOW_PROJECT_ID == (WOW_PROJECT_CATACLYSM_CLASSIC or 14)
CUF.vars.isMop = WOW_PROJECT_ID == (WOW_PROJECT_MISTS_CLASSIC or 19)
