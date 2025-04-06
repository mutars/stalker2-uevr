local BodyZones = require("gestures.bodyzone")

local function trigger_haptic(left)
    if left then
        local leftController = uevr.params.vr.get_left_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, leftController)
    else
        local rightController = uevr.params.vr.get_right_joystick_source()
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, rightController)
    end
end

BodyZones.headZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.leftShoulderZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.rightShoulderZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.rightHipZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.leftHipZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.leftChestZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.rightChestZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.lowerBackZoneLH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(true)
    end
end)

BodyZones.headZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.leftShoulderZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.rightShoulderZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.rightHipZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.leftHipZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.leftChestZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.rightChestZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)

BodyZones.lowerBackZoneRH:SetExecutionCallback(function(gesture, context)
    if gesture:JustActivated() then
        trigger_haptic(false)
    end
end)
