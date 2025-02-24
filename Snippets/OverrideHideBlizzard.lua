-- Override HideBlizzardUnitFrame prevent hiding Blizzard frames on specific units
--
-- See documentation for valid units here:
-- https://github.com/Krealle/Cell_UnitFrames/blob/master/Data/Constants.lua#L19
local function OverrideHideBlizzard()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    -- Store original function so we can still hide frames
    local _HideBlizzardUnitFrame = CUF.HideBlizzardUnitFrame

    -- Override default function
    CUF.HideBlizzardUnitFrame = function(self, unit)
        -- Early return on specific units
        if unit == "target" or unit == "targetoftarget" or unit == "focus" then
            return
        end

        -- Call orignial function to hide frames we don't want
        _HideBlizzardUnitFrame(self, unit)
    end
end
Cell.RegisterCallback("CUF_AddonLoaded", "Snippet_OverrideHideBlizzard", OverrideHideBlizzard)
