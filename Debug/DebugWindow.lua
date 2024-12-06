---@class CUF
local CUF = select(2, ...)

local const = CUF.constants

---@class CUF.DebugWindow
local DebugWindow = {}
DebugWindow.fstack = false

CUF.DebugWindow = DebugWindow

function DebugWindow:Create()
    self.cells = {}
    ---@type CUFDebugVar[]
    self.vars = {}

    ---@class CUF_DebugWindow: Frame
    self.frame = CUF:CreateFrame("CUF_DebugWindow", UIParent, 300, 60, false, true)
    self.frame:SetFrameStrata("DIALOG")
    self.frame:SetPoint("CENTER", -600, 200)

    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)

    local title = self.frame:CreateFontString(nil, "OVERLAY", const.FONTS.CLASS_TITLE)
    title = self.frame:CreateFontString(nil, "OVERLAY", const.FONTS.CLASS_TITLE)
    title:SetText("Debug Window")
    title:SetScale(1.2)
    title:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 5, 5)

    local frameStackButton = CUF:CreateButton(self.frame, "Framestack", { 117, 16 },
        function()
            self.fstack = not self.fstack
            UIParentLoadAddOn("Blizzard_DebugTools")
            --[[ local showHidden = false
            local showRegions = false ]]
            FrameStackTooltip_Toggle(false, false)
        end)
    frameStackButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -5, -5)

    local devToolButotn = CUF:CreateButton(frameStackButton, "DevTool", { 117, 16 }, function() DevTool:ToggleUI() end)
    devToolButotn:SetPoint("TOPRIGHT", frameStackButton, "BOTTOMRIGHT", 0, -2)

    local varTitle = CUF:CreateFrame(nil, self.frame, 1, 1, true, true) --[[@as CUFDebugVar]]
    varTitle:SetPoint("TOPLEFT", 5, -50)
    varTitle.title = varTitle:CreateFontString(nil, "OVERLAY", const.FONTS.CLASS_TITLE)
    varTitle.title:SetText("Variables")
    varTitle.title:SetPoint("TOPLEFT")
    self.frame.varTitle = varTitle

    local varButton = CUF:CreateButton(varTitle, "Update Vars", { 117, 16 }, self.UpdateVars)
    varButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -5, -50)
end

---@param name string
---@param dumpFn? function
---@param getTextFn? function
function DebugWindow:AddVar(name, dumpFn, getTextFn)
    local prevVar = #self.vars ~= 0 and self.vars[#self.vars] or nil

    ---@class CUFDebugVar: Frame
    local f = CUF:CreateFrame(nil, prevVar or self.frame.varTitle, 290, 20, false, true)
    f:SetPoint("TOPLEFT", 0, -22)

    f.title = f:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
    f.title:SetText(name .. ":")
    f.title:SetPoint("TOPLEFT", 2, -2)

    if dumpFn then
        local varButton = CUF:CreateButton(f, "Dump", { 60, 16 }, dumpFn, "green")
        varButton:SetPoint("TOPLEFT", f.title, "TOPLEFT", 150, 0)
        f.UpdateValue = function() end
    else
        f.value = f:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
        f.value:SetPoint("TOPLEFT", f.title, "TOPLEFT", 150, 0)

        f.UpdateValue = function()
            local text = getTextFn and getTextFn() or CUF.vars[name]
            if type(text) == "table" then
                CUF:DevAdd(text, name)
                text = "table"
            end

            f.value:SetText(tostring(text))
        end
    end

    table.insert(self.vars, f)
    self.frame:SetHeight(self.frame:GetHeight() + 24)
end

function DebugWindow:UpdateVars()
    for _, var in pairs(DebugWindow.vars) do
        var:UpdateValue()
    end
end
