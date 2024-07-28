---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local B = Cell.bFuncs
local P = Cell.pixelPerfectFuncs

local unit = "player"

local playerFrame, anchorFrame, hoverFrame, config = B:CreateBaseUnitFrame(unit, "Player Frame")
Cell.frames.playerFrame = playerFrame
Cell.frames.playerFrameAnchor = anchorFrame

local playerButton = CreateFrame("Button", "CellPlayerButton", playerFrame, "CellUnitButtonTemplate")
playerButton:SetAttribute("unit", unit)
playerButton:SetPoint("TOPLEFT")
playerButton._layout = "Player"
Cell.unitButtons.player[unit] = playerButton

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdateMenu(which)
    B:UpdateUnitButtonMenu(which, unit, playerButton, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "PlayerFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(_, which)
    B:UpdateUnitButtonLayout(unit, which, playerButton, anchorFrame)
end
Cell:RegisterCallback("UpdateLayout", "PlayerFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(playerFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "PlayerFrame_UpdatePixelPerfect", UpdatePixelPerfect)

local function PlayerFrame_UpdateVisibility(which)
    B:UpdateUnitFrameVisibility(which, unit, playerButton, playerFrame)
end
Cell:RegisterCallback("UpdateVisibility", "PlayerFrame_UpdateVisibility", PlayerFrame_UpdateVisibility)
CUF:RegisterCallback("UpdateVisibility", "PlayerFrame_UpdateVisibility", PlayerFrame_UpdateVisibility)
