local GestureBase = require("gestures.GestureBase")
local motionControllers = require("gestures.MotionControllerGestures")

-- Base Location Gesture class
local LocationGestureBase = GestureBase:new({
    name = "Location Gesture Base",
    location = Vector3f.new(0, 0, 0),
    rotation = Vector3f.new(0, 0, 0),
    weaponLocation = Vector3f.new(0, 0, 0)
})

function LocationGestureBase:new(config)
    config = config or {}
    config.location = Vector3f.new(0, 0, 0)
    config.rotation = Vector3f.new(0, 0, 0)
    config.weaponLocation = Vector3f.new(0, 0, 0)
    setmetatable(config, self)
    self.__index = self
    return config
end

-- Left Hand Location Gesture
local LeftHandLocationGesture = LocationGestureBase:new({
    name = "Left Hand Location",
    leftHand = nil,
    hmd = nil
})

function LeftHandLocationGesture:new(config)
    config = config or {}
    -- Populate dependencies from fields
    setmetatable(config, self)
    self.__index = self
    self.leftHand = motionControllers.LeftMotionControllerGesture
    self.hmd = motionControllers.HMDGesture
    table.insert(config.dependencies, self.leftHand)
    table.insert(config.dependencies, self.hmd)
    return config
end

function LeftHandLocationGesture:EvaluateInternal(context)
    if not self.leftHand or not self.hmd then
        return false
    end

    -- Calculate HMD-relative position
    local rotDiff = self.hmd.rotation.y
    local dx = self.leftHand.location.x - self.hmd.location.x
    local dy = self.leftHand.location.y - self.hmd.location.y
    
    self.location.x = dx * math.cos(-rotDiff/180*math.pi) - dy * math.sin(-rotDiff/180*math.pi)
    self.location.y = dx * math.sin(-rotDiff/180*math.pi) + dy * math.cos(-rotDiff/180*math.pi)
    self.location.z = self.leftHand.location.z - self.hmd.location.z
    
    return true
end

-- Right Hand Location Gesture
local RightHandLocationGesture = LocationGestureBase:new({
    name = "Right Hand Location",
    rightHand = nil,
    hmd = nil
})

function RightHandLocationGesture:new(config)
    config = config or {}
    -- Populate dependencies from fields
    setmetatable(config, self)
    self.__index = self
    self.rightHand = motionControllers.RightMotionControllerGesture
    self.hmd = motionControllers.HMDGesture
    table.insert(config.dependencies, self.rightHand)
    table.insert(config.dependencies, self.hmd)
    return config
end

function RightHandLocationGesture:EvaluateInternal(context)
    if not self.rightHand or not self.hmd then
        return false
    end

    -- Calculate HMD-relative position
    local rotDiff = self.hmd.rotation.y
    local dx = self.rightHand.location.x - self.hmd.location.x
    local dy = self.rightHand.location.y - self.hmd.location.y
    
    self.location.x = dx * math.cos(-rotDiff/180*math.pi) - dy * math.sin(-rotDiff/180*math.pi)
    self.location.y = dx * math.sin(-rotDiff/180*math.pi) + dy * math.cos(-rotDiff/180*math.pi)
    self.location.z = self.rightHand.location.z - self.hmd.location.z
    
    return true
end

-- Left Hand Weapon Location Gesture
local LeftHandRelativeToRightLocationGesture = LocationGestureBase:new({
    name = "Left Hand Weapon Location",
    leftHand = nil,
    rightHand = nil,
    weaponLocation = Vector3f.new(0, 0, 0)
})

function LeftHandRelativeToRightLocationGesture:new(config)
    config = config or {}
    -- Populate dependencies from fields
    setmetatable(config, self)
    self.__index = self
    self.leftHand = motionControllers.LeftMotionControllerGesture
    self.rightHand = motionControllers.RightMotionControllerGesture
    table.insert(self.dependencies, self.leftHand)
    table.insert(self.dependencies, self.rightHand)
    return config
end

