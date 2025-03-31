-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end

local gestureSet = require("gestures.GestureSet")
local flashlight = require("gestures.FlashlightGesture")
local motionControllerActors = require("gestures.MotionControllerActors")
local gripGestureLH = require("gestures.MotionControllerGestures").LeftGripAction
local gripGestureRH = require("gestures.MotionControllerGestures").RightGripAction

flashlight.flashlightGestureLH:SetExecutionCallback(function(context)
    -- Callback for when the left-hand flashlight gesture is executed
    print("Left Hand Flashlight Gesture Executed")
    -- You can add additional logic here, such as toggling a flashlight or other actions
end)
flashlight.flashlightGestureRH:SetExecutionCallback(function(context)
    -- Callback for when the right-hand flashlight gesture is executed
    print("Right Hand Flashlight Gesture Executed")
    -- You can add additional logic here, such as toggling a flashlight or other actions
end)

gripGestureLH:SetExecutionCallback(function(context)
    -- Callback for when the left-hand grip gesture is executed
    print("Left Hand Grip Gesture Executed")
    -- You can add additional logic here if needed
end)

gripGestureRH:SetExecutionCallback(function(context)
    -- Callback for when the right-hand grip gesture is executed
    print("Right Hand Grip Gesture Executed")
    -- You can add additional logic here if needed
end)

gestureSet = gestureSet:new(
    {
        -- Initialize the gesture set with the flashlight gestures for both hands
        rootGestures = {
            flashlight.flashlightGestureRH,
            flashlight.flashlightGestureLH,
            gripGestureLH,
            gripGestureRH,
        }
    }
)

uevr.sdk.callbacks.on_pre_engine_tick(
    function(engine, delta)
        motionControllerActors:Update(engine) -- Try to initialize if not already
        -- Update the gesture set with the current engine state
        gestureSet:Update({})
        
        -- Execute all gestures to check their state
        flashlight.flashlightGestureLH:Execute({}) -- Execute left hand flashlight gesture
        flashlight.flashlightGestureRH:Execute({}) -- Execute right hand flashlight gesture
        gripGestureLH:Execute({}) -- Execute the left grip gesture
        gripGestureRH:Execute({}) -- Execute the right grip gesture
    end
)


uevr.sdk.callbacks.on_script_reset(function()
    print("Resetting")
    gestureSet:Reset()
    motionControllerActors:Reset() -- Reset the motion controller actors
end)