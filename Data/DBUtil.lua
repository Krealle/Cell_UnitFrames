---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = CUF.DB

-- Props that should only be initialized once
-- eg we only want to initialize filters, not keep adding to them
-- which would potentially add spells that are unwanted by the user
-- TODO: We should *probably* migrate to a revision system, but thats future me's problem
DB.PropsToOnlyInit = {
    blacklist = true,
    whitelist = true,
}

-- Make sure that we have an active CellDB and that it has all the UnitLayouts we need
---@return false? noCellDB If CellDB is not present
function DB.VerifyDB()
    if not CellDB or not CellDB.layouts then return false end

    for _, layoutTable in pairs(CellDB.layouts) do
        layoutTable.CUFUnits = layoutTable.CUFUnits or {}

        for unit, unitLayout in pairs(CUF.Defaults.Layouts) do
            if type(layoutTable.CUFUnits[unit]) ~= "table" then
                layoutTable.CUFUnits[unit] = Cell.funcs:Copy(unitLayout)
            else
                CUF.Util:AddMissingProps(layoutTable.CUFUnits[unit], unitLayout, DB.PropsToOnlyInit)
                --CUF.Util:RenameProp(layoutTable.CUFUnits[unit], "pointTo", "relativePoint")
            end
        end
    end
end
