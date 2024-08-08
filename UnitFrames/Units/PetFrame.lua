---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

local U = CUF.uFuncs
local const = CUF.constants

local unit = const.UNIT.PET

local petFrame, anchorFrame, hoverFrame, config = U:CreateBaseUnitFrame(unit)

local petButton = CreateFrame("Button", "CUFPetButton", petFrame, "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]
petButton:SetAttribute("unit", unit)
petButton:SetPoint("TOPLEFT")
CUF.unitButtons.pet = petButton

-------------------------------------------------
-- callbacks
-------------------------------------------------

---@param which string?
local function UpdateMenu(which)
    U:UpdateUnitButtonMenu(which, unit, petButton, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "PetFrame_UpdateMenu", UpdateMenu)

---@param which string?
local function UpdateLayout(_, which)
    U:UpdateUnitButtonLayout(unit, which, petButton, anchorFrame)
end
Cell:RegisterCallback("UpdateLayout", "PetFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(petFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "PetFrame_UpdatePixelPerfect", UpdatePixelPerfect)

---@param which string?
local function PetFrame_UpdateVisibility(which)
    U:UpdateUnitFrameVisibility(which, unit, petButton, petFrame)
end
Cell:RegisterCallback("UpdateVisibility", "PetFrame_UpdateVisibility", PetFrame_UpdateVisibility)
CUF:RegisterCallback("UpdateVisibility", "PetFrame_UpdateVisibility", PetFrame_UpdateVisibility)
