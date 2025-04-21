---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = CUF.DB

local Util = CUF.Util
local L = CUF.L
local Defaults = CUF.Defaults

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
    ---@class CUF.database.backups
    ---@field automatic CUF.database.backup
    ---@field manual CUF.database.backup
    CUF_DB.backups = CUF_DB.backups or {}

    ---@type Defaults.Colors
    CUF_DB.colors = CUF_DB.colors or Util:CopyDeep(Defaults.Colors)

    ---@type table<string, boolean>
    CUF_DB.helpTips = CUF_DB.helpTips or {}

    if not CUF_DB.masterLayout then
        CUF_DB.masterLayout = "default"
    end

    CUF_DB.useScaling = CUF_DB.useScaling or false

    ---@type Defaults.BlizzardFrames
    CUF_DB.blizzardFrames = CUF_DB.blizzardFrames or Util:CopyDeep(Defaults.BlizzardFrames)

    ---@class CUF.database.dummyAnchors.anchor
    ---@field dummyName string
    ---@field enabled boolean

    ---@type table<string, CUF.database.dummyAnchors.anchor>
    CUF_DB.dummyAnchors = CUF_DB.dummyAnchors or {}

    DB.CreateAutomaticBackup()
    DB:Revise()

    Util:AddMissingProps(CUF_DB.colors, Defaults.Colors)
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

---@class CUF.database.backup
---@field timestamp string
---@field CUFVersion number
---@field layouts table<string, UnitLayoutTable>
---@field layoutNames string
---@field colors Defaults.Colors

--- Generic function to create a backup of the current layouts
---@param backupType "manual"|"automatic" the type of backup to create
---@param msg string the message to print to the chat window
local function CreateBackup(backupType, msg)
    CUF_DB.backups[backupType] = CUF_DB.backups[backupType] or {}
    CUF_DB.backups[backupType].layouts = CUF_DB.backups[backupType].layouts or {}

    ---@type CUF.database.backup
    local backup = CUF_DB.backups[backupType]

    -- Clear old backups
    table.wipe(backup.layouts)

    local timestamp = string.format("%s, %s", CUF.Util:GetFormattedTimeStamp(), CUF.Util:GetFormattedDate())
    backup.timestamp = timestamp
    backup.CUFVersion = CUF.version

    backup.colors = Util:CopyDeep(CUF_DB.colors)

    for layoutName, layoutTable in pairs(CellDB.layouts) do
        backup.layouts[layoutName] = Util:CopyDeep(layoutTable.CUFUnits)
    end

    local layoutNames = Util:GetAllLayoutNamesAsString(true)
    backup.layoutNames = layoutNames

    CUF:Print(msg, layoutNames)
end

--- Create a backup of the current layouts
---
--- This is used to create to a backup for updates that either:
---
--- A) Change the way the layout is stored
--- B) Implement potentially breaking changes
--- C) Prevent data loss due to a bug
function DB.CreateAutomaticBackup()
    if not CUF_DB.version -- First time addon is loaded, nothing to backup
        or (CUF_DB.backups.automatic and type(CUF_DB.backups.automatic.CUFVersion) == "number" and (CUF_DB.backups.automatic.CUFVersion >= CUF.version)) then
        return
    end

    CreateBackup("automatic", L.CreatedAutomaticBackup)
end

--- Create a backup of the current layouts
---
--- Overrides old manual backup
function DB.CreateManualBackup()
    CreateBackup("manual", L.CreatedManualBackup)
end

--- Restore layouts from a backup
---@param backupType "manual"|"automatic"
function DB.RestoreFromBackup(backupType)
    if InCombatLockdown() then
        CUF:Warn("Can't restore while in combat!")
        return
    end

    ---@type CUF.database.backup
    local backup = CUF_DB.backups[backupType]
    CUF:Log("|cff00ccffRestoreBackup:|r", backupType, backup.timestamp)

    if not backup then
        CUF:Warn("Failed to restore! No backup found.")
        return
    end

    -- TODO: Later this should bounce the restore completely on version mismatch
    -- For now it might be okay to just verify the DB
    if backup.CUFVersion ~= CUF.version then
        CUF:Log("Old version detected, verifying DB.", "Backup:", backup.CUFVersion, "New:", CUF.version)
    end

    for layoutName, backupLayoutTable in pairs(backup.layouts) do
        if not CellDB.layouts[layoutName] then
            CUF:Warn("Failed to restore Layout:", Util:FormatLayoutName(layoutName, true),
                " - Layout is missing from Cell!")
        else
            CUF:Print("Restored:", Util:FormatLayoutName(layoutName, true))
            CUF:DevAdd({ layoutTable = CellDB.layouts[layoutName].CUFUnits, backup = backupLayoutTable }, layoutName)
            CellDB.layouts[layoutName].CUFUnits = Util:CopyDeep(backupLayoutTable)
        end
    end

    CUF_DB.colors = Util:CopyDeep(backup.colors)

    -- Verify that all colors are present
    Util:AddMissingProps(CUF_DB.colors, Defaults.Colors)

    DB.VerifyDB()

    CUF:Fire("LoadPageDB", CUF.vars.selectedUnit, CUF.vars.selectedWidget)
    CUF:Fire("UpdateUnitButtons")
    CUF:Fire("UpdateWidget", DB.GetMasterLayout())
end

---@param backupType "manual"|"automatic"
function DB.GetBackupInfo(backupType)
    ---@type CUF.database.backup
    local backup = CUF_DB.backups[backupType]
    if not backup then return "" end

    local name = "|cffffa500" .. L["Backup_" .. backupType] .. ":|r"
    local info = string.format(L.BackupInfo, name, backup.timestamp, backup.layoutNames)

    return info
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
                layoutTable.CUFUnits[unit] = Util:CopyDeep(unitLayout)
            else
                Util:AddMissingProps(layoutTable.CUFUnits[unit], unitLayout, DB.PropsToOnlyInit)
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

    for _, layoutName in pairs(Util:GetAllLayoutNames()) do
        if layoutName == masterLayout then
            masterLayoutIsValid = true
        end
    end

    if not masterLayoutIsValid then
        CUF:Warn("Master layout is not valid, setting to " .. Util:FormatLayoutName("default", true))
        DB.SetMasterLayout("default")
    end
end

CUF:RegisterCallback("UpdateLayout", "CUF_VerifyMasterLayout", DB.VerifyMasterLayout)
CUF:RegisterCallback("LoadPageDB", "CUF_VerifyMasterLayout", DB.VerifyMasterLayout)

function DB.VerifyUnitPositions()
    local maxX, maxY = GetPhysicalScreenSize()
    local xVal = maxX / 2
    local yVal = maxY / 2

    Util.IterateAllUnitLayouts(function(layout, unit)
        if not layout.position then return end
        local x, y = unpack(layout.position)
        if x > xVal or y > yVal then
            layout.position = Defaults.Layouts[unit].position
        end
    end)
end
