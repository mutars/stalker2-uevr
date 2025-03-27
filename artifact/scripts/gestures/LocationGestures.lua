local GestureBase = require("artifact.scripts.gestures.GestureBase")

-- Base Location Gesture class
local LocationGestureBase = GestureBase:new({
    name = "Location Gesture Base",
    location = Vector3f.new(0, 0, 0),
    rotation = Vector3f.new(0, 0, 0),
    weaponLocation = Vector3f.new(0, 0, 0)
})

-- Left Hand Location Gesture
local LeftHandLocationGesture = LocationGestureBase:new({
    name = "Left Hand Location"
})

function LeftHandLocationGesture:EvaluateInternal(context)
    local leftHand = self.dependencies[1]
    local hmd = self.dependencies[2]
    
    if not leftHand.isActive or not hmd.isActive then
        return false
    end

    -- Calculate HMD-relative position
    local rotDiff = hmd.rotation.y
    local dx = leftHand.location.x - hmd.location.x
    local dy = leftHand.location.y - hmd.location.y
    
    self.location.x = dx * math.cos(-rotDiff/180*math.pi) - dy * math.sin(-rotDiff/180*math.pi)
    self.location.y = dx * math.sin(-rotDiff/180*math.pi) + dy * math.cos(-rotDiff/180*math.pi)
    self.location.z = leftHand.location.z - hmd.location.z
    
    return true
end

-- Right Hand Location Gesture
local RightHandLocationGesture = LocationGestureBase:new({
    name = "Right Hand Location"
})

function RightHandLocationGesture:EvaluateInternal(context)
    local rightHand = self.dependencies[1]
    local hmd = self.dependencies[2]
    
    if not rightHand.isActive or not hmd.isActive then
        return false
    end

    -- Calculate HMD-relative position
    local rotDiff = hmd.rotation.y
    local dx = rightHand.location.x - hmd.location.x
    local dy = rightHand.location.y - hmd.location.y
    
    self.location.x = dx * math.cos(-rotDiff/180*math.pi) - dy * math.sin(-rotDiff/180*math.pi)
    self.location.y = dx * math.sin(-rotDiff/180*math.pi) + dy * math.cos(-rotDiff/180*math.pi)
    self.location.z = rightHand.location.z - hmd.location.z
    
    return true
end

-- Left Hand Weapon Location Gesture
local LeftHandWeaponLocationGesture = LocationGestureBase:new({
    name = "Left Hand Weapon Location"
})

function LeftHandWeaponLocationGesture:EvaluateInternal(context)
    local leftHand = self.dependencies[1]
    local rightHand = self.dependencies[2]
    
    if not leftHand.isActive or not rightHand.isActive then
        return false
    end

    -- Calculate right-hand-relative position with rotations
    local rotZ = rightHand.rotation.y
    local rotX = rightHand.rotation.z
    local rotY = rightHand.rotation.x
    
    local dx = leftHand.location.x - rightHand.location.x
    local dy = leftHand.location.y - rightHand.location.y
    local dz = leftHand.location.z - rightHand.location.z

    -- Apply rotations in sequence (yaw, roll, pitch)
    -- Yaw (Z rotation)
    self.weaponLocation.x = dx * math.cos(-rotZ/180*math.pi) - dy * math.sin(-rotZ/180*math.pi)
    self.weaponLocation.y = dx * math.sin(-rotZ/180*math.pi) + dy * math.cos(-rotZ/180*math.pi)
    self.weaponLocation.z = dz

    -- Roll (X rotation)
    local tempY = self.weaponLocation.y
    self.weaponLocation.y = tempY * math.cos(rotX/180*math.pi) - self.weaponLocation.z * math.sin(rotX/180*math.pi)
    self.weaponLocation.z = tempY * math.sin(rotX/180*math.pi) + self.weaponLocation.z * math.cos(rotX/180*math.pi)

    -- Pitch (Y rotation)
    local tempX = self.weaponLocation.x
    self.weaponLocation.x = tempX * math.cos(-rotY/180*math.pi) - self.weaponLocation.z * math.sin(-rotY/180*math.pi)
    self.weaponLocation.z = tempX * math.sin(-rotY/180*math.pi) + self.weaponLocation.z * math.cos(-rotY/180*math.pi)
    
    return true
end

-- Right Hand Weapon Location Gesture
local RightHandWeaponLocationGesture = LocationGestureBase:new({
    name = "Right Hand Weapon Location"
})

function RightHandWeaponLocationGesture:EvaluateInternal(context)
    local rightHand = self.dependencies[1]
    local leftHand = self.dependencies[2]
    
    if not rightHand.isActive or not leftHand.isActive then
        return false
    end

    -- Calculate left-hand-relative position with rotations
    local rotZ = leftHand.rotation.y
    local rotX = leftHand.rotation.z
    local rotY = leftHand.rotation.x
    
    local dx = rightHand.location.x - leftHand.location.x
    local dy = rightHand.location.y - leftHand.location.y
    local dz = rightHand.location.z - leftHand.location.z

    -- Apply rotations in sequence (yaw, roll, pitch)
    -- Yaw (Z rotation)
    self.weaponLocation.x = dx * math.cos(-rotZ/180*math.pi) - dy * math.sin(-rotZ/180*math.pi)
    self.weaponLocation.y = dx * math.sin(-rotZ/180*math.pi) + dy * math.cos(-rotZ/180*math.pi)
    self.weaponLocation.z = dz

    -- Roll (X rotation)
    local tempY = self.weaponLocation.y
    self.weaponLocation.y = tempY * math.cos(rotX/180*math.pi) - self.weaponLocation.z * math.sin(rotX/180*math.pi)
    self.weaponLocation.z = tempY * math.sin(rotX/180*math.pi) + self.weaponLocation.z * math.cos(rotX/180*math.pi)

    -- Pitch (Y rotation)
    local tempX = self.weaponLocation.x
    self.weaponLocation.x = tempX * math.cos(-rotY/180*math.pi) - self.weaponLocation.z * math.sin(-rotY/180*math.pi)
    self.weaponLocation.z = tempX * math.sin(-rotY/180*math.pi) + self.weaponLocation.z * math.cos(-rotY/180*math.pi)
    
    return true
end

return {
    LeftHandLocationGesture = LeftHandLocationGesture,
    RightHandLocationGesture = RightHandLocationGesture,
    LeftHandWeaponLocationGesture = LeftHandWeaponLocationGesture,
    RightHandWeaponLocationGesture = RightHandWeaponLocationGesture
}