local GestureController = {
    -- Configuration
    HapticFeedback = true,
    SeatedOffset = 0,
    isRhand = true,
    
    -- State tracking
    RZone = 0,
    LZone = 0,
    RWeaponZone = 0,
    LWeaponZone = 0,
    
    -- Hand positions and rotations
    RHandLocation = Vector3f.new(0, 0, 0),
    LHandLocation = Vector3f.new(0, 0, 0),
    HmdLocation = Vector3f.new(0, 0, 0),
    RHandRotation = Vector3f.new(0, 0, 0),
    LHandRotation = Vector3f.new(0, 0, 0),
    HmdRotation = Vector3f.new(0, 0, 0),
    
    -- Transformed coordinates
    RHandNewX = 0, 
    RHandNewY = 0,
    RHandNewZ = 0,
    LHandNewX = 0,
    LHandNewY = 0,
    LHandNewZ = 0,
    
    -- Weapon-relative hand positions
    LHandWeaponX = 0,
    LHandWeaponY = 0,
    LHandWeaponZ = 0,
    RHandWeaponX = 0,
    RHandWeaponY = 0,
    RHandWeaponZ = 0,
    
    -- Haptic feedback tracking
    isHapticZoneR = false,
    isHapticZoneL = false,
    isHapticZoneWR = false,
    isHapticZoneWL = false,
    isHapticZoneRLast = false,
    isHapticZoneLLast = false,
    isHapticZoneWRLast = false,
    isHapticZoneWLLast = false,
    
    -- Controllers
    LeftController = nil,
    RightController = nil,
    RightJoystickIndex = nil,
    RAxis = nil,
    
    -- References
    motionControllers = nil
}

-- Initialize the GestureController
function GestureController:Init(motionControllers, config)
    self.motionControllers = motionControllers
    
    -- Apply configuration if provided
    if config then
        if config.HapticFeedback ~= nil then self.HapticFeedback = config.HapticFeedback end
        if config.SeatedOffset ~= nil then self.SeatedOffset = config.SeatedOffset end
        if config.isRhand ~= nil then self.isRhand = config.isRhand end
    end
    
    -- Get controller references for haptic feedback
    self.LeftController = uevr.params.vr.get_left_joystick_source()
    self.RightController = uevr.params.vr.get_right_joystick_source()
    self.RightJoystickIndex = uevr.params.vr.get_right_joystick_source()
    self.RAxis = UEVR_Vector2f.new()
    
    print("GestureController initialized")
    return true
end

-- Reset controller state
function GestureController:Reset()
    self.RZone = 0
    self.LZone = 0
    self.RWeaponZone = 0
    self.LWeaponZone = 0
    self.isHapticZoneR = false
    self.isHapticZoneL = false
    self.isHapticZoneWR = false
    self.isHapticZoneWL = false
    
    print("GestureController reset")
    return true
end

-- Get joystick vertical axis value
function GestureController:GetJoystickVerticalAxis(isRightHand, isLeftHandModeTriggerSwitchOnly)
    if isRightHand or isLeftHandModeTriggerSwitchOnly then
        uevr.params.vr.get_joystick_axis(self.RightJoystickIndex, self.RAxis)
    else
        uevr.params.vr.get_joystick_axis(self.LeftController, self.RAxis)
    end
    return self.RAxis.y
end

-- Update all zones based on the current motion controller states
function GestureController:Update()
    -- Get current positions and rotations
    self.RHandLocation = self.motionControllers:GetLocationByIndex(2) -- Right hand
    self.LHandLocation = self.motionControllers:GetLocationByIndex(1) -- Left hand
    self.HmdLocation = self.motionControllers:GetLocationByIndex(0)   -- HMD
    
    self.RHandRotation = self.motionControllers:GetRotationByIndex(2) -- Right hand
    self.LHandRotation = self.motionControllers:GetRotationByIndex(1) -- Left hand
    self.HmdRotation = self.motionControllers:GetRotationByIndex(0)   -- HMD
    
    -- Ensure we have valid positions
    if not self.RHandLocation or not self.LHandLocation or not self.HmdLocation then
        return false
    end
    
    -- Calculate HMD-relative positions
    self:CalculateHandPositions()
    
    -- Update haptic zones
    self:UpdateBodyZones()
    self:UpdateWeaponZones()
    
    -- Process haptic feedback if enabled
    if self.HapticFeedback then
        self:ProcessHapticFeedback()
    end
    
    return true
