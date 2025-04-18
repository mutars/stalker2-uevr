local MotionControllerGestures = require("gestures.motioncontrollergestures")

-- XInputState class to manage controller state
GamepadState = {
    -- State properties
    gamepadState = nil,
    leftGripAction = nil,
    rightGripAction = nil
}

-- Constructor
function GamepadState:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance.leftGripAction = MotionControllerGestures.LeftGripAction
    instance.rightGripAction = MotionControllerGestures.RightGripAction
    return instance
end

-- Update state from XInput
function GamepadState:Update(state)
    self.gamepadState = state
    if self.leftGripAction:IsLocked() then
        self:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
    end
    if self.rightGripAction:IsLocked() then
        self:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
    end
    local LTrigger= state.Gamepad.bLeftTrigger
	local RTrigger= state.Gamepad.bRightTrigger
	local rShoulder = self:isButtonPressed(XINPUT_GAMEPAD_RIGHT_SHOULDER)
	local lShoulder = self:isButtonPressed(XINPUT_GAMEPAD_LEFT_SHOULDER)
    if lShoulder then
        self:setLeftTrigger(255)
    else
        self:setLeftTrigger(0)
    end
    self:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
    if RTrigger > 125 then
        self:pressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
    else
        self:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
    end
    self:setRightTrigger(LTrigger)



end

-- Reset key state variables (does not modify gamepad state)
function GamepadState:Reset()
    self.gamepadState = nil
end

function GamepadState:isButtonPressed(button)
    if not self.gamepadState then
        return false
    end
    return self.gamepadState.Gamepad.wButtons & button ~= 0
end

function GamepadState:isButtonNotPressed(button)
    if not self.gamepadState then
        return false
    end
    return self.gamepadState.Gamepad.wButtons & button == 0
end

function GamepadState:pressButton(button)
    if self.gamepadState then
        self.gamepadState.Gamepad.wButtons = self.gamepadState.Gamepad.wButtons | button
    end
end

function GamepadState:unpressButton(button)
    if self.gamepadState then
        self.gamepadState.Gamepad.wButtons = self.gamepadState.Gamepad.wButtons & ~(button)
    end
end

function GamepadState:setThumbLX(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbLX = value
    end
end

function GamepadState:setThumbLY(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbLY = value
    end
end

function GamepadState:setThumbRX(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbRX = value
    end
end

function GamepadState:setThumbRY(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbRY = value
    end
end

function GamepadState:setLeftTrigger(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.bLeftTrigger = value
    end
end

function GamepadState:setRightTrigger(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.bRightTrigger = value
    end
end

local gamepadState = GamepadState:new()

return gamepadState
