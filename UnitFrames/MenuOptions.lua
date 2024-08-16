---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell

local L = CUF.L
local menu = CUF.Menu
local const = CUF.constants
local Util = CUF.Util

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
    ---@param page Unit
    local function LoadPageDB(page)
        if page ~= unit.id then return end
        -- size
        unit.widthSlider:SetValue(CUF.DB.SelectedLayoutTable()[page].size[1])
        unit.heightSlider:SetValue(CUF.DB.SelectedLayoutTable()[page].size[2])
        unit.powerSizeSlider:SetValue(CUF.DB.SelectedLayoutTable()[page].powerSize)

        -- unit arrangement
        unit.anchorDropdown:SetSelectedValue(CUF.DB.SelectedLayoutTable()[page].point)

        -- same as player
        if page ~= const.UNIT.PLAYER then
            unit.sameSizeAsPlayerCB:SetChecked(CUF.DB.SelectedLayoutTable()[page].sameSizeAsPlayer)
        end

        if page == const.UNIT.PLAYER then
            unit.widthSlider:SetEnabled(true)
            unit.heightSlider:SetEnabled(true)
            unit.powerSizeSlider:SetEnabled(true)
            unit.anchorDropdown:SetEnabled(true)
        else
            unit.widthSlider:SetEnabled(not CUF.DB.SelectedLayoutTable()[page].sameSizeAsPlayer)
            unit.heightSlider:SetEnabled(not CUF.DB.SelectedLayoutTable()[page].sameSizeAsPlayer)
            unit.powerSizeSlider:SetEnabled(not CUF.DB.SelectedLayoutTable()[page].sameSizeAsPlayer)
            unit.anchorDropdown:SetEnabled(not CUF.DB.SelectedLayoutTable()[page].sameSizeAsPlayer)
        end

        unit.unitFrameCB:SetChecked(CUF.DB.SelectedLayoutTable()[unit.id].enabled)
    end
    CUF:RegisterCallback("LoadPageDB", "Units_" .. unit.id .. "_LoadPageDB", LoadPageDB)
end

local function AddUnitsToMenu()
    for _, unit in pairs(CUF.constants.UNIT) do
        local unitName = Util:ToTitleCase(unit)

        menu:AddUnit(
        ---@param parent MenuFrame
        ---@return UnitsMenuPage
            function(parent)
                ---@class UnitsMenuPage
                local self = {}

                self.frame = CUF:CreateFrame(nil, parent.unitSection,
                    parent.unitSection:GetWidth(),
                    parent.unitSection:GetHeight(),
                    true)
                self.frame:SetPoint("TOPLEFT")

                self.id = unit

                -- button
                self.button = Cell:CreateButton(parent.unitSection, L[unit], "accent-hover", { 85, 17 })
                self.button.id = unit

                self.unitFrameCB = Cell:CreateCheckButton(self.frame, L["Enable"] .. " " .. L[unitName] .. " " .. L
                    .Frame,
                    function(checked)
                        CUF.DB.SelectedLayoutTable()[unit].enabled = checked
                        if CUF.vars.selectedLayout == Cell.vars.currentLayout then
                            Cell:Fire("UpdateLayout", CUF.vars.selectedLayout, unit)
                        end
                        Cell:Fire("UpdateVisibility", unit)
                    end)
                self.unitFrameCB:SetPoint("TOPLEFT", 5, -10)

                if unit ~= const.UNIT.PLAYER then
                    -- same size as player
                    self.sameSizeAsPlayerCB = Cell:CreateCheckButton(self.frame, L["Use Same Size As Player"],
                        function(checked)
                            CUF.DB.SelectedLayoutTable()[unit].sameSizeAsPlayer = checked
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
                    CUF.DB.SelectedLayoutTable()[unit].size[1] = value
                    UpdateSize()
                end)
                self.widthSlider:SetPoint("TOPLEFT", self.unitFrameCB, 0, -50)

                -- height
                self.heightSlider = Cell:CreateSlider(L["Height"], self.frame, 20, 500, 117, 1, function(value)
                    CUF.DB.SelectedLayoutTable()[unit].size[2] = value
                    UpdateSize()
                end)
                self.heightSlider:SetPoint("TOPLEFT", self.widthSlider, 0, -55)

                -- power height
                self.powerSizeSlider = Cell:CreateSlider(L["Power Size"], self.frame, 0, 100, 117, 1, function(value)
                    CUF.DB.SelectedLayoutTable()[unit].powerSize = value
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
                            CUF.DB.SelectedLayoutTable()[unit].point = "BOTTOMLEFT"
                            UpdateArrangement()
                        end,
                    },
                    {
                        ["text"] = L["BOTTOMRIGHT"],
                        ["value"] = "BOTTOMRIGHT",
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].point = "BOTTOMRIGHT"
                            UpdateArrangement()
                        end,
                    },
                    {
                        ["text"] = L["TOPLEFT"],
                        ["value"] = "TOPLEFT",
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].point = "TOPLEFT"
                            UpdateArrangement()
                        end,
                    },
                    {
                        ["text"] = L["TOPRIGHT"],
                        ["value"] = "TOPRIGHT",
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].point = "TOPRIGHT"
                            UpdateArrangement()
                        end,
                    },
                })

                self.anchorText = self.frame:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIGET)
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

    return true
end
CUF:AddEventListener("PLAYER_LOGIN", AddUnitsToMenu)
