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
---| LevelTextWidgetTable
---| ReadyCheckIconWidgetTable
---| RestingIconWidgetTable
---| CastBarWidgetTable

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
---| LevelTextWidget
---| ReadyCheckIconWidget
---| RestingIconWidget
---| CastBarWidget

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
---@field levelText LevelTextWidget
---@field readyCheckIcon ReadyCheckIconWidget
---@field restingIcon RestingIconWidget
---@field castBar CastBarWidget

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

---@class LevelTextWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field font SmallFontOpt
---@field color ColorOpt
---@field position PositionOpt

---@class ReadyCheckIconWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field size SizeOpt
---@field position PositionOpt

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

---@class RestingIconWidgetTable
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
---@field blacklist table<number>
---@field whitelist table<number>
---@field hideNoDuration boolean
---@field castByPlayers boolean
---@field useBlacklist boolean
---@field useWhitelist boolean
---@field nonPersonal boolean
---@field maxDuration number
---@field minDuration number
---@field castByNPC boolean
---@field personal boolean
---@field boss boolean

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

---@class CastBarWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field position PositionOpt
---@field size SizeOpt
---@field color CastBarColorsOpt
---@field reverse boolean

---@class CastBarColorsOpt
---@field texture string
---@field useClassColor boolean
---@field interruptible RGBAOpt
---@field nonInterruptible RGBAOpt
---@field background RGBAOpt

-------------------------------------------------
-- MARK: Generic Options
-------------------------------------------------

---@class PositionOpt
---@field point FramePoint
---@field offsetY number
---@field offsetX number
---@field relativePoint FramePoint

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
---@field point FramePoint
---@field offsetY number
---@field offsetX number
---@field size number

---@class SizeOpt
---@field width number
---@field height number

---@class SpacingOpt
---@field vertical number
---@field horizontal number
