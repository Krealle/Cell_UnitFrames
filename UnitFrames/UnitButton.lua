---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

---@class CUF.uFuncs
local U = CUF.uFuncs

local W = CUF.widgets
local const = CUF.constants
local Util = CUF.Util

-------------------------------------------------
-- MARK: Save Tooltip Position
-------------------------------------------------

---@param unit Unit
---@param tooltipPoint FramePoint
---@param tooltipRelativePoint FramePoint
---@param tooltipX number
---@param tooltipY number
function U:SaveTooltipPosition(unit, tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY)
    CUF.DB.CurrentLayoutTable()[unit].tooltipPosition = { tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY }
end

-------------------------------------------------
-- MARK: Create Unit Frame
-------------------------------------------------

---@param unit Unit
---@param onEnterLogic function?
---@return CUFUnitFrame CUFUnitFrame
---@return CUFAnchorFrame CUFAnchorFrame
---@return CUFHoverFrame CUFHoverFrame
---@return CUFConfigButton CUFConfigButton
function U:CreateBaseUnitFrame(unit, onEnterLogic)
    local name = Util:ToTitleCase(unit)

    ---@class CUFUnitFrame: Frame
    local frame = CreateFrame("Frame", "CUF" .. name .. "_Frame", Cell.frames.mainFrame, "SecureFrameTemplate")

    -- Anchor
    ---@class CUFAnchorFrame: Frame, CellAnimation
    local anchorFrame = CreateFrame("Frame", "CUF" .. name .. "_AnchorFrame", frame)
    PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)

    -- Hover
    ---@class CUFHoverFrame: Frame
    local hoverFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
    hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
    hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
    hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)

    A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

    ---@class CUFConfigButton: Button
    ---@field UpdatePixelPerfect function
    local config = Cell:CreateButton(anchorFrame, nil, "accent", { 20, 10 }, false, true, nil, nil,
        "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
    config:SetFrameStrata("MEDIUM")
    config:SetAllPoints(anchorFrame)
    config:RegisterForDrag("LeftButton")
    config:SetScript("OnDragStart", function()
        anchorFrame:StartMoving()
        anchorFrame:SetUserPlaced(false)
    end)
    config:SetScript("OnDragStop", function()
        anchorFrame:StopMovingOrSizing()
        P:SavePosition(anchorFrame, CUF.DB.CurrentLayoutTable()[unit].position)
    end)
    config:HookScript("OnEnter", function()
        hoverFrame:GetScript("OnEnter")(hoverFrame)
        CellTooltip:SetOwner(config, "ANCHOR_NONE")

        local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = unpack(CUF.DB.CurrentLayoutTable()[unit]
            .tooltipPosition)
        P:Point(CellTooltip, tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)

        CellTooltip:AddLine(L[unit] .. " " .. L.Frame)

        -- Execute additional logic passed to the function
        if type(onEnterLogic) == "function" then
            onEnterLogic(CellTooltip)
        end

        CellTooltip:Show()
    end)
    config:HookScript("OnLeave", function()
        hoverFrame:GetScript("OnLeave")(hoverFrame)
        CellTooltip:Hide()
    end)

    return frame, anchorFrame, hoverFrame, config
end

-------------------------------------------------
-- MARK: Button Position
-------------------------------------------------

---@param unit Unit
---@param button CUFUnitButton
---@param anchorFrame CUFAnchorFrame
function U:UpdateUnitButtonPosition(unit, button, anchorFrame)
    local layout = CUF.DB.CurrentLayoutTable()

    local anchorPoint
    if layout[unit].sameSizeAsPlayer then
        anchorPoint = layout[const.UNIT.PLAYER].point
    else
        anchorPoint = layout[unit].point
    end

    button:ClearAllPoints()
    -- NOTE: detach from PreviewAnchor
    P:LoadPosition(anchorFrame, layout[unit].position)

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)

        if anchorPoint == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            U:SaveTooltipPosition(unit, "TOPLEFT", "BOTTOMLEFT", 0, -3)
        elseif anchorPoint == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            U:SaveTooltipPosition(unit, "TOPRIGHT", "BOTTOMRIGHT", 0, -3)
        elseif anchorPoint == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            U:SaveTooltipPosition(unit, "BOTTOMLEFT", "TOPLEFT", 0, 3)
        elseif anchorPoint == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            U:SaveTooltipPosition(unit, "BOTTOMRIGHT", "TOPRIGHT", 0, 3)
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchorPoint == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            U:SaveTooltipPosition(unit, "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0)
        elseif anchorPoint == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            U:SaveTooltipPosition(unit, "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0)
        elseif anchorPoint == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            U:SaveTooltipPosition(unit, "TOPRIGHT", "TOPLEFT", -3, 0)
        elseif anchorPoint == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            U:SaveTooltipPosition(unit, "TOPLEFT", "TOPRIGHT", 3, 0)
        end
    end
end

-------------------------------------------------
-- MARK: Update Layout
-------------------------------------------------

---@param unit Unit
---@param kind string?
---@param button CUFUnitButton
---@param anchorFrame CUFAnchorFrame
function U:UpdateUnitButtonLayout(unit, kind, button, anchorFrame)
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

    -- Anchor points
    if not kind or strfind(kind, "arrangement$") then
        local anchorPoint
        if layout[unit].sameSizeAsPlayer then
            anchorPoint = layout[const.UNIT.PLAYER].point
        else
            anchorPoint = layout[unit].point
        end

        -- anchors
        local relativePoint
        if anchorPoint == "BOTTOMLEFT" then
            relativePoint = "TOPLEFT"
        elseif anchorPoint == "BOTTOMRIGHT" then
            relativePoint = "TOPRIGHT"
        elseif anchorPoint == "TOPLEFT" then
            relativePoint = "BOTTOMLEFT"
        elseif anchorPoint == "TOPRIGHT" then
            relativePoint = "BOTTOMRIGHT"
        end

        button:ClearAllPoints()
        button:SetPoint(anchorPoint, anchorFrame, relativePoint, 0)

        U:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not kind or kind == "barOrientation" then
        U:SetOrientation(button, Cell.vars.currentLayoutTable["barOrientation"][1],
            Cell.vars.currentLayoutTable["barOrientation"][2])
    end

    if not kind or strfind(kind, "power$") or kind == "barOrientation" then
        if layout[unit].sameSizeAsPlayer then
            W:SetPowerSize(button, layout[const.UNIT.PLAYER].powerSize)
        else
            W:SetPowerSize(button, layout[unit].powerSize)
        end
    end

    -- load position
    if not P:LoadPosition(anchorFrame, layout[unit].position) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end

-------------------------------------------------
-- MARK: Update Menu
-------------------------------------------------

---@param kind ("lock" | "fadeOut" | "position")?
---@param unit Unit
---@param button CUFUnitButton
---@param anchorFrame CUFAnchorFrame
---@param config CUFConfigButton
function U:UpdateUnitButtonMenu(kind, unit, button, anchorFrame, config)
    if not kind or kind == "lock" then
        if CellDB["general"]["locked"] then
            config:RegisterForDrag()
        else
            config:RegisterForDrag("LeftButton")
        end
    end

    if not kind or kind == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            anchorFrame.fadeOut:Play()
        else
            anchorFrame.fadeIn:Play()
        end
    end

    if kind == "position" then
        U:UpdateUnitButtonPosition(unit, button, anchorFrame)
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
        else
            UnregisterUnitWatch(button)
            frame:Hide()
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
        Util:IterateAllUnitButtons(function(button)
            U:UnitFrame_UpdateHealthColor(button)
            U:UnitFrame_UpdatePowerType(button)
        end)
    end
    if not kind or kind == "fullColor" then
        -- Most likely a better way to do this
        -- But it resolves a race condition so yea...
        C_Timer.After(0.01, function()
            Util:IterateAllUnitButtons(function(button)
                U:UnitFrame_UpdateHealthColor(button)
                U:UnitFrame_UpdatePowerType(button)
            end)
        end)
    end
end
Cell:RegisterCallback("UpdateAppearance", "CUF_UpdateAppearance", UpdateAppearance)
