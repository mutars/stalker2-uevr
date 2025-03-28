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
local MotionControllerAction = GestureBase:new({
    name = "Joystick Action",
    controllerIndex = 0,
    handle_name = "",
    handle = nil,
    controller = nil,
    isInitialized = false,
    
    actionState = false,
    pastActionState = false
})

function MotionControllerAction:InitHandle()
    if not self.isInitialized and self.handle_name then
        self.handle = uevr.params.vr.get_action_handle(self.handle_name)
        if self.controllerIndex == 1 then
            self.controller = uevr.params.vr.get_left_joystick_source()
        else
            self.controller = uevr.params.vr.get_right_joystick_source()
        end

        -- self.handle = uevr.params.vr.get_action_handle("/actions/default/in/Trigger")
        -- self.gripHandle = uevr.params.vr.get_action_handle("/actions/default/in/Grip")
        self.isInitialized = true
    end
end

function MotionControllerAction:EvaluateInternal(context)
    if not context or not self.handle or not self.controller then
        return false
    end
    
    self:InitHandle()
    
    -- Store past states
    self.pastActionState = self.actionState
    
    -- Update button states
    self.actionState = uevr.params.vr.is_action_active(self.handle, self.controller)
    
    -- Gesture is considered active if any button is pressed
    return self.actionState
end

-- Helper functions for state transitions
function MotionControllerAction:HasActivated()
    return self.actionState and not self.pastActionState
end

function MotionControllerAction:HasDeactivated()
    return not self.actionState and self.pastActionState
end

function MotionControllerAction:Reset()
    GestureBase.Reset(self)
    self.actionState = false
    self.pastActionState = false
    self.handle = nil
    self.controller = nil
    self.isInitialized = false
end

local LeftGripAction = MotionControllerAction:new({
    name = "Left Grip Action",
    controllerIndex = 1,
    handle_name = "/actions/default/in/Grip"
})

function LeftGripAction:Execute(context)
    if self:IsLocked() then
        context.gamepad:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER) -- XINPUT_GAMEPAD_LEFT_SHOULDER
    end
end

local RightGripAction = MotionControllerAction:new({
    name = "Right Grip Action",
    controllerIndex = 2,
    handle_name = "/actions/default/in/Grip"
})

function RightGripAction:Execute(context)
    if self:IsLocked() then
        context.gamepad:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER) -- XINPUT_GAMEPAD_RIGHT_SHOULDER
    end
end

local LeftTriggerAction = MotionControllerAction:new({
    name = "Left Trigger Action",
    controllerIndex = 1,
    handle_name = "/actions/default/in/Trigger"
})

function LeftTriggerAction:Execute(context)
    if self:IsLocked() then
        context.gamepad:unpressButton(XINPUT_GAMEPAD_LEFT_TRIGGER) -- XINPUT_GAMEPAD_LEFT_TRIGGER
    end
end

local RightTriggerAction = MotionControllerAction:new({
    name = "Right Trigger Action",
    controllerIndex = 2,
    handle_name = "/actions/default/in/Trigger"
})

function RightTriggerAction:Execute(context)
    if self:IsLocked() then
        context.gamepad:unpressButton(XINPUT_GAMEPAD_RIGHT_TRIGGER) -- XINPUT_GAMEPAD_RIGHT_TRIGGER
    end
end

return {
    LeftMotionControllerGesture = LeftMotionControllerGesture,
    RightMotionControllerGesture = RightMotionControllerGesture,
    HMDGesture = HMDGesture,
    LeftGripAction = LeftGripAction,
    RightGripAction = RightGripAction,
    LeftTriggerAction = LeftTriggerAction,
    RightTriggerAction = RightTriggerAction
}