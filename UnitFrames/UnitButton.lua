---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.uFuncs
local U = CUF.uFuncs

local W = CUF.widgets
local const = CUF.constants
local Util = CUF.Util
local DB = CUF.DB
local P = CUF.PixelPerfect

local MAX_BOSS_FRAMES = 10 -- MAX_BOSS_FRAMES or 5

-------------------------------------------------
-- MARK: Button Position
-------------------------------------------------

--- Save the position of a unit button
--- Clamps the position to the screen size
---@param unit Unit
---@param x number
---@param y number
function U:SavePosition(unit, x, y)
    local layout = CUF.DB.CurrentLayoutTable()
    local unitLayout = layout[unit]

    local maxX, maxY = GetPhysicalScreenSize()

    if x > maxX / 2 then
        x = maxX
    end
    if y > maxY / 2 then
        y = maxY
    end

    unitLayout.position = { x, y }

    CUF:Fire("UpdateLayout", nil, "position", unit)
end

---@param unit Unit
---@param button CUFUnitButton
function U:UpdateUnitButtonPosition(unit, button)
    if button.__customPositioning then return end

    local layout = CUF.DB.CurrentLayoutTable()
    local unitLayout = layout[unit]

    P.ClearPoints(button)
    if unitLayout.anchorToParent then
        local parent = CUF.unitButtons[unitLayout.parent]
        local anchor = unitLayout.anchorPosition --[[@as ParentAnchor]]

        P.Point(button, anchor.point, parent, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
    else
        -- Anchor 'child' buttons to 'parent' button
        local unitN = tonumber(string.match(button._unit, "%d+"))
        if unitN then
            if unitN > 1 then
                local parent = CUF.unitButtons[unit][unit .. unitN - 1]
                if not parent then
                    CUF:Warn("Parent button not found for child button", button:GetName())
                    return
                end

                local spacing = unitLayout.spacing or 0

                if unitLayout.growthDirection == const.GROWTH_ORIENTATION.TOP_TO_BOTTOM then
                    P.Point(button, "TOPLEFT", parent, "BOTTOMLEFT", 0, -spacing)
                elseif unitLayout.growthDirection == const.GROWTH_ORIENTATION.BOTTOM_TO_TOP then
                    P.Point(button, "BOTTOMLEFT", parent, "TOPLEFT", 0, spacing)
                elseif unitLayout.growthDirection == const.GROWTH_ORIENTATION.LEFT_TO_RIGHT then
                    P.Point(button, "LEFT", parent, "RIGHT", spacing, 0)
                else
                    P.Point(button, "RIGHT", parent, "LEFT", -spacing, 0)
                end

                return
            end
        end

        local x, y
        if unit == const.UNIT.TARGET and unitLayout.mirrorPlayer then
            x, y = -layout[const.UNIT.PLAYER].position[1], layout[const.UNIT.PLAYER].position[2]
        else
            x, y = unpack(unitLayout.position)
        end

        P.Point(button, "CENTER", UIParent, "CENTER", x, y)
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
    if (not kind or string.find(kind, "size$")) and not button.__customSize then
        local width, height
        if layout[unit].sameSizeAsPlayer then
            width, height = unpack(layout[const.UNIT.PLAYER].size)
        else
            width, height = unpack(layout[unit].size)
        end

        P.Size(button, width, height)
    end

    if not kind or kind == "barOrientation" then
        U:SetOrientation(button, layout[unit].barOrientation, false, layout[unit].reverseHealthFill)
    end

    if not kind or kind == "position" or kind == "spacing" or kind == "growthDirection" then
        U:UpdateUnitButtonPosition(unit, button)
    end

    if kind == "powerFilter" then
        button.widgets.powerBar.Update(button)
        button.widgets.powerText.Update(button)
    end

    if not kind or kind == "alwaysUpdate" then
        button.alwaysUpdate = layout[unit].alwaysUpdate
    end

    if not kind or kind == "colorType" then
        button.healthBarColorType = layout[unit].healthBarColorType
        button.healthLossColorType = layout[unit].healthLossColorType
        U:UnitFrame_UpdateHealthColor(button, true)
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
            local visibility = DB.CurrentLayoutTable()[unit].visibility
            if visibility ~= "" then
                UnregisterUnitWatch(button)
                RegisterAttributeDriver(button, 'state-visibility',
                    "[@" .. button._unit .. ",noexists]hide;" .. visibility)
            else
                RegisterUnitWatch(button)
            end
            frame:Show()
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
---@param reverseHealthFill boolean
function U:SetOrientation(button, orientation, rotateTexture, reverseHealthFill)
    local healthBar = button.widgets.healthBar
    local healthBarLoss = button.widgets.healthBarLoss

    button.orientation = orientation
    if orientation == "vertical_health" then
        healthBar:SetOrientation("VERTICAL")
    else
        healthBar:SetOrientation(orientation)
    end
    healthBar:SetRotatesTexture(rotateTexture)
    healthBar:SetReverseFill(reverseHealthFill)

    if rotateTexture then
        F.RotateTexture(healthBarLoss, 90)
    else
        F.RotateTexture(healthBarLoss, 0)
    end

    P.ClearPoints(button.widgets.healthBar)
    if orientation == "horizontal" then
        P.Point(button.widgets.healthBar, "TOPLEFT", button, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P.Point(button.widgets.healthBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -CELL_BORDER_SIZE,
            CELL_BORDER_SIZE)

        -- update healthBarLoss
        P.ClearPoints(healthBarLoss)
        if reverseHealthFill then
            P.Point(healthBarLoss, "TOPLEFT", healthBar)
            P.Point(healthBarLoss, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "BOTTOMLEFT")
        else
            P.Point(healthBarLoss, "TOPRIGHT", healthBar)
            P.Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
        end
    else -- vertical / vertical_health
        P.Point(button.widgets.healthBar, "TOPLEFT", button, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P.Point(button.widgets.healthBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -CELL_BORDER_SIZE,
            CELL_BORDER_SIZE)

        P.ClearPoints(healthBarLoss)
        if reverseHealthFill then
            P.Point(healthBarLoss, "BOTTOMRIGHT", healthBar)
            P.Point(healthBarLoss, "TOPLEFT", healthBar:GetStatusBarTexture(), "BOTTOMLEFT")
        else
            P.Point(healthBarLoss, "TOPRIGHT", healthBar)
            P.Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
        end
    end

    -- update actions
    --I.UpdateActionsOrientation(button, orientation)

    if button:HasWidget(const.WIDGET_KIND.SHIELD_BAR) then
        W.UpdateShieldBarWidget(button, button._baseUnit)
    end
    if button:HasWidget(const.WIDGET_KIND.HEAL_ABSORB) then
        button.widgets.healAbsorb:SetOrientation(orientation)
    end
    if button:HasWidget(const.WIDGET_KIND.HEAL_PREDICTION) then
        W.UpdateHealPredictionWidget(button, button._baseUnit)
    end
end

-------------------------------------------------
-- MARK: Update Appearance
-------------------------------------------------

---@param kind ("texture"|"color"|"fullColor"|"deathColor"|"animation"|"highlightColor"|"highlightSize"|"alpha"|"outOfRangeAlpha"|"shields"|"scale")?
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
            U:UnitFrame_UpdateHealthColor(button, true)
            button.widgets.powerBar:UpdateColorOptions()
            if button.healthBarColorType == const.UnitButtonColorType.CELL then
                button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
            else
                button:SetBackdropColor(0, 0, 0, DB.GetColors().unitFrames.backgroundAlpha)
            end
        end)
    end
    if not kind or kind == "fullColor" then
        -- Most likely a better way to do this
        -- But it resolves a race condition so yea...
        C_Timer.After(0.01, function()
            ---@param button CUFUnitButton
            Util:IterateAllUnitButtons(function(button)
                U:UnitFrame_UpdateHealthColor(button, true)
                button.widgets.powerBar:UpdateColorOptions()
            end)
        end)
    end
    if kind == "scale" then
        -- Full update for everything
        -- Needs to be delayed
        C_Timer.After(0.1, function()
            if InCombatLockdown() then
                CUF:AddEventListener("PLAYER_REGEN_ENABLED", function()
                    UpdateAppearance("scale")
                    return true
                end)

                return
            end

            CUF.PixelPerfect.SetPixelScale(CUF.mainFrame)
            CUF:Fire("UpdateUnitButtons")
        end)
    end
end
CUF:RegisterCallback("UpdateAppearance", "UpdateAppearance", UpdateAppearance)

-------------------------------------------------
-- MARK: Update Click Casting
-------------------------------------------------

local previousClickCastings

local function GetMouseWheelBindKey(fullKey, noTypePrefix)
    local modifier, key = string.match(fullKey, "^(.*)type%-(.+)$")
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
        if string.find(bindKey, "SCROLL") then
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
                F.UpdateClickCastings(noReload, onlyqueued)
                local snippet = F.GetBindingSnippet()
                --CUF:DevAdd(snippet, "snippet")
                F.UpdateClickCastOnFrame(button, snippet)
            else
                ClearClickCastings(button)

                button:SetAttribute('*type1', 'target')     -- makes left click target the unit
                button:SetAttribute('*type2', 'togglemenu') -- makes right click toggle a unit menu
            end
        end
    end)

    previousClickCastings = F.Copy(Cell.vars.clickCastings["useCommon"] and Cell.vars.clickCastings["common"] or
        Cell.vars.clickCastings[Cell.vars.playerSpecID])
end

CUF:RegisterCallback("UpdateClickCasting", "UpdateClickCasting", U.UpdateClickCasting)

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param unit Unit
---@param index number? unitN index
---@return CUFUnitButton
---@return CUFUnitFrame CUFUnitFrame
local function CreateUnitButton(unit, index)
    local name = CUF.constants.TITLE_CASED_UNITS[unit]

    local unitN = unit
    if index then
        unitN = unit .. index
        name = name .. index
    end

    ---@class CUFUnitFrame: Frame
    local frame = CreateFrame("Frame", "CUF_" .. name .. "_Frame", CUF.mainFrame, "SecureFrameTemplate")

    local button = CreateFrame("Button",
        "CUF_" .. name,
        frame,
        "CUFUnitButtonTemplate") --[[@as CUFUnitButton]]

    button:SetPoint("TOPLEFT")
    button:SetClampedToScreen(true)

    button.name = name
    -- Used for unitN buttons where we need to reference the base unit
    button._baseUnit = unit
    button._unit = unitN

    button:SetAttribute("unit", unitN)

    if index then
        CUF.unitButtons[unit][unitN] = button
    else
        CUF.unitButtons[unit] = button
    end

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
        if unit == "boss" then
            CUF.unitButtons.boss = {}
            for i = 1, MAX_BOSS_FRAMES do
                local button, unitFrame = CreateUnitButton(unit, i)
                RegisterUnitButtonCallbacks(unit, button, unitFrame)
                button._previewUnit = "player"
            end
        else
            local button, unitFrame = CreateUnitButton(unit)
            RegisterUnitButtonCallbacks(unit, button, unitFrame)
        end
    end
end
