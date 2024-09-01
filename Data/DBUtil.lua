---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = CUF.DB

local Util = CUF.Util

-- Props that should only be initialized once
-- eg we only want to initialize filters, not keep adding to them
-- which would potentially add spells that are unwanted by the user
-- TODO: We should *probably* migrate to a revision system, but thats future me's problem
DB.PropsToOnlyInit = {
    blacklist = true,
    whitelist = true,
}

--- Initialize the DB
function DB.InitDB()
    CUF_DB = CUF_DB or {}

    -- Backups
    CUF_DB.backups = CUF_DB.backups or {}
    CUF_DB.backups.version = CUF_DB.backups.version or {}
    CUF_DB.backups.version.layouts = CUF_DB.backups.version.layouts or {}

    DB.CreateVersionBackup()
end

-----------------------------------------
-- MARK: Copy
-----------------------------------------

-- Copy ALL settings from one layout to another
---@param from string
---@param to string
function DB.CopyFullLayout(from, to)
    CellDB.layouts[to].CUFUnits = Util:CopyDeep(DB.GetLayoutTable(from))
end

--- Copy ALL widget settings from one unit to another
---
--- Only copies for widgets that are shared between the two units
---@param from Unit
---@param to Unit
function DB.CopyWidgetSettings(from, to)
    local layoutTable = DB.SelectedLayoutTable()
    if not layoutTable then return end

    local fromWidgetTables = layoutTable[from].widgets
    local toWidgetTables = layoutTable[to].widgets

    for widgetName, widgetTable in pairs(fromWidgetTables) do
        if toWidgetTables[widgetName] then
            toWidgetTables[widgetName] = Util:CopyDeep(widgetTable)
        end
    end
end

-----------------------------------------
-- MARK: Backup
-----------------------------------------

--- Create a backup of the current layotus
---
--- This is used to create to a backup for updates that either:
---
--- A) Change the way the layout is stored
--- B) Implement poentially breaking changes
--- C) Prevent data loss due to a bug
function DB.CreateVersionBackup()
    if CUF_DB.backups.version.CUFVersion == CUF.version then
        return
    end

    wipe(CUF_DB.backups.version.layouts)

    CUF_DB.backups.version.CUFVersion = CUF.version

    for layoutName, layoutTable in pairs(CellDB.layouts) do
        CUF_DB.backups.version.layouts[layoutName] = Util:CopyDeep(layoutTable.CUFUnits)
    end
end

-----------------------------------------
-- MARK: Verify
-----------------------------------------

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
                Util:AddMissingProps(layoutTable.CUFUnits[unit], unitLayout, DB.PropsToOnlyInit)
                --Util:RenameProp(layoutTable.CUFUnits[unit], "pointTo", "relativePoint")

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
