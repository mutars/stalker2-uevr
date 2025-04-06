local BodyZones = require("gestures.bodyzone")

local function createHapticCB(left)
    return function(gesture, context)
        if left then
            local leftController = uevr.params.vr.get_left_joystick_source()
            uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
        else
            local rightController = uevr.params.vr.get_right_joystick_source()
            uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
        end
    end

end

BodyZones.headZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.leftShoulderZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.rightShoulderZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.rightHipZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.leftHipZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.leftChestZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.rightChestZoneLH:SetExecutionCallback(createHapticCB(true))
BodyZones.lowerBackZoneLH:SetExecutionCallback(createHapticCB(true))

BodyZones.headZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.leftShoulderZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.rightShoulderZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.rightHipZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.leftHipZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.leftChestZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.rightChestZoneRH:SetExecutionCallback(createHapticCB(false))
BodyZones.lowerBackZoneRH:SetExecutionCallback(createHapticCB(false))
