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
        CUF.vars.debug = not CUF.vars.debug
        CUF:Print("Debug: " .. (CUF.vars.debug and "ON" or "OFF"))
    elseif command == "debug" then
        Debug:ToggleDebugWindow()
    else
        CUF:Print("Available commands:" .. "\n" ..
            "/cuf test - toggle test mode" .. "\n" ..
            "/cuf dev - toggle debug mode" .. "\n" ..
            "/cuf debug - toggle dev window"
        )
    end
end
