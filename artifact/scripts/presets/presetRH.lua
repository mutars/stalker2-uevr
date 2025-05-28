--[[
    GesturePresetsLH.lua
    Left-handed gesture presets using the GripGesture base class
]]--

require("Config.CONFIG")
local GripGesture = require("stalker2.gripgesture")
local TwoHandedAimGesture = require("stalker2.twohandedaim")

local BodyZonesSitting = require("gestures.bodyzonesitting")
local BodyZonesStanding =  require("gestures.bodyzone")
local WeaponZones = require("gestures.weaponzones")
local motionControllers = require("gestures.motioncontrollergestures")
local gameState = require("stalker2.gamestate")
local GestureSet = require("gestures.gestureset")

local function createKeyPresExecutionCB(key, gesture_config_key)
    if not Config.gestures[gesture_config_key] then
        return nil
    end
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
        TwoHandedStateActive = true
        gesture.leftGripGesture:Lock()
    elseif gesture:JustDeactivated() then
        TwoHandedStateActive = false
        gesture.leftGripGesture:Unlock()
    end
end

local function createPreset(bodyZones, weaponZones, sittingExperience)
    -- Create left-hand gesture instances
    local flashlightGestureLH = GripGesture:new({
        name = "Flashlight Gesture (LH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = bodyZones.headZoneLH
    })

    local flashlightGestureRH = GripGesture:new({
        name = "Flashlight Gesture (RH)",
        gripGesture = motionControllers.RightGripAction,
        zone = bodyZones.headZoneRH
    })

    local primaryWeaponGestureRH = GripGesture:new({
        name = "Primary Weapon Gesture (RH)",
        gripGesture = motionControllers.RightGripAction,
        zone = bodyZones.rightShoulderZoneRH
    })

    local secondaryWeaponGestureRH = GripGesture:new({
        name = "Secondary Weapon Gesture (RH)",
        gripGesture = motionControllers.RightGripAction,
        zone = bodyZones.leftShoulderZoneRH
    })

    local sidearmWeaponGestureRH = GripGesture:new({
        name = "Sidearm Weapon Gesture (RH)",
        gripGesture = motionControllers.RightGripAction,
        zone = bodyZones.rightHipZoneRH
    })

    local meleeWeaponGestureLH = GripGesture:new({
        name = "Melee Weapon Gesture (LH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = bodyZones.leftHipZoneLH
    })

    local boltActionGestureRH = GripGesture:new({
        name = "Bolt Action Gesture (RH)",
        gripGesture = motionControllers.RightGripAction,
        zone = bodyZones.rightChestZoneRH
    })

    local grenadeGestureLH = GripGesture:new({
        name = "Grenade Gesture (LH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = bodyZones.leftChestZoneLH
    })

    local inventoryGestureLH = GripGesture:new({
        name = "Inventory Gesture (LH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = bodyZones.rightShoulderZoneLH
    })

    local dpadLeftGestureLH = GripGesture:new({
        name = "D-Pad Left Gesture (LH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = bodyZones.leftShoulderZoneLH
    })

    local scannerGestureLH = GripGesture:new({
        name = "Scanner Gesture (LH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = bodyZones.rightChestZoneLH
    })

    local pdaGestureRH = GripGesture:new({
        name = "PDA Gesture (RH)",
        gripGesture = motionControllers.RightGripAction,
        zone = bodyZones.leftChestZoneRH
    })

    local reloadGestureRH = GripGesture:new({
        name = "Reload Gesture (RH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = weaponZones.reloadZoneRH
    })

    local modeSwitchZoneRH = GripGesture:new({
        name = "Mode Switch Gesture (RH)",
        gripGesture = motionControllers.LeftGripAction,
        zone = weaponZones.modeSwitchZoneRH
    })

    local twoHandedAimGestureRH = TwoHandedAimGesture:new({
        name = "Two-Handed Aim Gesture (RH)",
        leftGripGesture = motionControllers.LeftGripAction,
        rightGripGesture = motionControllers.RightGripAction,
        zone = weaponZones.barrelZoneRH
    })

    flashlightGestureLH:SetExecutionCallback(createKeyPresExecutionCB('L', 'flashlight'))
    flashlightGestureRH:SetExecutionCallback(createKeyPresExecutionCB('L', 'flashlight'))
    primaryWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('3', 'primaryWeapon'))
    secondaryWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('4', 'secondaryWeapon'))
    sidearmWeaponGestureRH:SetExecutionCallback(createKeyPresExecutionCB('2', 'sidearmWeapon'))
    meleeWeaponGestureLH:SetExecutionCallback(createKeyPresExecutionCB('1', 'meleeWeapon'))
    boltActionGestureRH:SetExecutionCallback(createKeyPresExecutionCB('6', 'boltAction'))
    grenadeGestureLH:SetExecutionCallback(createKeyPresExecutionCB('5', 'grenade'))

    inventoryGestureLH:SetExecutionCallback(createKeyPresExecutionCB('I', 'inventory'))
    -- dpadLeftGestureLH:SetExecutionCallback(createKeyPresExecutionCB('D'))
    scannerGestureLH:SetExecutionCallback(createKeyPresExecutionCB('7', 'scanner'))
    pdaGestureRH:SetExecutionCallback(createKeyPresExecutionCB('M', 'pda'))
    reloadGestureRH:SetExecutionCallback(createKeyPresExecutionCB('R', 'reload'))
    modeSwitchZoneRH:SetExecutionCallback(createKeyPresExecutionCB('B', 'modeSwitch'))

    twoHandedAimGestureRH:SetExecutionCallback(twoHandedAimingCB)
    if sittingExperience then
        return  GestureSet:new(
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
    else
        return GestureSet:new(
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
    end
end

local SitmodeSetRH =  createPreset(BodyZonesSitting, WeaponZones, true)
local StandModeSetRH = createPreset(BodyZonesStanding, WeaponZones, false)

return {
    SitmodeSetRH = SitmodeSetRH,
    StandModeSetRH = StandModeSetRH
}