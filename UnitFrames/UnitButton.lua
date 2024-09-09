---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

---@class CUF.uFuncs
local U = CUF.uFuncs

local W = CUF.widgets
local const = CUF.constants
local Util = CUF.Util

-------------------------------------------------
-- MARK: Button Position
-------------------------------------------------

---@param unit Unit
---@param button CUFUnitButton
function U:UpdateUnitButtonPosition(unit, button)
    local layout = CUF.DB.CurrentLayoutTable()
    local unitLayout = layout[unit]

    button:ClearAllPoints()
    if unitLayout.anchorToParent then
        local parent = CUF.unitButtons[unitLayout.parent]
        local anchor = unitLayout.anchorPosition --[[@as ParentAnchor]]

        PixelUtil.SetPoint(button, anchor.point, parent, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
    else
        local x, y
        if unit == const.UNIT.TARGET and unitLayout.mirrorPlayer then
            x, y = -layout[const.UNIT.PLAYER].position[1], layout[const.UNIT.PLAYER].position[2]
        else
            x, y = unpack(unitLayout.position)
        end

        PixelUtil.SetPoint(button, "CENTER", UIParent, "CENTER", x, y)
    end
end

-------------------------------------------------
-- MARK: Update Layout
-------------------------------------------------

---@param unit Unit
---@param kind string?
---@param button CUFUnitButton
function U:UpdateUnitButtonLayout(unit, kind, button)
    local layout = CUF.DB.CurrentLayoutTable()

    -- Size
    if not kind or strfind(kind, "size$") then
        local width, height
        if layout[unit].sameSizeAsPlayer then
            width, height = unpack(layout[const.UNIT.PLAYER].size)
        else
            width, height = unpack(layout[unit].size)
        end

        P:Size(button, width, height)
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not kind or kind == "barOrientation" then
        U:SetOrientation(button, Cell.vars.currentLayoutTable.barOrientation[1],
            Cell.vars.currentLayoutTable.barOrientation[2])
    end

    if not kind or strfind(kind, "power$") or kind == "barOrientation" then
        if layout[unit].sameSizeAsPlayer then
            W:SetPowerSize(button, layout[const.UNIT.PLAYER].powerSize)
        else
            W:SetPowerSize(button, layout[unit].powerSize)
        end
    end

    if not kind or kind == "position" then
        U:UpdateUnitButtonPosition(unit, button)
    end
end

-------------------------------------------------
-- MARK: Update Visibility
-------------------------------------------------

---@param which string?
---@param unit Unit
---@param button CUFUnitButton
---@param frame CUFUnitFrame
function U:UpdateUnitFrameVisibility(which, unit, button, frame)
    if InCombatLockdown() then return end
    if not which or which == unit then
        if CUF.DB.CurrentLayoutTable()[unit].enabled then
            RegisterUnitWatch(button)
            frame:Show()
            CUF:HideBlizzardUnitFrame(unit)
        else
            UnregisterUnitWatch(button)
            frame:Hide()
            button:Hide()
        end
    end
end

-------------------------------------------------
-- MARK: Set Orientation
-------------------------------------------------

---@param button CUFUnitButton
---@param orientation string
---@param rotateTexture boolean
function U:SetOrientation(button, orientation, rotateTexture)
    local healthBar = button.widgets.healthBar
    local healthBarLoss = button.widgets.healthBarLoss
    local powerBar = button.widgets.powerBar
    local powerBarLoss = button.widgets.powerBarLoss
    --[[ local incomingHeal = button.widgets.incomingHeal
    local damageFlashTex = button.widgets.damageFlashTex
    local gapTexture = button.widgets.gapTexture
    local shieldBar = button.widgets.shieldBar
    local shieldBarR = button.widgets.shieldBarR
    local overShieldGlow = button.widgets.overShieldGlow
    local overShieldGlowR = button.widgets.overShieldGlowR
    local overAbsorbGlow = button.widgets.overAbsorbGlow
    local absorbsBar = button.widgets.absorbsBar ]]

    button.orientation = orientation
    if orientation == "vertical_health" then
        healthBar:SetOrientation("VERTICAL")
        powerBar:SetOrientation("HORIZONTAL")
    else
        healthBar:SetOrientation(orientation)
        powerBar:SetOrientation(orientation)
    end
    healthBar:SetRotatesTexture(rotateTexture)
    powerBar:SetRotatesTexture(rotateTexture)

    if rotateTexture then
        F:RotateTexture(healthBarLoss, 90)
        F:RotateTexture(powerBarLoss, 90)
    else
        F:RotateTexture(healthBarLoss, 0)
        F:RotateTexture(powerBarLoss, 0)
    end

    if orientation == "horizontal" then
        -- update healthBarLoss
        P:ClearPoints(healthBarLoss)
        P:Point(healthBarLoss, "TOPRIGHT", healthBar)
        P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update powerBarLoss
        P:ClearPoints(powerBarLoss)
        P:Point(powerBarLoss, "TOPRIGHT", powerBar)
        P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    else -- vertical / vertical_health
        P:ClearPoints(healthBarLoss)
        P:Point(healthBarLoss, "TOPRIGHT", healthBar)
        P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")

        if orientation == "vertical" then
            -- update powerBarLoss
            P:ClearPoints(powerBarLoss)
            P:Point(powerBarLoss, "TOPRIGHT", powerBar)
            P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "TOPLEFT")
        else -- vertical_health
            -- update powerBarLoss
            P:ClearPoints(powerBarLoss)
            P:Point(powerBarLoss, "TOPRIGHT", powerBar)
            P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
        end
    end

    -- update actions
    --I.UpdateActionsOrientation(button, orientation)
