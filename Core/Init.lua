---@class CUF
local CUF = select(2, ...)
_G.CUF = CUF

CUF.version = 13

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

---@class CUF.vars
---@field selectedLayout string
---@field selectedUnit Unit
---@field selectedWidget WIDGET_KIND
---@field testMode boolean
---@field isMenuOpen boolean
---@field isRetail boolean
---@field isVanilla boolean
---@field isBCC boolean
---@field isWrath boolean
---@field isCata boolean
---@field isTWW boolean
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
