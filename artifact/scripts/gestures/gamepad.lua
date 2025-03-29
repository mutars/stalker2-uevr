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
    gamepadState = nil,
    
    -- Additional non-gamepad state for holstering system
    Key1 = false,
    Key2 = false,
    Key3 = false,
    Key4 = false,
    Key5 = false,
    Key6 = false,
    Key7 = false,
    isDpadUp = false,
    isDpadDown = false,
    isDpadLeft = false,
    isDpadRight = false
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
    self.ThumbLX = state.Gamepad.sThumbLX
    self.ThumbLY = state.Gamepad.sThumbLY
    self.ThumbRX = state.Gamepad.sThumbRX
    self.ThumbRY = state.Gamepad.sThumbRY
    self.LTrigger = state.Gamepad.bLeftTrigger
    self.RTrigger = state.Gamepad.bRightTrigger
    self.rShoulder = self:isButtonPressed(XINPUT_GAMEPAD_RIGHT_SHOULDER)
    self.lShoulder = self:isButtonPressed(XINPUT_GAMEPAD_LEFT_SHOULDER)
    self.lThumb = self:isButtonPressed(XINPUT_GAMEPAD_LEFT_THUMB)
    self.rThumb = self:isButtonPressed(XINPUT_GAMEPAD_RIGHT_THUMB)
    self.Abutton = self:isButtonPressed(XINPUT_GAMEPAD_A)
    self.Bbutton = self:isButtonPressed(XINPUT_GAMEPAD_B)
    self.Xbutton = self:isButtonPressed(XINPUT_GAMEPAD_X)
    self.Ybutton = self:isButtonPressed(XINPUT_GAMEPAD_Y)
end

-- Reset key state variables (does not modify gamepad state)
function InputSessionState:Reset()
    self.rGrabActive = false
    self.lGrabActive = false
    self.LZone = 0
    self.RZone = 0
    self.LWeaponZone = 0
    self.RWeaponZone = 0
    
    self.lThumbSwitchState = 0
    self.lThumbOut = false
    self.rThumbSwitchState = 0
    self.rThumbOut = false
    self.isReloading = false
    self.ReadyUpTick = 0
    self.LTriggerWasPressed = 0
    self.RTriggerWasPressed = 0
    
    self.isFlashlightToggle = false
    self.isButtonA = false
    self.isButtonB = false
    self.isButtonX = false
    self.isButtonY = false
    self.isRShoulder = false
    
    self.isCrouch = false
    self.isJump = false
    self.vecy = 0
    
    self.Key1 = false
    self.Key2 = false
    self.Key3 = false
    self.Key4 = false
    self.Key5 = false
    self.Key6 = false
    self.Key7 = false
    self.KeyG = false
    self.KeyM = false
    self.KeyF = false
    self.KeyB = false
    self.KeyI = false
    self.KeySpace = false
    self.KeyCtrl = false
    
    self.isDpadUp = false
    self.isDpadDown = false
    self.isDpadLeft = false
    self.isDpadRight = false
    
    self.isRShoulderHeadR = false
    self.isRShoulderHeadL = false
    
    -- Don't reset actual gamepad hardware state values
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