end

-------------------------------------------------
-- MARK: Update Appearance
-------------------------------------------------

---@param kind ("texture"|"color"|"fullColor"|"deathColor"|"animation"|"highlightColor"|"highlightSize"|"alpha"|"outOfRangeAlpha"|"shields")?
local function UpdateAppearance(kind)
    if not kind or kind == "texture" then
        Util:IterateAllUnitButtons(function(button)
            U:UnitFrame_UpdateHealthTexture(button)
            U:UnitFrame_UpdatePowerTexture(button)
        end)
    end
    if not kind or kind == "color" or kind == "deathColor" or kind == "alpha" then
        ---@param button CUFUnitButton
        Util:IterateAllUnitButtons(function(button)
            U:UnitFrame_UpdateHealthColor(button)
            button.widgets.powerBar.UpdatePowerType(button)
            button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
        end)
    end
    if not kind or kind == "fullColor" then
        -- Most likely a better way to do this
        -- But it resolves a race condition so yea...
        C_Timer.After(0.01, function()
            ---@param button CUFUnitButton
            Util:IterateAllUnitButtons(function(button)
                U:UnitFrame_UpdateHealthColor(button)
                button.widgets.powerBar.UpdatePowerType(button)
            end)
        end)
    end
    if not kind or kind == "outOfRangeAlpha" then
        Util:IterateAllUnitButtons(function(button)
            button:UpdateInRange(nil, true)
        end)
    end
end
CUF:RegisterCallback("UpdateAppearance", "UpdateAppearance", UpdateAppearance)

-------------------------------------------------
-- MARK: Update Click Casting
-------------------------------------------------

local previousClickCastings

local function GetMouseWheelBindKey(fullKey, noTypePrefix)
    local modifier, key = strmatch(fullKey, "^(.*)type%-(.+)$")
    modifier = string.gsub(modifier, "-", "")

    if noTypePrefix then
        return modifier .. key
    else
        return "type-" .. modifier .. key -- type-ctrlSCROLLUP
    end
end

