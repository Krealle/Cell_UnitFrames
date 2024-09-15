---@class CUF
local CUF = select(2, ...)

---@class CUF.API
local API = CUF.API

--- Returns a frame by either its unit name or frame name
---
--- Example: local frame = API:GetUnitFrame("player")
---
--- Example: local frame = API:GetUnitFrame("CUF_Player")
---@param name string
---@return CUFUnitButton?
function API:GetUnitFrame(name)
    if not API:ValidateParms("GetUnitFrame", { { name, "string", "name" } }) then return end

    local unitFrame = CUF.unitButtons[name]
    if not unitFrame then
        unitFrame = _G[name]
        if not unitFrame then
            CUF:Warn("Cannot find valid unit frame for '" .. name .. "'.")
            return
        end
    end

    return unitFrame
end

--- Returns all unit frames as an indexed table
---
--- Example: local frames = API:GetAllUnitFrames()
---@return table<string, CUFUnitButton>
function API:GetAllUnitFrames()
    return CUF.unitButtons
end

------------------------------------------------------------
-- MARK: Validation
-- Private functions that the user should not call directly.
------------------------------------------------------------

---@param point FramePoint
---@return true|string
local function IsValidPoint(point)
    local isValidPoint = type(point) == "string" and
        (point == "TOPLEFT"
            or point == "TOPRIGHT"
            or point == "BOTTOMLEFT"
            or point == "BOTTOMRIGHT"
            or point == "CENTER"
            or point == "TOP"
            or point == "BOTTOM"
            or point == "LEFT"
            or point == "RIGHT")

    if not isValidPoint then
        return "FramePoint"
    end

    return isValidPoint
end

---@param frame Frame
---@return true|string
local function IsValidFrame(frame)
    local isValidFrame = type(frame) == "table" and
        frame.GetName ~= nil

    if not isValidFrame then
        return "Frame"
    end

    return isValidFrame
end

--- Validates the types of the given parameters.
---@param functionName string The name of the function being called.
---@param params table A table of parameters to check, with each entry being {value, expectedType, paramName}.
---@return boolean isValid all types are valid.
function API:ValidateParms(functionName, params)
    local errorMsg

    for _, param in ipairs(params) do
        local value, expectedType, paramName = unpack(param)
        local maybeErr

        if type(value) == "nil" then
            maybeErr = string.format("Missing param '%s'.", paramName)
        elseif type(expectedType) == "function" then
            local isValid = expectedType(value)
            if type(isValid) == "string" then
                maybeErr = string.format("Invalid type for param '%s'. Expected type '%s'.",
                    paramName,
                    isValid)
            end
        elseif expectedType == "Frame" then
            local isValid = IsValidFrame(value)
            if type(isValid) == "string" then
                maybeErr = string.format("Invalid type for param '%s'. Expected type '%s'.",
                    paramName,
                    isValid)
            end
        elseif expectedType == "FramePoint" then
            local isValid = IsValidPoint(value)
            if type(isValid) == "string" then
                maybeErr = string.format("Invalid type for param '%s'. Expected type '%s'.",
                    paramName,
                    isValid)
            end
        elseif type(value) ~= expectedType then
            maybeErr = string.format("Invalid type for param '%s'. Expected type '%s', got '%s'.",
                paramName,
                expectedType,
                type(value))
        end

        if type(maybeErr) == "string" then
            if not errorMsg then
                errorMsg = maybeErr
            else
                errorMsg = errorMsg .. "\n" .. maybeErr
            end
        end
    end

    if errorMsg then
        CUF:Warn("Error in API function '" .. functionName .. "'" .. ":\n" .. errorMsg)
        return false
    end

    return true
end
