-- Add your own custom tag
--
-- Tags added will be available for use in the Custom Text widget
--
-- Usage is the same as any other tag `[tagName]`
--
-- See full documentation for custom tags here:
-- https://github.com/Krealle/Cell_UnitFrames/blob/master/Widgets/Texts/CustomFormats.lua
local function AddTag()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    local W = CUF.widgets

    -- Add a new tag that shows the current level of the unit, updating on UNIT_LEVEL event
    -- Params:
    -- 1. tagName - the name of the tag
    -- 2. events - the events that will trigger the tag to update (space separated)
    -- 2.1 this can also be parsed a number (see throttledcurhp example)
    -- 3. func - the function that will be called to get the value (this function will be passed the unit)
    -- The return value of the function will be used as the value of the tag
    -- It is expected that the return type is either `string` or `nil`
    W:AddTag("level", "UNIT_LEVEL", function(unit)
        return tostring(UnitLevel(unit))
    end)

    -- Add a new tag that shows the current HP of the unit, updating every 0.25 seconds
    -- This can be usefull for squeezing out performance, or for showing values that aren't tied
    -- to events
    -- Params:
    -- 1. tagName - the name of the tag
    -- 2. updateInterval - the interval in seconds at which the tag will update (in seconds)
    -- 3. func - the function that will be called to get the value (this function will be passed the unit)
    -- The return value of the function will be used as the value of the tag
    -- It is expected that the return type is either `string` or `nil`
    W:AddTag("throttledcurhp", 0.25, function(unit)
        return tostring(UnitHealth(unit))
    end)
end
Cell.RegisterCallback("CUF_AddonLoaded", "Snippet_AddCustomTag", AddTag)
