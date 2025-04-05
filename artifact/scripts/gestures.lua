-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end

local bodyZones = require("gestures.bodyzone")
local gestureSet = require("gestures.gestureset")
local flashlight = require("stalker2.flashlight")
local primaryWeapon = require("stalker2.primaryweapon") -- Include the primary weapon gestures
local secondaryWeapon = require("stalker2.secondaryweapon") -- Include the secondary weapon gestures
local motionControllerActors = require("gestures.motioncontrolleractors")
local gameState = require("stalker2.gamestate") -- Ensure gameState is available for context
local gamepadState = require("stalker2.gamepad")

flashlight.flashlightGestureLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('L')
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('L')
        gesture.gripGesture:Unlock()
    end
end)

flashlight.flashlightGestureRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('L')
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('L')
        gesture.gripGesture:Unlock()
    end
end)

primaryWeapon.primaryWeaponGestureLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('1') -- Use key 1 to switch to primary weapon
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('1')
        gesture.gripGesture:Unlock()
    end
end)

primaryWeapon.primaryWeaponGestureRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('1') -- Use key 1 to switch to primary weapon
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('1')
        gesture.gripGesture:Unlock()
    end
end)

secondaryWeapon.secondaryWeaponGestureLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('2') -- Use key 2 to switch to secondary weapon
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('2')
        gesture.gripGesture:Unlock()
    end
end)

secondaryWeapon.secondaryWeaponGestureRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        gameState:SendKeyDown('2') -- Use key 2 to switch to secondary weapon
        gesture.gripGesture:Lock()
    elseif gesture:JustDeactivated() then
        gameState:SendKeyUp('2')
        gesture.gripGesture:Unlock()
    end
end)

bodyZones.headZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
end)

bodyZones.headZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local rightController = uevr.params.vr.get_right_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
    end
end)

bodyZones.leftShoulderZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
end)

bodyZones.rightShoulderZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        local rightController = uevr.params.vr.get_right_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
    end
end)

gestureSet = gestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            flashlight.flashlightGestureRH,
            flashlight.flashlightGestureLH,
            primaryWeapon.primaryWeaponGestureRH,
            primaryWeapon.primaryWeaponGestureLH,
            secondaryWeapon.secondaryWeaponGestureRH,
            secondaryWeapon.secondaryWeaponGestureLH
        }
    }
)

gameState:Init()
gamepadState:Reset()

uevr.sdk.callbacks.on_pre_engine_tick(
    function(engine, delta)
        motionControllerActors:Update(engine)
        gameState:Update()
        gestureSet:Update({})
        -- Execute all gestures to check their state
    end
)

uevr.sdk.callbacks.on_xinput_get_state(
    function(retval, user_index, state)
        gamepadState:Update(state)
    end
)

uevr.sdk.callbacks.on_script_reset(function()
    print("Resetting")
    gestureSet:Reset()
    gameState:Reset() -- Reset the game state to initial conditions
    motionControllerActors:Reset() -- Reset the motion controller actors
    gamepadState:Reset()
end)