---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local L = CUF.L
local F = Cell.funcs

local Handler = CUF.Handler
local const = CUF.constants
local DB = CUF.DB
local Util = CUF.Util

---@class CUF.builder
local Builder = CUF.Builder

-------------------------------------------------
-- 1:1 yoink from Cell - very cool stuff
-------------------------------------------------
local function GetExportString(t)
    local s = ""
    local n = 0
    for i, id in ipairs(t) do
        if type(id) == "table" then id = id[1] end
        local name = F.GetSpellInfo(id)
        if name then
            s = s .. (i == 1 and "" or "\n") .. id .. ", -- " .. name
            n = n + 1
        end
    end
    return s, n
end

---@param parent Cell.SettingsAuras.frame
---@param auraButtons table
---@param auraTable table
---@param noUpDownButtons boolean
---@param updateHeightFunc function
local function CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, updateHeightFunc)
    local n = #auraTable

    -- tooltip
    if not parent.popupEditBox then
        ---@class CUFEditBox: EditBox
        ---@field SetTips fun(self, text: string)
        local popup = Cell.CreatePopupEditBox(parent)
        popup:SetNumeric(true)

        popup:SetScript("OnTextChanged", function()
            local spellId = tonumber(popup:GetText())
            if not spellId then
                CellSpellTooltip:Hide()
                return
            end

            local name, tex = F.GetSpellInfo(spellId)
            if not name then
                CellSpellTooltip:Hide()
                return
            end

            CellSpellTooltip:SetOwner(popup, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -1)
            CellSpellTooltip:SetSpellByID(spellId, tex)
            CellSpellTooltip:Show()
        end)

        popup:HookScript("OnHide", function()
            CellSpellTooltip:Hide()
        end)
    end

    -- new
    if not auraButtons[0] then
        auraButtons[0] = Cell.CreateButton(parent, "", "transparent-accent", { 20, 20 })
        auraButtons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", { 16, 16 }, { "RIGHT", -1, 0 })
        auraButtons[0]:SetPoint("BOTTOMLEFT")
        auraButtons[0]:SetPoint("RIGHT")
    end

    auraButtons[0]:SetScript("OnClick", function(self)
        local popup = Cell.CreatePopupEditBox(parent, function(text)
            local spellId = tonumber(text)
            local spellName = F.GetSpellInfo(spellId)
            if (spellId and spellName) then
                -- update db
                table.insert(auraTable, spellId)

                parent.func(auraTable)
                CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, updateHeightFunc)
                updateHeightFunc(19)
            else
                F.Print(L["Invalid spell id."])
            end
        end)
        popup:SetPoint("TOPLEFT", self)
        popup:SetPoint("BOTTOMRIGHT", self)
        popup:ShowEditBox("")

        parent.popupEditBox:SetTips("|cffababab" .. L["Input spell id"])
    end)


    for i, spell in ipairs(auraTable) do
        -- creation
        if not auraButtons[i] then
            auraButtons[i] = Cell.CreateButton(parent, "", "transparent-accent", { 20, 20 })

            -- spellIcon
            auraButtons[i].spellIconBg = auraButtons[i]:CreateTexture(nil, "BORDER")
            auraButtons[i].spellIconBg:SetSize(16, 16)
            auraButtons[i].spellIconBg:SetPoint("TOPLEFT", 2, -2)
            auraButtons[i].spellIconBg:SetColorTexture(0, 0, 0, 1)
            auraButtons[i].spellIconBg:Hide()

            auraButtons[i].spellIcon = auraButtons[i]:CreateTexture(nil, "OVERLAY")
            auraButtons[i].spellIcon:SetPoint("TOPLEFT", auraButtons[i].spellIconBg, 1, -1)
            auraButtons[i].spellIcon:SetPoint("BOTTOMRIGHT", auraButtons[i].spellIconBg, -1, 1)
            auraButtons[i].spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            auraButtons[i].spellIcon:Hide()

            -- spellId text
            auraButtons[i].spellIdText = auraButtons[i]:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
            auraButtons[i].spellIdText:SetPoint("LEFT", auraButtons[i].spellIconBg, "RIGHT", 5, 0)
            auraButtons[i].spellIdText:SetPoint("RIGHT", auraButtons[i], "LEFT", 80, 0)
            auraButtons[i].spellIdText:SetWordWrap(false)
            auraButtons[i].spellIdText:SetJustifyH("LEFT")

            -- spellName text
            auraButtons[i].spellNameText = auraButtons[i]:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
            auraButtons[i].spellNameText:SetPoint("LEFT", auraButtons[i].spellIdText, "RIGHT", 5, 0)
            auraButtons[i].spellNameText:SetPoint("RIGHT", -70, 0)
            auraButtons[i].spellNameText:SetWordWrap(false)
            auraButtons[i].spellNameText:SetJustifyH("LEFT")

            -- del
            auraButtons[i].del = Cell.CreateButton(auraButtons[i], "", "none", { 18, 20 }, true, true)
            auraButtons[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", { 16, 16 }, { "CENTER", 0, 0 })
            auraButtons[i].del:SetPoint("RIGHT")
            auraButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            auraButtons[i].del:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].del:SetScript("OnLeave", function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- edit
            -- auraButtons[i].edit = Cell.CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            -- auraButtons[i].edit:SetPoint("RIGHT", auraButtons[i].del, "LEFT", 1, 0)
            -- auraButtons[i].edit:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info", {16, 16}, {"CENTER", 0, 0})
            -- auraButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            -- auraButtons[i].edit:SetScript("OnEnter", function()
            --     auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
            --     auraButtons[i].edit.tex:SetVertexColor(1, 1, 1, 1)
            -- end)
            -- auraButtons[i].edit:SetScript("OnLeave",  function()
            --     auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
            --     auraButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            -- end)

            -- down
            auraButtons[i].down = Cell.CreateButton(auraButtons[i], "", "none", { 18, 20 }, true, true)
            auraButtons[i].down:SetPoint("RIGHT", auraButtons[i].del, "LEFT", 1, 0)
            auraButtons[i].down:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\down", { 16, 16 }, { "CENTER", 0, 0 })
            auraButtons[i].down.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            auraButtons[i].down:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].down.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].down:SetScript("OnLeave", function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].down.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- up
            auraButtons[i].up = Cell.CreateButton(auraButtons[i], "", "none", { 18, 20 }, true, true)
            auraButtons[i].up:SetPoint("RIGHT", auraButtons[i].down, "LEFT", 1, 0)
            auraButtons[i].up:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\up", { 16, 16 }, { "CENTER", 0, 0 })
            auraButtons[i].up.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            auraButtons[i].up:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].up.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].up:SetScript("OnLeave", function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].up.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- color
            auraButtons[i].colorPicker = Cell.CreateColorPicker(auraButtons[i], "", true)
            auraButtons[i].colorPicker:SetPoint("RIGHT", auraButtons[i].up, "LEFT", -1, 0)
            auraButtons[i].colorPicker:SetPoint("TOP", 0, -3)
            auraButtons[i].colorPicker:HookScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
            end)
            auraButtons[i].colorPicker:HookScript("OnLeave", function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
            end)

            -- spell tooltip
            auraButtons[i]:HookScript("OnEnter", function(self)
                if parent.popupEditBox:IsShown() then return end

                local name = F.GetSpellInfo(self.spellId)
                if not name then
                    CellSpellTooltip:Hide()
                    return
                end

                CellSpellTooltip:SetOwner(auraButtons[i], "ANCHOR_NONE")
                CellSpellTooltip:SetPoint("TOPRIGHT", auraButtons[i], "TOPLEFT", -1, 0)
                CellSpellTooltip:SetSpellByID(self.spellId, self.spellTex)
                CellSpellTooltip:Show()
            end)
            auraButtons[i]:HookScript("OnLeave", function()
                if not parent.popupEditBox:IsShown() then
                    CellSpellTooltip:Hide()
                end
            end)
        end

        if spell == 0 then
            auraButtons[i].spellIdText:SetText(spell)
            auraButtons[i].spellId = nil
            auraButtons[i].spellNameText:SetText("|cff22ff22" .. L["all"])
            auraButtons[i].spellIconBg:Hide()
            auraButtons[i].spellIcon:Hide()
        else
            local name, icon = F.GetSpellInfo(spell)
            auraButtons[i].spellIdText:SetText(spell)
            auraButtons[i].spellId = spell
            auraButtons[i].spellTex = icon
            auraButtons[i].spellNameText:SetText(name or ("|cffff2222" .. L["Invalid"]))
            if icon then
                auraButtons[i].spellIcon:SetTexture(icon)
                auraButtons[i].spellIconBg:Show()
                auraButtons[i].spellIcon:Show()
            else
                auraButtons[i].spellIconBg:Hide()
                auraButtons[i].spellIcon:Hide()
            end
        end

        -- points
        auraButtons[i]:ClearAllPoints()
        if i == 1 then -- first
            auraButtons[i]:SetPoint("TOPLEFT")
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].up:Hide()
                auraButtons[i].down:Hide()
            else
                auraButtons[i].up:Hide()
                auraButtons[i].down:Show()
            end
        elseif i == n then -- last
            auraButtons[i]:SetPoint("TOPLEFT", auraButtons[i - 1], "BOTTOMLEFT", 0, 1)
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].up:Hide()
                auraButtons[i].down:Hide()
            else
                auraButtons[i].up:Show()
                auraButtons[i].down:Hide()
            end
        else
            auraButtons[i]:SetPoint("TOPLEFT", auraButtons[i - 1], "BOTTOMLEFT", 0, 1)
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].down:Hide()
                auraButtons[i].up:Hide()
            else
                auraButtons[i].down:Show()
                auraButtons[i].up:Show()
            end
        end

        -- update spellNameText width
        if noUpDownButtons then
            auraButtons[i].spellNameText:SetPoint("RIGHT", auraButtons[i].del, "LEFT", -5, 0)
        else
            auraButtons[i].spellNameText:SetPoint("RIGHT", auraButtons[i].up, "LEFT", -5, 0)
        end

        auraButtons[i]:SetPoint("RIGHT")
        auraButtons[i]:Show()

        -- functions
        auraButtons[i]:SetScript("OnClick", function()
            local popup = Cell.CreatePopupEditBox(parent, function(text)
                local spellId = tonumber(text)
                if spellId == 0 then
                    F.Print(L["Invalid spell id."])
                else
                    local spellName, spellIcon = F.GetSpellInfo(spellId)
                    if spellId and spellName then
                        -- update text
                        auraButtons[i].spellIdText:SetText(spellId)
                        auraButtons[i].spellId = spellId
                        auraButtons[i].spellTex = spellIcon
                        auraButtons[i].spellNameText:SetText(spellName)
                        -- update db
                        auraTable[i] = spellId
                        parent.func(auraTable)
                        if spellIcon then
                            auraButtons[i].spellIcon:SetTexture(spellIcon)
                            auraButtons[i].spellIconBg:Show()
                            auraButtons[i].spellIcon:Show()
                        else
                            auraButtons[i].spellIconBg:Hide()
                            auraButtons[i].spellIcon:Hide()
                        end
                    else
                        F.Print(L["Invalid spell id."])
                    end
                end
            end)
            popup:SetPoint("TOPLEFT", auraButtons[i])
            popup:SetPoint("BOTTOMRIGHT", auraButtons[i])
            popup:ShowEditBox(auraButtons[i].spellId or "")
            parent.popupEditBox:SetTips("|cffababab" .. L["Input spell id"])
        end)

        auraButtons[i].del:SetScript("OnClick", function()
            table.remove(auraTable, i)
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, updateHeightFunc)
            updateHeightFunc(-19)
        end)

        auraButtons[i].up:SetScript("OnClick", function()
            local temp = auraTable[i - 1]
            auraTable[i - 1] = auraTable[i]
            auraTable[i] = temp
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, updateHeightFunc)
        end)

        auraButtons[i].down:SetScript("OnClick", function()
            local temp = auraTable[i + 1]
            auraTable[i + 1] = auraTable[i]
            auraTable[i] = temp
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, updateHeightFunc)
        end)

        auraButtons[i].colorPicker:Hide()
    end

    -- check up down
    if n == 1 then
        auraButtons[1].up:Hide()
        auraButtons[1].down:Hide()
    end

    for i = n + 1, #auraButtons do
        auraButtons[i]:Hide()
        auraButtons[i]:ClearAllPoints()
    end
