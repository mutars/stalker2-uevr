--[[
    GesturePresetsLH.lua
    Left-handed gesture presets using the GripGesture base class
]]--

require("Config.CONFIG")
local GripGesture = require("stalker2.gripgesture")
local TwoHandedAimGesture = require("stalker2.twohandedaim")

local BodyZones = SitMode and require("gestures.bodyzonesitting") or require("gestures.bodyzone")
local WeaponZones = require("gestures.weaponzones")
local motionControllers = require("gestures.motioncontrollergestures")
local gameState = require("stalker2.gamestate")
local GestureSet = require("gestures.gestureset")

local function createKeyPresExecutionCB(key)
    return function(gesture, context)
        if gesture:JustActivated() then
            gameState:SendKeyDown(key)
            gesture.gripGesture:Lock()
        elseif gesture:JustDeactivated() then
            gameState:SendKeyUp(key)
            gesture.gripGesture:Unlock()
        end
    end
end

local function twoHandedAimingCB(gesture, context)
    if gesture:JustActivated() then
        two_hand_aiming = true
        gesture.rightGripGesture:Lock()
    elseif gesture:JustDeactivated() then
        two_hand_aiming = false
        gesture.rightGripGesture:Unlock()
    end
end


-- Create left-hand gesture instances
local flashlightGestureLH = GripGesture:new({
    name = "Flashlight Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.headZoneLH
})

local flashlightGestureRH = GripGesture:new({
    name = "Flashlight Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.headZoneRH
})

local primaryWeaponGestureLH = GripGesture:new({
    name = "Primary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftShoulderZoneLH
})

local secondaryWeaponGestureLH = GripGesture:new({
    name = "Secondary Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightShoulderZoneLH  -- Left hand on right shoulder
})

local sidearmWeaponGestureLH = GripGesture:new({
    name = "Sidearm Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftHipZoneLH
})

local meleeWeaponGestureRH = GripGesture:new({
    name = "Melee Weapon Gesture (LH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightHipZoneRH
})

local boltActionGestureLH = GripGesture:new({
    name = "Bolt Action Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftChestZoneLH
})

local grenadeGestureRH = GripGesture:new({
    name = "Grenade Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightChestZoneRH
})

local inventoryGestureRH = GripGesture:new({
    name = "Inventory Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.leftShoulderZoneRH
})

local dpadLeftGestureRH = GripGesture:new({
    name = "D-Pad Left Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightShoulderZoneRH
})

local scannerGestureRH = GripGesture:new({
    name = "Scanner Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.leftChestZoneRH
})

local pdaGestureLH = GripGesture:new({
    name = "PDA Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightChestZoneLH
})

local reloadGestureLH = GripGesture:new({
    name = "Reload Gesture (LH)",
    gripGesture = motionControllers.RightGripAction,
    zone = WeaponZones.reloadZoneLH
})

local modeSwitchZoneLH = GripGesture:new({
    name = "Mode Switch Gesture (LH)",
    gripGesture = motionControllers.RightGripAction,
    zone = WeaponZones.modeSwitchZoneLH
})

local twoHandedAimGestureLH = TwoHandedAimGesture:new({
    name = "Two-Handed Aim Gesture (LH)",
    leftGripGesture = motionControllers.LeftGripAction,
    rightGripGesture = motionControllers.RightGripAction,
    zone = WeaponZones.barrelZoneLH
})

flashlightGestureLH:SetExecutionCallback(createKeyPresExecutionCB('L'))
flashlightGestureRH:SetExecutionCallback(createKeyPresExecutionCB('L'))
primaryWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('3'))
secondaryWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('4'))
sidearmWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('2'))
meleeWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('1'))
boltActionGestureLH:SetExecutionCallback(createKeyPresExecutionCB('6'))
grenadeGestureRH:SetExecutionCallback(createKeyPresExecutionCB('5'))

inventoryGestureRH:SetExecutionCallback(createKeyPresExecutionCB('I'))
-- dpadLeftGestureRH:SetExecutionCallback(createKeyPresExecutionCB('D'))
scannerGestureRH:SetExecutionCallback(createKeyPresExecutionCB('7'))
pdaGestureLH:SetExecutionCallback(createKeyPresExecutionCB('M'))
reloadGestureLH:SetExecutionCallback(createKeyPresExecutionCB('R'))
modeSwitchZoneLH:SetExecutionCallback(createKeyPresExecutionCB('B'))

twoHandedAimGestureLH:SetExecutionCallback(twoHandedAimingCB)


local SitModeSetLH = GestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            twoHandedAimGestureLH,
            flashlightGestureLH,
            flashlightGestureRH,
            primaryWeaponGestureLH,
            secondaryWeaponGestureLH,
            sidearmWeaponGestureLH,
            meleeWeaponGestureRH,
            boltActionGestureLH,
            grenadeGestureRH,
            inventoryGestureRH,
            scannerGestureRH,
            pdaGestureLH,
            reloadGestureLH,
            modeSwitchZoneLH
        }
    }
)


local StandModeSetLH = GestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            twoHandedAimGestureLH,
            flashlightGestureLH,
            flashlightGestureRH,
            primaryWeaponGestureLH,
            secondaryWeaponGestureLH,
            sidearmWeaponGestureLH,
            meleeWeaponGestureRH,
            boltActionGestureLH,
            grenadeGestureRH,
            inventoryGestureRH,
            scannerGestureRH,
            pdaGestureLH,
            reloadGestureLH,
            modeSwitchZoneLH
        }
    }
)

if SitMode then
    return SitModeSetLH
else
    return StandModeSetLH
end