---@param button CUFUnitButton
local function ClearClickCastings(button)
    if not previousClickCastings then return end
    button:SetAttribute("cell", nil)
    button:SetAttribute("menu", nil)
    for _, t in pairs(previousClickCastings) do
        local bindKey = t[1]
        if strfind(bindKey, "SCROLL") then
            bindKey = GetMouseWheelBindKey(t[1])
        end

        button:SetAttribute(bindKey, nil)
        local attr = string.gsub(bindKey, "type", "spell")
        button:SetAttribute(attr, nil)
        attr = string.gsub(bindKey, "type", "macro")
        button:SetAttribute(attr, nil)
        attr = string.gsub(bindKey, "type", "macrotext")
        button:SetAttribute(attr, nil)
        attr = string.gsub(bindKey, "type", "item")
        button:SetAttribute(attr, nil)
    end
end

---@param noReload boolean?
---@param onlyqueued boolean?
---@param which string?
function U.UpdateClickCasting(noReload, onlyqueued, which)
    Util:IterateAllUnitButtons(function(button, unit)
        if not which or which == unit then
            if CUF.DB.CurrentLayoutTable()[unit].clickCast then
                F:UpdateClickCastings(noReload, onlyqueued)
                local snippet = F:GetBindingSnippet()
                CUF:DevAdd(snippet, "snippet")
                F:UpdateClickCastOnFrame(button, snippet)
            else
                ClearClickCastings(button)

                button:SetAttribute('*type1', 'target')     -- makes left click target the unit
                button:SetAttribute('*type2', 'togglemenu') -- makes right click toggle a unit menu
            end
        end
    end)

    previousClickCastings = F:Copy(Cell.vars.clickCastings["useCommon"] and Cell.vars.clickCastings["common"] or
        Cell.vars.clickCastings[Cell.vars.playerSpecID])
end

CUF:RegisterCallback("UpdateClickCasting", "UpdateClickCasting", U.UpdateClickCasting)

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param unit Unit
---@return CUFUnitButton
---@return CUFUnitFrame CUFUnitFrame
local function CreateUnitButton(unit)
    local name = CUF.constants.TITLE_CASED_UNITS[unit]

    ---@class CUFUnitFrame: Frame
    local frame = CreateFrame("Frame", "CUF_" .. name .. "_Frame", Cell.frames.mainFrame, "SecureFrameTemplate")

    local button = CreateFrame("Button",
        "CUF_" .. name,
        frame,
        "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]
    button:SetAttribute("unit", unit)
    button:SetPoint("TOPLEFT")

    button.name = name
    CUF.unitButtons[unit] = button

    return button, frame
end

-------------------------------------------------
-- MARK: Register Callbacks
-------------------------------------------------

-- Register callbacks: UpdateLayout, UpdateVisibility, UpdateUnitButtons
---@param unit Unit
---@param button CUFUnitButton
---@param unitFrame CUFUnitFrame
local function RegisterUnitButtonCallbacks(unit, button, unitFrame)
    ---@param kind string?
    ---@param which Unit?
    local function UpdateLayout(_, kind, which)
        if not which or which == unit then
            U:UpdateUnitButtonLayout(unit, kind, button)
        end
    end
    CUF:RegisterCallback("UpdateLayout", button.name .. "Frame_UpdateLayout", UpdateLayout)

    ---@param which string? Frame name (unit)
    local function UnitFrame_UpdateVisibility(which)
        U:UpdateUnitFrameVisibility(which, unit, button, unitFrame)
    end
    CUF:RegisterCallback("UpdateVisibility", button.name .. "Frame_UpdateVisibility", UnitFrame_UpdateVisibility)

    -- Call all callback functions and do a full update
    local function UpdateUnitButtons()
        UpdateLayout()
        UnitFrame_UpdateVisibility()
    end
    CUF:RegisterCallback("UpdateUnitButtons", button.name .. "UpdateUnitButtons", UpdateUnitButtons)
end

-------------------------------------------------
-- MARK: Init
-------------------------------------------------

-- Initialize unit buttons
function U:InitUnitButtons()
    for _, unit in pairs(CUF.constants.UNIT) do
        local button, unitFrame = CreateUnitButton(unit)
        RegisterUnitButtonCallbacks(unit, button, unitFrame)
    end
end
