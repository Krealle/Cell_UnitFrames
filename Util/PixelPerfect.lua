---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local CellP = Cell.pixelPerfectFuncs

---@class CUF.PixelPerfect
local PixelPerfect = CUF.PixelPerfect

--- Debug

---@return string
function PixelPerfect.DebugInfo()
    local physicalScreenWidth, physicalScreenHeight = GetPhysicalScreenSize()
    local UIParentWidth, UIParentHeight = UIParent:GetSize()
    local UIParentScale = UIParent:GetEffectiveScale()
    local UIParentCenterX, UIParentCenterY = UIParent:GetCenter()
    local relativeScale = 1 / UIParent:GetEffectiveScale()

    local CellScale = CellDB["appearance"]["scale"] or -1

    local info = string.format(
        [[Screen size: %d x %d
    UIParent size: %d x %d
    UIParent center: %d x %d
    UIParent effective scale: %.6f
    Relative scale: %.6f
    GetPixelScale: %.6f
    Cell.Scale: %.3f
    Cell.GetPixelPerfectScale: %.6f | Cell.GetEffectiveScale: %.6f
    Cell.Scale(1): %.3f
    Cell.Scale(0.1): %.3f
    Cell.Scale(220): %.3f
        ]],
        physicalScreenWidth, physicalScreenHeight,
        UIParentWidth, UIParentHeight,
        UIParentCenterX, UIParentCenterY,
        UIParentScale,
        relativeScale,
        PixelPerfect.GetPixelScale(),
        CellScale,
        CellP:GetPixelPerfectScale(),
        CellP:GetEffectiveScale(),
        CellP:Scale(1),
        CellP:Scale(0.1),
        CellP:Scale(220)
    )

    return info
end

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
    if CUF_DB.useScaling then
        CellP:SetEffectiveScale(CUF.mainFrame)
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

    local physicalScreenWidth, physicalScreenHeight = GetPhysicalScreenSize()

    local scale = PixelPerfect.Scale(1)

    local relativeX = normX - ((physicalScreenWidth / 2) * scale)
    local relativeY = normY - ((physicalScreenHeight / 2) * scale)

    return relativeX, relativeY
end

---@param num number
---@return number
function PixelPerfect.Scale(num)
    if CUF_DB.useScaling then
        return CellP:Scale(num)
    end

    return num
end

---@param frame Frame|Texture
---@param width uiUnit
---@param height uiUnit
---@overload fun(frame: Frame|Texture, size: uiUnit)
function PixelPerfect.Size(frame, width, height)
    if not width then return end
    height = height or width

    if CUF_DB.useScaling then
        CellP:Size(frame, width, height)
    else
        frame:SetSize(width, height)
    end
end

---@param frame Frame|Texture
---@param width uiUnit
function PixelPerfect.Width(frame, width)
    if not width then return end

    if CUF_DB.useScaling then
        CellP:Width(frame, width)
    else
        frame:SetWidth(width)
    end
end

---@param frame Frame|Texture
---@param height uiUnit
function PixelPerfect.Height(frame, height)
    if not height then return end

    if CUF_DB.useScaling then
        CellP:Height(frame, height)
    else
        frame:SetHeight(height)
    end
end

---@param frame Frame|Texture|table
---@param point FramePoint
---@param relativeTo? any
---@param relativePoint? FramePoint
---@param offsetX? uiUnit
---@param offsetY? uiUnit
---@overload fun(frame: Frame, point: FramePoint, offsetX: uiUnit, offsetY: uiUnit)
---@overload fun(frame: Frame, point: FramePoint, relativeTo: Frame, offsetX: uiUnit, offsetY: uiUnit)
function PixelPerfect.Point(frame, point, relativeTo, relativePoint, offsetX, offsetY)
    if CUF_DB.useScaling then
        CellP:Point(frame, point, relativeTo, relativePoint, offsetX, offsetY)
    else
        frame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
    end
end

---@param frame Frame|Texture|table
function PixelPerfect.ClearPoints(frame)
    if CUF_DB.useScaling then
        CellP:ClearPoints(frame)
    else
        frame:ClearAllPoints()
    end
end
