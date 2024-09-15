---@class CUF
local CUF = select(2, ...)

---@class CUF.API
local API = CUF.API

--- Returns a frame by its unit name
---
--- Example: local frame = API:GetUnitFrameByUnitName("player")
---@param unit Unit
---@return CUFUnitButton?
function API:GetUnitFrameByUnitName(unit)
    if not API:ValidateParms("GetUnitFrameByUnitName", { { unit, "string", "unit" } }) then return end

    local unitFrame = CUF.unitButtons[unit]
    if not unitFrame then
        CUF:Warn("Unit '" .. unit .. "' does not exist.")
        return
    end

    return unitFrame
end

--- Returns a frame by its frame name
---
--- Example: local frame = API:GetUnitFrameByFrameName("CUF_Player")
---@param frameName string
---@return CUFUnitButton?
function API:GetUnitFrameByFrameName(frameName)
    if not API:ValidateParms("GetUnitFrameByFrameName", { { frameName, "string", "unit" } }) then return end

    local unitFrame = _G[frameName]
    if not unitFrame then
        CUF:Warn("Frame '" .. frameName .. "' does not exist.")
        return
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

--- Validates the types of the given parameters.
---@param functionName string The name of the function being called.
---@param params table A table of parameters to check, with each entry being {value, expectedType, paramName}.
---@return boolean isValid all types are valid.
function API:ValidateParms(functionName, params)
    local errorMsg

    for _, param in ipairs(params) do
        local value, expectedType, paramName = unpack(param)
        if type(value) ~= expectedType then
            local newError = string.format("Invalid type for param '%s'. Expected type '%s', got '%s'.",
                paramName,
                expectedType,
                type(value))
            if not errorMsg then
                errorMsg = newError
            else
                errorMsg = errorMsg .. "\n" .. newError
            end
        end
    end

    if errorMsg then
        CUF:Warn("Error in API function '" .. functionName .. "'" .. ":\n" .. errorMsg)
        return false
    end

    return true
end
