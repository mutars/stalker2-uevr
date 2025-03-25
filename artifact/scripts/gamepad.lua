-- XInputState class to manage controller state
InputSessionState = {
    rGrabActive =false,
    lGrabActive =false,
    LZone=0,
    ThumbLX   = 0,
    ThumbLY   = 0,
    ThumbRX   = 0,
    ThumbRY   = 0,
    LTrigger  = 0,
    RTrigger  = 0,
    rShoulder = false,
    lShoulder = false,
    lThumb    = false,
    rThumb    = false,
    lThumbSwitchState= 0,
    lThumbOut= false,
    rThumbSwitchState= 0,
    rThumbOut= false,
    isReloading= false,
    ReadyUpTick = 0,
    RZone=0,
    LWeaponZone=0,
    RWeaponZone=0,
    inMenu=false,
    LTriggerWasPressed = 0,
    RTriggerWasPressed = 0,
    isFlashlightToggle =false,
    isButtonA =false,
    isButtonB  =false,
    isButtonX =false,
    isButtonY  =false,
    isRShoulder=false,
    isCrouch = false,
    StanceButton= false,
    isJournal=0,
    GrenadeReady=false,
    KeyG=false,
    KeyM=false,
    KeyF=false,
    KeyB=false,
    KeyI=false,
    KeySpace=false,
    KeyCtrl=false,
    vecy=0,
    isJump=false,
    isInventoryPDA=false,
    LastWorldTime= 0.000,
    WorldTime=0.000,
    isRShoulderHeadR= false,
    isRShoulderHeadL= false,
    -- State properties
    gamepadState = nil
}

-- Constructor
function InputSessionState:new()
    local instance = {}
    setmetatable(instance, { __index = InputSessionState })
    return instance
end

-- Update state from XInput
function InputSessionState:updateXInputState(state)
    self.gamepadState = state
	ThumbLX = self.gamepadState.sThumbLX
	ThumbLY = self.gamepadState.sThumbLY
	ThumbRX = self.gamepadState.sThumbRX
	ThumbRY = self.gamepadState.sThumbRY
	LTrigger= self.gamepadState.bLeftTrigger
	RTrigger= self.gamepadState.bRightTrigger
	rShoulder= isButtonPressed(XINPUT_GAMEPAD_RIGHT_SHOULDER)
	lShoulder= isButtonPressed(XINPUT_GAMEPAD_LEFT_SHOULDER)
	lThumb   = isButtonPressed(XINPUT_GAMEPAD_LEFT_THUMB)
	rThumb   = isButtonPressed(XINPUT_GAMEPAD_RIGHT_THUMB)
	Abutton  = isButtonPressed(XINPUT_GAMEPAD_A)
	Bbutton  = isButtonPressed(XINPUT_GAMEPAD_B)
	Xbutton  = isButtonPressed(XINPUT_GAMEPAD_X)
	Ybutton  = isButtonPressed(XINPUT_GAMEPAD_Y)
end

function InputSessionState:isButtonPressed(button)
    if not self.gamepadState then
        return false
    end
    return self.gamepadState.Gamepad.wButtons & button ~= 0
end

function InputSessionState:isButtonNotPressed(button)
    if not self.gamepadState then
        return false
    end
    return self.gamepadState.Gamepad.wButtons & button == 0
end

function InputSessionState:pressButton(button)
    if self.gamepadState then
        self.gamepadState.Gamepad.wButtons = self.gamepadState.Gamepad.wButtons | button
    end
end

function InputSessionState:unpressButton(button)
    if self.gamepadState then
        self.gamepadState.Gamepad.wButtons = self.gamepadState.Gamepad.wButtons & ~(button)
    end
end

function InputSessionState:setThumbLX(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbLX = value
    end
end

function InputSessionState:setThumbLY(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbLY = value
    end
end

function InputSessionState:setThumbRX(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbRX = value
    end
end

function InputSessionState:setThumbRY(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.sThumbRY = value
    end
end

function InputSessionState:setLeftTrigger(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.bLeftTrigger = value
    end
end

function InputSessionState:setRightTrigger(value)
    if self.gamepadState then
        self.gamepadState.Gamepad.bRightTrigger = value
    end
end

function InputSessionState:switch_lh_layout()
    -- Updated to use self references for all button operations
    self:setThumbRX(self.ThumbLX)
    self:setThumbRY(self.ThumbLY)
    self:setThumbLX(self.ThumbRX)
    self:setThumbLY(self.ThumbRY)
    self:setLeftTrigger(self.RTrigger)
    self:setRightTrigger(self.LTrigger)
    self:unpressButton(XINPUT_GAMEPAD_B)
    self:unpressButton(XINPUT_GAMEPAD_A)
    self:unpressButton(XINPUT_GAMEPAD_X)
    self:unpressButton(XINPUT_GAMEPAD_Y)
    self:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
    self:unpressButton(XINPUT_GAMEPAD_LEFT_THUMB)
    self:unpressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
    
    if self.Ybutton then
        self:pressButton(XINPUT_GAMEPAD_X)
    end
    if self.Bbutton then
        self:pressButton(XINPUT_GAMEPAD_A)
    end
    if self.Xbutton then
        self:pressButton(XINPUT_GAMEPAD_Y)
    end
    if self.Abutton then
        self:pressButton(XINPUT_GAMEPAD_B)
    end
    
    if self.lShoulder then
        self:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
    end
    if self.rShoulder then
        self:pressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
    end
    if self.lThumb then
        self:pressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
    end
    if self.rThumb then
        self:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
    end
end

