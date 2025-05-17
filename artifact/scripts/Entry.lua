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
local scopeController = require("Base.scope") -- Require the scope controller

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
    -- Update scope brightness
    if scopeController then
        scopeController:SetScopeBrightness(config.scopeBrightnessAmplifier)
        scopeController:SetScopePlaneScale(config.cylinderDepth)
        scopeController:UpdateIndoorMode(config.indoor)
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
    -- Scope Brightness Amplifier
    local brightnessChanged, newBrightness = imgui.slider_float("Scope Brightness", Config.scopeBrightnessAmplifier, 0.01, 2.0)
    if brightnessChanged then
        Config.scopeBrightnessAmplifier = newBrightness
        changed = true
    end

    local scaleLerpChanged, newScaleLerp = imgui.checkbox("Scale Lerp with Camera FOV", Config.scaleLerpWithCameraFov)
    if scaleLerpChanged then
        Config.scaleLerpWithCameraFov = newScaleLerp
        changed = true
    end
    -- Lerp Override
    local lerpOverrideChanged, newLerpOverride = imgui.drag_float("Lerp Override", Config.lerpOverride, 0.1, 0.1, 20.0, "%.2f")
    if lerpOverrideChanged then
        Config.lerpOverride = newLerpOverride
        changed = true
    end

    -- Virtual Gunstock
    local gunstockChanged, newGunstock = imgui.checkbox("Virtual Gunstock (Debug Not working)", Config.virtualGunstock)
    if gunstockChanged then
        Config.virtualGunstock = newGunstock
        changed = true
    end

    -- Virtual Gunstock Distance
    local gunstockDistanceChanged, newGunstockDistance = imgui.drag_float("Virtual Gunstock Distance", Config.virtualGunstockDistance, 0.01, 0.01, 0.1, "%.3f")
    if gunstockDistanceChanged then
        Config.virtualGunstockDistance = newGunstockDistance
        changed = true
    end

    -- Indoor Mode
    local indoorChanged, newIndoor = imgui.checkbox("Indoor Mode (Scope OverExposure fix)", Config.indoor)
    if indoorChanged then
        Config.indoor = newIndoor
        changed = true
    end

    -- Scope Diameter
    local diameterChanged, newDiameter = imgui.drag_float("Scope Diameter", Config.scopeDiameter, 0.001, 0.01, 0.1, "%.3f")
    if diameterChanged then
        Config.scopeDiameter = newDiameter
        changed = true
    end

    -- Scope Magnifier
    local magnifierChanged, newMagnifier = imgui.drag_float("Scope FOV Magnifier", Config.scopeMagnifier, 0.1, 0.1, 1.0, "%.2f")
    if magnifierChanged then
        Config.scopeMagnifier = newMagnifier
        changed = true
    end

    -- Scope Texture Size
    local textureSizeChanged, newTextureSize = imgui.drag_int("Scope Texture Size (Require Script Reset)", Config.scopeTextureSize, 1, 256, 3072)
    if textureSizeChanged then
        Config.scopeTextureSize = newTextureSize
        changed = true
    end

    -- Cylinder Depth (Debug)
    local depthChanged, newDepth = imgui.drag_float("Cylinder Depth (Debug)", Config.cylinderDepth, 0.00001, 0.0, 0.1, "%.5f")
    if depthChanged then
        Config.cylinderDepth = newDepth
        changed = true
    end


    -- local projection_matrix = UEVR_Matrix4x4f.new()
    -- uevr.params.vr.get_ue_projection_matrix(0, projection_matrix)
    -- imgui.text("Projection Matrix:")
    -- imgui.text(string.format("[%.2f,%.2f,%.2f,%.2f]", projection_matrix[0][1], projection_matrix[1][1], projection_matrix[2][1], projection_matrix[3][1]))
    -- imgui.text(string.format("[%.2f,%.2f,%.2f,%.2f]", projection_matrix[0][2], projection_matrix[1][2], projection_matrix[2][2], projection_matrix[3][2]))
    -- imgui.text(string.format("[%.2f,%.2f,%.2f,%.2f]", projection_matrix[0][3], projection_matrix[1][3], projection_matrix[2][3], projection_matrix[3][3]))
    -- imgui.text(string.format("[%.2f,%.2f,%.2f,%.2f]", projection_matrix[0][4], projection_matrix[1][4], projection_matrix[2][4], projection_matrix[3][4]))

    -- local pawn = uevr.api:get_local_pawn(0)

    -- if pawn and scopeController.scope_actor and uevr.params.vr.is_hmd_active() then
    --     local size_ratio = scopeController:CalcActorScreenSizeSq(scopeController.scope_actor, 0)
    --     local GetViewDistance = scopeController:GetViewDistance(0)
    --     local view_pos = scopeController.left_view_location;
    --     imgui.text("View Location: " .. string.format("X: %.2f, Y: %.2f, Z: %.2f", view_pos.x, view_pos.y, view_pos.z))
    --     imgui.text("Scope Size Ratio: " .. size_ratio .. "distance: " .. GetViewDistance)
    -- end


    if changed then
        updateConfig(Config)
        Config:save()
    end
end)