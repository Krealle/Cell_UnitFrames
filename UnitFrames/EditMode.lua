---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

---@class CUF.uFuncs
local U = CUF.uFuncs

local const = CUF.constants
local Util = CUF.Util
local L = CUF.L

-------------------------------------------------
-- MARK: Positioning Popup
-------------------------------------------------

---@type CUFPositioningPopup
local positioningPopup

local function CreatePositioningPopup()
    ---@class CUFPositioningPopup: Frame
    ---@field unit Unit
    positioningPopup = CUF:CreateFrame("CUFPositioningPopup", UIParent, 340, 160)
    positioningPopup:SetPoint("CENTER")
    positioningPopup:Hide()

    positioningPopup:SetMovable(true)
    positioningPopup:EnableMouse(true)
    positioningPopup:RegisterForDrag("LeftButton")
    positioningPopup:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    positioningPopup:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local closeBtn = Cell:CreateButton(positioningPopup, "×", "red", { 18, 18 }, false, false, "CELL_FONT_SPECIAL",
        "CELL_FONT_SPECIAL")
    closeBtn:SetPoint("TOPRIGHT", P:Scale(-5), P:Scale(-1))
    closeBtn:SetScript("OnClick", function() positioningPopup:Hide() end)

    local title = positioningPopup:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)
    positioningPopup.title = title

    -- Offsets
    local maxX, maxY = GetPhysicalScreenSize()
    local xVal = maxX / 2
    local yVal = maxY / 2

    positioningPopup.xPosSlider = Cell:CreateSlider(L["X Offset"], positioningPopup, -xVal, xVal, 150, 1)
    positioningPopup.xPosSlider:SetPoint("TOPLEFT", 10, -45)
    positioningPopup.xPosSlider.onValueChangedFn = function(value)
        CUF.DB.CurrentLayoutTable()[positioningPopup.unit].position[1] = value
        CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)

        if positioningPopup.unit == const.UNIT.PLAYER then
            CUF:Fire("UpdateLayout", nil, "position", const.UNIT.TARGET)
        end
    end

    positioningPopup.yPosSlider = Cell:CreateSlider(L["Y Offset"], positioningPopup, -yVal, yVal, 150, 1)
    positioningPopup.yPosSlider:SetPoint("TOPLEFT", positioningPopup.xPosSlider, "TOPRIGHT", 20, 0)

    positioningPopup.yPosSlider.onValueChangedFn = function(value)
        CUF.DB.CurrentLayoutTable()[positioningPopup.unit].position[2] = value
        CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)

        if positioningPopup.unit == const.UNIT.PLAYER then
            CUF:Fire("UpdateLayout", nil, "position", const.UNIT.TARGET)
        end
    end

    -- Mirror
    ---@type CheckButton
    local mirrorCB = Cell:CreateCheckButton(positioningPopup, L.MirrorPlayer, function(checked)
        CUF.DB.CurrentLayoutTable()[const.UNIT.TARGET].mirrorPlayer = checked
        U:UpdateUnitButtonPosition("target", CUF.unitButtons.target)
        positioningPopup.xPosSlider:SetEnabled(not checked)
        positioningPopup.yPosSlider:SetEnabled(not checked)
    end)
    mirrorCB:SetPoint("TOPLEFT", positioningPopup.xPosSlider, "BOTTOMLEFT", 0, -40)
    positioningPopup.mirrorCB = mirrorCB

    -- Parent Anchor
    local parentAnchorFrame = CreateFrame("Frame", nil, positioningPopup)

    ---@type CellCheckButton
    local anchorToParentCB = Cell:CreateCheckButton(parentAnchorFrame, "", function(checked)
        CUF.DB.CurrentLayoutTable()[positioningPopup.unit].anchorToParent = checked
        U:UpdateUnitButtonPosition("target", CUF.unitButtons.target)
        CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)

        positioningPopup.pointDropdown:SetEnabled(checked)
        positioningPopup.relativeDropdown:SetEnabled(checked)
        positioningPopup.parentOffsetXSlider:SetEnabled(checked)
        positioningPopup.parentOffsetYSlider:SetEnabled(checked)

        positioningPopup.xPosSlider:SetEnabled(not checked)
        positioningPopup.yPosSlider:SetEnabled(not checked)
    end)
    anchorToParentCB:SetPoint("TOPLEFT", positioningPopup.xPosSlider, "BOTTOMLEFT", 0, -40)
    positioningPopup.anchorToParentCB = anchorToParentCB

    ---@type CellDropdown
    local pointDropdown = Cell:CreateDropdown(parentAnchorFrame, 117)
    pointDropdown:SetPoint("TOPLEFT", anchorToParentCB, "BOTTOMLEFT", 0, -30)
    pointDropdown:SetLabel(L["Anchor Point"])

    ---@type CellDropdown
    local relativePointDropdown = Cell:CreateDropdown(parentAnchorFrame, 117)
    relativePointDropdown:SetPoint("TOPLEFT", pointDropdown, "TOPRIGHT", 30, 0)
    relativePointDropdown:SetLabel(L["To UnitButton's"])

    for _, point in pairs(const.ANCHOR_POINTS) do
        pointDropdown:AddItem({
            text = L[point],
            value = point,
            onClick = function()
                CUF.DB.CurrentLayoutTable()[positioningPopup.unit].anchorPosition.point = point
                CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)
            end,
        })
        relativePointDropdown:AddItem({
            text = L[point],
            value = point,
            onClick = function()
                CUF.DB.CurrentLayoutTable()[positioningPopup.unit].anchorPosition.relativePoint = point
                CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)
            end,
        })
    end

    local parentOffsetXSlider = Cell:CreateSlider(L["X Offset"], parentAnchorFrame, -xVal, xVal, 150, 1)
    parentOffsetXSlider:SetPoint("TOPLEFT", pointDropdown, "BOTTOMLEFT", 0, -30)
    parentOffsetXSlider.onValueChangedFn = function(value)
        CUF.DB.CurrentLayoutTable()[positioningPopup.unit].anchorPosition.offsetX = value
        CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)
    end

    local parentOffsetYSlider = Cell:CreateSlider(L["Y Offset"], parentAnchorFrame, -yVal, yVal, 150, 1)
    parentOffsetYSlider:SetPoint("TOPLEFT", parentOffsetXSlider, "TOPRIGHT", 20, 0)
    parentOffsetYSlider.onValueChangedFn = function(value)
        CUF.DB.CurrentLayoutTable()[positioningPopup.unit].anchorPosition.offsetY = value
        CUF:Fire("UpdateLayout", nil, "position", positioningPopup.unit)
    end

    positioningPopup.parentAnchorFrame = parentAnchorFrame
    positioningPopup.pointDropdown = pointDropdown
    positioningPopup.relativeDropdown = relativePointDropdown
    positioningPopup.parentOffsetXSlider = parentOffsetXSlider
    positioningPopup.parentOffsetYSlider = parentOffsetYSlider
