-- Apply Glow to buffs with specific spellIDs
--
-- See documentation for Glow functions here:
-- https://github.com/Krealle/Cell_UnitFrames/blob/master/Util/Utils.lua#L498
--
-- `auraData` arg being passed is in this format:
-- https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataByIndex
local function AuraGlow()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    local Util = CUF.Util

    local function PostUpdate(icon, auraData)
        if auraData.spellId == 393438 then
            Util.GlowStart_Normal(icon)
        else
            Util.GlowStop(icon)
        end
    end

    -- Override PostUpdate for all auras
    Util:IterateAllUnitButtons(function(button, unit)
        -- Nil check
        if not button:HasWidget("buffs") then return end

        -- NOTE: Only apply to player
        -- if unit ~= "player" then return end

        -- can also iterate "button.widgets.debuffs"
        for _, icon in ipairs(button.widgets.buffs) do
            icon.PostUpdate = PostUpdate
        end
    end)
end
Cell.RegisterCallback("CUF_FramesInitialized", "Snippet_AuraGlow", AuraGlow)
