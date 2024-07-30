-------------------------------------------------
-- MARK: External Annotations
-------------------------------------------------

---@class SmoothStatusBar: StatusBar
---@field SetMinMaxSmoothedValue number
---@field ResetSmoothedValue number
---@field SetSmoothedValue number

---@class CellAnimationGroup: AnimationGroup
---@field alpha Animation

---@class CellAnimation
---@field fadeIn CellAnimationGroup
---@field fadeOut CellAnimationGroup

---@class LibGroupInfo
---@field GetCachedInfo function

-------------------------------------------------
-- MARK: CUF Annotations
-------------------------------------------------

---@alias Units "player" | "target" | "focus"

-------------------------------------------------
-- MARK: CUF Frames
-------------------------------------------------

---@class CUFUnitFrame: Frame

---@class CUFAnchorFrame: Frame, CellAnimation

---@class CUFHoverFrame: Frame

---@class CUFConfigButton: Button
---@field UpdatePixelPerfect function
