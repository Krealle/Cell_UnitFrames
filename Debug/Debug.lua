---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

---@class CFU.Debug
local Debug = {}

CUF.Debug = Debug

function Debug:InitDebugWindow()
    self.window = CUF.DebugWindow
    self.window:Create()
    self.window:UpdateVars()

    self.window:AddVar("isMenuOpen")
    self.window:AddVar("selectedLayout")
    self.window:AddVar("selectedUnit")
    self.window:AddVar("selectedWidget")
    self.window:AddVar(
        "selectedLayoutTable", function() CUF:DevAdd(CUF.vars.selectedLayoutTable, "selectedLayoutTable") end)
    self.window:AddVar("selectedWidgetTable",
        function() CUF:DevAdd(CUF.vars.selectedWidgetTable, "selectedWidgetTable") end)
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
