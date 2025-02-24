---@class CUF
local CUF = select(2, ...)

local L = CUF.L
local Menu = CUF.Menu

local Serializer = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local deflateConfig = { level = 9 }

---@class CUF.ImportExport
local ImportExport = {}

CUF.ImportExport = ImportExport

-------------------------------------------------
-- MARK: Show
-------------------------------------------------

---@param self CUF.ImportExport.Frame
local function ShowImportFrame(self)
    self:Show()
    self.isImport = true
    self.importBtn:Show()
    self.importBtn:SetEnabled(false)

    self.exported = ""
    self.title:SetText(L["Import"])
    self.textArea:SetText("")
    self.textArea.eb:SetFocus(true)
end

---@param self CUF.ImportExport.Frame
local function ShowExportFrame(self)
    self:Show()
    self.isImport = false
    self.importBtn:Hide()

    self.title:SetText(L["Export"] .. ": " .. L[self.which])

    local prefix = "!CUF:" .. CUF.version .. ":" .. string.upper(self.which) .. "!"

    self.exported = Serializer:Serialize(self.exportFn())                    -- serialize
    self.exported = LibDeflate:CompressDeflate(self.exported, deflateConfig) -- compress
    self.exported = LibDeflate:EncodeForPrint(self.exported)                 -- encode
    self.exported = prefix .. self.exported

    self.textArea:SetText(self.exported)
    self.textArea.eb:SetFocus(true)
end

-------------------------------------------------
-- MARK: Create
-------------------------------------------------

---@param which string
---@param importFn fun(imported: any)
---@param exportFn fun(): table
---@param verifyFn fun(imported: any): boolean
---@param minVersion number?
function ImportExport:CreateImportExportFrame(which, importFn, exportFn, verifyFn, minVersion)
    ---@class CUF.ImportExport.Frame: Frame, BackdropTemplate
    local importExportFrame = CreateFrame("Frame", "CUF_ImportExport", Menu.window, "BackdropTemplate")
    importExportFrame.which = which
    importExportFrame.exportFn = exportFn

    importExportFrame:Hide()
    Cell.StylizeFrame(importExportFrame, nil, Cell.GetAccentColorTable())
    importExportFrame:EnableMouse(true)
    importExportFrame:SetFrameLevel(Menu.window:GetFrameLevel() + 50)
    importExportFrame:SetSize(Menu.window:GetWidth() - 5, 170)
    importExportFrame:SetPoint("CENTER", 1, 0)

    -- close
    local closeBtn = Cell.CreateButton(importExportFrame, "×", "red", { 18, 18 }, false, false, "CELL_FONT_SPECIAL",
        "CELL_FONT_SPECIAL")
    closeBtn:SetPoint("TOPRIGHT", -5, -1)
    closeBtn:SetScript("OnClick", function() importExportFrame:Hide() end)

    -- import
    local importBtn = Cell.CreateButton(importExportFrame, L["Import"], "green", { 57, 18 })
    importBtn:Hide()
    importBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", 1, 0)
    importBtn:SetScript("OnClick", function()
        -- lower frame level
        importExportFrame:SetFrameLevel(Menu.window:GetFrameLevel() + 20)

        local popup = Cell.CreateConfirmPopup(Menu.window, 200, L["Overwrite "] .. L[which] .. "?",
            function()
                importFn(importExportFrame.imported)
                importExportFrame:Hide()
            end, nil, true)
        popup:SetPoint("TOPLEFT", importExportFrame, 117, -50)
        importExportFrame.textArea.eb:ClearFocus()
    end)
    importExportFrame.importBtn = importBtn

    -- title
    local title = importExportFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)
    importExportFrame.title = title

    -- textArea
    local textArea = Cell.CreateScrollEditBox(importExportFrame, function(eb, userChanged)
        if userChanged then
            if importExportFrame.isImport then
                importExportFrame.imported = {}
                local text = eb:GetText()
                -- check
                local version, type, data = string.match(text,
                    "^!CUF:(%d+):(.+)!(.+)$")
                version = tonumber(version)

                if type and type == string.upper(which) and version and data then
                    if not minVersion or version >= minVersion then
                        local success
                        data = LibDeflate:DecodeForPrint(data)                                -- decode
                        success, data = pcall(LibDeflate.DecompressDeflate, LibDeflate, data) -- decompress
                        success, data = Serializer:Deserialize(data)                          -- deserialize

                        if success and data and verifyFn(data) then
                            title:SetText(L["Import"] .. ": " .. L[which])
                            importExportFrame.imported = data
                            importBtn:SetEnabled(true)
                        else
                            title:SetText(L["Import"] .. ": |cffff2222" .. L["Error"])
                            importBtn:SetEnabled(false)
                        end
                    else -- incompatible version
                        title:SetText(L["Import"] .. ": |cffff2222" .. L["Incompatible Version"])
                        importBtn:SetEnabled(false)
                    end
                else
                    title:SetText(L["Import"] .. ": |cffff2222" .. L["Error"])
                    importBtn:SetEnabled(false)
                end
            else
                eb:SetText(importExportFrame.exported)
                eb:SetCursorPosition(0)
                eb:HighlightText()
            end
        end
    end)
    Cell.StylizeFrame(textArea.scrollFrame, { 0, 0, 0, 0 }, Cell.GetAccentColorTable())
    textArea:SetPoint("TOPLEFT", 5, -20)
    textArea:SetPoint("BOTTOMRIGHT", -5, 5)

    -- highlight text
    textArea.eb:SetScript("OnEditFocusGained", function() textArea.eb:HighlightText() end)
    textArea.eb:SetScript("OnMouseUp", function()
        if not importExportFrame.isImport then
            textArea.eb:HighlightText()
        end
    end)
    importExportFrame.textArea = textArea

    importExportFrame:SetScript("OnHide", function()
        importExportFrame:Hide()
        importExportFrame.isImport = false
        importExportFrame.exported = ""
        importExportFrame.imported = {}
        -- hide mask
        Menu.window.mask:Hide()
    end)

    importExportFrame:SetScript("OnShow", function()
        -- raise frame level
        importExportFrame:SetFrameLevel(Menu.window:GetFrameLevel() + 50)
        Menu.window.mask:Show()
    end)

    importExportFrame.ShowImport = ShowImportFrame
    importExportFrame.ShowExport = ShowExportFrame

    return importExportFrame
end
