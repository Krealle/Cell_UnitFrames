---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = CUF.DB

function DB.VerifyDB()
    if not CellDB or not CellDB["layouts"] then return false end

    for _, layoutTable in pairs(CellDB["layouts"]) do
        layoutTable["CUFUnits"] = layoutTable["CUFUnits"] or {}

        for unit, unitLayout in pairs(CUF.Defaults.Layouts) do
            if type(layoutTable["CUFUnits"][unit]) ~= "table" then
                layoutTable["CUFUnits"][unit] = Cell.funcs:Copy(unitLayout)
            else
                CUF.Util:AddMissingProps(layoutTable["CUFUnits"][unit], unitLayout)
            end
        end
    end
end
