---@meta

---@alias WidgetTable
---| NameTextWidgetTable
---| HealthTextWidgetTable
---| PowerTextWidgetTable
---| AuraWidgetTable
---| RaidIconWidgetTable
---| RoleIconWidgetTable
---| LeaderIconWidgetTable
---| CombatIconWidgetTable
---| ShieldBarWidgetTable

---@alias Widget
---| NameTextWidget
---| HealthTextWidget
---| PowerTextWidget
---| CellAuraIcons
---| RaidIconWidget
---| RoleIconWidget
---| LeaderIconWidget
---| CombatIconWidget
---| ShieldBarWidget

---@class CUFUnitButtonWidgets
---@field healthBar HealthBarWidget
---@field healthBarLoss Texture
---@field deadTex Texture
---@field powerBar PowerBarWidget
---@field powerBarLoss Texture
---@field powerText PowerTextWidget
---@field nameText NameTextWidget
---@field targetHighlight HighlightWidget
---@field mouseoverHighlight HighlightWidget
---@field healthText HealthTextWidget
---@field buffs CellAuraIcons
---@field debuffs CellAuraIcons
---@field raidIcon RaidIconWidget
---@field roleIcon RoleIconWidget
---@field leaderIcon LeaderIconWidget
---@field combatIcon CombatIconWidget
---@field shieldBar ShieldBarWidget

---@class BaseWidget
---@field enabled boolean
---@field id WIDGET_KIND
---@field _isSelected boolean
---@field _SetIsSelected function
---@field _OnIsSelected function?

-------------------------------------------------
-- MARK: Text Widgets
-------------------------------------------------

---@class NameTextWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field font SmallFontOpt
---@field color ColorOpt
---@field width FontWidthOpt
---@field position PositionOpt

---@class HealthTextWidgetTable
---@field enabled boolean
---@field textFormat string
---@field frameLevel number
---@field color ColorOpt
---@field hideIfEmptyOrFull boolean
---@field position PositionOpt
---@field format string
---@field font SmallFontOpt

---@class PowerTextWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field color ColorOpt
---@field hideIfEmptyOrFull boolean
---@field position PositionOpt
---@field format string
---@field font SmallFontOpt
---@field textFormat string

-------------------------------------------------
-- MARK: Icon Widgets
-------------------------------------------------

---@class RoleIconWidgetTable
---@field enabled boolean
---@field position PositionOpt
---@field frameLevel number
---@field size SizeOpt

---@class LeaderIconWidgetTable
---@field enabled boolean
---@field size SizeOpt
---@field frameLevel number
---@field position PositionOpt

---@class RaidIconWidgetTable
---@field enabled boolean
---@field position PositionOpt
---@field frameLevel number
---@field size SizeOpt

---@class CombatIconWidgetTable
---@field enabled boolean
---@field position PositionOpt
---@field frameLevel number
---@field size SizeOpt

-------------------------------------------------
-- MARK: Aura Widgets
-------------------------------------------------

---@class AuraWidgetTable
---@field enabled boolean
---@field showDuration boolean
---@field numPerLine number
---@field showAnimation boolean
---@field showTooltip boolean
---@field maxIcons number
---@field font AuraFontOpt
---@field showStack boolean
---@field filter FilterOpt
---@field orientation AuraOrientation
---@field position PositionOpt
---@field spacing SpacingOpt
---@field size SizeOpt

---@class FilterOpt
---@field hideNoDuration boolean
---@field useWhitelist boolean
---@field hidePersonal boolean
---@field blacklist table<number>
---@field maxDuration number
---@field hideExternal boolean
---@field useBlacklist boolean
---@field whitelist table<number>
---@field minDuration number
---@field boss boolean
---@field castByPlayers boolean
---@field castByNPC boolean
---@field nonPersonal boolean
---@field personal boolean

---@class AuraFontOpt
---@field stacks BigFontOpt
---@field duration BigFontOpt

-------------------------------------------------
-- MARK: Bar Widgets
-------------------------------------------------

---@class ShieldBarWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field position PositionOpt
---@field rgba RGBAOpt

-------------------------------------------------
-- MARK: Generic Options
-------------------------------------------------

---@class PositionOpt
---@field anchor FramePoint
---@field offsetY number
---@field offsetX number
---@field extraAnchor FramePoint

---@class FontWidthOpt
---@field value number
---@field type FontWidthType
---@field auxValue number

---@class RGBOpt
---@field [1] number
---@field [2] number
---@field [3] number

---@class RGBAOpt
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number

---@class ColorOpt
---@field rgb RGBOpt
---@field type ColorType

---@class SmallFontOpt
---@field outline string
---@field size number
---@field style string
---@field shadow boolean

---@class BigFontOpt
---@field outline string
---@field rgb RGBOpt
---@field style string
---@field shadow boolean
---@field anchor string
---@field offsetY number
---@field offsetX number
---@field size number

---@class SizeOpt
---@field width number
---@field height number

---@class SpacingOpt
---@field vertical number
---@field horizontal number
