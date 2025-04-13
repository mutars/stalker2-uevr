--[[
    GesturePresetsLH.lua
    Left-handed gesture presets using the GripGesture base class
]]--

local GripGesture = require("stalker2.gripgesture")
local BodyZones = require("gestures.bodyzonesitting")
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

local grenadeGestureLH = GripGesture:new({
    name = "Grenade Gesture (LH)",
    gripGesture = motionControllers.LeftGripAction,
    zone = BodyZones.rightChestZoneLH
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

local pdaGestureRH = GripGesture:new({
    name = "PDA Gesture (RH)",
    gripGesture = motionControllers.RightGripAction,
    zone = BodyZones.rightChestZoneRH
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

flashlightGestureLH:SetExecutionCallback(createKeyPresExecutionCB('L'))
flashlightGestureRH:SetExecutionCallback(createKeyPresExecutionCB('L'))
primaryWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('3'))
secondaryWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('4'))
sidearmWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('2'))
meleeWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('1'))
boltActionGestureLH:SetExecutionCallback(createKeyPresExecutionCB('6'))
grenadeGestureLH:SetExecutionCallback(createKeyPresExecutionCB('5'))

inventoryGestureRH:SetExecutionCallback(createKeyPresExecutionCB('I'))
-- dpadLeftGestureRH:SetExecutionCallback(createKeyPresExecutionCB('D'))
scannerGestureRH:SetExecutionCallback(createKeyPresExecutionCB('7'))
pdaGestureRH:SetExecutionCallback(createKeyPresExecutionCB('M'))
reloadGestureLH:SetExecutionCallback(createKeyPresExecutionCB('R'))
modeSwitchZoneLH:SetExecutionCallback(createKeyPresExecutionCB('B'))


local gestureSetLH = GestureSet:new(
    {
        -- Initialize the gesture set with the flashlight and primary weapon gestures for both hands
        rootGestures = {
            flashlightGestureLH,
            flashlightGestureRH,
            primaryWeaponGestureLH,
            secondaryWeaponGestureLH,
            -- sidearmWeaponGestureLH,
            -- meleeWeaponGestureRH,
            boltActionGestureLH,
            grenadeGestureLH,
            inventoryGestureRH,
            scannerGestureRH,
            pdaGestureRH,
            reloadGestureLH,
            modeSwitchZoneLH
        }
    }
)

return gestureSetLH