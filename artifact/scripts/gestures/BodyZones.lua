local ZonedGestures = require("artifact.scripts.gestures.ZonedGestures")

-- Factory functions for Body Zones
local function createRightShoulderZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Right Shoulder Zone",
        locationGesture = locationGesture,
        minX = -10,
        maxX = 20,
        minY = 10,
        maxY = 30,
        minZ = -10,
        maxZ = 20
    })
end

local function createLeftShoulderZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Left Shoulder Zone",
        locationGesture = locationGesture,
        minX = -10,
        maxX = 20,
        minY = -30,
        maxY = -10,
        minZ = -10,
        maxZ = 20
    })
end

local function createHeadZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Head Zone",
        locationGesture = locationGesture,
        minX = 0,
        maxX = 20,
        minY = -5,
        maxY = 5,
        minZ = 0,
        maxZ = 20
    })
end

local function createRightHipZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Right Hip Zone",
        locationGesture = locationGesture,
        minX = -100,
        maxX = -60,
        minY = 22,
        maxY = 50,
        minZ = -10,
        maxZ = 10
    })
end

local function createLeftHipZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Left Hip Zone",
        locationGesture = locationGesture,
        minX = -100,
        maxX = -50,
        minY = -30,
        maxY = 5,
        minZ = -10,
        maxZ = 30
    })
end

local function createLeftChestZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Left Chest Zone",
        locationGesture = locationGesture,
        minX = -40,
        maxX = -25,
        minY = -15,
        maxY = -5,
        minZ = 0,
        maxZ = 10
    })
end

local function createRightChestZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Right Chest Zone",
        locationGesture = locationGesture,
        minX = -40,
        maxX = -25,
        minY = 5,
        maxY = 15,
        minZ = 0,
        maxZ = 10
    })
end

local function createLowerBackZone(locationGesture)
    return ZonedGestures.BodyZoneGesture:new({
        name = "Lower Back Zone",
        locationGesture = locationGesture,
        minX = -100,
        maxX = -50,
        minY = -20,
        maxY = 20,
        minZ = -30,
        maxZ = -15
    })
end

return {
    createRightShoulderZone = createRightShoulderZone,
    createLeftShoulderZone = createLeftShoulderZone,
    createHeadZone = createHeadZone,
    createRightHipZone = createRightHipZone,
    createLeftHipZone = createLeftHipZone,
    createLeftChestZone = createLeftChestZone,
    createRightChestZone = createRightChestZone,
    createLowerBackZone = createLowerBackZone
}