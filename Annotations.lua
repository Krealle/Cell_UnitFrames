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
---@field ClearSelected function
---@field GetSelected function
---@field AddItem function
---@field ClearItems function

---@class CellColorPicker: Frame, BackdropTemplate
---@field SetColor fun(self: CellColorPicker, r: number|table, g: number?, b: number?, a: number?)
---@field label FontString
---@field onChange fun(r: number, g: number, b: number, a: number)

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

-------------------------------------------------
-- MARK: Help Tip
-------------------------------------------------

-- Internal

---@class HelpTips.Info
---@field text string -- also acts as a key for various API, MUST BE SET
---@field dbKey string
---@field alignment HelpTip.Alignment Alignment of the helptip relative to the parent/relativeRegion (basically where the arrow is located)
---@field targetPoint HelpTip.Point Where at the parent/relativeRegion the helptip should point
---@field buttonStyle HelpTip.ButtonStyle?
---@field textColor any? HIGHLIGHT_FONT_COLOR
---@field textJustifyH FramePoint? "LEFT"
---@field hideArrow boolean?
---@field offsetX number?
---@field offsetY number?
---@field autoEdgeFlipping boolean? on: will flip helptip to opposite edge based on relative region's center vs helptip's center during OnUpdate
---@field autoHorizontalSlide boolean? on: will change the alignment to fit helptip on screen during OnUpdate
---@field useParentStrata boolean?
---@field extraRightMarginPadding number? extra padding on the right side of the helptip
---@field acknowledgeOnHide boolean? whether to treat a hide as an acknowledge
---@field appendFrame Frame? if a helptip needs a custom display you can append your own frame to the text
---@field appendFrameYOffset number? the offset for the vertical anchor for appendFrame
---@field system string? reference string
---@field systemPriority number? if a system and a priority is specified, higher priority helptips will close another helptip in that system
---@field onHideCallback fun(acknowledged: boolean, ...)? callback whenever the helptip is closed
---@field onAcknowledgeCallback fun(...)? callback whenever the helptip is closed by the user clicking its button

---@class HelpTips.Frame: Frame
---@field width number
---@field info HelpTips.Info
---@field acknowledged boolean
---@field Close fun(self: HelpTips.Frame)
---@field Init fun(self: HelpTips.Frame, parent: Frame, info: table, relativeRegion: Frame?)
---@field Matches fun(self: HelpTips.Frame, parent: Frame, text: string): boolean

-- Blizzard
HelpTip = {}

---@enum HelpTip.Point
HelpTip.Point = {
    TopEdgeLeft = 1,
    TopEdgeCenter = 2,
    TopEdgeRight = 3,
    BottomEdgeLeft = 4,
    BottomEdgeCenter = 5,
    BottomEdgeRight = 6,
    RightEdgeTop = 7,
    RightEdgeCenter = 8,
    RightEdgeBottom = 9,
    LeftEdgeTop = 10,
    LeftEdgeCenter = 11,
    LeftEdgeBottom = 12,
}

---@enum HelpTip.Alignment
HelpTip.Alignment = {
    Left = 1,
    Center = 2,
    Right = 3,
    Top = 1,
    Bottom = 3,
}

---@enum HelpTip.ButtonStyle
HelpTip.ButtonStyle = {
    None = 1,
    Close = 2,
    Okay = 3,
    GotIt = 4,
    Next = 5,
}
