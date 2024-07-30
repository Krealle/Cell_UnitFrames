---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = Cell.L

local menu = CUF.Menu

local function UpdateSize()
    if CUF.vars.selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", CUF.vars.selectedLayout, CUF.vars.selectedUnit .. "-size")
    end
end

local function UpdateArrangement()
    if CUF.vars.selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", CUF.vars.selectedLayout, CUF.vars.selectedUnit .. "-arrangement")
    end
end

---@param unit UnitsMenuPage
local function AddLoadPageDB(unit)
    -- Load page from DB
    ---@param page Units
    local function LoadPageDB(page)
        if page ~= unit.id then return end
        -- size
        unit.widthSlider:SetValue(CUF.vars.selectedLayoutTable[page]["size"][1])
        unit.heightSlider:SetValue(CUF.vars.selectedLayoutTable[page]["size"][2])
        unit.powerSizeSlider:SetValue(CUF.vars.selectedLayoutTable[page]["powerSize"])

        -- unit arrangement
        unit.anchorDropdown:SetSelectedValue(CUF.vars.selectedLayoutTable[page]["anchor"])

        -- same as player
        if page ~= "player" then
            unit.sameSizeAsPlayerCB:SetChecked(CUF.vars.selectedLayoutTable[page]["sameSizeAsPlayer"])
        end

        if page == "player" then
            unit.widthSlider:SetEnabled(true)
            unit.heightSlider:SetEnabled(true)
            unit.powerSizeSlider:SetEnabled(true)
            unit.anchorDropdown:SetEnabled(true)
        else
            unit.widthSlider:SetEnabled(not CUF.vars.selectedLayoutTable[page]["sameSizeAsPlayer"])
            unit.heightSlider:SetEnabled(not CUF.vars.selectedLayoutTable[page]["sameSizeAsPlayer"])
            unit.powerSizeSlider:SetEnabled(not CUF.vars.selectedLayoutTable[page]["sameSizeAsPlayer"])
            unit.anchorDropdown:SetEnabled(not CUF.vars.selectedLayoutTable[page]["sameSizeAsPlayer"])
        end

        unit.unitFrameCB:SetChecked(CUF.vars.selectedLayoutTable[unit.id]["enabled"])
    end
    CUF:RegisterCallback("LoadPageDB", "Units_" .. unit.id .. "_LoadPageDB", LoadPageDB)
end

for _, unit in pairs(CUF.vars.units) do
    local unitName = unit:gsub("^%l", string.upper)

    menu:AddUnit(
    ---@param parent MenuFrame
    ---@return UnitsMenuPage
        function(parent)
            ---@class UnitsMenuPage
            local self = {}

            self.frame = CreateFrame("Frame", nil, parent.unitAnchor)
            self.id = unit

            -- button
            self.button = Cell:CreateButton(parent.unitAnchor, L[unitName], "accent-hover", { 85, 17 })
            self.button.id = unit

            self.unitFrameCB = Cell:CreateCheckButton(self.frame, L["Enable " .. unitName .. " Frame"],
                function(checked)
                    CUF.vars.selectedLayoutTable[unit]["enabled"] = checked
                    if CUF.vars.selectedLayout == Cell.vars.currentLayout then
                        Cell:Fire("UpdateLayout", CUF.vars.selectedLayout, unit)
                    end
                    Cell:Fire("UpdateVisibility", unit)
                end)
            self.unitFrameCB:SetPoint("TOPLEFT", 5, -27)

            if unit ~= "player" then
                -- same size as player
                self.sameSizeAsPlayerCB = Cell:CreateCheckButton(self.frame, L["Use Same Size As Player"],
                    function(checked)
                        CUF.vars.selectedLayoutTable[unit]["sameSizeAsPlayer"] = checked
                        self.widthSlider:SetEnabled(not checked)
                        self.heightSlider:SetEnabled(not checked)
                        self.powerSizeSlider:SetEnabled(not checked)
                        --self.anchorDropdown:SetEnabled(not checked)
                        -- update size and power
                        UpdateSize()
                        if CUF.vars.selectedLayout == Cell.vars.currentLayout then
                            Cell:Fire("UpdateLayout", CUF.vars.selectedLayout, unit .. "-power")
                        end
                    end)
                self.sameSizeAsPlayerCB:SetPoint("TOPLEFT", self.unitFrameCB, "TOPRIGHT", 200, 0)
            end

            -- width
            self.widthSlider = Cell:CreateSlider(L["Width"], self.frame, 20, 500, 117, 1, function(value)
                CUF.vars.selectedLayoutTable[unit]["size"][1] = value
                UpdateSize()
            end)
            self.widthSlider:SetPoint("TOPLEFT", self.unitFrameCB, 0, -50)

            -- height
            self.heightSlider = Cell:CreateSlider(L["Height"], self.frame, 20, 500, 117, 1, function(value)
                CUF.vars.selectedLayoutTable[unit]["size"][2] = value
                UpdateSize()
            end)
            self.heightSlider:SetPoint("TOPLEFT", self.widthSlider, 0, -55)

            -- power height
            self.powerSizeSlider = Cell:CreateSlider(L["Power Size"], self.frame, 0, 100, 117, 1, function(value)
                CUF.vars.selectedLayoutTable[unit]["powerSize"] = value
                if CUF.vars.selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", CUF.vars.selectedLayout, unit .. "-power")
                end
            end)
            self.powerSizeSlider:SetPoint("TOPLEFT", self.heightSlider, "TOPRIGHT", 30, 0)

            -- anchor
            self.anchorDropdown = Cell:CreateDropdown(self.frame, 117)
            self.anchorDropdown:SetPoint("TOPLEFT", self.widthSlider, "TOPRIGHT", 30, 0)
            self.anchorDropdown:SetItems({
                {
                    ["text"] = L["BOTTOMLEFT"],
                    ["value"] = "BOTTOMLEFT",
                    ["onClick"] = function()
                        CUF.vars.selectedLayoutTable[unit]["anchor"] = "BOTTOMLEFT"
                        UpdateArrangement()
                    end,
                },
                {
                    ["text"] = L["BOTTOMRIGHT"],
                    ["value"] = "BOTTOMRIGHT",
                    ["onClick"] = function()
                        CUF.vars.selectedLayoutTable[unit]["anchor"] = "BOTTOMRIGHT"
                        UpdateArrangement()
                    end,
                },
                {
                    ["text"] = L["TOPLEFT"],
                    ["value"] = "TOPLEFT",
                    ["onClick"] = function()
                        CUF.vars.selectedLayoutTable[unit]["anchor"] = "TOPLEFT"
                        UpdateArrangement()
                    end,
                },
                {
                    ["text"] = L["TOPRIGHT"],
                    ["value"] = "TOPRIGHT",
                    ["onClick"] = function()
                        CUF.vars.selectedLayoutTable[unit]["anchor"] = "TOPRIGHT"
                        UpdateArrangement()
                    end,
                },
            })

            self.anchorText = self.frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            self.anchorText:SetPoint("BOTTOMLEFT", self.anchorDropdown, "TOPLEFT", 0, 1)
            self.anchorText:SetText(L["Anchor Point"])

            hooksecurefunc(self.anchorDropdown, "SetEnabled", function(_, enabled)
                if enabled then
                    self.anchorText:SetTextColor(1, 1, 1)
                else
                    self.anchorText:SetTextColor(0.4, 0.4, 0.4)
                end
            end)

            AddLoadPageDB(self)
            return self
        end)
end
