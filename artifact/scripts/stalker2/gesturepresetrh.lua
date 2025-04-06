--[[
    GesturePresetsRH.lua
    Right-handed gesture presets using the GripGesture base class
]]--

local GripGesture = require("stalker2.gripgesture")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")
local gameState = require("stalker2.gamestate")


-- Create right-hand gesture instances
-- Create left-hand gesture instances
local flashlightGestureLH = GripGesture:new({
    name = "Flashlight Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.headZoneLH
})

local flashlightGestureRH = GripGesture:new({
    name = "Flashlight Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.headZoneRH
})


local primaryWeaponGesture = GripGesture:new({
    name = "Primary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightShoulderZoneRH
})

local secondaryWeaponGesture = GripGesture:new({
    name = "Secondary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.leftShoulderZoneRH  -- Right hand on left shoulder
})


flashlightGestureLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('L')
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('L')
        gesture.gripGesture:Unlock()
    end
end)

flashlightGestureRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('L')
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('L')
        gesture.gripGesture:Unlock()
    end
end)


return {
    flashlightGestureLH = flashlightGestureLH,
    flashlightGestureRH = flashlightGestureRH,
    primaryWeaponGesture = primaryWeaponGesture,
    secondaryWeaponGesture = secondaryWeaponGesture
}