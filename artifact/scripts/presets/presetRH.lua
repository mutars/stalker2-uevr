--[[
    GesturePresetsLH.lua
    Left-handed gesture presets using the GripGesture base class
]]--

require("Config.CONFIG")
local GripGesture = require("stalker2.gripgesture")
local TwoHandedAimGesture = require("stalker2.twohandedaim")

local BodyZones = SitMode and require("gestures.bodyzonesitting") or require("gestures.bodyzones")
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

local primaryWeaponGestureRH = GripGesture:new({
    name = "Primary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightShoulderZoneRH
})

local secondaryWeaponGestureRH = GripGesture:new({
    name = "Secondary Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.leftShoulderZoneRH
})

local sidearmWeaponGestureRH = GripGesture:new({
    name = "Sidearm Weapon Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightHipZoneRH
})

local meleeWeaponGestureLH = GripGesture:new({
    name = "Melee Weapon Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftHipZoneLH
})

local boltActionGestureRH = GripGesture:new({
    name = "Bolt Action Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightChestZoneRH
})

local grenadeGestureLH = GripGesture:new({
    name = "Grenade Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftChestZoneLH
})

local inventoryGestureLH = GripGesture:new({
    name = "Inventory Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightShoulderZoneLH
})

local dpadLeftGestureLH = GripGesture:new({
    name = "D-Pad Left Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.leftShoulderZoneLH
})

local scannerGestureLH = GripGesture:new({
    name = "Scanner Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightChestZoneLH
})

local pdaGestureRH = GripGesture:new({
    name = "PDA Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.leftChestZoneRH
})

local reloadGestureRH = GripGesture:new({
    name = "Reload Gesture (RH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = WeaponZones.reloadZoneRH
})

local modeSwitchZoneRH = GripGesture:new({
    name = "Mode Switch Gesture (RH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = WeaponZones.modeSwitchZoneRH
})

local twoHandedAimGestureRH = TwoHandedAimGesture:new({
    name = "Two-Handed Aim Gesture (RH)",
    leftGripGesture = motionControllers.LeftGripAction,
    rightGripGesture = motionControllers.RightGripAction,
    zone = WeaponZones.barrelZoneRH
})

flashlightGestureLH:SetExecutionCallback(createKeyPresExecutionCB('L'))
flashlightGestureRH:SetExecutionCallback(createKeyPresExecutionCB('L'))
primaryWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('3'))
secondaryWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('4'))
sidearmWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('2'))
meleeWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('1'))
boltActionGestureRH:SetExecutionCallback(createKeyPresExecutionCB('6'))
grenadeGestureLH:SetExecutionCallback(createKeyPresExecutionCB('5'))

inventoryGestureLH:SetExecutionCallback(createKeyPresExecutionCB('I'))
-- dpadLeftGestureLH:SetExecutionCallback(createKeyPresExecutionCB('D'))
scannerGestureLH:SetExecutionCallback(createKeyPresExecutionCB('7'))
pdaGestureRH:SetExecutionCallback(createKeyPresExecutionCB('M'))
reloadGestureRH:SetExecutionCallback(createKeyPresExecutionCB('R'))
modeSwitchZoneRH:SetExecutionCallback(createKeyPresExecutionCB('B'))

twoHandedAimGestureRH:SetExecutionCallback(twoHandedAimingCB)


local SitmodeSetRH = GestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            twoHandedAimGestureRH,
            flashlightGestureLH,
            flashlightGestureRH,
            primaryWeaponGestureRH,
            secondaryWeaponGestureRH,
            -- sidearmWeaponGestureRH,
            -- meleeWeaponGestureLH,
            -- boltActionGestureRH,
            grenadeGestureLH,
            inventoryGestureLH,
            scannerGestureLH,
            pdaGestureRH,
            reloadGestureRH,
            modeSwitchZoneRH
        }
    }
)

local StandModeSetRH = GestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            twoHandedAimGestureRH,
            flashlightGestureLH,
            flashlightGestureRH,
            primaryWeaponGestureRH,
            secondaryWeaponGestureRH,
            sidearmWeaponGestureRH,
            meleeWeaponGestureLH,
            boltActionGestureRH,
            grenadeGestureLH,
            inventoryGestureLH,
            scannerGestureLH,
            pdaGestureRH,
            reloadGestureRH,
            modeSwitchZoneRH
        }
    }
)

return SitMode and SitmodeSetRH or StandModeSetRH