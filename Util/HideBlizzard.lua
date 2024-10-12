---@class CUF
local CUF = select(2, ...)

local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES or 5

-- stolen from cell, which is stolen from elvui
local hiddenParent = CreateFrame("Frame", nil, _G.UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function HideFrame(frame)
    if not frame then return end

    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(hiddenParent)

    local health = frame.healthBar or frame.healthbar
    if health then
        health:UnregisterAllEvents()
    end

    local power = frame.manabar
    if power then
        power:UnregisterAllEvents()
    end

    local spell = frame.castBar or frame.spellbar
    if spell then
        spell:UnregisterAllEvents()
    end

    local altpowerbar = frame.powerBarAlt
    if altpowerbar then
        altpowerbar:UnregisterAllEvents()
    end

    local buffFrame = frame.BuffFrame
    if buffFrame then
        buffFrame:UnregisterAllEvents()
    end

    local petFrame = frame.PetFrame
    if petFrame then
        petFrame:UnregisterAllEvents()
    end
end

---@diagnostic disable: undefined-field
---@param unit Unit
function CUF:HideBlizzardUnitFrame(unit)
    if unit == "player" and _G.PlayerFrame then
        HideFrame(_G.PlayerFrame)

        if CUF.DB.CurrentLayoutTable()[unit].hideBlizzardCastBar then
            if _G.PlayerCastingBarFrame then
                HideFrame(_G.PlayerCastingBarFrame)
            end
        end
    elseif unit == "target" and _G.TargetFrame then
        HideFrame(_G.TargetFrame)
    elseif unit == "focus" and _G.FocusFrame then
        HideFrame(_G.FocusFrame)
    elseif unit == "pet" and _G.PetFrame then
        HideFrame(_G.PetFrame)
    elseif unit == "boss" then
        HideFrame(_G.BossTargetFrameContainer)
        for i = 1, MAX_BOSS_FRAMES do
            HideFrame(_G["Boss" .. i .. "TargetFrame"])
        end
    end
end
