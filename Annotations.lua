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
---@field button button

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
---@field SetContentHeight fun(self: CellScrollFrame, height: number, num: number?, spacing: number?)
---@field Reset fun(self: CellScrollFrame)

---@class CellCheckButton: CheckButton
---@field label FontString

---@class CellButton: Button
---@field SetTextColor fun(self: CellButton, r: number, g: number, b: number, a: number)

-------------------------------------------------
-- MARK: CUF Frames
-------------------------------------------------

---@class SmoothStatusBar: StatusBar
---@field SetMinMaxSmoothedValue number
---@field ResetSmoothedValue number
---@field SetSmoothedValue number

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
---@field readyCheckStatus ("ready" | "waiting" | "notready")?
---@field isResting boolean

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
---@field name string
---@field HasWidget fun(self: CUFUnitButton, widget: WIDGET_KIND): boolean

-------------------------------------------------
-- MARK: Misc
-------------------------------------------------

---@class stringlib
---@field utf8charbytes fun(text: string, index: number): number
---@field utf8len fun(text: string): number
---@field utf8sub fun(text: string, start: number, end_: number): string
---@field utf8replace fun(text: string, mapping: table): string
---@field utf8upper fun(text: string): string
---@field utf8lower fun(text: string): string
---@field utf8reverse fun(text: string): string
