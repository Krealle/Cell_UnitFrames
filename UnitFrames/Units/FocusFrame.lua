---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

---@class CUF.uFuncs
local U = CUF.uFuncs
---@class CUF.constants
local const = CUF.constants

local unit = const.UNIT.FOCUS

local focusFrame, anchorFrame, hoverFrame, config = U:CreateBaseUnitFrame(unit)

local focusButton = CreateFrame("Button", "CUFFocusButton", focusFrame, "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]
focusButton:SetAttribute("unit", unit)
focusButton:SetPoint("TOPLEFT")
CUF.unitButtons.focus = focusButton

-------------------------------------------------
-- callbacks
-------------------------------------------------

---@param which string?
local function UpdateMenu(which)
    U:UpdateUnitButtonMenu(which, unit, focusButton, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "FocusFrame_UpdateMenu", UpdateMenu)

---@param which string?
local function UpdateLayout(_, which)
    U:UpdateUnitButtonLayout(unit, which, focusButton, anchorFrame)
end
Cell:RegisterCallback("UpdateLayout", "FocusFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(focusFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "FocusFrame_UpdatePixelPerfect", UpdatePixelPerfect)

---@param which string?
local function FocusFrame_UpdateVisibility(which)
    U:UpdateUnitFrameVisibility(which, unit, focusButton, focusFrame)
end
Cell:RegisterCallback("UpdateVisibility", "FocusFrame_UpdateVisibility", FocusFrame_UpdateVisibility)
CUF:RegisterCallback("UpdateVisibility", "FocusFrame_UpdateVisibility", FocusFrame_UpdateVisibility)