end

local function UpdatePositioningPopup()
    if not positioningPopup then return end
    local unit = positioningPopup.unit
    local layout = CUF.DB.CurrentLayoutTable()[unit]

    positioningPopup.xPosSlider:SetValue(layout.position[1])
    positioningPopup.yPosSlider:SetValue(layout.position[2])

    local isMirrored = layout.mirrorPlayer or false

    if unit == const.UNIT.TARGET then
        positioningPopup.mirrorCB:SetChecked(isMirrored)
        positioningPopup.mirrorCB:Show()
    else
        positioningPopup.mirrorCB:Hide()
    end

    if layout.anchorToParent ~= nil then
        local checked = layout.anchorToParent

        positioningPopup.anchorToParentCB:SetChecked(checked)
        positioningPopup.anchorToParentCB.label:SetText(L["Anchor To"] .. " " .. L[layout.parent])

        positioningPopup.pointDropdown:SetSelectedValue(layout.anchorPosition.point)
        positioningPopup.relativeDropdown:SetSelectedValue(layout.anchorPosition
            .relativePoint)
        positioningPopup.parentOffsetXSlider:SetValue(layout.anchorPosition.offsetX)
        positioningPopup.parentOffsetYSlider:SetValue(layout.anchorPosition.offsetY)

        positioningPopup.pointDropdown:SetEnabled(checked)
        positioningPopup.relativeDropdown:SetEnabled(checked)
        positioningPopup.parentOffsetXSlider:SetEnabled(checked)
        positioningPopup.parentOffsetYSlider:SetEnabled(checked)

        positioningPopup.xPosSlider:SetEnabled(not checked)
        positioningPopup.yPosSlider:SetEnabled(not checked)
    else
        positioningPopup.xPosSlider:SetEnabled(not isMirrored)
        positioningPopup.yPosSlider:SetEnabled(not isMirrored)
    end
