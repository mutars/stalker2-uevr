require("CONFIG")
require("Trackers")
--CONFIG--
--------	
	local isRhand = true
	local HapticFeedback = true
	local isLeftHandModeTriggerSwitchOnly = true
	--local PhysicalLeaning = false
	local SwapLShoulderLThumb = true --sprinting switch with l shoulder
	local SitMode = false
	        
--------
--------	
	local SeatedOffset = 0 
	if SitMode then
		SeatedOffset = 20
	end
		
	local api = uevr.api
	
	local params = uevr.params
	local callbacks = params.sdk.callbacks

-- Import our motion controller module
local MotionControllerActors = require("scripts/MotionControllerActors")
local motionControllers = MotionControllerActors:new()

-- Import InputSessionState and initialize
local InputSessionState = require("scripts/gamepad")
local inputState = InputSessionState:new()

-- Import GameStateManager and initialize
local GameStateManager = require("scripts/GameStateManager")
local gameState = GameStateManager:new()

-- Import GestureController and initialize
local GestureController = require("scripts/GestureController")
local gestureController = GestureController:new(motionControllers, {
    HapticFeedback = HapticFeedback,
    SeatedOffset = SeatedOffset,
    isRhand = isRhand
})

-- Constants for controller indices
local lControllerIndex = 1
local rControllerIndex = 2

-- Initialize state
local counting = false
local tickCount = 0
local last_level = nil

-- Handle engine tick events
uevr.sdk.callbacks.on_pre_engine_tick(function(engine_voidptr, delta)
	local game_engine = UEVR_UObjectHook.get_first_object_by_class(motionControllers.game_engine_class)
	if not game_engine then return end
	
	local viewport = game_engine.GameViewport
	if not viewport then return end
	
	local world = viewport.World
	if not world then return end

	local current_level = world.PersistentLevel
	
	-- Check if level has changed
	local levelChanged = (last_level ~= current_level)
	if levelChanged then
		print("Level changed")
		if current_level then
			print("New level: " .. current_level:get_full_name())
		end
		last_level = current_level
		motionControllers:Reset()
		gameState:Reset() -- Reset the GameStateManager when level changes
		gestureController:Reset() -- Reset the GestureController when level changes
		counting = true
	end
	
	if counting == true then 
		tickCount = tickCount + 1
		if tickCount >= 1000 then
			State = 3
			counting = false
			tickCount = 0
			motionControllers:Init()
		end
	end
	
	-- Check if any controllers need to be respawned
	local needsRespawn = motionControllers:Validate()
	if needsRespawn then
		motionControllers:Init()
	end
	
	-- Update GameStateManager on each tick
	gameState:Update()
end)

-- Use Vector3d if this is a UE5 game (double precision)
local last_rot = Vector3f.new(0, 0, 0)
local last_pos = Vector3f.new(0, 0, 0)

