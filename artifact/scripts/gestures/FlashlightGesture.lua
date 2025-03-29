--[[
    FlashlightGesture.lua
    Gesture that activates when a motion controller is near the head and grip button is pressed
]]--

local GestureBase = require("gestures.GestureBase")
local BodyZones = require("gestures.BodyZones")
local motionControllers = require("gestures.MotionControllerGestures")

-- FlashlightGesture: Base class for flashlight gestures
local FlashlightGesture = GestureBase:new({
    name = "Flashlight Gesture Base",
    
    -- The grip gesture to check for grip button
    gripGesture = nil,
    
    -- The zone around the head to detect
    headZone = nil,
})

function FlashlightGesture:new(config)
    -- Set up dependencies
    config.dependencies = {
        config.gripGesture,
        config.headZone
    }

    setmetatable(config, self)
    self.__index = self
    return config
end

function FlashlightGesture:EvaluateInternal(context)
    if self.gripGesture:isLocked() then
        return
    end
    self.isActive = self.gripGesture:JustActivated() and self.headZone:isActive()
    if self.isActive and not self.wasActive then
        self.gripGesture:Lock()
    end
end

-- Create specific instances for Left Hand and Right Hand
local flashlightGestureRH = FlashlightGesture:new({
    name = "Flashlight Gesture (RH)",
    gripGesture = motionControllers.RightGrip,
    headZone = BodyZones.headZoneRH
})

local flashlightGestureLH = FlashlightGesture:new({
    name = "Flashlight Gesture (LH)",
    gripGesture = motionControllers.LeftGrip,
    headZone = BodyZones.headZoneLH
})

return {
    FlashlightGesture = FlashlightGesture,
    flashlightGestureRH = flashlightGestureRH,
    flashlightGestureLH = flashlightGestureLH
}