end

---@param unit Unit
local function ShowPositioningPopup(unit)
    if not positioningPopup then
        CreatePositioningPopup()
    end
    positioningPopup:Show()
    positioningPopup.title:SetText(L.Positioning .. ": " .. L[unit])

    positioningPopup.unit = unit

    if CUF.DB.CurrentLayoutTable()[unit].anchorToParent ~= nil then
        positioningPopup.parentAnchorFrame:Show()
        positioningPopup:SetHeight(230)
    else
        positioningPopup.parentAnchorFrame:Hide()
        if unit == const.UNIT.TARGET then
            positioningPopup:SetHeight(120)
        else
            positioningPopup:SetHeight(85)
        end
    end

    UpdatePositioningPopup()

    CUF:RegisterCallback("UpdateUnitButtons", "UpdatePositioningPopup", UpdatePositioningPopup)
    CUF:RegisterCallback("UpdateLayout", "UpdatePositioningPopup", UpdatePositioningPopup)
end

local function HidePositioningPopup()
    if positioningPopup then
        positioningPopup:Hide()
    end

    CUF:UnregisterCallback("UpdateUnitButtons", "UpdatePositioningPopup")
    CUF:UnregisterCallback("UpdateLayout", "UpdatePositioningPopup")
end

-------------------------------------------------
-- MARK: Overlay
-------------------------------------------------

---@type table<Unit, CUFOverlayBox>
local overlays = {}

local colors = {
    [const.UNIT.PLAYER] = { 1, 0, 0 },
    [const.UNIT.TARGET] = { 1, 0.5, 0 },
    [const.UNIT.TARGET_TARGET] = { 1, 1, 0 },
    [const.UNIT.FOCUS] = { 0, 1, 0 },
    [const.UNIT.PET] = { 0, 0.5, 1 },
}

---@param button CUFUnitButton
---@param unit Unit
---@param unitN number?
---@param parentButton CUFUnitButton?
local function CreateOverlayBox(button, unit, unitN, parentButton)
    ---@class CUFOverlayBox: CellButton
    local overlay = CUF:CreateButton(UIParent, "", { 1, 1 },
        function() ShowPositioningPopup(unit) end, "accent")
    overlay:SetAllPoints(button)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(overlay:GetFrameLevel() + 100)
    overlay:Hide()
    overlay:SetClampedToScreen(true)

    local label = overlay:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    label:SetPoint("CENTER")
    label:SetText(L[unit] .. (unitN or ""))

    if parentButton then
        button = parentButton
    end

    -- Register mouse and movable
    overlay:RegisterForDrag("LeftButton")
    overlay:SetMovable(true)
    button:SetMovable(true)

    -- Animation
    overlay.fadeIn = overlay:CreateAnimationGroup()
    local fadeIn = overlay.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetScript("OnPlay", function()
        overlay:Show()
    end)

    overlay.fadeOut = overlay:CreateAnimationGroup()
    local fadeOut = overlay.fadeOut:CreateAnimation("alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        overlay:Hide()
    end)

    -- Scripts
    overlay:SetScript("OnDragStart", function()
        button:StartMoving()
    end)
    overlay:SetScript("OnDragStop", function()
        button:StopMovingOrSizing()

        local x, y = Util.GetPositionRelativeToScreenCenter(button)
        U:SavePosition(unit, x, y)

        if unit == const.UNIT.PLAYER then
            CUF:Fire("UpdateLayout", nil, "position", const.UNIT.TARGET)
        end

        if Util:ButtonIsAnchoredToParent(unit) then
            CUF.DB.CurrentLayoutTable()[unit].anchorToParent = false
            CUF:Fire("UpdateLayout", nil, "position", unit)
        end

        if Util:ButtonIsMirrored(unit) then
            CUF.DB.CurrentLayoutTable()[unit].mirrorPlayer = false
            CUF:Fire("UpdateLayout", nil, "position", unit)
        end

        UpdatePositioningPopup()
    end)

    -- Hooks
    overlay:HookScript("OnShow", function()
        button:SetMovable(true)
    end)
    overlay:HookScript("OnHide", function()
        button:SetMovable(false)
    end)

    local overlayUnit = unit .. (unitN or "")
    overlays[overlayUnit] = overlay
    return overlay