-- Function to execute at the end of on_pre_engine_tick to make sure we reset state
local function initCallbacks()
    -- Get engine tick event
    uevr.sdk.callbacks.on_pre_engine_tick(function(engine_voidptr, delta)
        local game_engine = UEVR_UObjectHook.get_first_object_by_class(motionControllers.game_engine_class)
        if not game_engine then return end
        
        local viewport = game_engine.GameViewport
        if not viewport then return end
        
        local world = viewport.World
        if not world then return end

        local current_level = world.PersistentLevel
        
        -- Check if level has changed
        local levelChanged = (last_level ~= current_level)
        if levelChanged then
            print("Level changed")
            if current_level then
                print("New level: " .. current_level:get_full_name())
            end
            last_level = current_level
            motionControllers:Reset()
            gameState:Reset() -- Reset the GameStateManager when level changes
            gestureController:Reset() -- Reset the GestureController when level changes
            inputState:Reset() -- Reset InputSessionState when level changes
            counting = true
        end
        
        if counting == true then 
            tickCount = tickCount + 1
            if tickCount >= 1000 then
                counting = false
                tickCount = 0
                motionControllers:Init()
            end
        end
        
        -- Check if any controllers need to be respawned
        local needsRespawn = motionControllers:Validate()
        if needsRespawn then
            motionControllers:Init()
        end
        
        -- Update GameStateManager on each tick
        gameState:Update()
    end)

    -- Update gesture controller and handle holster logic 
    uevr.sdk.callbacks.on_pre_engine_tick(
        function(engine, delta)
        local pawn = gameState:GetLocalPawn() -- Using GameStateManager to get pawn

        -- Update GestureController to calculate all zones
        gestureController:Update()
        
        -- Sync GestureController zones to InputState for a single source of truth
        inputState.RZone = gestureController.RZone
        inputState.LZone = gestureController.LZone
        inputState.RWeaponZone = gestureController.RWeaponZone
        inputState.LWeaponZone = gestureController.LWeaponZone
        
        if gestureController.RHandLocation and gestureController.LHandLocation and gestureController.HmdLocation then
            -- Code to equip
            if isRhand then
                if inputState.RZone == 1 and inputState.rGrabActive and inputState.RWeaponZone == 0 then
                    inputState.Key3 = true
                    gameState:SendKeyDown('3')
                elseif inputState.RZone == 2 and inputState.rGrabActive then
                    inputState.Key4 = true
                    gameState:SendKeyDown('4')
                elseif inputState.RZone == 4 and inputState.rGrabActive then
                    inputState.Key2 = true
                    gameState:SendKeyDown('2')
                elseif inputState.RZone == 5 and inputState.rGrabActive then
                    inputState.Key1 = true
                    gameState:SendKeyDown('1')
                elseif inputState.LZone == 1 and inputState.lGrabActive and inputState.RWeaponZone == 0 then
                    inputState.isDpadLeft = true
                elseif inputState.RZone == 8 and inputState.rGrabActive then
                    inputState.Key1 = true
                    gameState:SendKeyDown('1')
                elseif inputState.RZone == 6 and inputState.rGrabActive then
                    inputState.Key6 = true
                    gameState:SendKeyDown('6')
                elseif inputState.RZone == 7 and inputState.rGrabActive then
                    inputState.Key5 = true
                    gameState:SendKeyDown('5')
                elseif inputState.LZone == 2 and inputState.lGrabActive and inputState.RWeaponZone == 0 then
                    inputState.KeyI = true
                    gameState:SendKeyDown('I')
                elseif inputState.RZone == 3 and inputState.rGrabActive and inputState.isRShoulderHeadR == false then
                    if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
                        inputState.isRShoulderHeadR = true
                    end
                elseif inputState.LZone == 3 and inputState.lGrabActive and inputState.isRShoulderHeadL == false then
                    if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
                        inputState.isRShoulderHeadL = true
                    end
                elseif inputState.LZone == 7 and inputState.lGrabActive and inputState.RWeaponZone == 0 then
                    inputState.KeyM = true
                    gameState:SendKeyDown('M')
                elseif inputState.LZone == 6 and inputState.lGrabActive and inputState.RWeaponZone == 0 then
                    inputState.Key7 = true
                    gameState:SendKeyDown('7')
                end
            else 
                if inputState.LZone == 2 and inputState.lGrabActive then
                    inputState.Key3 = true
                    gameState:SendKeyDown('3')
                elseif inputState.LZone == 1 and inputState.lGrabActive then
                    inputState.Key4 = true
                    gameState:SendKeyDown('4')
                elseif inputState.LZone == 5 and inputState.lGrabActive then
                    inputState.Key2 = true
                    gameState:SendKeyDown('2')
                elseif inputState.RZone == 3 and inputState.rGrabActive and inputState.isRShoulderHeadR == false then
                    if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
                        inputState.isRShoulderHeadR = true
                    end
                elseif inputState.LZone == 3 and inputState.lGrabActive and inputState.isRShoulderHeadL == false then
                    if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
                        inputState.isRShoulderHeadL = true
                    end
                elseif inputState.LZone == 8 and inputState.lGrabActive then
                    inputState.Key1 = true
                    gameState:SendKeyDown('1')
                elseif inputState.LZone == 6 and inputState.lGrabActive then
                    inputState.Key5 = true
                    gameState:SendKeyDown('5')
                elseif inputState.LZone == 7 and inputState.lGrabActive then
                    inputState.Key6 = true
                    gameState:SendKeyDown('6')
                elseif inputState.RZone == 1 and inputState.rGrabActive and inputState.LWeaponZone == 0 then
                    inputState.KeyI = true
                    gameState:SendKeyDown('I')
                elseif inputState.RZone == 2 and inputState.rGrabActive and inputState.LWeaponZone == 0 then
                    inputState.isDpadLeft = true
                elseif inputState.LZone == 4 and inputState.lGrabActive then
                    inputState.Key1 = true
                    gameState:SendKeyDown('1')
                elseif inputState.RZone == 7 and inputState.rGrabActive and inputState.LWeaponZone == 0 then
                    inputState.Key7 = true
                    gameState:SendKeyDown('7')
                elseif inputState.RZone == 6 and inputState.rGrabActive and inputState.LWeaponZone == 0 then
                    inputState.KeyM = true
                    gameState:SendKeyDown('M')
                end
                
            end
            
            -- Code to trigger Weapon
            if isRhand then
                if inputState.RWeaponZone == 1 and inputState.lGrabActive then
                    inputState.isReloading = true
                elseif inputState.RWeaponZone == 2 and inputState.LTrigger > 230 and inputState.LTriggerWasPressed == 0 then
                    inputState.KeyB = true
                    gameState:SendKeyDown('B')
                    inputState.LTriggerWasPressed = 1
                elseif inputState.RWeaponZone == 3 and inputState.lThumbOut then
                    if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "2" then
                        inputState.isRShoulder = true
                    end
                end
            else
                if inputState.LWeaponZone == 1 then
                    if inputState.rGrabActive then
                        inputState.isReloading = true
                    else 
                        inputState.isReloading = false
                    end
                elseif inputState.LWeaponZone == 2 and inputState.RTrigger > 230 and inputState.RTriggerWasPressed == 0 then
                    inputState.KeyB = true
                    gameState:SendKeyDown('B')
                    inputState.RTriggerWasPressed = 1
                elseif inputState.LWeaponZone == 3 and inputState.rThumbOut then
                    if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "3" then
                        inputState.isRShoulder = true
                    end
                end
            end
        end
    end)
    
    -- Handle controller state
    uevr.sdk.callbacks.on_xinput_get_state(function(retval, user_index, state)
        -- Update our input state with the current XInput state
        inputState:updateXInputState(state)
        
        -- Use GameStateManager to check menu and inventory status
        inputState.inMenu = gameState.inMenu
        inputState.isInventoryPDA = gameState.isInventoryPDA
        
        -- Check if in menu or inventory or PDA
        if not inputState.inMenu and not inputState.isInventoryPDA then
            -- Reset variable for weapon zone Firemode switch
            if inputState.LTrigger < 10 then
                inputState.LTriggerWasPressed = 0
            end
            if inputState.RTrigger < 10 then
                inputState.RTriggerWasPressed = 0
            end
            
            -- Disable buttons for different hand modes
            if isRhand or isLeftHandModeTriggerSwitchOnly then
                if inputState.lShoulder and SwapLShoulderLThumb then
                    inputState:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                end
            else
                if inputState.rShoulder and SwapLShoulderLThumb then
                    inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                end
            end
            
            -- Left Hand config (currently not used)
            if not isRhand then
                if not isLeftHandModeTriggerSwitchOnly then
                    inputState:setLeftTrigger(inputState.RTrigger)
                    inputState:setRightTrigger(inputState.LTrigger)
                    inputState:unpressButton(XINPUT_GAMEPAD_B)
                    inputState:unpressButton(XINPUT_GAMEPAD_A)
                    inputState:unpressButton(XINPUT_GAMEPAD_X)
                    inputState:unpressButton(XINPUT_GAMEPAD_Y)
                    inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                    inputState:unpressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                    inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
                    if inputState.Ybutton then
                        inputState:pressButton(XINPUT_GAMEPAD_X)
                    end
                    if inputState.Bbutton then
                        inputState:pressButton(XINPUT_GAMEPAD_A)
                    end
                    if inputState.Xbutton then
                        inputState:pressButton(XINPUT_GAMEPAD_Y)
                    end
                    if inputState.Abutton then
                        inputState:pressButton(XINPUT_GAMEPAD_B)
                    end
                    
                    if inputState.lShoulder then
                        inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                    end
                    if inputState.rShoulder then
                        inputState:pressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                    end
                    if inputState.lThumb then
                        inputState:pressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
                    end
                    if inputState.rThumb then
                        inputState:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                    end
                end
            end
            
            -- Process directional pad and button presses
            if inputState.isDpadUp then
                inputState:pressButton(XINPUT_GAMEPAD_DPAD_UP)
                inputState.isDpadUp = false
            end
            if inputState.isDpadRight then
                inputState:pressButton(XINPUT_GAMEPAD_DPAD_RIGHT)
                inputState.isDpadRight = false
            end
            if inputState.isDpadLeft then
                inputState:pressButton(XINPUT_GAMEPAD_DPAD_LEFT)
                inputState.isDpadLeft = false
            end
            if inputState.isDpadDown then
                inputState:pressButton(XINPUT_GAMEPAD_DPAD_DOWN)
                inputState.isDpadDown = false
            end
            if inputState.isButtonX then
                inputState:pressButton(XINPUT_GAMEPAD_X)
                inputState.isButtonX = false
            end
            if inputState.isButtonB then
                inputState:pressButton(XINPUT_GAMEPAD_B)
                inputState.isButtonB = false
            end
            if inputState.isButtonA then
                inputState:pressButton(XINPUT_GAMEPAD_A)
                inputState.isButtonA = false
            end
            if inputState.isButtonY then
                inputState:pressButton(XINPUT_GAMEPAD_Y)
                inputState.isButtonY = false
            end
            
            -- Unpress when in Zone
            if isRhand or isLeftHandModeTriggerSwitchOnly then	
                if inputState.RZone ~= 0 then
                    inputState:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                    inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                    inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
                end
            else
                if inputState.LZone ~= 0 then
                    inputState:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                    inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                    inputState:unpressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                end
            end
            
            -- Disable Trigger for mode switch
            if inputState.RWeaponZone == 2 then
                inputState:setLeftTrigger(0)
            end
            
            if inputState.LWeaponZone == 3 then
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
            end
            
            -- Attachement singlepress fix
            if inputState.lThumb and inputState.lThumbSwitchState == 0 then 
                inputState.lThumbOut = true 
                inputState.lThumbSwitchState = 1
            elseif inputState.lThumb and inputState.lThumbSwitchState == 1 then
                inputState.lThumbOut = false
            elseif not inputState.lThumb and inputState.lThumbSwitchState == 1 then
                inputState.lThumbOut = false
                inputState.lThumbSwitchState = 0
                inputState.isRShoulder = false
            end
            
            if inputState.rThumb and inputState.rThumbSwitchState == 0 then 
                inputState.rThumbOut = true 
                inputState.rThumbSwitchState = 1
            elseif inputState.rThumb and inputState.rThumbSwitchState == 1 then
                inputState.rThumbOut = false
            elseif not inputState.rThumb then
                inputState.rThumbOut = false
                inputState.rThumbSwitchState = 0
                inputState.isRShoulder = false
            end
            
            if inputState.isRShoulderHeadR == true then
                inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                if inputState.rGrabActive == false then
                    inputState.isRShoulderHeadR = false
                end
            end
            if inputState.isRShoulderHeadL == true then
                inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                if inputState.lGrabActive == false then
                    inputState.isRShoulderHeadL = false
                end
            end
            
            if inputState.isReloading then
                inputState:pressButton(XINPUT_GAMEPAD_X)
                inputState.isReloading = false
            end
            
            -- Grab activation
            if inputState.rShoulder then
                inputState.rGrabActive = true
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
            else 
                inputState.rGrabActive = false
            end
            
            if inputState.lShoulder then
                inputState.lGrabActive = true
            else 
                inputState.lGrabActive = false
            end
            
            -- Using GameStateManager to send key commands
            if inputState.Key1 and not inputState.rGrabActive then
                gameState:SendKeyUp('1')
                inputState.Key1 = false
            end
            if inputState.Key2 and not inputState.rGrabActive then
                gameState:SendKeyUp('2')
                inputState.Key2 = false
            end
            if inputState.Key3 and not inputState.rGrabActive then
                gameState:SendKeyUp('3')
                inputState.Key3 = false
            end
            if inputState.Key4 and not inputState.rGrabActive then
                gameState:SendKeyUp('4')
                inputState.Key4 = false
            end
            if inputState.Key5 and not inputState.rGrabActive then
                gameState:SendKeyUp('5')
                inputState.Key5 = false
            end
            if inputState.Key6 and not inputState.rGrabActive then
                gameState:SendKeyUp('6')
                inputState.Key6 = false
            end
            if inputState.Key7 and not inputState.rGrabActive then
                gameState:SendKeyUp('7')
                inputState.Key7 = false
            end
            if inputState.KeyM and not inputState.rGrabActive then
                gameState:SendKeyUp('M')
                inputState.KeyM = false
            end
            if inputState.KeyI == true then
                gameState:SendKeyUp('I')
                inputState.KeyI = false
            end
            if inputState.KeyB then
                gameState:SendKeyUp('B')
                inputState.KeyB = false
            end
            if inputState.KeyCtrl then
                gameState:SendKeyUp('0xA2')
                inputState.KeyCtrl = false
            end
            if inputState.KeySpace then
                gameState:SendKeyUp('0x20')
                inputState.KeySpace = false
            end

            -- Get vertical axis value from GestureController
            inputState.vecy = gestureController:GetJoystickVerticalAxis(isRhand, isLeftHandModeTriggerSwitchOnly)

            if math.abs(inputState.vecy) < 0.1 and inputState.isJump == true then
                inputState.isJump = false
            end
            
            if math.abs(inputState.vecy) < 0.1 and inputState.isCrouch == true then
                inputState.isCrouch = false
            end
            
            if inputState.vecy > 0.8 and inputState.isJump == false then
                inputState.KeySpace = true
                gameState:SendKeyDown('0x20')
                inputState.isJump = true
            end
            
            if inputState.vecy < -0.8 and inputState.isCrouch == false then
                inputState.KeyCtrl = true
                gameState:SendKeyDown('0xA2')
                inputState.isCrouch = true
            end
            
            if inputState.GrenadeReady then
                if inputState.rGrabActive == false then
                    gameState:SendKeyDown('G')
                    inputState.GrenadeReady = false
                    inputState.KeyG = true
                end
            end
            
            if inputState.isRShoulder then
                inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
            end
                
            -- CONTROL REMAP:
            if isRhand or isLeftHandModeTriggerSwitchOnly then	
                if inputState.lShoulder and SwapLShoulderLThumb then
                    if inputState.LZone == 0 or inputState.LZone == 5 and inputState.RWeaponZone == 0 then
                        inputState:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                    end
                end
            else
                if inputState.rShoulder and SwapLShoulderLThumb then
                    if inputState.RZone == 0 or inputState.RZone == 5 and inputState.LWeaponZone == 0 then
                        inputState:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                    end
                end
            end
        end	
    end)

    -- Register script reset logic
    uevr.sdk.callbacks.on_script_reset(function()
        print("Resetting")
        motionControllers:Reset()
        gameState:Reset() -- Reset the GameStateManager on script reset
        gestureController:Reset() -- Reset the GestureController on script reset
        if inputState then inputState:Reset() end -- Reset inputState on script reset
    end)
end

-- Initialize the HolsterScript
local function init()
    -- Initialize modules
    -- Use or create init methods if needed
    
    -- Initialize callbacks
    initCallbacks()
    
    print("HolsterScript initialized")
end

-- Start the script
init()