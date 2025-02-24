-- Increase the maximum number of aura icons that can be shown
local function IncreaseMaxAuraIcons()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    CUF.Defaults.Values.maxAuraIcons = 40
end
Cell.RegisterCallback("CUF_AddonLoaded", "Snippet_IncreaseMaxAuraIcons", IncreaseMaxAuraIcons)
