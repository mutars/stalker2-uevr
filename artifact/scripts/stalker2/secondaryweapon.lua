--[[
    SecondaryWeaponGesture.lua
    Gesture that activates when a motion controller is near the opposite shoulder and grip button is pressed
    For left-handed users, triggers when left grip is pressed near right shoulder
    For right-handed users, triggers when right grip is pressed near left shoulder
]]--

local GestureBase = require("gestures.gesturebase")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")

-- SecondaryWeaponGesture: Base class for secondary weapon gestures
SecondaryWeaponGesture = GestureBase:new({
    name = "Secondary Weapon Gesture Base",
    gripGesture = nil,
    shoulderZone = nil,
})

function SecondaryWeaponGesture:new(config)
    -- Set up dependencies
    config = config or {}
    if not config.gripGesture then
        error("gripGesture is required for SecondaryWeaponGesture")
    end
    if not config.shoulderZone then
        error("shoulderZone is required for SecondaryWeaponGesture")
    end
    
    local instance = GestureBase.new(self, config)
    instance:AddDependency(instance.gripGesture) -- Ensure gripGesture is a dependency
    instance:AddDependency(instance.shoulderZone) -- Ensure shoulderZone is a dependency
    return instance
end

function SecondaryWeaponGesture:EvaluateInternal(context)
    -- Modified to ensure correct activation for the right-handed mode
    local justActivated = not self.gripGesture:IsLocked() and self.gripGesture:JustActivated() and self.shoulderZone.isActive
    if justActivated then
        return true -- Ensure we return true for the just activated case
    end
    return self.wasActive and self.shoulderZone.isActive and self.gripGesture.isActive
end

-- Create specific instances for Left Hand and Right Hand
-- Note: RH user's secondary weapon is triggered by right hand on LEFT shoulder
-- LH user's secondary weapon is triggered by left hand on RIGHT shoulder
local secondaryWeaponGestureRH = SecondaryWeaponGesture:new({
    name = "Secondary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    shoulderZone = BodyZones.leftShoulderZoneRH  -- Right hand on left shoulder
})

local secondaryWeaponGestureLH = SecondaryWeaponGesture:new({
    name = "Secondary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    shoulderZone = BodyZones.rightShoulderZoneLH  -- Left hand on right shoulder
})

return {
    secondaryWeaponGestureRH = secondaryWeaponGestureRH,
    secondaryWeaponGestureLH = secondaryWeaponGestureLH
}