---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CUF.Debug
local Debug = CUF.Debug

function Debug:InitDebugWindow()
    self.window = CUF.DebugWindow
    self.window:Create()
    self.window:UpdateVars()

    self.window:AddVar("isMenuOpen")
    self.window:AddVar("selectedLayout")
    self.window:AddVar("selectedUnit")
    self.window:AddVar("selectedWidget")
    self.window:AddVar(
        "selectedLayoutTable", function() CUF:DevAdd(CUF.DB.SelectedLayoutTable(), "selectedLayoutTable") end)
    self.window:AddVar("selectedWidgetTable",
        function() CUF:DevAdd(CUF.DB.GetSelectedWidgetTables(), "selectedWidgetTable") end)
    self.window:AddVar("CUF.vars", function() CUF:DevAdd(CUF.vars, "CUF.vars") end)
    self.window:AddVar("CUF_DB", function() CUF:DevAdd(CUF_DB, "CUF_DB") end)
    self.window:AddVar("Buttons", function() CUF:DevAdd(CUF.unitButtons, "unitButtons") end)
    self.window:AddVar("Cell", function() CUF:DevAdd(Cell, "Cell") end)
    self.window:AddVar("Cell.vars", function() CUF:DevAdd(Cell.vars, "Cell.vars") end)
    self.window:AddVar("CellDB", function() CUF:DevAdd(CellDB, "CellDB") end)

    self.window:UpdateVars()
end

function Debug:ToggleDebugWindow()
    if not self.window then
        self:InitDebugWindow()
        return
    end

    if self.window.frame:IsShown() then
        self.window.frame:Hide()
    else
        self.window.frame:Show()
    end
end

---@param playerLoginOwnerId number
---@return boolean
local function OnPlayerLogin(playerLoginOwnerId)
    if CUF.IsInDebugMode() then
        Debug:InitDebugWindow()
    end
    return true
end
CUF:AddEventListener("PLAYER_LOGIN", OnPlayerLogin)

function CUF.IsInDebugMode()
    return CUF_DB.debug
end

---@param mode boolean
function CUF.SetDebugMode(mode)
    if type(mode) ~= "boolean" then
        mode = false
    end
    CUF_DB.debug = mode
end