end

--- Play the fade out animation and hide the overlays
---
--- If instant is true, the overlays will be hidden instantly
---@param instant boolean?
local function HideOverlays(instant)
    for _, overlay in pairs(overlays) do
        if instant then
            overlay:Hide()
        else
            overlay.fadeOut:Play()
            if overlay.fadeIn:IsPlaying() then
                overlay.fadeIn:Stop()
            end
        end
    end
end

--- Play the fade in animation and show the overlays
local function ShowOverlays()
    for _, unit in pairs(CUF.constants.UNIT) do
        if unit == "boss" then
            local mainBossFrame = CUF.unitButtons.boss["boss1"]
            for i = 1, 5 do
                local overlay = overlays[unit .. i] or
                    CreateOverlayBox(CUF.unitButtons.boss[unit .. i], unit, i, mainBossFrame)

                overlay.fadeIn:Play()
                if overlay.fadeIn:IsPlaying() then
                    overlay.fadeIn:Stop()
                end
            end
            return
        end

        local overlay = overlays[unit] or CreateOverlayBox(CUF.unitButtons[unit], unit)

        if unit == "player" then
            CUF.HelpTips:Show(overlay, {
                text = L.HelpTip_EditModeOverlay,
                dbKey = "editModeOverlay",
                buttonStyle = HelpTip.ButtonStyle.GotIt,
                alignment = HelpTip.Alignment.Center,
                targetPoint = HelpTip.Point.TopEdgeCenter,
            })
        end

        overlay.fadeIn:Play()
        if overlay.fadeOut:IsPlaying() then
            overlay.fadeOut:Stop()
        end
    end
end

-------------------------------------------------
-- MARK: Cell Edit Mode
-------------------------------------------------

local CellAnchorFrameNames = {
    CellAnchorFrame = { name = "Main Frame", key = "main" },
    CellSeparateNPCFrameAnchor = { name = "Seperate NPC Frame", key = "npc" },
    CellRaidPetAnchorFrame = { name = "Raid Pet Frame", key = "pet" },
    CellSpotlightAnchorFrame = { name = "Spotlight Frame", key = "spotlight" },
    CellQuickAssistAnchorFrame = { name = "Quick Assist Frame" },
}

local cellPopup, HideCellEditModePopup

local function GetAnchorFrame()
    if not cellPopup then return end

    local anchor = cellPopup.frameDropdown:GetSelected()
    if not anchor then return end

    local anchorFrame = _G[anchor]
    if not anchorFrame then return end

    local key = CellAnchorFrameNames[cellPopup.frameDropdown:GetSelected()].key
    return anchorFrame, key
end

local function UpdateCellEditModePopup()
    if not cellPopup then return end

    local anchorFrame, key = GetAnchorFrame()
    if not anchorFrame then return end

    local x, y
    if key then
        x, y = unpack(Cell.vars.currentLayoutTable[key].position)
    else
        x, y = unpack(CellDB["quickAssist"][Cell.vars.playerSpecID].layout.position)
    end

    -- Disable Cell frame positioning if data is invalid
    -- Also print out some debug info to help with narrowing issues
    if not x or not y or type(x) ~= "number" or type(y) ~= "number" then
        CUF:Warn("Cell frame positioning disabled, due to invalid data.",
            "\nDebug info - frame:",
            Util.ColorWrap((cellPopup.frameDropdown:GetSelected() or "n/a"), "gold"),
            "key:", key, "x:", x, "y:", y)

        HideCellEditModePopup()
        return
    end

    cellPopup.xPosSlider:SetValue(x)
    cellPopup.yPosSlider:SetValue(y)
end

