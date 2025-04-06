--[[
    GesturePresetsLH.lua
    Left-handed gesture presets using the GripGesture base class
]]--

local GripGesture = require("stalker2.gripgesture")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")
local gameState = require("stalker2.gamestate")
local GestureSet = require("gestures.gestureset")


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

local primaryWeaponGestureLH = GripGesture:new({
    name = "Primary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftShoulderZoneLH
})

local secondaryWeaponGestureLH = GripGesture:new({
    name = "Secondary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightShoulderZoneLH  -- Left hand on right shoulder
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


primaryWeaponGestureLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('3') -- Use key 1 to switch to primary weapon
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('3')
        gesture.gripGesture:Unlock()
    end
end)


secondaryWeaponGestureLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('4') -- Use key 2 to switch to secondary weapon
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('4')
        gesture.gripGesture:Unlock()
    end
end)


BodyZones.headZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
end)


BodyZones.headZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local rightController = uevr.params.vr.get_right_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
    end
end)

BodyZones.leftShoulderZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
end)

BodyZones.rightShoulderZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
end)

local gestureSetLH = GestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            flashlightGestureLH,
            flashlightGestureRH,
            primaryWeaponGestureLH,
            secondaryWeaponGestureLH
        }
    }
)

return gestureSetLH