--[[
    GestureBase.lua
    Base class for all gestures in the gesture system
]]--
local global_id_sequence = 0

local GestureBase = {
    -- Unique identifier for the gesture
    id = nil,
    
    -- Name for this gesture (for debugging)
    name = "Generic Gesture",
    
    -- Whether this gesture is currently active/detected
    isActive = false,
    
    -- Previous state for detecting transitions
    wasActive = false,
    
    -- List of dependencies (other gestures this one depends on)
    dependencies = {},
    
    config = {}
}

function GestureBase:Update(visited, context)
    if visited[self.id] then
        return
    end
    visited[self.id] = true
    for _, dep in ipairs(self.dependencies) do
        if dep then
            dep:Update(visited, context)
        end
    end
    self:Evaluate(context)
end

-- Update the gesture state (should be called from GestureGraph)
function GestureBase:Evaluate(context)
    -- Save previous state
    self.wasActive = self.isActive
    
    -- Evaluate current state
    self.isActive = self:EvaluateInternal(context)
    
    -- Return true if state changed
    return self.isActive ~= self.wasActive
end

function GestureBase:EvaluateInternal(context)
    return false
end

function GestureBase:Reset()
    self.isActive = false
    self.wasActive = false
end

-- Returns true if gesture just became active this frame
function GestureBase:JustActivated()
    return self.isActive and not self.wasActive
end

-- Returns true if gesture just became inactive this frame
function GestureBase:JustDeactivated()
    return not self.isActive and self.wasActive
end


-- Create a new instance of the gesture
function GestureBase:new(config)
    config = config or {}
    setmetatable(config, self)
    self.__index = self
    
    -- Always generate a new ID for each instance
    global_id_sequence = global_id_sequence + 1
    config.id = global_id_sequence
    
    return config
end

return GestureBase