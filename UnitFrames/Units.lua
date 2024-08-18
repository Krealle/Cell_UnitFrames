---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local P = Cell.pixelPerfectFuncs

---@class CUF.uFuncs
local U = CUF.uFuncs

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param unit Unit
---@param unitFrame CUFUnitFrame
---@return CUFUnitButton
local function CreateUnitButton(unit, unitFrame)
    local name = CUF.constants.TITLE_CASED_UNITS[unit]
    local button = CreateFrame("Button",
        "CUF_" .. name,
        unitFrame,
        "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]
    button:SetAttribute("unit", unit)
    button:SetPoint("TOPLEFT")

    button.name = name
    CUF.unitButtons[unit] = button
    return button
end

-------------------------------------------------
-- MARK: Register Callbacks
-------------------------------------------------

-- Register callbacks: UpdateMenu, UpdateLayout, UpdatePixelPerfect, UpdateVisibility, UpdateUnitButtons
---@param unit Unit
---@param button CUFUnitButton
---@param unitFrame CUFUnitFrame
---@param anchorFrame CUFAnchorFrame
---@param hoverFrame CUFHoverFrame
---@param config CUFConfigButton
local function RegisterUnitButtonCallbacks(unit, button, unitFrame, anchorFrame, hoverFrame, config)
    ---@param kind ("lock" | "fadeOut" | "position")?
    local function UpdateMenu(kind)
        U:UpdateUnitButtonMenu(kind, unit, button, anchorFrame, config)
    end
    CUF:RegisterCallback("UpdateMenu", L[unit] .. "Frame_UpdateMenu", UpdateMenu)

    ---@param kind string?
    local function UpdateLayout(_, kind)
        U:UpdateUnitButtonLayout(unit, kind, button, anchorFrame)
    end
    CUF:RegisterCallback("UpdateLayout", L[unit] .. "Frame_UpdateLayout", UpdateLayout)

    local function UpdatePixelPerfect()
        P:Resize(unitFrame)
        P:Resize(anchorFrame)
        config:UpdatePixelPerfect()
    end
    CUF:RegisterCallback("UpdatePixelPerfect", L[unit] .. "Frame_UpdatePixelPerfect", UpdatePixelPerfect)

    ---@param which string? Frame name (unit)
    local function UnitFrame_UpdateVisibility(which)
        U:UpdateUnitFrameVisibility(which, unit, button, unitFrame)
    end
    CUF:RegisterCallback("UpdateVisibility", L[unit] .. "Frame_UpdateVisibility", UnitFrame_UpdateVisibility)

    -- Call all callback functions and do a full update
    local function UpdateUnitButtons()
        UpdateMenu()
        UpdateLayout()
        UpdatePixelPerfect()
        UnitFrame_UpdateVisibility()
    end
    CUF:RegisterCallback("UpdateUnitButtons", L[unit] .. "UpdateUnitButtons", UpdateUnitButtons)
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

-- Initialize unit buttons
function U:InitUnitButtons()
    for _, unit in pairs(CUF.constants.UNIT) do
        local unitFrame, anchorFrame, hoverFrame, config = U:CreateBaseUnitFrame(unit)
        local button = CreateUnitButton(unit, unitFrame)

        RegisterUnitButtonCallbacks(unit, button, unitFrame, anchorFrame, hoverFrame, config)

        button:SetAttribute('*type1', 'target')     -- makes left click target the unit
        button:SetAttribute('*type2', 'togglemenu') -- makes right click toggle a unit menu
    end
end