end

-- Calculate hand positions relative to HMD and each other
function GestureController:CalculateHandPositions()
    -- Y IS LEFT RIGHT, X IS BACK FORWARD, Z IS DOWN UP
    local RotDiff = self.HmdRotation.y
    
    -- Calculate left hand position relative to HMD
    self.LHandNewX = (self.LHandLocation.x - self.HmdLocation.x) * math.cos(-RotDiff/180*math.pi) - 
                     (self.LHandLocation.y - self.HmdLocation.y) * math.sin(-RotDiff/180*math.pi)
    
    self.LHandNewY = (self.LHandLocation.x - self.HmdLocation.x) * math.sin(-RotDiff/180*math.pi) + 
                     (self.LHandLocation.y - self.HmdLocation.y) * math.cos(-RotDiff/180*math.pi)
    
    -- Calculate right hand position relative to HMD
    self.RHandNewX = (self.RHandLocation.x - self.HmdLocation.x) * math.cos(-RotDiff/180*math.pi) - 
                     (self.RHandLocation.y - self.HmdLocation.y) * math.sin(-RotDiff/180*math.pi)
    
    self.RHandNewY = (self.RHandLocation.x - self.HmdLocation.x) * math.sin(-RotDiff/180*math.pi) + 
                     (self.RHandLocation.y - self.HmdLocation.y) * math.cos(-RotDiff/180*math.pi)
    
    self.RHandNewZ = self.RHandLocation.z - self.HmdLocation.z
    self.LHandNewZ = self.LHandLocation.z - self.HmdLocation.z
    
    -- For R Handed - z,yaw Rotation
    local RotWeaponZ = self.RHandRotation.y
    self.LHandWeaponX = (self.LHandLocation.x - self.RHandLocation.x) * math.cos(-RotWeaponZ/180*math.pi) - 
                        (self.LHandLocation.y - self.RHandLocation.y) * math.sin(-RotWeaponZ/180*math.pi)
    
    self.LHandWeaponY = (self.LHandLocation.x - self.RHandLocation.x) * math.sin(-RotWeaponZ/180*math.pi) + 
                        (self.LHandLocation.y - self.RHandLocation.y) * math.cos(-RotWeaponZ/180*math.pi)
    
    self.LHandWeaponZ = (self.LHandLocation.z - self.RHandLocation.z)
    
    -- x, Roll Rotation
    local RotWeaponX = self.RHandRotation.z
    self.LHandWeaponY = self.LHandWeaponY * math.cos(RotWeaponX/180*math.pi) - 
                        self.LHandWeaponZ * math.sin(RotWeaponX/180*math.pi)
    
    self.LHandWeaponZ = self.LHandWeaponY * math.sin(RotWeaponX/180*math.pi) + 
                        self.LHandWeaponZ * math.cos(RotWeaponX/180*math.pi)
    
    -- y, Pitch Rotation
    local RotWeaponY = self.RHandRotation.x
    self.LHandWeaponX = self.LHandWeaponX * math.cos(-RotWeaponY/180*math.pi) - 
                        self.LHandWeaponZ * math.sin(-RotWeaponY/180*math.pi)
    
    self.LHandWeaponZ = self.LHandWeaponX * math.sin(-RotWeaponY/180*math.pi) + 
                        self.LHandWeaponZ * math.cos(-RotWeaponY/180*math.pi)
    
    -- For LEFT hand - z,yaw Rotation
    local RotWeaponLZ = self.LHandRotation.y
    self.RHandWeaponX = (self.RHandLocation.x - self.LHandLocation.x) * math.cos(-RotWeaponLZ/180*math.pi) - 
                        (self.RHandLocation.y - self.LHandLocation.y) * math.sin(-RotWeaponLZ/180*math.pi)
    
    self.RHandWeaponY = (self.RHandLocation.x - self.LHandLocation.x) * math.sin(-RotWeaponLZ/180*math.pi) + 
                        (self.RHandLocation.y - self.LHandLocation.y) * math.cos(-RotWeaponLZ/180*math.pi)
    
    self.RHandWeaponZ = (self.RHandLocation.z - self.LHandLocation.z)
    
    -- x, Roll Rotation
    local RotWeaponLX = self.LHandRotation.z
    self.RHandWeaponY = self.RHandWeaponY * math.cos(RotWeaponLX/180*math.pi) - 
                        self.RHandWeaponZ * math.sin(RotWeaponLX/180*math.pi)
    
    self.RHandWeaponZ = self.RHandWeaponY * math.sin(RotWeaponLX/180*math.pi) + 
                        self.RHandWeaponZ * math.cos(RotWeaponLX/180*math.pi)
    
    -- y, Pitch Rotation
    local RotWeaponLY = self.LHandRotation.x
    self.RHandWeaponX = self.RHandWeaponX * math.cos(-RotWeaponLY/180*math.pi) - 
                        self.RHandWeaponZ * math.sin(-RotWeaponLY/180*math.pi)
    
    self.RHandWeaponZ = self.RHandWeaponX * math.sin(-RotWeaponLY/180*math.pi) + 
                        self.RHandWeaponZ * math.cos(-RotWeaponLY/180*math.pi)
