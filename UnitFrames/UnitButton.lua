---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L
local B = Cell.bFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

-------------------------------------------------
-- unit button generics/helpers
-------------------------------------------------

function B:SaveTooltipPosition(unit, tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY)
    Cell.vars.currentLayoutTable[unit]["tooltipPosition"] = { tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY }
end

function B:CreateBaseUnitFrame(unit, configTitle, onEnterLogic)
    local name = unit:gsub("^%l", string.upper)
    local frame = CreateFrame("Frame", "Cell" .. name .. "Frame", Cell.frames.mainFrame, "SecureFrameTemplate")

    -- Anchor
    local anchorFrame = CreateFrame("Frame", "Cell" .. name .. "AnchorFrame", frame)
    PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)

    -- Hover
    local hoverFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
    hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
    hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
    hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)

    A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

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
        P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable[unit]["position"])
    end)
    config:HookScript("OnEnter", function()
        hoverFrame:GetScript("OnEnter")(hoverFrame)
        CellTooltip:SetOwner(config, "ANCHOR_NONE")

        local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = unpack(Cell.vars.currentLayoutTable[unit]
            ["tooltipPosition"])
        P:Point(CellTooltip, tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)

        CellTooltip:AddLine(L[configTitle])

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

function B:UpdateUnitButtonPosition(unit, button, anchorFrame)
    local layout = Cell.vars.currentLayoutTable

    local anchor
    if layout[unit]["sameSizeAsPlayer"] then
        anchor = layout["player"]["anchor"]
    else
        anchor = layout[unit]["anchor"]
    end

    button:ClearAllPoints()
    -- NOTE: detach from PreviewAnchor
    P:LoadPosition(anchorFrame, layout[unit]["position"])

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)

        if anchor == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            B:SaveTooltipPosition(unit, "TOPLEFT", "BOTTOMLEFT", 0, -3)
        elseif anchor == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            B:SaveTooltipPosition(unit, "TOPRIGHT", "BOTTOMRIGHT", 0, -3)
        elseif anchor == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            B:SaveTooltipPosition(unit, "BOTTOMLEFT", "TOPLEFT", 0, 3)
        elseif anchor == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            B:SaveTooltipPosition(unit, "BOTTOMRIGHT", "TOPRIGHT", 0, 3)
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            P:Point(button, "BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            B:SaveTooltipPosition(unit, "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0)
        elseif anchor == "BOTTOMRIGHT" then
            P:Point(button, "BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            B:SaveTooltipPosition(unit, "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0)
        elseif anchor == "TOPLEFT" then
            P:Point(button, "TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            B:SaveTooltipPosition(unit, "TOPRIGHT", "TOPLEFT", -3, 0)
        elseif anchor == "TOPRIGHT" then
            P:Point(button, "TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            B:SaveTooltipPosition(unit, "TOPLEFT", "TOPRIGHT", 3, 0)
        end
    end
end

function B:UpdateUnitButtonLayout(unit, which, button, anchorFrame)
    local layout = Cell.vars.currentLayoutTable

    -- Size
    if not which or strfind(which, "size$") then
        local width, height
        if layout[unit]["sameSizeAsPlayer"] then
            width, height = unpack(layout["player"]["size"])
        else
            width, height = unpack(layout[unit]["size"])
        end

        P:Size(button, width, height)
    end

    -- Anchor points
    if not which or strfind(which, "arrangement$") then
        local anchor
        if layout[unit]["sameSizeAsPlayer"] then
            anchor = layout["player"]["anchor"]
        else
            anchor = layout[unit]["anchor"]
        end

        -- anchors
        local anchorPoint
        if anchor == "BOTTOMLEFT" then
            anchorPoint = "TOPLEFT"
        elseif anchor == "BOTTOMRIGHT" then
            anchorPoint = "TOPRIGHT"
        elseif anchor == "TOPLEFT" then
            anchorPoint = "BOTTOMLEFT"
        elseif anchor == "TOPRIGHT" then
            anchorPoint = "BOTTOMRIGHT"
        end

        button:ClearAllPoints()
        button:SetPoint(anchor, anchorFrame, anchorPoint, 0)

        B:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        B:SetOrientation(button, layout["barOrientation"][1], layout["barOrientation"][2])
    end

    if not which or strfind(which, "power$") or which == "barOrientation" then
        if layout[unit]["sameSizeAsPlayer"] then
            B:SetPowerSize(button, layout["player"]["powerSize"])
        else
            B:SetPowerSize(button, layout[unit]["powerSize"])
        end
    end

    -- load position
    if not P:LoadPosition(anchorFrame, layout[unit]["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end

function B:UpdateUnitButtonMenu(which, unit, button, anchorFrame, config)
    if not which or which == "lock" then
        if CellDB["general"]["locked"] then
            config:RegisterForDrag()
        else
            config:RegisterForDrag("LeftButton")
        end
    end

    if not which or which == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            anchorFrame.fadeOut:Play()
        else
            anchorFrame.fadeIn:Play()
        end
    end

    if which == "position" then
        B:UpdateUnitButtonPosition(unit, button, anchorFrame)
    end
end

function B:UpdateUnitFrameVisibility(which, unit, button, frame)
    if not which or which == unit then
        if Cell.vars.currentLayoutTable[unit]["enabled"] then
            RegisterUnitWatch(button)
            frame:Show()
            --F:HideBlizzardUnitFrame(unit)
        else
            UnregisterUnitWatch(button)
            frame:Hide()
        end
    end
end
