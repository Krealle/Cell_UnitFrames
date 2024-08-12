---@class CUF
local CUF = select(2, ...)

---@class CUF.database
local DB = {}
CUF.DB = DB

local dbDebug = function(...) if CUF.IsInDebugMode() and 2 == 1 then CUF:Log(...) end end

-----------------------------------------
-- Getters
-----------------------------------------

---@param name string
local function OnLayoutoutImported(name)
    if CUF_DB.layouts[name] then return end

    CUF_DB.layouts[name] = Cell.funcs:Copy(CUF.Defaults.Layouts)
end
Cell:RegisterCallback("LayoutImported", "CUF_DB_LayoutImported", OnLayoutoutImported)

-- Verify we have DB entry for a layout change
--
-- TODO: Proper delete/rename handling
---@param layout string
function DB.HandleLayoutLoad(layout)
    --[[ local state = CUF.vars.CellLayoutButtonState
    CUF:Log("HandleLayoutLoad",
        "state:", state,
        "Old:", CUF.vars.selectedLayout, (CUF_DB.layouts[CUF.vars.selectedLayout] ~= nil),
        "New:", layout, (CUF_DB.layouts[layout] ~= nil))

    if state == "Delete" then
        if CUF_DB.layouts[CUF.vars.selectedLayout]
            and strlower(CUF.vars.selectedLayout) ~= "default"
            and CUF.vars.selectedLayout ~= _G.DEFAULT then
            CUF:Print("Layout Deleted:", CUF.vars.selectedLayout)

            CUF_DB.layouts[CUF.vars.selectedLayout] = nil
        end
    end

    if state == "Rename" then
        if CUF_DB.layouts[CUF.vars.selectedLayout]
            and not CUF_DB.layouts[layout]
            and strlower(CUF.vars.selectedLayout) ~= "default"
            and CUF.vars.selectedLayout ~= _G.DEFAULT then
            CUF:Print("Layout renamed:", CUF.vars.selectedLayout, "=>", layout)

            CUF_DB.layouts[layout] = Cell.funcs:Copy(CUF_DB.layouts[CUF.vars.selectedLayout])
            CUF_DB.layouts[CUF.vars.selectedLayout] = nil
        end
    end ]]

    if not CUF_DB.layouts[layout] then
        CUF:Print("Layout added:", layout)
        CUF_DB.layouts[layout] = Cell.funcs:Copy(CUF.Defaults.Layouts)
    end
    CUF.vars.CellLayoutButtonState = "Unknown"
end

-- Returns selected layout table (differes from current in menu)
---@return UnitLayoutTable
function DB.SelectedLayoutTable()
    return CUF_DB.layouts[CUF.vars.selectedLayout]
end

-- Returns selected widget tables
---@return WidgetTables
function DB.SelectedWidgetTables()
    return DB.SelectedLayoutTable()[CUF.vars.selectedUnit].widgets
end

-- Returns active layout table
---@return UnitLayoutTable
function DB.CurrentLayoutTable()
    return CUF_DB.layouts[Cell.vars.currentLayout]
end

---@param unit Unit?
---@param layout string?
---@return WidgetTables
function DB.GetAllWidgetTables(unit, layout)
    dbDebug("|cffff7777DB:GetWidgetTable:|r", unit, layout)
    return CUF_DB.layouts[layout or CUF.vars.selectedLayout][unit or CUF.vars.selectedUnit].widgets
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