end

---@type Cell.auraImportExportFrame
local auraImportExportFrame

---@param parent WidgetsMenuPageFrame
---@param which "buffs"|"debuffs"
---@param kind "blacklist"|"whitelist"
---@return Cell.SettingsAuras
function Builder.CreateSetting_Auras(parent, which, kind)
    if not auraImportExportFrame then
        ---@class Cell.auraImportExportFrame: Frame, BackdropTemplate
        auraImportExportFrame = CUF:CreateFrame(nil, parent, 1, 200)
        auraImportExportFrame:SetBackdropBorderColor(Cell.GetAccentColorRGB())
        auraImportExportFrame:EnableMouse(true)
        auraImportExportFrame:Hide()

        function auraImportExportFrame:ShowUp()
            auraImportExportFrame:SetParent(auraImportExportFrame.parent)
            auraImportExportFrame:SetPoint("TOPLEFT")
            auraImportExportFrame:SetPoint("TOPRIGHT")
            auraImportExportFrame:SetToplevel(true)
            auraImportExportFrame:Show()
        end

        auraImportExportFrame:SetScript("OnHide", function()
            auraImportExportFrame:Hide()
        end)

        auraImportExportFrame.textArea = Cell.CreateScrollEditBox(auraImportExportFrame, function(eb, userChanged)
            if userChanged then
                if auraImportExportFrame.isImport then
                    local data = string.gsub(eb:GetText(), "[^%d]+", ",")
                    if data ~= "" then
                        auraImportExportFrame.data = F.StringToTable(data, ",", true)
                        auraImportExportFrame.info:SetText(Cell.GetAccentColorString() ..
                            L["Spells"] .. ":|r " .. #auraImportExportFrame.data)
                        auraImportExportFrame.importBtn:SetEnabled(true)
                    else
                        auraImportExportFrame.info:SetText(Cell.GetAccentColorString() .. L["Spells"] .. ":|r 0")
                        auraImportExportFrame.importBtn:SetEnabled(false)
                    end
                else
                    eb:SetText(auraImportExportFrame.exported)
                    eb:SetCursorPosition(0)
                    eb:HighlightText()
                end
            end
        end)
        Cell.StylizeFrame(auraImportExportFrame.textArea.scrollFrame, { 0, 0, 0, 0 }, Cell.GetAccentColorTable())
        auraImportExportFrame.textArea:SetPoint("TOPLEFT", 5, -22)
        auraImportExportFrame.textArea:SetPoint("BOTTOMRIGHT", -5, 5)
        auraImportExportFrame.textArea.eb:SetAutoFocus(true)

        auraImportExportFrame.textArea.eb:SetScript("OnEditFocusGained",
            function() auraImportExportFrame.textArea.eb:HighlightText() end)
        auraImportExportFrame.textArea.eb:SetScript("OnMouseUp", function()
            if not auraImportExportFrame.isImport then
                auraImportExportFrame.textArea.eb:HighlightText()
            end
        end)

        auraImportExportFrame.info = auraImportExportFrame:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
        auraImportExportFrame.info:SetPoint("BOTTOMLEFT", auraImportExportFrame.textArea, "TOPLEFT", 0, 3)

        auraImportExportFrame.closeBtn = Cell.CreateButton(auraImportExportFrame, "×", "red", { 18, 18 }, false, false,
            "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
        auraImportExportFrame.closeBtn:SetPoint("BOTTOMRIGHT", auraImportExportFrame.textArea, "TOPRIGHT", 0, 1)
        auraImportExportFrame.closeBtn:SetScript("OnClick", function() auraImportExportFrame:Hide() end)

        auraImportExportFrame.importBtn = Cell.CreateButton(auraImportExportFrame, L["Import"], "green", { 57, 18 })
        auraImportExportFrame.importBtn:SetPoint("TOPRIGHT", auraImportExportFrame.closeBtn, "TOPLEFT", 1, 0)
        auraImportExportFrame.importBtn:SetScript("OnClick", function(self)
            local curIds = {}

            if self.isAdditive then
                for _, spellID in pairs(auraImportExportFrame.parent.t) do
                    curIds[spellID] = true
                end
            else
                table.wipe(auraImportExportFrame.parent.t)
            end

            for _, id in pairs(auraImportExportFrame.data) do
                if not curIds[id] then
                    table.insert(auraImportExportFrame.parent.t, id)
                end
            end
            -- update list
            auraImportExportFrame.parent:SetDBValue(auraImportExportFrame.parent.t)
            auraImportExportFrame:Hide()
            -- event
            auraImportExportFrame.parent.frame.func(auraImportExportFrame.parent.t)
        end)
    end

    local title = Util:ToTitleCase(which, kind)

    ---@class Cell.SettingsAuras: OptionsFrame
    local widget = CUF:CreateFrame("AuraOptions_" .. title, parent, 420, 128)

    ---@class Cell.SettingsAuras.frame: Frame
    ---@field popupEditBox CUFEditBox
    widget.frame = CUF:CreateFrame(nil, widget, 20, 20)
    widget.frame:SetPoint("TOPLEFT", 5, -22)
    widget.frame:SetPoint("RIGHT", -5, 0)
    widget.frame:Show()
    Cell.StylizeFrame(widget.frame, { 0.15, 0.15, 0.15, 1 })

    widget.text = widget:CreateFontString(nil, "OVERLAY", const.FONTS.CELL_WIDGET)
    widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 3)
    widget.text:SetText(L[kind])

    widget.export = Cell.CreateButton(widget, nil, "accent-hover", { 21, 17 }, nil, nil, nil, nil, nil, L["Export"])
    widget.export:SetPoint("BOTTOMRIGHT", widget.frame, "TOPRIGHT", 0, 1)
    widget.export:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", { 15, 15 }, { "CENTER", 0, 0 })
    widget.export:SetScript("OnClick", function()
        auraImportExportFrame.isImport = false
        auraImportExportFrame.parent = widget
        local n
        auraImportExportFrame.exported, n = GetExportString(widget.t)
        auraImportExportFrame.info:SetText(Cell.GetAccentColorString() .. L["Spells"] .. ":|r " .. n)
        auraImportExportFrame.textArea:SetText(auraImportExportFrame.exported)
        auraImportExportFrame.importBtn:Hide()
        auraImportExportFrame:ShowUp()
        -- hide editbox
        if widget.frame.popupEditBox then
            widget.frame.popupEditBox:Hide()
        end
    end)

    widget.import = Cell.CreateButton(widget, nil, "accent-hover", { 21, 17 }, nil, nil, nil, nil, nil,
        L["Import"] .. " (" .. L.Override .. ")", L.OverrideImportTooltip)
    widget.import:SetPoint("BOTTOMRIGHT", widget.export, "BOTTOMLEFT", -1, 0)
    widget.import:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", { 15, 15 }, { "CENTER", 0, 0 })
    widget.import:SetScript("OnClick", function()
        auraImportExportFrame.isImport = true
        auraImportExportFrame.parent = widget
        auraImportExportFrame.textArea:SetText("")
        auraImportExportFrame.info:SetText(Cell.GetAccentColorString() .. L["Spells"] .. ":|r 0")
        auraImportExportFrame.importBtn:Show()
        auraImportExportFrame.importBtn:SetEnabled(false)
        auraImportExportFrame:ShowUp()
        auraImportExportFrame.importBtn.isAdditive = false
        -- hide editbox
        if widget.frame.popupEditBox then
            widget.frame.popupEditBox:Hide()
        end
    end)

    widget.importAdditive = Cell.CreateButton(widget, nil, "accent-hover", { 21, 17 }, nil, nil, nil, nil, nil,
        L["Import"] .. " (" .. L.Additive .. ")", L.AdditiveImportTooltip)
    widget.importAdditive:SetPoint("BOTTOMRIGHT", widget.import, "BOTTOMLEFT", -1, 0)
    widget.importAdditive:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", { 15, 15 }, { "CENTER", 0, 0 })
    widget.importAdditive:SetScript("OnClick", function()
        auraImportExportFrame.isImport = true
        auraImportExportFrame.parent = widget
        auraImportExportFrame.textArea:SetText("")
        auraImportExportFrame.info:SetText(Cell.GetAccentColorString() .. L["Spells"] .. ":|r 0")
        auraImportExportFrame.importBtn:Show()
        auraImportExportFrame.importBtn:SetEnabled(false)
        auraImportExportFrame:ShowUp()
        auraImportExportFrame.importBtn.isAdditive = true
        -- hide editbox
        if widget.frame.popupEditBox then
            widget.frame.popupEditBox:Hide()
        end
    end)

    widget.clear = Cell.CreateButton(widget, nil, "accent-hover", { 21, 17 }, nil, nil, nil, nil, nil, L["Clear"],
        "|cffffb5c5Ctrl+" .. L["Left-Click"])
    widget.clear:SetPoint("BOTTOMRIGHT", widget.importAdditive, "BOTTOMLEFT", -1, 0)
    widget.clear:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\trash", { 15, 15 }, { "CENTER", 0, 0 })
    widget.clear:SetScript("OnClick", function(self, button)
        if button == "LeftButton" and IsControlKeyDown() then
            table.wipe(widget.t)
            -- update list
            widget:SetDBValue(widget.t)
            -- event
            widget.frame.func(widget.t)
            -- hide editbox
            if widget.frame.popupEditBox then
                widget.frame.popupEditBox:Hide()
            end
        end
    end)

    -- callback
    function widget:SetFunc(func)
        widget.frame.func = func
    end

    widget.frame.func = function(val)
        DB.SetAuraFilter(which, kind, val)
        CUF:Fire("UpdateWidget", CUF.vars.selectedLayout, CUF.vars.selectedUnit,
            which,
            const.AURA_OPTION_KIND.FILTER,
            kind)
    end

    local auraButtons = {}

    local function UpdateHeight()
        local curHeight = widget:GetHeight()

        widget.frame:SetHeight((#widget.t + 1) * 19 + 1)
        widget:SetHeight((#widget.t + 1) * 19 + 1 + 22 + 7)

        local diff = widget:GetHeight() - curHeight
        if diff == 0 then return end

        parent._SetHeight(parent._GetHeight() + diff)
    end

    -- show db value
    ---@param t table auraTable
    function widget:SetDBValue(t)
        widget.t = t
        CreateAuraButtons(widget.frame, auraButtons, t, false, UpdateHeight)
        UpdateHeight()
    end

    local function LoadPageDB()
        widget:SetDBValue(DB.GetAuraFilter(which, kind))
    end
    Handler:RegisterOption(LoadPageDB, which, "SettingAuras_" .. kind)

    widget:Show()

    return widget
end
