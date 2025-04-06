--[[
    SecondaryWeaponGesture.lua
    Gesture that activates when a motion controller is near the opposite shoulder and grip button is pressed
    For left-handed users, triggers when left grip is pressed near right shoulder
    For right-handed users, triggers when right grip is pressed near left shoulder
]]--

local GripGesture = require("stalker2.gripgesture")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")

-- Create specific instances directly from GripGesture
-- Note: RH user's secondary weapon is triggered by right hand on LEFT shoulder
-- LH user's secondary weapon is triggered by left hand on RIGHT shoulder
local secondaryWeaponGestureRH = GripGesture:new({
    name = "Secondary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.leftShoulderZoneRH  -- Right hand on left shoulder
})

local secondaryWeaponGestureLH = GripGesture:new({
    name = "Secondary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightShoulderZoneLH  -- Left hand on right shoulder
})

return {
    secondaryWeaponGestureRH = secondaryWeaponGestureRH,
    secondaryWeaponGestureLH = secondaryWeaponGestureLH
}