function LeftHandRelativeToRightLocationGesture:EvaluateInternal(context)
    if not self.leftHand or not self.rightHand or
       not self.leftHand.isActive or not self.rightHand.isActive then
        return false
    end

    -- Calculate right-hand-relative position with rotations
    local rotZ = self.rightHand.rotation.y
    local rotX = self.rightHand.rotation.z
    local rotY = self.rightHand.rotation.x
    
    local dx = self.leftHand.location.x - self.rightHand.location.x
    local dy = self.leftHand.location.y - self.rightHand.location.y
    local dz = self.leftHand.location.z - self.rightHand.location.z

    -- Calculate all transformations first
    local newX, newY, newZ = dx, dy, dz

    -- Yaw (Z rotation)
    newX = dx * math.cos(-rotZ/180*math.pi) - dy * math.sin(-rotZ/180*math.pi)
    newY = dx * math.sin(-rotZ/180*math.pi) + dy * math.cos(-rotZ/180*math.pi)
    newZ = dz

    -- Roll (X rotation)
    local tempY = newY
    newY = tempY * math.cos(rotX/180*math.pi) - newZ * math.sin(rotX/180*math.pi)
    newZ = tempY * math.sin(rotX/180*math.pi) + newZ * math.cos(rotX/180*math.pi)

    -- Pitch (Y rotation)
    local tempX = newX
    newX = tempX * math.cos(-rotY/180*math.pi) - newZ * math.sin(-rotY/180*math.pi)
    newZ = tempX * math.sin(-rotY/180*math.pi) + newZ * math.cos(-rotY/180*math.pi)

    -- Atomic assignment of final position
    self.weaponLocation.x = newX
    self.weaponLocation.y = newY
    self.weaponLocation.z = newZ
    
    return true
end

-- Right Hand Weapon Location Gesture
local RightHandRelativeToLeftLocationGesture = LocationGestureBase:new({
    name = "Right Hand Weapon Location",
    rightHand = nil,
    leftHand = nil,
    weaponLocation = Vector3f.new(0, 0, 0)
})

function RightHandRelativeToLeftLocationGesture:new(config)
    config = config or {}
    -- Populate dependencies from fields
    setmetatable(config, self)
    self.__index = self
    self.leftHand = motionControllers.LeftMotionControllerGesture
    self.rightHand = motionControllers.RightMotionControllerGesture
    table.insert(self.dependencies, self.leftHand)
    table.insert(self.dependencies, self.rightHand)
    return config
end

function RightHandRelativeToLeftLocationGesture:EvaluateInternal(context)
    if not self.rightHand or not self.leftHand then
        return false
    end

    -- Calculate left-hand-relative position with rotations
    local rotZ = self.leftHand.rotation.y
    local rotX = self.leftHand.rotation.z
    local rotY = self.leftHand.rotation.x
    
    local dx = self.rightHand.location.x - self.leftHand.location.x
    local dy = self.rightHand.location.y - self.leftHand.location.y
    local dz = self.rightHand.location.z - self.leftHand.location.z

    -- Calculate all transformations first
    local newX, newY, newZ = dx, dy, dz

    -- Yaw (Z rotation)
    newX = dx * math.cos(-rotZ/180*math.pi) - dy * math.sin(-rotZ/180*math.pi)
    newY = dx * math.sin(-rotZ/180*math.pi) + dy * math.cos(-rotZ/180*math.pi)
    newZ = dz

    -- Roll (X rotation)
    local tempY = newY
    newY = tempY * math.cos(rotX/180*math.pi) - newZ * math.sin(rotX/180*math.pi)
    newZ = tempY * math.sin(rotX/180*math.pi) + newZ * math.cos(rotX/180*math.pi)

    -- Pitch (Y rotation)
    local tempX = newX
    newX = tempX * math.cos(-rotY/180*math.pi) - newZ * math.sin(-rotY/180*math.pi)
    newZ = tempX * math.sin(-rotY/180*math.pi) + newZ * math.cos(-rotY/180*math.pi)

    -- Atomic assignment of final position
    self.weaponLocation.x = newX
    self.weaponLocation.y = newY
    self.weaponLocation.z = newZ
    
    return true
end

return {
    LeftHandLocationGesture = LeftHandLocationGesture,
    RightHandLocationGesture = RightHandLocationGesture,
    LeftHandRelativeToRightLocationGesture = LeftHandRelativeToRightLocationGesture,
    RightHandRelativeToLeftLocationGesture = RightHandRelativeToLeftLocationGesture
}