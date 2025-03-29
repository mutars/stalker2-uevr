local ZonedGestures = require("gestures.ZonedGestures")
local LocationGestures = require("gestures.LocationGestures")

-- Body Zone Instances
local rightShoulderZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Right Shoulder Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -10,
    maxX = 20,
    minY = 10,
    maxY = 30,
    minZ = -10,
    maxZ = 20
})

local rightShoulderZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Right Shoulder Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -10,
    maxX = 20,
    minY = 10,
    maxY = 30,
    minZ = -10,
    maxZ = 20
})

local leftShoulderZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Left Shoulder Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -10,
    maxX = 20,
    minY = -30,
    maxY = -10,
    minZ = -10,
    maxZ = 20
})

local leftShoulderZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Left Shoulder Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -10,
    maxX = 20,
    minY = -30,
    maxY = -10,
    minZ = -10,
    maxZ = 20
})

local headZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Head Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = 0,
    maxX = 20,
    minY = -5,
    maxY = 5,
    minZ = 0,
    maxZ = 20
})

local headZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Head Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = 0,
    maxX = 20,
    minY = -5,
    maxY = 5,
    minZ = 0,
    maxZ = 20
})

local rightHipZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Right Hip Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -100,
    maxX = -60,
    minY = 22,
    maxY = 50,
    minZ = -10,
    maxZ = 10
})

local rightHipZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Right Hip Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -100,
    maxX = -60,
    minY = 22,
    maxY = 50,
    minZ = -10,
    maxZ = 10
})

local leftHipZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Left Hip Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -100,
    maxX = -50,
    minY = -30,
    maxY = 5,
    minZ = -10,
    maxZ = 30
})

local leftHipZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Left Hip Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -100,
    maxX = -50,
    minY = -30,
    maxY = 5,
    minZ = -10,
    maxZ = 30
})

local leftChestZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Left Chest Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -40,
    maxX = -25,
    minY = -15,
    maxY = -5,
    minZ = 0,
    maxZ = 10
})

local leftChestZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Left Chest Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -40,
    maxX = -25,
    minY = -15,
    maxY = -5,
    minZ = 0,
    maxZ = 10
})

local rightChestZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Right Chest Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -40,
    maxX = -25,
    minY = 5,
    maxY = 15,
    minZ = 0,
    maxZ = 10
})

local rightChestZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Right Chest Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -40,
    maxX = -25,
    minY = 5,
    maxY = 15,
    minZ = 0,
    maxZ = 10
})

local lowerBackZoneRH = ZonedGestures.BodyZoneGesture:new({
    name = "Lower Back Zone (RH)",
    locationGesture = LocationGestures.RightHand,
    minX = -100,
    maxX = -50,
    minY = -20,
    maxY = 20,
    minZ = -30,
    maxZ = -15
})

local lowerBackZoneLH = ZonedGestures.BodyZoneGesture:new({
    name = "Lower Back Zone (LH)",
    locationGesture = LocationGestures.LeftHand,
    minX = -100,
    maxX = -50,
    minY = -20,
    maxY = 20,
    minZ = -30,
    maxZ = -15
})

return {
    rightShoulderZoneRH = rightShoulderZoneRH,
    rightShoulderZoneLH = rightShoulderZoneLH,
    leftShoulderZoneRH = leftShoulderZoneRH,
    leftShoulderZoneLH = leftShoulderZoneLH,
    headZoneRH = headZoneRH,
    headZoneLH = headZoneLH,
    rightHipZoneRH = rightHipZoneRH,
    rightHipZoneLH = rightHipZoneLH,
    leftHipZoneRH = leftHipZoneRH,
    leftHipZoneLH = leftHipZoneLH,
    leftChestZoneRH = leftChestZoneRH,
    leftChestZoneLH = leftChestZoneLH,
    rightChestZoneRH = rightChestZoneRH,
    rightChestZoneLH = rightChestZoneLH,
    lowerBackZoneRH = lowerBackZoneRH,
    lowerBackZoneLH = lowerBackZoneLH
}