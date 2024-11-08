---@class CUF
local CUF = select(2, ...)

local Debug = CUF.Debug

SLASH_CUF1 = "/cuf"
function SlashCmdList.CUF(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "test" then
        CUF.vars.testMode = not CUF.vars.testMode
        CUF:Print("Test mode: " .. (CUF.vars.testMode and "ON" or "OFF"))
    elseif command == "dev" then
        CUF.SetDebugMode(not CUF.IsInDebugMode())
        Debug:ToggleDebugWindow()
        CUF:Print("Debug: " .. (CUF.IsInDebugMode() and "ON" or "OFF"))
    elseif command == "restore" then
        if rest ~= "automatic" and rest ~= "manual" then
            CUF:Print("Usage: /cuf restore <automatic|manual>")
            return
        end
        CUF.DB.RestoreFromBackup(rest)
    elseif command == "edit" then
        CUF.uFuncs:EditMode()
    elseif command == "tips" then
        for tip, _ in pairs(CUF_DB.helpTips) do
            CUF.DB.SetHelpTip(tip, false)
        end
        CUF:Print("All Help Tips have been reset, reload to see them again")
    elseif command == "tags" then
        CUF.widgets:ShowTooltipFrame()
    elseif command == "pixel" then
        CUF:Print(CUF.PixelPerfect.DebugInfo())
    else
        CUF:Print("Available commands:" .. "\n" ..
            "/cuf test - toggle test mode" .. "\n" ..
            "/cuf dev - toggle debug mode" .. "\n" ..
            "/cuf edit - toggle edit mode" .. "\n" ..
            "/cuf restore <automatic|manual> - restore a backup" .. "\n" ..
            "/cuf resettips - reset all help tips" .. "\n" ..
            "/cuf tags - show available tags" .. "\n" ..
            "/cuf pixel - show pixel debug info"
        )
    end
end
