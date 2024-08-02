---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs
---@class CUF.Util
local Util = CUF.Util
---@class CUF.widgets.Handler
local Handler = CUF.widgetsHandler
---@class CUF.builder
local Builder = CUF.Builder

---@class CUF.Menu
local menu = CUF.Menu
---@class CUF.constants
local const = CUF.constants

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------
menu:AddWidget(const.WIDGET_KIND.BUFFS, 250, "Buffs",
    Builder.MenuOptions.AuraIconOptions, Builder.MenuOptions.AuraStackFontOptions)
