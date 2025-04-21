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
