require("Config.CONFIG")
if not HapticFeedback then
    print("Haptic feedback is disabled in the configuration.")
    return
end

local BodyZones = SitMode and require("gestures.bodyzonesitting") or require("gestures.bodyzone")
local WeaponZones = require("gestures.weaponzones")

local function HapticLeftCB(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
    -- if gesture.isActive then
    --     local location = gesture.locationGesture.location
    --     print("[BodyZones] " .. gesture.name .. " is active [" .. location.x .. ", " .. location.y .. ", " .. location.z .. "]")
    -- end
end


local function HapticRightCB(gesture, context)
    if gesture:JustActivated() then
        local rightController = uevr.params.vr.get_right_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
    end
    -- if gesture.isActive then
    --     local location = gesture.locationGesture.location
    --     print("[BodyZones] " .. gesture.name .. " is active [" .. location.x .. ", " .. location.y .. ", " .. location.z .. "]")
    -- end
end


BodyZones.headZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.leftShoulderZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.rightShoulderZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.rightHipZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.leftHipZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.leftChestZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.rightChestZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.lowerBackZoneLH:SetExecutionCallback(HapticLeftCB)
WeaponZones.reloadZoneLH:SetExecutionCallback(HapticLeftCB)
WeaponZones.modeSwitchZoneLH:SetExecutionCallback(HapticLeftCB)


BodyZones.headZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.leftShoulderZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.rightShoulderZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.rightHipZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.leftHipZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.leftChestZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.rightChestZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.lowerBackZoneRH:SetExecutionCallback(HapticRightCB)
WeaponZones.reloadZoneRH:SetExecutionCallback(HapticRightCB)
WeaponZones.modeSwitchZoneRH:SetExecutionCallback(HapticRightCB)

