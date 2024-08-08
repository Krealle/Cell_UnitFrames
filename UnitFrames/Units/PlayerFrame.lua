---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

---@class CUF.uFuncs
local U = CUF.uFuncs
---@class CUF.constants
local const = CUF.constants

local unit = const.UNIT.PLAYER

local playerFrame, anchorFrame, hoverFrame, config = U:CreateBaseUnitFrame(unit)

local playerButton = CreateFrame("Button", "CUFPlayerButton", playerFrame, "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]
playerButton:SetAttribute("unit", unit)
playerButton:SetPoint("TOPLEFT")
CUF.unitButtons.player = playerButton

-------------------------------------------------
-- callbacks
-------------------------------------------------

---@param which string?
local function UpdateMenu(which)
    U:UpdateUnitButtonMenu(which, unit, playerButton, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "PlayerFrame_UpdateMenu", UpdateMenu)

---@param which string?
local function UpdateLayout(_, which)
    U:UpdateUnitButtonLayout(unit, which, playerButton, anchorFrame)
end
Cell:RegisterCallback("UpdateLayout", "PlayerFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(playerFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "PlayerFrame_UpdatePixelPerfect", UpdatePixelPerfect)

---@param which string?
local function PlayerFrame_UpdateVisibility(which)
    U:UpdateUnitFrameVisibility(which, unit, playerButton, playerFrame)
end
Cell:RegisterCallback("UpdateVisibility", "PlayerFrame_UpdateVisibility", PlayerFrame_UpdateVisibility)
CUF:RegisterCallback("UpdateVisibility", "PlayerFrame_UpdateVisibility", PlayerFrame_UpdateVisibility)
