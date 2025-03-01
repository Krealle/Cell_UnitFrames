-- Set custom textures for various frames/widgets
--
-- See documentation for valid units here:
-- https://github.com/Krealle/Cell_UnitFrames/blob/master/Data/Constants.lua#L19
---@deprecated by version 1.4.47
local function CustomTextures()
    -- Make sure CUF is actually loaded
    local CUF = _G["CUF"]
    if not CUF then return end

    -- Store local references to default functions
    local Default_UnitFrame_UpdateHealthTexture = CUF.uFuncs.UnitFrame_UpdateHealthTexture
    local Default_UnitFrame_UpdatePowerTexture = CUF.uFuncs.UnitFrame_UpdatePowerTexture

    -- Override default function for setting Health Bar textures
    CUF.uFuncs.UnitFrame_UpdateHealthTexture = function(self, button)
        -- Only use custom textures for certain frames
        if button._baseUnit == "target" then
            button.widgets.healthBar:SetStatusBarTexture("YOUR_TEX_PATH\\YOUR_TEX")
            button.widgets.healthBarLoss:SetTexture("YOUR_TEX_PATH\\YOUR_TEX")
        else
            -- Call default function for other frames
            Default_UnitFrame_UpdateHealthTexture(self, button)
        end
    end

    -- Override default function for setting Power Bar textures
    CUF.uFuncs.UnitFrame_UpdatePowerTexture = function(self, button)
        -- Only use custom textures for certain frames
        if button._baseUnit == "target" then
            button.widgets.powerBar:SetStatusBarTexture("YOUR_TEX_PATH\\YOUR_TEX")
            button.widgets.powerBar.bg:SetTexture("YOUR_TEX_PATH\\YOUR_TEX")
        else
            -- Call default function for other frames
            Default_UnitFrame_UpdatePowerTexture(self, button)
        end
    end
end
Cell.RegisterCallback("CUF_AddonLoaded", "Snippet_CustomTextures", CustomTextures)
