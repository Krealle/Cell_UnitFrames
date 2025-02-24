-- Make frames click-through unless a modifier key is pressed
local function ClickThroughFrames()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    CUF.Util:IterateAllUnitButtons(function(button, unit)
        -- Optional unit check to only apply for certain frames
        -- Below is an example of how to do this, only applying to the player frame
        --
        -- Valid units can be found here:
        -- https://github.com/Krealle/Cell_UnitFrames/blob/master/Data/Constants.lua#L19
        --if unit ~= "player" then return end

        -- Create a helper frame to check for clickthrough
        local helperFrame = CreateFrame("Frame", nil, button)
        helperFrame.elapsed = 0

        -- Hook onto the button's OnEnter and OnLeave events
        button:HookScript("OnEnter", function()
            helperFrame:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed

                -- Only check every 0.1s, this can be lowered/removed if needed
                if self.elapsed < 0.1 then return end
                self.elapsed = 0

                if InCombatLockdown() then return end

                -- Check if a modifier key is pressed
                if IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() then
                    -- Make the frame clickable
                    button:SetMouseClickEnabled(true)
                else
                    -- Make the frame click-through
                    button:SetMouseClickEnabled(false)
                end
            end)
        end)
        button:HookScript("OnLeave", function()
            helperFrame:SetScript("OnUpdate", nil)
        end)
    end)
end
Cell.RegisterCallback("CUF_FramesInitialized", "Snippet_ClickThroughFrames", ClickThroughFrames)
