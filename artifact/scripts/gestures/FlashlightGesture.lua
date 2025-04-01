--[[
    FlashlightGesture.lua
    Gesture that activates when a motion controller is near the head and grip button is pressed
]]--

local GestureBase = require("gestures.GestureBase")
local BodyZones = require("gestures.BodyZones")
local motionControllers = require("gestures.MotionControllerGestures")

-- FlashlightGesture: Base class for flashlight gestures
FlashlightGesture = GestureBase:new({
    name = "Flashlight Gesture Base",
    gripGesture = nil,
    headZone = nil,
})

function FlashlightGesture:new(config)
    -- Set up dependencies
    config = config or {}
    if not config.gripGesture then
        error("gripGesture is required for FlashlightGesture")
    end
    if not config.headZone then
        error("headZone is required for FlashlightGesture")
    end
    
    local instance = GestureBase.new(self, config)
    instance:AddDependency(instance.gripGesture) -- Ensure gripGesture is a dependency
    instance:AddDependency(instance.headZone) -- Ensure headZone is a dependency
    return instance
end

function FlashlightGesture:EvaluateInternal(context)
    if self.gripGesture:IsLocked() then
        return false
    end
    local isActive = self.gripGesture:JustActivated() and self.headZone.isActive
    if isActive then
        self.gripGesture:Lock()
    end
    return isActive
end

-- Create specific instances for Left Hand and Right Hand
local flashlightGestureRH = FlashlightGesture:new({
    name = "Flashlight Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    headZone = BodyZones.headZoneRH
})

local flashlightGestureLH = FlashlightGesture:new({
    name = "Flashlight Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    headZone = BodyZones.headZoneLH
})

return {
    flashlightGestureRH = flashlightGestureRH,
    flashlightGestureLH = flashlightGestureLH
}