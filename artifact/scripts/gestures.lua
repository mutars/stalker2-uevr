-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end

local gestureSet = require("gestures.GestureSet")
local flashlight = require("gestures.FlashlightGesture")
local motionControllerActors = require("gestures.MotionControllerActors")
local gameState = require("GameStateManager") -- Ensure gameState is available for context

flashlight.flashlightGestureLH:SetActivationCallback(function(gesture, context)
    gameState:SendKeyDown('L')
    gesture.gripGesture:Lock()
end)
flashlight.flashlightGestureLH:SetDeactivationCallback(function(gesture, context)
    gameState:SendKeyUp('L')
    gesture.gripGesture:Unlock()
end)
flashlight.flashlightGestureRH:SetActivationCallback(function(gesture, context)
    gameState:SendKeyDown('L')
    gesture.gripGesture:Lock()
end)
flashlight.flashlightGestureRH:SetDeactivationCallback(function(gesture, context)
    gameState:SendKeyUp('L')
    gesture.gripGesture:Unlock()
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

uevr.sdk.callbacks.on_pre_engine_tick(
    function(engine, delta)
        motionControllerActors:Update(engine)
        gameState:Update()
        gestureSet:Update({})
        -- Execute all gestures to check their state
        flashlight.flashlightGestureLH:Execute({}) -- Execute left hand flashlight gesture
        flashlight.flashlightGestureRH:Execute({}) -- Execute right hand flashlight gesture
    end
)


uevr.sdk.callbacks.on_script_reset(function()
    print("Resetting")
    gestureSet:Reset()
    gameState:Reset() -- Reset the game state to initial conditions
    motionControllerActors:Reset() -- Reset the motion controller actors
end)