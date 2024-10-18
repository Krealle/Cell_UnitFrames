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
---| ClassBarWidgetTable
---| CustomTextWidgetTable
---| HealAbsorbWidgetTable
---| DispelsWidgetTable
---| TotemsWidgetTable

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
---| ClassBarWidget
---| CustomTextWidget
---| HealAbsorbWidget
---| DispelsWidget
---| TotemsWidget

---@class CUFUnitButton.Widgets
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
---@field classBar ClassBarWidget
---@field customText CustomTextWidget
---@field healAbsorb HealAbsorbWidget
---@field dispels DispelsWidget
---@field totems TotemsWidget

---@class BaseWidget
---@field enabled boolean
---@field id WIDGET_KIND
---@field _isSelected boolean
---@field _SetIsSelected function
---@field _OnIsSelected function?
---@field _isEnabled boolean

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
---@field format NameFormat

---@class HealthTextWidgetTable
---@field enabled boolean
---@field textFormat string
---@field frameLevel number
---@field color ColorOpt
---@field position PositionOpt
---@field format string
---@field font SmallFontOpt
---@field hideIfFull boolean
---@field hideIfEmpty boolean
---@field showDeadStatus boolean

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

---@class CustomTextWidgetTable
---@field enabled boolean
---@field textFormat string
---@field color ColorOpt
---@field position PositionOpt
---@field font SmallFontOpt

---@class CustomTextMainWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field texts CustomTextWidgetTable[]

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

---@class ReadyCheckIconWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field size SizeOpt
---@field position PositionOpt

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
---@field orientation GrowthOrientation
---@field position PositionOpt
---@field spacing SpacingOpt
---@field size SizeOpt
---@field hideInCombat boolean

---@class FilterOpt
---@field whiteListPriority boolean
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

---@class DispelsWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field highlightType "entire" | "current" | "current+" | "gradient" | "gradient-half"
---@field onlyShowDispellable boolean
---@field curse boolean
---@field disease boolean
---@field magic boolean
---@field poison boolean
---@field bleed boolean
---@field iconStyle "none" | "blizzard" | "rhombus"
---@field size number
---@field position PositionOpt

---@class TotemsWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field showDuration boolean
---@field numPerLine number
---@field showAnimation boolean
---@field showTooltip boolean
---@field maxIcons number
---@field font AuraFontOpt
---@field orientation GrowthOrientation
---@field position PositionOpt
---@field spacing SpacingOpt
---@field size SizeOpt
---@field hideInCombat boolean

-------------------------------------------------
-- MARK: Bar Widgets
-------------------------------------------------

---@class ShieldBarWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field point "RIGHT"|"LEFT"|"healthBar"
---@field reverseFill boolean
---@field overShield boolean

---@class CastBarWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field position PositionOpt
---@field size SizeOpt
---@field reverse boolean
---@field timer BigFontOpt
---@field timerFormat CastBarTimerFormat
---@field spell BigFontOpt
---@field spellWidth FontWidthOpt
---@field showSpell boolean
---@field spark CastBarSparkOpt
---@field empower EmpowerOpt
---@field border BorderOpt
---@field icon CastBarIconOpt
---@field useClassColor boolean

---@class CastBarSparkOpt
---@field enabled boolean
---@field width number
---@field color RGBAOpt

---@class CastBarIconOpt
---@field enabled boolean
---@field position "left"|"right"
---@field zoom number

---@class EmpowerOpt
---@field useFullyCharged boolean
---@field showEmpowerName boolean

---@class ClassBarWidgetTable
---@field enabled boolean
---@field frameLevel number
---@field position PositionOpt
---@field size SizeOpt
---@field spacing number
---@field verticalFill boolean
---@field sameSizeAsHealthBar boolean

---@class HealAbsorbWidgetTable
---@field enabled boolean
---@field frameLevel number

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

---@class BorderOpt
---@field showBorder boolean
---@field offset number
---@field size number
---@field color RGBAOpt