end

-- Update body-relative zones (shoulders, hip, etc)
function GestureController:UpdateBodyZones()
    -- Check right hand zones
    if self:RCheckZone(-10, 15, 10, 30, -10, 20 + self.SeatedOffset) then 
        self.isHapticZoneR = true
        self.RZone = 1 -- RShoulder
    elseif self:RCheckZone(-10, 15, -30, -10, -10, 20 + self.SeatedOffset) then
        self.isHapticZoneR = true
        self.RZone = 2 -- Left Shoulder
    elseif self:RCheckZone(0, 20, -5, 5, 0, 20 + self.SeatedOffset) then
        self.isHapticZoneR = true
        self.RZone = 3 -- Over Head
    elseif self:RCheckZone(-100, -60, 22, 50, -10, 10 + self.SeatedOffset) then
        self.isHapticZoneR = true
        self.RZone = 4 -- RHip
    elseif self:RCheckZone(-100, -50, -30, 5, -10, 30 + self.SeatedOffset) then
        self.isHapticZoneR = true
        self.RZone = 5 -- LHip
    elseif self:RCheckZone(-40, -25, -15, -5, 0, 10 + self.SeatedOffset) then
        self.isHapticZoneR = true
        self.RZone = 6 -- ChestLeft
    elseif self:RCheckZone(-40, -25, 5, 15, 0, 10 + self.SeatedOffset) then
        self.isHapticZoneR = true
        self.RZone = 7 -- ChestRight
    elseif self:RCheckZone(-100, -50, -20, 20, -30, -15) then
        self.isHapticZoneR = true
        self.RZone = 8 -- LowerBack Center
    elseif self:RCheckZone(-5, 10, -10, 0, 0, 10) then
        self.isHapticZoneR = true
        self.RZone = 9 -- LeftEar
    elseif self:RCheckZone(-5, 10, 0, 10, 0, 10) then
        self.isHapticZoneR = true
        self.RZone = 10 -- RightEar
    else 
        self.isHapticZoneR = false
        self.RZone = 0 -- EMPTY
    end
    
    -- Check left hand zones
    if self:LCheckZone(-10, 15, 10, 30, -10, 20 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 1 -- RShoulder
    elseif self:LCheckZone(-10, 15, -30, -10, -10, 20 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 2 -- Left Shoulder
    elseif self:LCheckZone(0, 30, -5, 5, 0, 20 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 3 -- Over Head
    elseif self:LCheckZone(-100, -50, -5, 50, -10, 30 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 4 -- RPouch
    elseif self:LCheckZone(-100, -60, -50, -10, -10, 10 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 5 -- LPouch
    elseif self:LCheckZone(-40, -25, -15, -5, 0, 10 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 6 -- ChestLeft
    elseif self:LCheckZone(-40, -25, 5, 15, 0, 10 + self.SeatedOffset) then
        self.isHapticZoneL = true
        self.LZone = 7 -- ChestRight
    elseif self:LCheckZone(-100, -50, -20, 20, -30, -15) then
        self.isHapticZoneL = true
        self.LZone = 8 -- LowerBack Center
    elseif self:LCheckZone(-5, 10, -10, 0, 0, 10) then
        self.isHapticZoneL = true
        self.LZone = 9 -- LeftEar
    elseif self:LCheckZone(-5, 10, 0, 10, 0, 10) then
        self.isHapticZoneL = true
        self.LZone = 10 -- RightEar
    else 
        self.isHapticZoneL = false
        self.LZone = 0 -- EMPTY
    end
end

-- Update weapon-relative zones
function GestureController:UpdateWeaponZones()
    if self.isRhand then
        -- Right hand is weapon hand
        if self.LHandWeaponZ < -5 and self.LHandWeaponZ > -30 and 
           self.LHandWeaponX < 20 and self.LHandWeaponX > -15 and 
           self.LHandWeaponY < 12 and self.LHandWeaponY > -12 then
            self.isHapticZoneWL = true
            self.RWeaponZone = 1 -- below gun, e.g. mag reload
        elseif self.LHandWeaponZ < 10 and self.LHandWeaponZ > 0 and 
               self.LHandWeaponX < 10 and self.LHandWeaponX > -5 and 
               self.LHandWeaponY < 12 and self.LHandWeaponY > -12 then
            self.isHapticZoneWL = true
            self.RWeaponZone = 2 -- close above RHand, e.g. WeaponModeSwitch
        elseif self.LHandWeaponZ < 25 and self.LHandWeaponZ > 0 and 
               self.LHandWeaponX < 45 and self.LHandWeaponX > 15 and 
               self.LHandWeaponY < 15 and self.LHandWeaponY > -15 then
            self.isHapticZoneWL = true
            self.RWeaponZone = 3 -- Front at barrel l, e.g. Attachement
        else
            self.RWeaponZone = 0
            self.isHapticZoneWL = false
        end
    else
        -- Left hand is weapon hand
        if self.RHandWeaponZ < -5 and self.RHandWeaponZ > -30 and 
           self.RHandWeaponX < 20 and self.RHandWeaponX > -5 and 
           self.RHandWeaponY < 12 and self.RHandWeaponY > -12 then
            self.isHapticZoneWR = true
            self.LWeaponZone = 1 -- below gun, e.g. mag reload
        elseif self.RHandWeaponZ < 10 and self.RHandWeaponZ > 0 and 
               self.RHandWeaponX < 10 and self.RHandWeaponX > -5 and 
               self.RHandWeaponY < 12 and self.RHandWeaponY > -12 then
            self.isHapticZoneWR = true
            self.LWeaponZone = 2 -- close above RHand, e.g. WeaponModeSwitch
        elseif self.RHandWeaponZ < 25 and self.RHandWeaponZ > 0 and 
               self.RHandWeaponX < 45 and self.RHandWeaponX > 15 and 
               self.RHandWeaponY < 12 and self.RHandWeaponY > -12 then
            self.isHapticZoneWR = true
            self.LWeaponZone = 3 -- Front at barrel l, e.g. Attachement
        else
            self.LWeaponZone = 0
            self.isHapticZoneWR = false
        end
    end
end

-- Process haptic feedback for zone transitions
function GestureController:ProcessHapticFeedback()
    if self.isHapticZoneRLast ~= self.isHapticZoneR then
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, self.RightController)
        self.isHapticZoneRLast = self.isHapticZoneR
    end
    
    if self.isHapticZoneLLast ~= self.isHapticZoneL then
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, self.LeftController)
        self.isHapticZoneLLast = self.isHapticZoneL
    end
    
    if self.isHapticZoneWRLast ~= self.isHapticZoneWR then
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, self.RightController)
        self.isHapticZoneWRLast = self.isHapticZoneWR
    end
    
    if self.isHapticZoneWLLast ~= self.isHapticZoneWL then
        uevr.params.vr.trigger_haptic_vibration(0.0, 0.1, 1.0, 100.0, self.LeftController)
        self.isHapticZoneWLLast = self.isHapticZoneWL
    end
end

-- Check if right hand is in a specific zone
function GestureController:RCheckZone(Zmin, Zmax, Ymin, Ymax, Xmin, Xmax)
    if self.RHandNewZ > Zmin and self.RHandNewZ < Zmax and 
       self.RHandNewY > Ymin and self.RHandNewY < Ymax and 
       self.RHandNewX > Xmin and self.RHandNewX < Xmax then
        return true
    else 
        return false
    end
end

-- Check if left hand is in a specific zone
function GestureController:LCheckZone(Zmin, Zmax, Ymin, Ymax, Xmin, Xmax)
    if self.LHandNewZ > Zmin and self.LHandNewZ < Zmax and 
       self.LHandNewY > Ymin and self.LHandNewY < Ymax and 
       self.LHandNewX > Xmin and self.LHandNewX < Xmax then
        return true
    else 
        return false
    end
end

-- Create a new instance
function GestureController:new(motionControllers, config)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance:Init(motionControllers, config)
    return instance
end

return GestureController
