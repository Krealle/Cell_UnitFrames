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
---@param type string
function CUF:HideBlizzardUnitFrame(type)
    if type == "player" and _G.PlayerFrame then
        HideFrame(_G.PlayerFrame)
    elseif type == "playerCastBar" then
        if _G.PlayerCastingBarFrame then
            HideFrame(_G.PlayerCastingBarFrame)
        end
        if CUF.vars.isVanilla and _G.CastingBarFrame then
            HideFrame(_G.CastingBarFrame)
        end
    elseif type == "target" and _G.TargetFrame then
        HideFrame(_G.TargetFrame)
    elseif type == "focus" and _G.FocusFrame then
        HideFrame(_G.FocusFrame)
    elseif type == "pet" and _G.PetFrame then
        HideFrame(_G.PetFrame)
    elseif type == "boss" then
        HideFrame(_G.BossTargetFrameContainer)
        for i = 1, MAX_BOSS_FRAMES do
            HideFrame(_G["Boss" .. i .. "TargetFrame"])
        end
    elseif type == "buffFrame" then
        HideFrame(_G.BuffFrame)
    elseif type == "debuffFrame" then
        HideFrame(_G.DebuffFrame)
    end
end
