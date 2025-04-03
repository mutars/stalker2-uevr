local ZonedGestures = require("gestures.basezones")
local LocationGestures = require("gestures.locationgesture")

-- Weapon Zone Instances
local reloadZoneRH = ZonedGestures.WeaponZoneGesture:new({
    name = "Weapon Reload Zone (RH)",
    weaponLocationGesture = LocationGestures.RightHand,
    minX = -15,
    maxX = 20,
    minY = -12,
    maxY = 12,
    minZ = -30,
    maxZ = -5
})

local reloadZoneLH = ZonedGestures.WeaponZoneGesture:new({
    name = "Weapon Reload Zone (LH)",
    weaponLocationGesture = LocationGestures.LeftHand,
    minX = -15,
    maxX = 20,
    minY = -12,
    maxY = 12,
    minZ = -30,
    maxZ = -5
})

local modeSwitchZoneRH = ZonedGestures.WeaponZoneGesture:new({
    name = "Weapon Mode Switch Zone (RH)",
    weaponLocationGesture = LocationGestures.RightHand,
    minX = -5,
    maxX = 10,
    minY = -12,
    maxY = 12,
    minZ = 0,
    maxZ = 10
})

local modeSwitchZoneLH = ZonedGestures.WeaponZoneGesture:new({
    name = "Weapon Mode Switch Zone (LH)",
    weaponLocationGesture = LocationGestures.LeftHand,
    minX = -5,
    maxX = 10,
    minY = -12,
    maxY = 12,
    minZ = 0,
    maxZ = 10
})

local barrelZoneRH = ZonedGestures.WeaponZoneGesture:new({
    name = "Weapon Barrel Zone (RH)",
    weaponLocationGesture = LocationGestures.RightHand,
    minX = 15,
    maxX = 45,
    minY = -15,
    maxY = 15,
    minZ = 0,
    maxZ = 25
})

local barrelZoneLH = ZonedGestures.WeaponZoneGesture:new({
    name = "Weapon Barrel Zone (LH)",
    weaponLocationGesture = LocationGestures.LeftHand,
    minX = 15,
    maxX = 45,
    minY = -15,
    maxY = 15,
    minZ = 0,
    maxZ = 25
})

return {
    reloadZoneRH = reloadZoneRH,
    reloadZoneLH = reloadZoneLH,
    modeSwitchZoneRH = modeSwitchZoneRH,
    modeSwitchZoneLH = modeSwitchZoneLH,
    barrelZoneRH = barrelZoneRH,
    barrelZoneLH = barrelZoneLH
}