-- Override Fallback layout
-- Used for when Master Layout is set to "None" and Cell's layout is set to "Hide"
local function OverwriteFallbackLayout()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    CUF.Defaults.Values.fallbackLayout = "My Layout Name"
end
Cell.RegisterCallback("CUF_AddonLoaded", "Snippet_OverwriteFallbackLayout", OverwriteFallbackLayout)
