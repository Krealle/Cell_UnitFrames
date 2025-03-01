---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L

local Menu = CUF.Menu

local function UpdateSize()
    if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
        CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, CUF.vars.selectedUnit .. "-size")
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

        -- same as player
        if not isPlayerPage then
            unitPage.sameSizeAsPlayerCB:SetChecked(isSameSizeAsPlayer)
        end

        -- click casting
        unitPage.clickCastCB:SetChecked(pageDB.clickCast)

        if isPlayerPage then
            unitPage.widthSlider:SetEnabled(true)
            unitPage.heightSlider:SetEnabled(true)
        else
            unitPage.widthSlider:SetEnabled(not isSameSizeAsPlayer)
            unitPage.heightSlider:SetEnabled(not isSameSizeAsPlayer)
        end

        -- copy from
        unitPage.copyFromDropdown:ClearItems()
        for _, unit in pairs(CUF.constants.UNIT) do
            if unitPage.id ~= unit then
                unitPage.copyFromDropdown:AddItem({
                    ["text"] = L[unit],
                    ["value"] = unit,
                    ["onClick"] = function()
                        Menu:ShowPopup(string.format(L.CopyFromPopUp, L[unit], L[unitPage.id]),
                            function()
                                CUF.DB.CopyWidgetSettings(unit, unitPage.id)
                                CUF:Fire("LoadPageDB", unitPage.id, CUF.vars.selectedWidget)
                                CUF:Fire("UpdateWidget", CUF.vars.selectedLayout)
                            end)
                        unitPage.copyFromDropdown:ClearSelected()
                    end,
                })
            end
        end

        unitPage.barOrientationDropdown:SetSelectedValue(pageDB.barOrientation)

        if pageId == "boss" then
            unitPage.spacingSlider:SetValue(pageDB.spacing)
            unitPage.growthDirectionDropdown:SetSelectedValue(pageDB.growthDirection)
        end

        if pageId == "targettarget" then
            unitPage.alwaysUpdateCB:SetChecked(pageDB.alwaysUpdate)
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

                -- First row

                ---@type CheckButton
                unitPage.enabledCB = Cell.CreateCheckButton(unitPage.frame,
                    L["Enable"],
                    function(checked)
                        CUF.DB.SelectedLayoutTable()[unit].enabled = checked
                        if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                            CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, unit)
                        end
                        CUF:Fire("UpdateVisibility", unit)
                    end)
                unitPage.enabledCB:SetPoint("TOPLEFT", 5, -10)

                unitPage.clickCastCB = Cell.CreateCheckButton(unitPage.frame, L["Click Casting"],
                    function(checked)
                        CUF.DB.SelectedLayoutTable()[unit].clickCast = checked
                        CUF:Fire("UpdateClickCasting", false, false, unit)
                    end)
                unitPage.clickCastCB:SetPoint("TOPLEFT", unitPage.enabledCB, "TOPRIGHT", 70, 0)

                if unit ~= CUF.constants.UNIT.PLAYER then
                    -- same size as player
                    ---@type CheckButton?
                    unitPage.sameSizeAsPlayerCB = Cell.CreateCheckButton(unitPage.frame, L["Use Same Size As Player"],
                        function(checked)
                            CUF.DB.SelectedLayoutTable()[unit].sameSizeAsPlayer = checked
                            unitPage.widthSlider:SetEnabled(not checked)
                            unitPage.heightSlider:SetEnabled(not checked)

                            -- update size and power
                            UpdateSize()
                            if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, unit .. "-power")
                            end
                        end)
                    unitPage.sameSizeAsPlayerCB:SetPoint("TOPLEFT", unitPage.clickCastCB, "TOPRIGHT", 130, 0)
                end

                -- Second row

                ---@type CellSlider
                unitPage.widthSlider = Cell.CreateSlider(L["Width"], unitPage.frame, 5, 500, 117, 1, function(value)
                    CUF.DB.SelectedLayoutTable()[unit].size[1] = value
                    UpdateSize()
                end)
                unitPage.widthSlider:SetPoint("TOPLEFT", unitPage.enabledCB, 0, -50)

                ---@type CellDropdown
                unitPage.copyFromDropdown = Cell.CreateDropdown(unitPage.frame, 117)
                unitPage.copyFromDropdown:SetPoint("TOPLEFT", unitPage.widthSlider, "TOPRIGHT", 30, 0)
                unitPage.copyFromDropdown:SetLabel(L.CopyWidgetsFrom)
                CUF:SetTooltips(unitPage.copyFromDropdown, "ANCHOR_TOPLEFT", 0, 3, L.CopyWidgetsFrom,
                    L.CopyWidgetsFromTooltip)

                ---@type CellDropdown
                unitPage.barOrientationDropdown = Cell.CreateDropdown(unitPage.frame, 117)
                unitPage.barOrientationDropdown:SetPoint("TOPLEFT", unitPage.copyFromDropdown, "TOPRIGHT", 40, 0)
                unitPage.barOrientationDropdown:SetLabel(L["Bar Orientation"])
                unitPage.barOrientationDropdown:SetItems({
                    {
                        ["text"] = L["Horizontal"],
                        ["value"] = "horizontal",
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].barOrientation = "horizontal"
                            CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "barOrientation", unit)
                        end,
                    },
                    {
                        ["text"] = L["Vertical"] .. " A",
                        ["value"] = "vertical",
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].barOrientation = "vertical"
                            CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "barOrientation", unit)
                        end,
                    },
                    {
                        ["text"] = L["Vertical"] .. " B",
                        ["value"] = "vertical_health",
                        ["onClick"] = function()
                            CUF.DB.SelectedLayoutTable()[unit].barOrientation = "vertical_health"
                            CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "barOrientation", unit)
                        end,
                    },
                })

                -- Third row

                ---@type CellSlider
                unitPage.heightSlider = Cell.CreateSlider(L["Height"], unitPage.frame, 5, 500, 117, 1, function(value)
                    CUF.DB.SelectedLayoutTable()[unit].size[2] = value
                    UpdateSize()
                end)
                unitPage.heightSlider:SetPoint("TOPLEFT", unitPage.widthSlider, 0, -55)

                if unit == "boss" then
                    ---@type CellSlider
                    unitPage.spacingSlider = Cell.CreateSlider(L["Spacing"], unitPage.frame, 0, 100, 117, 1,
                        function(value)
                            CUF.DB.SelectedLayoutTable()[unit].spacing = value
                            if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "spacing", unit)
                            end
                        end)
                    unitPage.spacingSlider:SetPoint("LEFT", unitPage.heightSlider, "RIGHT", 25, 0)

                    ---@type CellDropdown
                    unitPage.growthDirectionDropdown = Cell.CreateDropdown(unitPage.frame, 141)
                    unitPage.growthDirectionDropdown:SetPoint("TOPLEFT", unitPage.spacingSlider, "TOPRIGHT",
                        25, 0)
                    unitPage.growthDirectionDropdown:SetLabel(L.GrowthDirection)

                    for _, orientation in pairs(CUF.constants.GROWTH_ORIENTATION) do
                        unitPage.growthDirectionDropdown:AddItem({
                            ["text"] = L[orientation],
                            ["value"] = orientation,
                            ["onClick"] = function()
                                CUF.DB.SelectedLayoutTable()[unit].growthDirection = orientation
                                CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "growthDirection", unit)
                            end,
                        })
                    end

                    if CUF.unitButtons.boss and CUF.unitButtons.boss.boss1 then
                        CUF.HelpTips:Show(unitPage.spacingSlider, {
                            text = string.format(L.HelpTip_BossFramePreview, L.Boss, L.player),
                            dbKey = "bossFramePreview",
                            buttonStyle = HelpTip.ButtonStyle.GotIt,
                            alignment = HelpTip.Alignment.Left,
                            targetPoint = HelpTip.Point.LeftEdgeCenter,
                        }, CUF.unitButtons.boss.boss1)
                    end
                else
                    if unit == "targettarget" then
                        unitPage.alwaysUpdateCB = Cell.CreateCheckButton(unitPage.frame,
                            L.AlwaysUpdate,
                            function(checked)
                                CUF.DB.SelectedLayoutTable()[unit].alwaysUpdate = checked
                                if CUF.vars.selectedLayout == CUF.DB.GetMasterLayout() then
                                    CUF:Fire("UpdateLayout", CUF.vars.selectedLayout, "alwaysUpdate", unit)
                                end
                            end, L.AlwaysUpdate, string.format(L.AlwaysUpdateUnitFrameTooltip, "0.25"))
                        unitPage.alwaysUpdateCB:SetPoint("LEFT", unitPage.heightSlider, "RIGHT", 25, 0)
                    end
                end

                AddLoadPageDB(unitPage)
                return unitPage
            end)
    end

    return true
end
CUF:AddEventListener("PLAYER_LOGIN", AddUnitsToMenu)