local function UpdateCellFramePosition()
    if not cellPopup then return end
    local x, y = cellPopup.xPosSlider:GetValue(), cellPopup.yPosSlider:GetValue()
    local anchorFrame, key = GetAnchorFrame()

    -- Use Cell functions directly to reduce chance of error
    P:LoadPosition(anchorFrame, { x, y })
    if key then
        P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable[key].position)
    else
        P:SavePosition(anchorFrame, CellDB["quickAssist"][Cell.vars.playerSpecID].layout.position)
    end
end

local function CreateCellEditModePopup()
    ---@class CUF_CellEditModePopup: Frame
    cellPopup = CUF:CreateFrame("CUF_CellEditModePopup", UIParent, 340, 150)
    cellPopup:SetPoint("CENTER", 0, 200)

    cellPopup:SetMovable(true)
    cellPopup:EnableMouse(true)
    cellPopup:RegisterForDrag("LeftButton")
    cellPopup:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    cellPopup:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local closeBtn = Cell:CreateButton(cellPopup, "×", "red", { 18, 18 }, false, false, "CELL_FONT_SPECIAL",
        "CELL_FONT_SPECIAL")
    closeBtn:SetPoint("TOPRIGHT", P:Scale(-5), P:Scale(-1))
    closeBtn:SetScript("OnClick", function() cellPopup:Hide() end)

    local title = cellPopup:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)
    title:SetText(L.CellEditMode)

    local subTitle = cellPopup:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
    subTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subTitle:SetText(L.CellEditModeTip)
    subTitle:SetScale(0.9)

    ---@type CellDropdown
    local frameDropdown = Cell:CreateDropdown(cellPopup, 200)
    frameDropdown:SetPoint("TOPLEFT", 10, -60)
    frameDropdown:SetLabel(L.Frame)

    -- Offsets
    local maxX, maxY = GetPhysicalScreenSize()

    local xPosSlider = Cell:CreateSlider(L["X Offset"], cellPopup, 0, maxX, 150, 1)
    xPosSlider:SetPoint("TOPLEFT", frameDropdown, "BOTTOMLEFT", 0, -30)
    local yPosSlider = Cell:CreateSlider(L["Y Offset"], cellPopup, 0, maxY, 150, 1)
    yPosSlider:SetPoint("TOPLEFT", xPosSlider, "TOPRIGHT", 20, 0)

    yPosSlider.onValueChangedFn = UpdateCellFramePosition
    xPosSlider.onValueChangedFn = UpdateCellFramePosition

    for anchorName, info in pairs(CellAnchorFrameNames) do
        frameDropdown:AddItem({
            text = L[info.name],
            value = anchorName,
            onClick = function()
                UpdateCellEditModePopup()
            end,
        })
    end

    frameDropdown:SetSelected(CellAnchorFrameNames.CellAnchorFrame.name)

    cellPopup.xPosSlider = xPosSlider
    cellPopup.yPosSlider = yPosSlider
    cellPopup.frameDropdown = frameDropdown
end

local function ShowCellEditModePopup()
    if not cellPopup then
        CreateCellEditModePopup()
    end
    cellPopup:Show()

    UpdateCellEditModePopup()

    CUF:RegisterCallback("UpdateLayout", "UpdateCellEditModePopup", UpdateCellEditModePopup)
end

HideCellEditModePopup = function()
    if cellPopup then
        cellPopup:Hide()
        CUF:UnregisterCallback("UpdateLayout", "UpdateCellEditModePopup")
    end
end

-------------------------------------------------
-- MARK: Edit Mode
-------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
    CUF.vars.inEditMode = false
    HideOverlays(true)
    HidePositioningPopup()
    HideCellEditModePopup()
end)

--- Enable or disable edit mode
---
--- If show is nil then the current state will be toggled
---@param show boolean?
function U:EditMode(show)
    if InCombatLockdown() then return end

    if show ~= nil then
        CUF.vars.inEditMode = show
    else
        CUF.vars.inEditMode = not CUF.vars.inEditMode
    end

    if CUF.vars.inEditMode then
        ShowOverlays()
        ShowCellEditModePopup()
        eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    else
        HideOverlays()
        HidePositioningPopup()
        HideCellEditModePopup()
        eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end
end
