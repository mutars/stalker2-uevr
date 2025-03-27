local GestureBase = require("artifact.scripts.gestures.GestureBase")

-- Base Motion Controller Gesture class
local MotionControllerGesture = GestureBase:new({
    name = "Motion Controller Base",
    controllerIndex = 0,
    location = Vector3f.new(0, 0, 0),
    rotation = Vector3f.new(0, 0, 0),
    pastLocation = Vector3f.new(0, 0, 0),
    pastRotation = Vector3f.new(0, 0, 0)
})

function MotionControllerGesture:EvaluateInternal(context)
    if not context or not context.motionControllers then
        return false
    end
    
    -- Store past values
    self.pastLocation = Vector3f.new(self.location.x, self.location.y, self.location.z)
    self.pastRotation = Vector3f.new(self.rotation.x, self.rotation.y, self.rotation.z)
    
    -- Get current position and rotation
    self.location = context.motionControllers:GetLocationByIndex(self.controllerIndex)
    self.rotation = context.motionControllers:GetRotationByIndex(self.controllerIndex)
    
    return self.location ~= nil and self.rotation ~= nil
end

-- Left Motion Controller Gesture
local LeftMotionControllerGesture = MotionControllerGesture:new({
    name = "Left Motion Controller",
    controllerIndex = 1
})

-- Right Motion Controller Gesture
local RightMotionControllerGesture = MotionControllerGesture:new({
    name = "Right Motion Controller",
    controllerIndex = 2
})

-- HMD Gesture
local HMDGesture = MotionControllerGesture:new({
    name = "HMD",
    controllerIndex = 0
})

-- Base Joystick State Gesture class
local MotionControllerJoystickState = GestureBase:new({
    name = "Joystick State Base",
    controllerIndex = 0,
    triggerHandle = nil,
    gripHandle = nil,
    isInitialized = false,
    
    -- Current states
    triggerActive = false,
    gripActive = false,
    
    -- Past states
    wasTriggerActive = false,
    wasGripActive = false
})

function MotionControllerJoystickState:InitHandles()
    if not self.isInitialized then
        self.triggerHandle = uevr.params.vr.get_action_handle("/actions/default/in/Trigger")
        self.gripHandle = uevr.params.vr.get_action_handle("/actions/default/in/Grip")
        self.isInitialized = true
    end
end

function MotionControllerJoystickState:EvaluateInternal(context)
    if not context then
        return false
    end
    
    self:InitHandles()
    
    -- Store past states
    self.wasTriggerActive = self.triggerActive
    self.wasGripActive = self.gripActive
    
    -- Get controller source based on index
    local controller
    if self.controllerIndex == 1 then
        controller = uevr.params.vr.get_left_joystick_source()
    else
        controller = uevr.params.vr.get_right_joystick_source()
    end
    
    -- Update button states
    self.triggerActive = uevr.params.vr.is_action_active(self.triggerHandle, controller)
    self.gripActive = uevr.params.vr.is_action_active(self.gripHandle, controller)
    
    -- Gesture is considered active if any button is pressed
    return self.triggerActive or self.gripActive
end

-- Helper functions for state transitions
function MotionControllerJoystickState:TriggerJustPressed()
    return self.triggerActive and not self.wasTriggerActive
end

function MotionControllerJoystickState:TriggerJustReleased()
    return not self.triggerActive and self.wasTriggerActive
end

function MotionControllerJoystickState:GripJustPressed()
    return self.gripActive and not self.wasGripActive
end

function MotionControllerJoystickState:GripJustReleased()
    return not self.gripActive and self.wasGripActive
end

function MotionControllerJoystickState:Reset()
    GestureBase.Reset(self)
    self.triggerActive = false
    self.gripActive = false
    self.wasTriggerActive = false
    self.wasGripActive = false
end

-- Left Controller Joystick State
local LeftJoystickState = MotionControllerJoystickState:new({
    name = "Left Joystick State",
    controllerIndex = 1
})

-- Right Controller Joystick State
local RightJoystickState = MotionControllerJoystickState:new({
    name = "Right Joystick State",
    controllerIndex = 2
})

return {
    LeftMotionControllerGesture = LeftMotionControllerGesture,
    RightMotionControllerGesture = RightMotionControllerGesture,
    HMDGesture = HMDGesture,
    LeftJoystickState = LeftJoystickState,
    RightJoystickState = RightJoystickState
}