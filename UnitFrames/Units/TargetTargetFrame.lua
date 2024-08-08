---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

local U = CUF.uFuncs
local const = CUF.constants

local unit = const.UNIT.TARGET_TARGET

local targetTargetFrame, anchorFrame, hoverFrame, config = U:CreateBaseUnitFrame(unit)

local targetTargetButton = CreateFrame("Button", "CUFTargetTargetButton", targetTargetFrame, "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]
targetTargetButton:SetAttribute("unit", unit)
targetTargetButton:SetPoint("TOPLEFT")
CUF.unitButtons.targettarget = targetTargetButton

-------------------------------------------------
-- callbacks
-------------------------------------------------

---@param which string?
local function UpdateMenu(which)
    U:UpdateUnitButtonMenu(which, unit, targetTargetButton, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "TargetTargetFrame_UpdateMenu", UpdateMenu)

---@param which string?
local function UpdateLayout(_, which)
    U:UpdateUnitButtonLayout(unit, which, targetTargetButton, anchorFrame)
end
Cell:RegisterCallback("UpdateLayout", "TargetTargetFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(targetTargetFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "TargetTargetFrame_UpdatePixelPerfect", UpdatePixelPerfect)

---@param which string?
local function TargetTargetFrame_UpdateVisibility(which)
    U:UpdateUnitFrameVisibility(which, unit, targetTargetButton, targetTargetFrame)
end
Cell:RegisterCallback("UpdateVisibility", "TargetTargetFrame_UpdateVisibility", TargetTargetFrame_UpdateVisibility)
CUF:RegisterCallback("UpdateVisibility", "TargetTargetFrame_UpdateVisibility", TargetTargetFrame_UpdateVisibility)
