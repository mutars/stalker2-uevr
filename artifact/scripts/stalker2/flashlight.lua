--[[
    FlashlightGesture.lua
    Gesture that activates when a motion controller is near the head and grip button is pressed
]]--

local GripGesture = require("stalker2.gripgesture")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")

-- Create specific instances directly from GripGesture
local flashlightGestureRH = GripGesture:new({
    name = "Flashlight Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.headZoneRH
})

local flashlightGestureLH = GripGesture:new({
    name = "Flashlight Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.headZoneLH
})

return {
    flashlightGestureRH = flashlightGestureRH,
    flashlightGestureLH = flashlightGestureLH
}