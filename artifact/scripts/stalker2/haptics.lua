local BodyZones = require("gestures.bodyzone")

local function HapticLeftCB(gesture, context)
    if gesture:JustActivated() then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    end
end


local function HapticRightCB(gesture, context)
    if gesture:JustActivated() then
        local rightController = uevr.params.vr.get_right_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
    end
end


BodyZones.headZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.leftShoulderZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.rightShoulderZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.rightHipZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.leftHipZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.leftChestZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.rightChestZoneLH:SetExecutionCallback(HapticLeftCB)
BodyZones.lowerBackZoneLH:SetExecutionCallback(HapticLeftCB)

BodyZones.headZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.leftShoulderZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.rightShoulderZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.rightHipZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.leftHipZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.leftChestZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.rightChestZoneRH:SetExecutionCallback(HapticRightCB)
BodyZones.lowerBackZoneRH:SetExecutionCallback(HapticRightCB)
