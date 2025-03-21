---@class CUF
local CUF = select(2, ...)

---@class CUF.Compat
local Compat = CUF.Compat

local dummyAnchors = {}

---@param name string
---@param parent string
function Compat:CreateDummyAnchor(name, parent)
    if type(name) ~= "string" then
        CUF:Warn("Invalid dummy anchor name:", "'" .. name .. "'")
        return
    end

    if type(parent) ~= "string" then
        CUF:Warn("Invalid dummy anchor parent:", "'" .. parent .. "'")
        return
    end
    if not _G[parent] then
        CUF:Warn("Parent frame with name:", "'" .. parent .. "'", "does not exist! Unable to create dummy anchor.")
        return
    end

    if dummyAnchors[name] then
        CUF:Log("Anchor with name:", "'" .. name .. "'", "already created.")
        dummyAnchors[name]:SetAllPoints(_G[parent])
        return
    end

    if _G[name] then
        CUF:Warn("Frame with name:", "'" .. name .. "'", "already exists! Unable to create dummy anchor.")
        return
    end

    local dummy = CreateFrame("Frame", name, _G[parent])
    dummy:SetAllPoints(_G[parent])
    CUF:Log("Created dummy anchor:", "'" .. name .. "'")

    dummyAnchors[name] = dummy
end

function Compat:InitDummyAnchors()
    for parent, anchor in pairs(CUF_DB.dummyAnchors) do
        if anchor.enabled then
            Compat:CreateDummyAnchor(anchor.dummyName, parent)
        end
    end
end
