---@diagnostic disable: inject-field
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
end
