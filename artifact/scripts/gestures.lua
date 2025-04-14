-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end

local motionControllerActors = require("gestures.motioncontrolleractors")
local gameState = require("stalker2.gamestate") -- Ensure gameState is available for context
local gamepadState = require("stalker2.gamepad")
local gestureSet = require("stalker2.gesturepresetlh")
local haptics = require("stalker2.haptics")
require("Base.basic")


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