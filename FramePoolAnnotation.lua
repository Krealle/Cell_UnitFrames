---@meta

---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateFramePool)
---@generic T, Tp
---@param frameType `T` | FrameType
---@param parent? any
---@param template? `Tp` | Template
---@param resetFunc? fun(self: T) Custom function to prepare a frame for reuse; the default function simply hides the frame and clears all points. Arg1 is the Pool object itself, Arg2 is the frame being reset.
---@param forbidden? boolean If true, frames will be made using CreateForbiddenFrame instead of CreateFrame.
---@param frameInitializer? fun(self: T) Custom function to run once after a frame is initially created by the pool. The frame created is passed as the functions only argument.
---@param capacity? number
---@return FramePoolMixin FramePool
function CreateFramePool(frameType, parent, template, resetFunc, forbidden, frameInitializer, capacity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateFramePool)
---@class FramePoolMixin
---@field Acquire fun(self: FramePoolMixin): Frame
---@field Release fun(self: FramePoolMixin, frame: Frame)
---@field ReleaseAll fun(self: FramePoolMixin)
---@field EnumerateActive fun(self: FramePoolMixin): Frame[]
---@field EnumerateInactive fun(self: FramePoolMixin): Frame[]
---@field GetNextActive fun(self: FramePoolMixin, current: Frame): Frame
---@field GetNextInactive fun(self: FramePoolMixin, current: Frame): Frame
---@field IsActive fun(self: FramePoolMixin, frame: Frame): boolean
---@field GetNumActive fun(self: FramePoolMixin): number
---@field SetResetDisallowedIfNew fun(self: FramePoolMixin)
