-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end

local bodyZones = require("gestures.bodyzone")
local gestureSet = require("gestures.gestureset")
local flashlight = require("stalker2.flashlight")
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


gestureSet = gestureSet:new(
    {
        -- Initialize the gesture set with the flashlight gestures for both hands
        rootGestures = {
            flashlight.flashlightGestureRH,
            flashlight.flashlightGestureLH
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
        bodyZones.headZoneRH:Execute({}) -- Execute right hand head zone gesture
        bodyZones.headZoneLH:Execute({})
        flashlight.flashlightGestureLH:Execute({}) -- Execute left hand flashlight gesture
        flashlight.flashlightGestureRH:Execute({}) -- Execute right hand flashlight gesture
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