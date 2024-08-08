---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = {}
CUF.DB = DB

local dbDebug = function(...) if CUF.vars.debugDB then CUF:Log(...) end end

-----------------------------------------
-- Getters
-----------------------------------------

---@param unit Unit?
---@param layout string?
---@return UnitFrameWidgetsTable
function DB.GetAllWidgetTables(unit, layout)
    dbDebug("|cffff7777DB:GetWidgetTable:|r", unit, layout)
    return CellDB["layouts"][layout or CUF.vars.selectedLayout][unit or CUF.vars.selectedUnit].widgets
end

---@param which WIDGET_KIND
---@param unit Unit?
---@param layout string?
---@return WidgetTable
function DB.GetWidgetTable(which, unit, layout)
    dbDebug("|cffff7777DB:GetWidget:|r", which, unit, layout)
    return DB.GetAllWidgetTables(unit, layout)[which]
end

---@param which WIDGET_KIND
---@param property OPTION_KIND | AURA_OPTION_KIND
---@param unit Unit?
---@param layout string?
---@return any
function DB.GetWidgetProperty(which, property, unit, layout)
    dbDebug("|cffff7777DB:GetWidgetProperty:|r", which, property, unit, layout)
    return DB.GetWidgetTable(which, unit, layout)[property]
end

---@param which WIDGET_KIND
---@param unit Unit?
---@param layout string?
---@return boolean
function DB.IsWidgetEnabled(which, unit, layout)
    dbDebug("|cffff7777DB:IsWidgetEnabled:|r", which, unit, layout)
    return DB.GetWidgetTable(which, unit, layout).enabled
end

---@param which WIDGET_KIND
---@param unit Unit?
---@param layout string?
---@return PositionOpt
function DB.GetWidgetPosition(which, unit, layout)
    dbDebug("|cffff7777DB:GetWidgetPosition:|r", which, unit, layout)
    return DB.GetAllWidgetTables(unit, layout)[which].position
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
-- Setters
-----------------------------------------

---@param which WIDGET_KIND
---@param enabled boolean
---@param unit Unit?
---@param layout string?
function DB.SetWidgetEnabled(which, enabled, unit, layout)
    dbDebug("|cffff7777DB:SetWidgetEnabled:|r", which, enabled, unit, layout)
    DB.GetWidgetTable(which, unit, layout).enabled = enabled
end

---@param which WIDGET_KIND
---@param property OPTION_KIND | AURA_OPTION_KIND
---@param value any
---@param unit Unit?
---@param layout string?
function DB.SetWidgetProperty(which, property, value, unit, layout)
    dbDebug("|cffff7777DB:SetWidgetProperty:|r", which, property, value, unit, layout)
    DB.GetWidgetTable(which, unit, layout)[property] = value
end

---@param which "buffs"|"debuffs"
---@param kind "blacklist"|"whitelist"
---@param value table
---@param unit Unit?
---@param layout string?
function DB.SetAuraFilter(which, kind, value, unit, layout)
    DB.GetAllWidgetTables(unit, layout)[which].filter[kind] = value
end
