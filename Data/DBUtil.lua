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

-- Copy ALL settings from one layout to another
---@param from string
---@param to string
function DB.CopyFullLayout(from, to)
    CellDB.layouts[to].CUFUnits = CUF.Util:CopyDeep(DB.GetLayoutTable(from))
end

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

                -- Remove any widgets that shouldn't be there
                for widgetName, _ in pairs(layoutTable.CUFUnits[unit].widgets) do
                    if type(widgetName) == "string" and not unitLayout.widgets[widgetName] then
                        CUF:Warn("Found widget in DB that doesn't exist for", unit .. ": " .. widgetName)
                        layoutTable.CUFUnits[unit].widgets[widgetName] = nil
                    end
                end
            end
        end
    end

    -- Make sure that we have a valid master layout
    DB.VerifyMasterLayout()
end

function DB.VerifyMasterLayout()
    local masterLayout = DB.GetMasterLayout(true)
    if masterLayout == "CUFLayoutMasterNone" then return end

    local masterLayoutIsValid = false

    for layoutName, _ in pairs(CellDB.layouts) do
        if layoutName == masterLayout then
            masterLayoutIsValid = true
        end
    end

    if not masterLayoutIsValid then
        CUF:Warn("Master layout is not valid, setting to default")
        DB.SetMasterLayout("default")
    end
end

CUF:RegisterCallback("UpdateLayout", "CUF_VerifyMasterLayout", DB.VerifyMasterLayout)
CUF:RegisterCallback("LoadPageDB", "CUF_VerifyMasterLayout", DB.VerifyMasterLayout)
