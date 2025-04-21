-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end
require("Config.CONFIG")
local motionControllerActors = require("gestures.motioncontrolleractors")
local gameState = require("stalker2.gamestate") -- Ensure gameState is available for context
local gestureSet = isRhand and require("presets.presetRH") or require("presets.presetLH")
local gamepadState = require("stalker2.gamepad")
local haptics = require("stalker2.haptics")
require("Base.basic")
require("Base.scope")

gameState:Init()
gamepadState:Reset()

uevr.sdk.callbacks.on_pre_engine_tick(
    function(engine, delta)
        if gameState:IsLevelChanged(engine) then
            print("Level changed, resetting game state and motion controllers")
            gestureSet:Reset()
            motionControllerActors:Reset() -- Reset the motion controller actors
            gamepadState:Reset()
        else
            gameState:Update()
            motionControllerActors:Update(engine)
            if not gameState.isInventoryPDA and not gameState.inMenu then
                gestureSet:Update({})
            end
        end
    end
)

uevr.sdk.callbacks.on_xinput_get_state(
    function(retval, user_index, state)
        if not gameState.isInventoryPDA and not gameState.inMenu then
            gamepadState:Update(state)
        end
    end
)

uevr.sdk.callbacks.on_script_reset(function()
    print("Resetting")
    gestureSet:Reset()
    gameState:Reset() -- Reset the game state to initial conditions
    motionControllerActors:Reset() -- Reset the motion controller actors
    gamepadState:Reset()
end)