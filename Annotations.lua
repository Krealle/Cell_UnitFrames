-------------------------------------------------
-- MARK: External Annotations
-------------------------------------------------

---@class LibGroupInfo
---@field GetCachedInfo function

-------------------------------------------------
-- MARK: Cell Annotations
-------------------------------------------------

---@class CellDBGeneral
---@field menuPosition "top_bottom" | "left_right"
---@field locked boolean

---@class CellDBAppearance
---@field outOfRangeAlpha number
---@field barAlpha number
---@field lossAlpha number
---@field healPrediction table<number, table<number, number>>
---@field barAnimation "Smooth" | "Flash"

---@class CellDB
---@field layouts Layouts
---@field general CellDBGeneral
---@field appearance CellDBAppearance

---@class CellAnimationGroup: AnimationGroup
---@field alpha Animation

---@class CellAnimation
---@field fadeIn CellAnimationGroup
---@field fadeOut CellAnimationGroup

---@class CellDropdown: Frame, BackdropTemplate
---@field SetItems function
---@field SetEnabled function
---@field SetSelectedValue function
---@field SetLabel function

---@class CellColorPicker: Frame, BackdropTemplate
---@field SetColor function

---@class CellSlider: Slider
---@field afterValueChangedFn function

---@class CellUnknowFrame: Frame
---@field title FontString
---@field GetSelected function

---@class CellCombatFrame: Frame
---@field mask Frame
---@field combatMask Frame

---@alias LayoutTable table<Units, Layout>
---@alias Layouts table<string, LayoutTable>

---@class Layout
---@field enabled boolean
---@field sameSizeAsPlayer boolean
---@field size table<number, number>
---@field position table<string, number>
---@field tooltipPosition table<number, string|number>
---@field powerSize number
---@field anchor AnchorPoint
---@field widgets UnitFrameWidgetsTable
---@field barOrientation table
---@field powerFilters table<string, boolean|string>

-------------------------------------------------
-- MARK: CUF Alias
-------------------------------------------------

---@alias Units "player" | "target" | "focus"
---@alias Callbacks "UpdateMenu" | "UpdateWidget" | "LoadPageDB" | "UpdateVisibility"

-------------------------------------------------
-- MARK: CUF Widgets
-------------------------------------------------

---@alias Widgets "nameText" | "healthText"

---@class TextWidgetTable
---@field enabled boolean
---@field color ColorOpt
---@field font FontOpt
---@field position PositionOpt
---@field width FontWidth

---@class FontWidth
---@field type "percentage" | "unlimited" | "length"
---@field value number
---@field auxValue number

---@class FontOpt
---@field size number
---@field outline "None" | "Outline" | "Monochrome"
---@field shadow boolean
---@field style string

---@class ColorOpt
---@field type "class_color" | "custom"
---@field rgb table<number>

---@class PositionOpt
---@field anchor AnchorPoint
---@field offsetX number
---@field offsetY number

-------------------------------------------------
-- MARK: CUF Frames
-------------------------------------------------

---@class CUFUnitFrame: Frame

---@class CUFAnchorFrame: Frame, CellAnimation

---@class CUFHoverFrame: Frame

---@class CUFConfigButton: Button
---@field UpdatePixelPerfect function

---@class SmoothStatusBar: StatusBar
---@field SetMinMaxSmoothedValue number
---@field ResetSmoothedValue number
---@field SetSmoothedValue number

-------------------------------------------------
-- MARK: CUF Menu
-------------------------------------------------

---@class UnitsMenuPage
---@field frame Frame
---@field id Units
---@field button UnitMenuPageButton
---@field unitFrameCB CheckButton
---@field sameSizeAsPlayerCB CheckButton?
---@field widthSlider Slider
---@field heightSlider Slider
---@field powerSizeSlider Slider
---@field anchorDropdown CellDropdown
---@field anchorText FontString

---@class UnitMenuPageButton: Button
---@field id Units


---@class WidgetsMenuPage
---@field frame Frame
---@field id Widgets
---@field button WidgetMenuPageButton
---@field height number

---@class WidgetMenuPageButton: Button
---@field id Widgets

---@class UnitColorOptions: Frame
---@field colorPicker CellColorPicker
---@field dropdown CellDropdown

---@class AnchorOptions: Frame
---@field nameAnchorDropdown CellDropdown
---@field nameXSlider CellSlider
---@field nameYSlider CellSlider

---@class FontOptions: Frame


-------------------------------------------------
-- MARK: CUF UnitButton
-------------------------------------------------

---@class CUFUnitButtonStates
---@field unit string
---@field displayedUnit string
---@field name string
---@field fullName string
---@field class string
---@field guid string?
---@field isPlayer boolean
---@field health number
---@field healthMax number
---@field healthPercent number
---@field healthPercentOld number
---@field totalAbsorbs number
---@field wasDead boolean
---@field isDead boolean
---@field wasDeadOrGhost boolean
---@field isDeadOrGhost boolean
---@field hasSoulstone boolean
---@field inVehicle boolean
---@field role string
---@field powerType number
---@field powerMax number
---@field power number
---@field inRange boolean
---@field wasInRange boolean

---@class CUFUnitButton: Button, BackdropTemplate
---@field widgets CUFUnitButtonWidgets
---@field states CUFUnitButtonStates
---@field GetTargetPingGUID function
---@field __unitGuid string
---@field class string
---@field _layout string
---@field powerSize number
---@field _powerBarUpdateRequired boolean
---@field _updateRequired boolean
---@field __tickCount number
---@field __updateElapsed number
---@field __displayedGuid string?
---@field __unitName string
---@field __nameRetries number
---@field orientation "horizontal" | "vertical_health" | "vertical"
---@field _casts table
---@field _timers table
---@field _buffs_cache table
---@field _buffs_count_cache table

---@class CUFUnitButtonWidgets
---@field healthBar HealthBarWidget
---@field healthBarLoss Texture
---@field deadTex Texture
---@field powerBar PowerBarWidget
---@field powerBarLoss Texture
---@field nameText NameTextWidget
---@field targetHighlight HighlightWidget
---@field mouseoverHighlight HighlightWidget
---@field healthText HealthTextWidget

---@class HighlightWidget: BackdropTemplate, Frame
