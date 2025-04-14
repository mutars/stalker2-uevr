--[[
    GripGesture.lua
    Base class for gestures that activate when a motion controller is in a specific zone and grip button is pressed
]]--

local GestureBase = require("gestures.gesturebase")
local motionControllers = require("gestures.motioncontrollergestures")

-- GripGesture: Base class for grip-based gestures
local TwoHandedAimGesture = GestureBase:new({
    name = "Double Grip Gesture Base",
    leftGripGesture = nil,
    rightGripGesture = nil,
    zone = nil,
})

function TwoHandedAimGesture:new(config)
    -- Set up dependencies
    config = config or {}
    
    local instance = GestureBase.new(self, config)
    
    -- Verify required properties after the instance is created
    if not instance.leftGripGesture then
        error("gripGesture is required for GripGesture")
    end
    if not instance.rightGripGesture then
        error("gripGesture is required for GripGesture")
    end
    if not instance.zone then
        error("zone is required for GripGesture")
    end
    
    instance:AddDependency(instance.leftGripGesture) -- Ensure gripGesture is a dependency
    instance:AddDependency(instance.rightGripGesture) -- Ensure gripGesture is a dependency
    instance:AddDependency(instance.zone) -- Ensure zone is a dependency
    return instance
end

function TwoHandedAimGesture:EvaluateInternal(context)
    local justActivated = not self.rightGripGesture:IsLocked() and self.rightGripGesture.isActive and  not self.leftGripGesture:IsLocked() and self.leftGripGesture.isActive and self.zone.isActive
    if justActivated then
        return true
    end
    return self.wasActive and self.leftGripGesture.isActive and self.rightGripGesture.isActive
end

return TwoHandedAimGesture