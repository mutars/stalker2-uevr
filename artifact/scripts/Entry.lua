-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end
require("Config.CONFIG")
local motionControllerActors = require("gestures.motioncontrolleractors")
local gameState = require("stalker2.gamestate") -- Ensure gameState is available for context
local gestureSetRH = require("presets.presetRH")
local gestureSetLH = require("presets.presetLH")
local gamepadState = require("stalker2.gamepad")
local haptics = require("stalker2.haptics")
require("Base.basic")
require("Base.scope")

gameState:Init()
gamepadState:Reset()

local currentPreset = gestureSetRH.StandModeSetRH

local function updateConfig(config)
    haptics.updateHapticFeedback(Config.hapticFeedback)
    if Config.dominantHand == 1 then
        currentPreset = Config.sittingExperience and gestureSetRH.SitmodeSetRH or gestureSetRH.StandModeSetRH
    else
        currentPreset = Config.sittingExperience and gestureSetLH.SitModeSetLH or gestureSetLH.StandModeSetLH
    end
end

uevr.sdk.callbacks.on_pre_engine_tick(
    function(engine, delta)
        if gameState:IsLevelChanged(engine) then
            print("Level changed, resetting game state and motion controllers")
            currentPreset:Reset()
            motionControllerActors:Reset() -- Reset the motion controller actors
            gamepadState:Reset()
        else
            gameState:Update()
            motionControllerActors:Update(engine)
            if not gameState.isInventoryPDA and not gameState.inMenu then
                currentPreset:Update({})
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
    currentPreset:Reset()
    gameState:Reset() -- Reset the game state to initial conditions
    motionControllerActors:Reset() -- Reset the motion controller actors
    gamepadState:Reset()
end)

-- Load config at script init
Config:load()
updateConfig(Config)

-- Config UI as a collapsing header
uevr.sdk.callbacks.on_draw_ui(function()
    if not imgui.collapsing_header("VR Mod Config") then return end

    local changed = false

    -- Dominant Hand
    local handOptions = {"Left","Right"}
    local handIdx = Config.dominantHand + 1
    local handChanged, newHand = imgui.combo("Dominant Hand", handIdx, handOptions)
    if handChanged then
        Config.dominantHand = newHand - 1
        changed = true
    end

    -- Sitting Experience
    local sitChanged, newSit = imgui.checkbox("Sitting Experience", Config.sittingExperience)
    if sitChanged then
        Config.sittingExperience = newSit
        changed = true
    end

    -- Haptic Feedback
    local hapticChanged, newHaptic = imgui.checkbox("Haptic Feedback", Config.hapticFeedback)
    if hapticChanged then
        Config.hapticFeedback = newHaptic
        changed = true
    end

    -- Recoil
    local recoilChanged, newRecoil = imgui.checkbox("Recoil", Config.recoil)
    if recoilChanged then
        Config.recoil = newRecoil
        changed = true
    end

    -- Two-Handed Aiming
    local twoHandedChanged, newTwoHanded = imgui.checkbox("Two-Handed Aiming", Config.twoHandedAiming)
    if twoHandedChanged then
        Config.twoHandedAiming = newTwoHanded
        changed = true
    end

    if changed then
        updateConfig(Config)
        Config:save()
    end
end)