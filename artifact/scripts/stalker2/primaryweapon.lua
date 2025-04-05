--[[
    PrimaryWeaponGesture.lua
    Gesture that activates when a motion controller is near the shoulder and grip button is pressed
    For left-handed users, triggers when left grip is pressed near left shoulder
    For right-handed users, triggers when right grip is pressed near right shoulder
]]--

local GestureBase = require("gestures.gesturebase")
local BodyZones = require("gestures.bodyzone")
local motionControllers = require("gestures.motioncontrollergestures")

-- PrimaryWeaponGesture: Base class for primary weapon gestures
PrimaryWeaponGesture = GestureBase:new({
    name = "Primary Weapon Gesture Base",
    gripGesture = nil,
    shoulderZone = nil,
})

function PrimaryWeaponGesture:new(config)
    -- Set up dependencies
    config = config or {}
    if not config.gripGesture then
        error("gripGesture is required for PrimaryWeaponGesture")
    end
    if not config.shoulderZone then
        error("shoulderZone is required for PrimaryWeaponGesture")
    end
    
    local instance = GestureBase.new(self, config)
    instance:AddDependency(instance.gripGesture) -- Ensure gripGesture is a dependency
    instance:AddDependency(instance.shoulderZone) -- Ensure shoulderZone is a dependency
    return instance
end

function PrimaryWeaponGesture:EvaluateInternal(context)
    local justActivated = not self.gripGesture:IsLocked() and self.gripGesture:JustActivated() and self.shoulderZone.isActive
    if justActivated then
        return justActivated
    end
    return self.wasActive and self.shoulderZone.isActive and self.gripGesture.isActive
end

-- Create specific instances for Left Hand and Right Hand
local primaryWeaponGestureRH = PrimaryWeaponGesture:new({
    name = "Primary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    shoulderZone = BodyZones.rightShoulderZoneRH
})

local primaryWeaponGestureLH = PrimaryWeaponGesture:new({
    name = "Primary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    shoulderZone = BodyZones.leftShoulderZoneLH
})

return {
    primaryWeaponGestureRH = primaryWeaponGestureRH,
    primaryWeaponGestureLH = primaryWeaponGestureLH
}