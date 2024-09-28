-- Run Snippet late to ensure addon is properly loaded
EventUtil.RegisterOnceFrameEventAndCallback("LOADING_SCREEN_DISABLED", function()
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
end)
