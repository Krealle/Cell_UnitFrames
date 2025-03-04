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

---@param unit Unit?
---@return WidgetTables
function DB.GetSelectedWidgetTables(unit)
    return DB.GetUnit(CUF.vars.selectedLayout, unit or CUF.vars.selectedUnit).widgets
end

---@param which WIDGET_KIND
---@param unit Unit?
---@return WidgetTable
function DB.GetSelectedWidgetTable(which, unit)
    return DB.GetSelectedWidgetTables(unit)[which]
end

---@param which "buffs"|"debuffs"
---@param kind "blacklist"|"whitelist"
---@param unit Unit?
---@return table
function DB.GetAuraFilter(which, kind, unit)
    return DB.GetSelectedWidgetTables(unit)[which].filter[kind]
end

-- Returns active layout table
---@return UnitLayoutTable
function DB.CurrentLayoutTable()
    if CUF.vars.isMenuOpen and DB.GetMasterLayout(true) == "CUFLayoutMasterNone" then
        return DB.SelectedLayoutTable()
    end
    return DB.GetLayoutTable(DB.GetMasterLayout())
end

---@param unit Unit
---@return WidgetTables
function DB.GetCurrentWidgetTables(unit)
    return DB.CurrentLayoutTable()[unit].widgets
end

---@param which WIDGET_KIND
---@param unit Unit
---@return WidgetTable
function DB.GetCurrentWidgetTable(which, unit)
    return DB.GetCurrentWidgetTables(unit)[which]
end

-----------------------------------------
-- MARK: Layout Setters
-----------------------------------------

---@param which "buffs"|"debuffs"
---@param kind "blacklist"|"whitelist"
---@param value table
---@param unit Unit?
function DB.SetAuraFilter(which, kind, value, unit)
    DB.GetSelectedWidgetTables(unit)[which].filter[kind] = value
end

-----------------------------------------
-- MARK: General Getters
-----------------------------------------

---@param rawValue boolean?
---@return string
function DB.GetMasterLayout(rawValue)
    local layout = CUF_DB.masterLayout
    if layout == "CUFLayoutMasterNone" and not rawValue then
        if Cell.vars.currentLayout == "hide" then
            return CUF.Defaults.Values.fallbackLayout
        end

        return Cell.vars.currentLayout
    end

    return layout
end

--- Returns the colors table from DB
---@return Defaults.Colors
function DB.GetColors()
    return CUF_DB.colors
end

---@param helpTip string
---@return boolean
function DB.GetHelpTip(helpTip)
    local acknowledged = CUF_DB.helpTips[helpTip]
    if acknowledged == nil then
        DB.SetHelpTip(helpTip, false)
        return false
    end

    return acknowledged
end

-----------------------------------------
-- MARK: General Setters
-----------------------------------------

---@param layout string
function DB.SetMasterLayout(layout)
    CUF_DB.masterLayout = layout

    CUF.vars.selectedLayout = DB.GetMasterLayout()

    CUF:Fire("UpdateWidget", DB.GetMasterLayout())
    CUF:Fire("UpdateUnitButtons")
end

--- Sets the color of a specific color type
---@param which Defaults.Colors.Types
---@param colorName string
---@param val RGBAOpt|string
function DB.SetColor(which, colorName, val)
    DB.GetColors()[which][colorName] = val
end

---@param helpTip string
---@param acknowledged boolean
function DB.SetHelpTip(helpTip, acknowledged)
    CUF_DB.helpTips[helpTip] = acknowledged
end

---@param useScaling boolean
function DB.SetUseScaling(useScaling)
    CUF_DB.useScaling = useScaling
    CUF:Fire("UpdateAppearance", "scale")
end
