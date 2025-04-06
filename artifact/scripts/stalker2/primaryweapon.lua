--[[
    PrimaryWeaponGesture.lua
    Gesture that activates when a motion controller is near the shoulder and grip button is pressed
    For left-handed users, triggers when left grip is pressed near left shoulder
    For right-handed users, triggers when right grip is pressed near right shoulder
]]--

local GripGesture = require("stalker2.gripgesture")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")

-- Create specific instances directly from GripGesture
local primaryWeaponGestureRH = GripGesture:new({
    name = "Primary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightShoulderZoneRH
})

local primaryWeaponGestureLH = GripGesture:new({
    name = "Primary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftShoulderZoneLH
})

return {
    primaryWeaponGestureRH = primaryWeaponGestureRH,
    primaryWeaponGestureLH = primaryWeaponGestureLH
}