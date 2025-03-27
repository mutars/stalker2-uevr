local GestureBase = require("artifact.scripts.gestures.GestureBase")

-- Base Motion Controller Gesture class
local MotionControllerGesture = GestureBase:new({
    name = "Motion Controller Base",
    controllerIndex = 0,
    location = Vector3f.new(0, 0, 0),
    rotation = Vector3f.new(0, 0, 0),
    pastLocation = Vector3f.new(0, 0, 0),
    pastRotation = Vector3f.new(0, 0, 0)
})

function MotionControllerGesture:EvaluateInternal(context)
    if not context or not context.motionControllers then
        return false
    end
    
    -- Store past values
    self.pastLocation = Vector3f.new(self.location.x, self.location.y, self.location.z)
    self.pastRotation = Vector3f.new(self.rotation.x, self.rotation.y, self.rotation.z)
    
    -- Get current position and rotation
    self.location = context.motionControllers:GetLocationByIndex(self.controllerIndex)
    self.rotation = context.motionControllers:GetRotationByIndex(self.controllerIndex)
    
    return self.location ~= nil and self.rotation ~= nil
end

-- Left Motion Controller Gesture
local LeftMotionControllerGesture = MotionControllerGesture:new({
    name = "Left Motion Controller",
    controllerIndex = 1
})

-- Right Motion Controller Gesture
local RightMotionControllerGesture = MotionControllerGesture:new({
    name = "Right Motion Controller",
    controllerIndex = 2
})

-- HMD Gesture
local HMDGesture = MotionControllerGesture:new({
    name = "HMD",
    controllerIndex = 0
})

return {
    LeftMotionControllerGesture = LeftMotionControllerGesture,
    RightMotionControllerGesture = RightMotionControllerGesture,
    HMDGesture = HMDGesture
}