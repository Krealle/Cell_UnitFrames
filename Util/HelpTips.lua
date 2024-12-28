---@class CUF
local CUF = select(2, ...)

local DB = CUF.DB

---@class CUF.HelpTips
local HelpTips = {}
CUF.HelpTips = HelpTips

local function HelpTipReset(framePool, frame)
    frame:ClearAllPoints()
    frame:Hide()
    frame:Reset()
end
HelpTips.framePool = CreateFramePool("Frame", UIParent, "HelpTipTemplate", HelpTipReset)

-- Blizzard functions
HelpTips.IsShowing = HelpTip.IsShowing ---@type fun(self: CUF.HelpTips, parent: Frame, text: string): boolean
HelpTips.Acknowledge = HelpTip.Acknowledge ---@type fun(self: CUF.HelpTips, parent: Frame, text: string)
-- Due to Blizzard's implementation, sometimes a frame is attempted to be released
-- Without actually being shown. This prevents the taint that follows that behaviour.
HelpTips.Release = function(...) pcall(HelpTip.Release, ...) end ---@type fun(self: CUF.HelpTips, frame: HelpTips.Frame)

---@param frame HelpTips.Frame
local function HandleAcknowledge(frame)
    DB.SetHelpTip(frame.info.dbKey, true)
    frame.acknowledged = true
end

---@param parent Frame
---@param info HelpTips.Info
---@param relativeRegion Frame?
---@return boolean showing
function HelpTips:Show(parent, info, relativeRegion)
    if not self:CanShow(info) then
        return false
    end

    if self:IsShowing(parent, info.text) then
        return true
    end

    if not info.buttonStyle then
        info.buttonStyle = HelpTip.ButtonStyle.Okay
    end

    ---@class HelpTips.Frame
    local frame = self.framePool:Acquire()
    frame.width = HelpTip.width + (info.extraRightMarginPadding or 0)
    frame:SetWidth(frame.width)
    frame:Init(parent, info, relativeRegion or parent)

    -- Override mixin functions
    frame.HandleAcknowledge = HandleAcknowledge

    frame:Show()

    return true
end

---@param info HelpTips.Info
---@return boolean
function HelpTips:CanShow(info)
    if DB.GetHelpTip(info.dbKey) then
        return false
    end

    return true
end
