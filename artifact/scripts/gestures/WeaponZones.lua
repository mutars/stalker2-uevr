local ZonedGestures = require("artifact.scripts.gestures.ZonedGestures")

-- Factory functions for Weapon Zones
local function createReloadZone(weaponLocationGesture)
    return ZonedGestures.WeaponZoneGesture:new({
        name = "Weapon Reload Zone",
        weaponLocationGesture = weaponLocationGesture,
        minX = -15,
        maxX = 20,
        minY = -12,
        maxY = 12,
        minZ = -30,
        maxZ = -5
    })
end

local function createModeSwitchZone(weaponLocationGesture)
    return ZonedGestures.WeaponZoneGesture:new({
        name = "Weapon Mode Switch Zone",
        weaponLocationGesture = weaponLocationGesture,
        minX = -5,
        maxX = 10,
        minY = -12,
        maxY = 12,
        minZ = 0,
        maxZ = 10
    })
end

local function createBarrelZone(weaponLocationGesture)
    return ZonedGestures.WeaponZoneGesture:new({
        name = "Weapon Barrel Zone",
        weaponLocationGesture = weaponLocationGesture,
        minX = 15,
        maxX = 45,
        minY = -15,
        maxY = 15,
        minZ = 0,
        maxZ = 25
    })
end

return {
    createReloadZone = createReloadZone,
    createModeSwitchZone = createModeSwitchZone,
    createBarrelZone = createBarrelZone
}