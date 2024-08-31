---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = CUF.DB

-----------------------------------------
-- MARK: Layout Getters
-----------------------------------------

-- Returns CUF UnitLayoutTable from CellDB
---@param layout string
---@return UnitLayoutTable
local function GetCUFLayoutTableFromCellDB(layout)
    return CellDB.layouts[layout].CUFUnits
end

---@param layout string
---@return UnitLayoutTable
function DB.GetLayoutTable(layout)
    return GetCUFLayoutTableFromCellDB(layout)
end

---@param layout string
---@param unit Unit
---@return UnitLayout
function DB.GetUnit(layout, unit)
    return DB.GetLayoutTable(layout)[unit]
end

-- Returns selected layout table (differes from current in menu)
---@return UnitLayoutTable
function DB.SelectedLayoutTable()
    return DB.GetLayoutTable(CUF.vars.selectedLayout)
end

-- Returns active layout table
---@return UnitLayoutTable
function DB.CurrentLayoutTable()
    return DB.GetLayoutTable(Cell.vars.currentLayout)
end

---@param unit Unit?
---@param layout string?
---@return WidgetTables
function DB.GetAllWidgetTables(unit, layout)
    return DB.GetUnit(layout or CUF.vars.selectedLayout, unit or CUF.vars.selectedUnit).widgets
end

---@param which WIDGET_KIND
---@param unit Unit?
---@param layout string?
---@return WidgetTable
function DB.GetWidgetTable(which, unit, layout)
    return DB.GetAllWidgetTables(unit, layout)[which]
end

---@param which "buffs"|"debuffs"
---@param kind "blacklist"|"whitelist"
---@param unit Unit?
---@param layout string?
---@return table
function DB.GetAuraFilter(which, kind, unit, layout)
    return DB.GetAllWidgetTables(unit, layout)[which].filter[kind]
end

-----------------------------------------
-- MARK: Layout Setters
-----------------------------------------

---@param which "buffs"|"debuffs"
---@param kind "blacklist"|"whitelist"
---@param value table
---@param unit Unit?
---@param layout string?
function DB.SetAuraFilter(which, kind, value, unit, layout)
    DB.GetAllWidgetTables(unit, layout)[which].filter[kind] = value
end

-----------------------------------------
-- MARK: General Getters
-----------------------------------------

---@return string
function DB.GetMasterLayout()
    return CUF_DB.masterLayout
end

-----------------------------------------
-- MARK: General Setters
-----------------------------------------

---@param layout string
function DB.SetMasterLayout(layout)
    CUF_DB.masterLayout = layout
end
