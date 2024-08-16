---@meta

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
---@field fadeOut boolean

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
---@field SetSelected function
---@field SetFont function

---@class CellColorPicker: Frame, BackdropTemplate
---@field SetColor function

---@class CellSlider: Slider
---@field afterValueChangedFn function
---@field currentEditBox Frame

---@class CellUnknowFrame: Frame
---@field title FontString
---@field GetSelected function

---@class CellCombatFrame: Frame
---@field mask Frame
---@field combatMask Frame

---@alias Layouts table<string, LayoutTable>

---@class LayoutTable
---@field CUFUnits UnitLayoutTable
---@field barOrientation table
---@field powerFilters table<string, boolean|string>
---@field groupFilter table<number, boolean>

---@class CellScrollFrame: ScrollFrame
---@field content Frame
---@field SetScrollStep fun(self: CellScrollFrame, step: number)
---@field ResetScroll fun(self: CellScrollFrame)
---@field SetContentHeight fun(self: CellScrollFrame, height: number)

-------------------------------------------------
-- MARK: CUF Frames
-------------------------------------------------

---@class SmoothStatusBar: StatusBar
---@field SetMinMaxSmoothedValue number
---@field ResetSmoothedValue number
---@field SetSmoothedValue number

-------------------------------------------------
-- MARK: CUF Menu
-------------------------------------------------

---@class WidgetsMenuPage
---@field frame WidgetsMenuPageFrame
---@field id WIDGET_KIND
---@field button WidgetMenuPageButton
---@field height number

---@class WidgetMenuPageButton: Button
---@field id WIDGET_KIND

---@class AnchorOptions: Frame
---@field nameAnchorDropdown CellDropdown
---@field nameXSlider CellSlider
---@field nameYSlider CellSlider

---@class EnabledCheckBox: Frame

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
---@field isLeader boolean
---@field isAssistant boolean

---@class CUFUnitButton: Button, BackdropTemplate
---@field widgets CUFUnitButtonWidgets
---@field states CUFUnitButtonStates
---@field GetTargetPingGUID function
---@field __unitGuid string
---@field class string
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
---@field _isSelected boolean
