---@class CUF
local CUF = select(2, ...)

---@class CUF.API
local API = CUF.API

--- Enables custom positioning for all unit frames.
--- If a specific unit or frame name is passed, only enables custom positioning for that frame.
---
--- Custom positioning prevents CUF from overriding the frame's position, allowing manual control.
---
--- Example usage:
--- ```
--- API:EnableCustomPositioningForUnitFrames("player")
---
--- or
---
--- API:EnableCustomPositioningForUnitFrames("CUF_Player")
---
--- or
---
--- API:EnableCustomPositioningForUnitFrames()
--- ```
---@param name string? Optional unit or frame name
function API:EnableCustomPositioningForUnitFrames(name)
    if name ~= nil then
        local unitFrame = API:GetUnitFrame(name)
        if not unitFrame then return end

        unitFrame.__customPositioning = true
        return
    end

    for _, unitFrame in pairs(CUF.unitButtons) do
        unitFrame.__customPositioning = true
    end
end

--- Disables custom positioning for all unit frames.
--- If a specific unit or frame name is passed, only disables custom positioning for that frame.
---
--- This function resets positioning back to the current layout managed by CUF.
---
--- Example usage:
--- ```
--- API:DisableCustomPositioningForUnitFrames("player")
---
--- or
---
--- API:DisableCustomPositioningForUnitFrames("CUF_Player")
---
--- or
---
--- API:DisableCustomPositioningForUnitFrames()
--- ```
---@param name string? Optional unit or frame name
function API:DisableCustomPositioningForUnitFrames(name)
    if name ~= nil then
        local unitFrame, unitName = API:GetUnitFrame(name)
        if not unitFrame then return end

        unitFrame.__customPositioning = false
        CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "position", unitName)

        return
    end

    for _, unitFrame in pairs(CUF.unitButtons) do
        unitFrame.__customPositioning = false
    end
    CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "position")
end

--- Returns the custom positioning status for a specific unit or frame.
--- If custom positioning is enabled, the function returns `true`. Otherwise, it returns `false`.
---
--- Example usage:
--- ```
--- local isCustomEnabled = API:GetCustomPositioningStatusForUnit("player")
---
--- or
---
--- local isCustomEnabled = API:GetCustomPositioningStatusForUnit("CUF_Player")
--- ```
---@param name string Unit or frame name
---@return boolean|nil status if custom positioning is enabled, otherwise false or nil if not found
function API:GetCustomPositioningStatusForUnit(name)
    local unitFrame = API:GetUnitFrame(name)
    if not unitFrame then return end

    return unitFrame.__customPositioning or false
end

--- Sets a custom position for a unit frame.
--- Automatically enables custom positioning, preventing CUF from overriding it.
---
--- Example usage:
--- ```
--- API:SetCustomUnitFramePoint("player", "TOPLEFT", MyFrame, "TOPLEFT", 0, 0)
---
--- or
---
--- API:SetCustomUnitFramePoint("CUF_Player", "TOPLEFT", MyFrame, "TOPLEFT", 0, 0)
--- ```
---@param name string Unit or frame name
---@param point string The point on the unit frame to anchor
---@param anchor Frame The frame to anchor the unit frame to
---@param relativePoint string The point on the anchor frame to which the unit frame is anchored
---@param offsetX number X offset relative to the anchor
---@param offsetY number Y offset relative to the anchor
function API:SetCustomUnitFramePoint(name, point, anchor, relativePoint, offsetX, offsetY)
    local params = {
        { point,         "FramePoint", "point" },
        { relativePoint, "FramePoint", "relativePoint" },
        { anchor,        "Frame",      "anchor" },
        { offsetX,       "number",     "offsetX" },
        { offsetY,       "number",     "offsetY" },
    }
    if not API:ValidateParms("SetCustomUnitFramePoint", params) then return end

    local unitFrame = API:GetUnitFrame(name)
    if not unitFrame then return end

    API:EnableCustomPositioningForUnitFrames(name)
    unitFrame:ClearAllPoints()

    unitFrame:SetPoint(point, anchor, relativePoint, offsetX, offsetY)
end

--- Sets a custom size for a unit frame.
--- Automatically enables custom sizing, preventing CUF from overriding it.
---
--- Example usage:
--- ```
--- API:SetCustomUnitFrameSize("player", 200, 200)
---
--- or
---
--- API:SetCustomUnitFrameSize("CUF_Player", 200, 200)
--- ```
---@param name string Unit or frame name
---@param width number The desired width for the frame
---@param height number The desired height for the frame
function API:SetCustomUnitFrameSize(name, width, height)
    local params = {
        { width,  "number", "width" },
        { height, "number", "height" },
    }
    if not API:ValidateParms("SetCustomUnitFrameSize", params) then return end

    local unitFrame = API:GetUnitFrame(name)
    if not unitFrame then return end

    unitFrame.__customSize = true
    unitFrame:SetSize(width, height)
end
