-- Set custom sizing for the player unit frame based on resolution size
--
-- See documentation for SetCustomUnitFrameSize here:
-- https://github.com/Krealle/Cell_UnitFrames/blob/master/API/CustomAnchors.lua#L121
local function SetCustomSizing()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    if (GetScreenWidth() * UIParent:GetEffectiveScale() <= 1228) then
        CUF.API:SetCustomUnitFrameSize("player", 100, 100)
    else
        CUF.API:SetCustomUnitFrameSize("player", 600, 100)
    end
end
Cell.RegisterCallback("CUF_FramesInitialized", "Snippet_SetCustomSizing", SetCustomSizing)
