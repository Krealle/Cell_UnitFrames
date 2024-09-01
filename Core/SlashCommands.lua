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
    else
        CUF:Print("Available commands:" .. "\n" ..
            "/cuf test - toggle test mode" .. "\n" ..
            "/cuf dev - toggle debug mode" .. "\n" ..
            "/cuf restore <automatic|manual> - restore a backup"
        )
    end
end
