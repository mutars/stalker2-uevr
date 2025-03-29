local GestureBase = require("gestures.GestureBase")

-- Base Body Zone Gesture class
local BodyZoneGesture = GestureBase:new({
    name = "Body Zone Gesture Base",
    locationGesture = nil,
    
    -- Zone boundaries
    minX = 0,
    maxX = 0,
    minY = 0,
    maxY = 0,
    minZ = 0,
    maxZ = 0
})

function BodyZoneGesture:new(config)
    if not config.locationGesture then
        error("locationGesture is required for BodyZoneGesture")
    end
    config = config or {}
    -- Populate dependencies from fields
    config.dependencies = {}
    if config.locationGesture then
        table.insert(config.dependencies, config.locationGesture)
    end
    setmetatable(config, self)
    self.__index = self
    return config
end

function BodyZoneGesture:EvaluateInternal(context)
    if not self.locationGesture or not self.locationGesture.isActive then
        return false
    end

    local x = self.locationGesture.location.x
    local y = self.locationGesture.location.y
    local z = self.locationGesture.location.z

    return x >= self.minX and x <= self.maxX and
           y >= self.minY and y <= self.maxY and
           z >= self.minZ and z <= self.maxZ
end

-- Base Weapon Zone Gesture class
local WeaponZoneGesture = GestureBase:new({
    name = "Weapon Zone Gesture Base",
    weaponLocationGesture = nil,
    
    -- Zone boundaries
    minX = 0,
    maxX = 0,
    minY = 0,
    maxY = 0,
    minZ = 0,
    maxZ = 0
})

function WeaponZoneGesture:new(config)
    if not config.weaponLocationGesture then
        error("weaponLocationGesture is required for WeaponZoneGesture")
    end
    config = config or {}
    -- Populate dependencies from fields
    config.dependencies = {}
    if config.weaponLocationGesture then
        table.insert(config.dependencies, config.weaponLocationGesture)
    end
    setmetatable(config, self)
    self.__index = self
    return config
end

function WeaponZoneGesture:EvaluateInternal(context)
    if not self.weaponLocationGesture or not self.weaponLocationGesture.isActive then
        return false
    end

    local x = self.weaponLocationGesture.weaponLocation.x
    local y = self.weaponLocationGesture.weaponLocation.y
    local z = self.weaponLocationGesture.weaponLocation.z

    return x >= self.minX and x <= self.maxX and
           y >= self.minY and y <= self.maxY and
           z >= self.minZ and z <= self.maxZ
end

return {
    BodyZoneGesture = BodyZoneGesture,
    WeaponZoneGesture = WeaponZoneGesture
}