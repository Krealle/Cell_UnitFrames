---@diagnostic disable: inject-field, undefined-field
---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = CUF.DB

---@param func fun(layout: UnitLayout, unit: Unit)
local function IterateUnitLayouts(func)
    for _, layoutTable in pairs(CellDB.layouts) do
        for unit, unitLayout in pairs(layoutTable.CUFUnits) do
            func(unitLayout, unit)
        end
    end
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
            local hideIfEmptyOrFull = layout.widgets.healthText.hideIfEmptyOrFull
            layout.widgets.healthText.hideIfFull = hideIfEmptyOrFull
            layout.widgets.healthText.hideIfEmpty = hideIfEmptyOrFull

            layout.widgets.healthText.hideIfEmptyOrFull = nil
        end)
    end
end
