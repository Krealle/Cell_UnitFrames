-- Set custom sizing for the player unit frame based on resolution size
--
-- See documentation for SetCustomUnitFrameSize here:
-- https://github.com/Krealle/Cell_UnitFrames/blob/master/API/CustomAnchors.lua#L121

-- Wrap the snippet in to only run once, on the "LOADING_SCREEN_DISABLED" event
-- This is to ensure the plugin is fully loaded before running the snippet
-- Since Cell runs snippets before this plugin gets loaded.
EventUtil.RegisterOnceFrameEventAndCallback("LOADING_SCREEN_DISABLED", function()
    -- Check if CUF is loaded
    local CUF = CUF
    if not CUF then return end

    if (GetScreenWidth() * UIParent:GetEffectiveScale() <= 1228) then
        CUF.API:SetCustomUnitFrameSize("player", 100, 100)
    else
        CUF.API:SetCustomUnitFrameSize("player", 600, 100)
    end
end)
