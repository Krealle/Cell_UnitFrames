---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L

local function UpdateSize()
    if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
        CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, CUF.vars.selectedUnit .. "-size")
    end
end

local function UpdateArrangement()
    if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
        CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, CUF.vars.selectedUnit .. "-arrangement")
    end
end

---@param unitPage UnitsMenuPage
local function AddLoadPageDB(unitPage)
    -- Load page from DB
    ---@param pageId Unit
    local function LoadPageDB(pageId)
        if pageId ~= unitPage.id then return end
        local pageDB = CUF.DB.SelectedLayoutTable()[pageId]
        local isPlayerPage = pageId == CUF.constants.UNIT.PLAYER
        local isSameSizeAsPlayer = pageDB.sameSizeAsPlayer

        -- size
        unitPage.widthSlider:SetValue(pageDB.size[1])
        unitPage.heightSlider:SetValue(pageDB.size[2])
        unitPage.powerSizeSlider:SetValue(pageDB.powerSize)

        -- unit arrangement
        unitPage.anchorDropdown:SetSelectedValue(pageDB.point)

        -- same as player
        if not isPlayerPage then
            unitPage.sameSizeAsPlayerCB:SetChecked(isSameSizeAsPlayer)
        end

        if isPlayerPage then
            unitPage.widthSlider:SetEnabled(true)
            unitPage.heightSlider:SetEnabled(true)
            unitPage.powerSizeSlider:SetEnabled(true)
            unitPage.anchorDropdown:SetEnabled(true)
        else
            unitPage.widthSlider:SetEnabled(not isSameSizeAsPlayer)
            unitPage.heightSlider:SetEnabled(not isSameSizeAsPlayer)
            unitPage.powerSizeSlider:SetEnabled(not isSameSizeAsPlayer)
            unitPage.anchorDropdown:SetEnabled(not isSameSizeAsPlayer)
        end

        unitPage.enabledCB:SetChecked(pageDB.enabled)
    end
    CUF:RegisterCallback("LoadPageDB", "Units_" .. unitPage.id .. "_LoadPageDB", LoadPageDB)
end

local function AddUnitsToMenu()
    for _, unit in pairs(CUF.constants.UNIT) do
        CUF.Menu:AddUnit(
        ---@param parent UnitsFramesTab
        ---@return UnitsMenuPage
            function(parent)
                ---@class UnitsMenuPage
                local unitPage = {}

                unitPage.frame = CUF:CreateFrame(nil, parent.unitSection,
                    parent.unitSection:GetWidth(),
                    parent.unitSection:GetHeight(),
                    true)
                unitPage.frame:SetPoint("TOPLEFT")
                unitPage.id = unit ---@type Unit

                ---@class UnitMenuPageButton: CellButton
                unitPage.pageButton = CUF:CreateButton(parent.unitSection, L[unit], { 85, 17 })
                unitPage.pageButton.id = unit ---@type Unit

                ---@type CheckButton
                unitPage.enabledCB = Cell:CreateCheckButton(unitPage.frame,
                    L["Enable"] .. " " .. L[unit] .. " " .. L
                    .Frame,
                    function(checked)
                        CUF.DB.SelectedLayoutTable()[unit].enabled = checked
                        if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                            CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, unit)
                        end
                        CUF:Fire("UpdateVisibility", unit)
                    end)
                unitPage.enabledCB:SetPoint("TOPLEFT", 5, -10)

                if unit ~= CUF.constants.UNIT.PLAYER then
                    -- same size as player
                    ---@type CheckButton?
                    unitPage.sameSizeAsPlayerCB = Cell:CreateCheckButton(unitPage.frame, L["Use Same Size As Player"],
                        function(checked)
                            CUF.DB.SelectedLayoutTable()[unit].sameSizeAsPlayer = checked
                            unitPage.widthSlider:SetEnabled(not checked)
                            unitPage.heightSlider:SetEnabled(not checked)
                            unitPage.powerSizeSlider:SetEnabled(not checked)
                            -- TODO: should be arrangment based instead
                            unitPage.anchorDropdown:SetEnabled(not checked)

                            -- update size and power
                            UpdateSize()
                            if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, unit .. "-power")
                            end
                        end)
                    unitPage.sameSizeAsPlayerCB:SetPoint("TOPLEFT", unitPage.enabledCB, "TOPRIGHT", 200, 0)
                end

                ---@type CellSlider
                unitPage.widthSlider = Cell:CreateSlider(L["Width"], unitPage.frame, 20, 500, 117, 1, function(value)
                    CUF.DB.SelectedLayoutTable()[unit].size[1] = value
                    UpdateSize()
                end)
                unitPage.widthSlider:SetPoint("TOPLEFT", unitPage.enabledCB, 0, -50)

                ---@type CellDropdown
                unitPage.anchorDropdown = Cell:CreateDropdown(unitPage.frame, 117)
                unitPage.anchorDropdown:SetPoint("TOPLEFT", unitPage.widthSlider, "TOPRIGHT", 30, 0)

                local dropdownItems = {}
                for _, point in ipairs(CUF.constants.UNIT_ANCHOR_POINTS) do
                    tinsert(dropdownItems, {
                        ["text"] = L[point],
                        ["value"] = point,
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].point = point
                            UpdateArrangement()
                        end,
                    })
                end
                unitPage.anchorDropdown:SetItems(dropdownItems)
                unitPage.anchorDropdown:SetLabel(L["Anchor Point"])

                ---@type CellSlider
                unitPage.heightSlider = Cell:CreateSlider(L["Height"], unitPage.frame, 20, 500, 117, 1, function(value)
                    CUF.DB.SelectedLayoutTable()[unit].size[2] = value
                    UpdateSize()
                end)
                unitPage.heightSlider:SetPoint("TOPLEFT", unitPage.widthSlider, 0, -55)

                ---@type CellSlider
                unitPage.powerSizeSlider = Cell:CreateSlider(L["Power Size"], unitPage.frame, 0, 100, 117, 1,
                    function(value)
                        CUF.DB.SelectedLayoutTable()[unit].powerSize = value
                        if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                            CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, unit .. "-power")
                        end
                    end)
                unitPage.powerSizeSlider:SetPoint("TOPLEFT", unitPage.heightSlider, "TOPRIGHT", 30, 0)

                AddLoadPageDB(unitPage)
                return unitPage
            end)
    end

    return true
end
CUF:AddEventListener("PLAYER_LOGIN", AddUnitsToMenu)
