---@diagnostic disable: inject-field, undefined-field
---@class CUF
local CUF = select(2, ...)
local addonName = select(1, ...)

---@class CUF.database
local DB = CUF.DB

local L = CUF.L

---@param func fun(layout: UnitLayout, unit: Unit)
local function IterateUnitLayouts(func)
    for _, layoutTable in pairs(CellDB.layouts) do
        if layoutTable.CUFUnits then
            for unit, unitLayout in pairs(layoutTable.CUFUnits) do
                func(unitLayout, unit)
            end
        end
    end
end

local changelog = {}
local function AddToChangelog(text)
    text = (#changelog + 1) .. ". " .. text
    if #changelog > 0 then
        text = "\n" .. text
    end
    table.insert(changelog, text)
end

local function ShowChangelog()
    if #changelog == 0 then return end

    local version = C_AddOns.GetAddOnMetadata(addonName, "version")
    local changelogsFrame = CUF:CreateInformationPopupFrame(L.NewVersion .. ": " .. version, 400, unpack(changelog))
    changelogsFrame:Show()
end

function DB:Revise()
    if not CUF_DB.version then return end

    if CUF_DB.version < 3 then
        IterateUnitLayouts(function(layout)
            local castBar = layout.widgets.castBar
            if not castBar then return end

            if castBar.color then
                if castBar.color.useClassColor ~= nil then
                    castBar.useClassColor = castBar.color.useClassColor
                end
                castBar.color = nil
            end

            if castBar.empower and castBar.empower.pipColors then
                castBar.empower.pipColors = nil
            end
        end)
    end
    if CUF_DB.version < 5 then
        -- Load late since we need proper screen size
        CUF:AddEventListener("LOADING_SCREEN_DISABLED", function()
            local sWidth = GetScreenWidth() / 2
            local sHeight = GetScreenHeight() / 2
            local buffer = 14

            IterateUnitLayouts(function(layout)
                if not layout.point then return end
                local anchorPoint = layout.point

                local xPos, yPos = unpack(layout.position)
                local bWidth, bHeight = unpack(layout.size)
                local bOffsetX = bWidth / 2
                local bOffsetY = bHeight / 2

                local newX = xPos - sWidth
                local newY = yPos - sHeight

                if CellDB.general.menuPosition == "top_bottom" then
                    if anchorPoint == "BOTTOMLEFT" then
                        newY = newY + buffer + bOffsetY
                    elseif anchorPoint == "BOTTOMRIGHT" then
                        newY = newY + buffer + bOffsetY
                    elseif anchorPoint == "TOPLEFT" then
                        newY = newY - 4 - bOffsetY
                    elseif anchorPoint == "TOPRIGHT" then
                        newY = newY - 4 - bOffsetY
                    end
                else
                    if anchorPoint == "BOTTOMLEFT" then
                        newX = newX + buffer + bOffsetX
                    elseif anchorPoint == "BOTTOMRIGHT" then
                        newX = newX - 4 - bOffsetX
                    elseif anchorPoint == "TOPLEFT" then
                        newX = newX + buffer + bOffsetX
                    elseif anchorPoint == "TOPRIGHT" then
                        newX = newX - 4 - bOffsetX
                    end
                end

                layout.position = { newX, newY }
            end)

            CUF:Fire("UpdateUnitButtons")
            return true
        end)
    end
    if CUF_DB.version < 7 then
        IterateUnitLayouts(function(layout)
            if not layout.widgets.healthText then return end
            if layout.widgets.healthText.hideIfEmptyOrFull == nil then return end

            local hideIfEmptyOrFull = layout.widgets.healthText.hideIfEmptyOrFull
            layout.widgets.healthText.hideIfFull = hideIfEmptyOrFull
            layout.widgets.healthText.hideIfEmpty = hideIfEmptyOrFull

            layout.widgets.healthText.hideIfEmptyOrFull = nil
        end)
    end
    if CUF_DB.version < 9 then
        AddToChangelog("Custom Tag formats have been changed in a recent update. You may need to update your tags.")
    end
    if CUF_DB.version < 11 then
        IterateUnitLayouts(function(layout, unit)
            if unit == "boss" and layout.growthDirection then
                if layout.growthDirection == "up" then
                    layout.growthDirection = CUF.constants.GROWTH_ORIENTATION.BOTTOM_TO_TOP
                elseif layout.growthDirection == "down" then
                    layout.growthDirection = CUF.constants.GROWTH_ORIENTATION.TOP_TO_BOTTOM
                end
            end
        end)
    end
    if CUF_DB.version < 13 then
        local curLayout = DB.GetMasterLayout()
        if not CellDB.layouts[curLayout] then
            curLayout = "default"
        end
        if CellDB.layouts[curLayout] and CellDB.layouts[curLayout].CUFUnits then
            for unit, unitLayout in pairs(CellDB.layouts[curLayout].CUFUnits) do
                if CUF_DB.blizzardFrames[unit] ~= nil then
                    CUF_DB.blizzardFrames[unit] = unitLayout.enabled
                end
                if unit == "player" then
                    CUF_DB.blizzardFrames.playerCastBar = unitLayout.hideBlizzardCastBar
                end
            end
        end

        IterateUnitLayouts(function(layout)
            layout.hideBlizzardCastBar = nil
        end)
    end
    if CUF_DB.version < 17 then
        CUF:RegisterCallback("AddonLoaded", "AddonLoaded_Revise_17", function()
            IterateUnitLayouts(function(layout)
                if not layout.widgets.powerBar then
                    layout.widgets.powerBar = CUF.Util:CopyDeep(CUF.Defaults.Widgets.powerBar)
                end

                if layout.powerSize ~= nil then
                    if layout.powerSize > 0 then
                        layout.widgets.powerBar.size.height = layout.powerSize
                        layout.widgets.powerBar.enabled = true
                    else
                        layout.widgets.powerBar.enabled = false
                    end
                    --layout.powerSize = nil
                end
                if layout.powerFilter ~= nil then
                    layout.widgets.powerBar.powerFilter = layout.powerFilter
                    --layout.powerFilter = nil
                end
                if layout.barOrientation == "vertical" then
                    layout.widgets.powerBar.orientation = CUF.constants.GROWTH_ORIENTATION.BOTTOM_TO_TOP
                    layout.widgets.powerBar.sameWidthAsHealthBar = false
                    layout.widgets.powerBar.sameHeightAsHealthBar = true

                    layout.widgets.powerBar.position.point = "BOTTOMRIGHT"
                    layout.widgets.powerBar.position.relativePoint = "BOTTOMRIGHT"

                    if layout.powerSize ~= nil and layout.powerSize > 0 then
                        layout.widgets.powerBar.size.width = layout.powerSize
                    else
                        layout.widgets.powerBar.size.width = CUF.Defaults.Widgets.powerBar.size.height
                    end
                end
            end)

            CUF:UnregisterCallback("AddonLoaded", "AddonLoaded_Revise_17")
        end)

        IterateUnitLayouts(function(layout)
            if not layout.widgets.castBar
                or layout.widgets.castBar.reverse == nil then
                return
            end

            if layout.widgets.castBar.reverse then
                layout.widgets.castBar.orientation = CUF.constants.GROWTH_ORIENTATION.RIGHT_TO_LEFT
            end

            layout.widgets.castBar.reverse = nil
        end)
    end

    ShowChangelog()
end
