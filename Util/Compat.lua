---@class CUF
local CUF = select(2, ...)

---@class CUF.Compat
local Compat = CUF.Compat

---@param name string
---@param parent string
function Compat:CreateDummyAnchor(name, parent)
    if type(name) ~= "string" then
        CUF:Warn("Invalid dummy anchor name:", "'" .. name .. "'")
        return
    end

    if type(parent) ~= "string" then return end
    if not _G[parent] then return end

    if _G[name] then
        CUF:Warn("Frame with name:", "'" .. name .. "'", "already exists! Unable to create dummy anchor.")
        return
    end

    local dummy = CreateFrame("Frame", name, _G[parent])
    dummy:SetAllPoints(_G[parent])
end

function Compat:InitDummyAnchors()
    for parent, anchor in pairs(CUF_DB.dummyAnchors) do
        if anchor.enabled then
            Compat:CreateDummyAnchor(anchor.dummyName, parent)
        end
    end
end
