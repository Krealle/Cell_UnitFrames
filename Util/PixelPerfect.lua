---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

---@class CUF.PixelPerfect
local PixelPerfect = CUF.PixelPerfect

---@return number
function PixelPerfect.GetPixelScale()
    local width, height = GetPhysicalScreenSize()
    if height then
        return 768 / height
    else
        return 1
    end
end

---@param frame Frame
function PixelPerfect.SetPixelScale(frame)
    if CUF.vars.useScaling then
        P:SetEffectiveScale(CUF.mainFrame)
    else
        frame:SetScale(PixelPerfect.GetPixelScale())
    end
end

--- Calculates the nearest pixel size of a number
---@param number number
---@return number
function PixelPerfect.GetNearestPixelSize(number)
    return PixelUtil.GetNearestPixelSize(number, 1)
end

--- Calculates the relative position of a frame to the center of the UIParent
---@param frame Frame
---@return number, number
function PixelPerfect.GetPositionRelativeToScreenCenter(frame)
    -- Get the center of the frame and normalize the coords
    -- We need to round the coords to reduce any small pixel discrepancies
    local frameX, frameY = frame:GetCenter()
    local normX = math.floor(PixelPerfect.GetNearestPixelSize(frameX))
    local normY = math.floor(PixelPerfect.GetNearestPixelSize(frameY))

    local uiCenterX, uiCenterY = UIParent:GetCenter()

    local scale = PixelPerfect.Scale(1)

    local relativeX = normX - (uiCenterX * scale)
    local relativeY = normY - (uiCenterY * scale)

    return relativeX, relativeY
end

---@param num number
function PixelPerfect.Scale(num)
    if CUF.vars.useScaling then
        return P:Scale(num)
    end

    return num
end

---@param frame Frame
---@param width number
---@param height number
function PixelPerfect.Size(frame, width, height)
    if CUF.vars.useScaling then
        P:Size(frame, width, height)
    else
        frame:SetSize(width, height)
    end
end

---@param frame Frame|Texture
function PixelPerfect.Point(frame, ...)
    if CUF.vars.useScaling then
        P:Point(frame, ...)
    else
        frame:SetPoint(...)
    end
end

---@param frame Frame|Texture
function PixelPerfect.ClearPoints(frame)
    if CUF.vars.useScaling then
        P:ClearPoints(frame)
    else
        frame:ClearAllPoints()
    end
end
