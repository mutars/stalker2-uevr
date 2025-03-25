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

local lControllerIndex = 1
local rControllerIndex = 2

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

uevr.sdk.callbacks.on_script_reset(function()
	print("Resetting")
	motionControllers:Reset()
	gameState:Reset() -- Reset the GameStateManager on script reset
	gestureController:Reset() -- Reset the GestureController on script reset
end)

function PositiveIntegerMask(text)
	return text:gsub("[^%-%d]", "")
end

uevr.sdk.callbacks.on_xinput_get_state(function(retval, user_index, state)
    -- Update our input state with the current XInput state
    inputState:updateXInputState(state)
    
    -- Read the current state values from InputSessionState
    local LTrigger = inputState.LTrigger
    local RTrigger = inputState.RTrigger
    local rShoulder = inputState.rShoulder
    local lShoulder = inputState.lShoulder
    local lThumb = inputState.lThumb
    local rThumb = inputState.rThumb
    local Abutton = inputState.Abutton
    local Bbutton = inputState.Bbutton
    local Xbutton = inputState.Xbutton
    local Ybutton = inputState.Ybutton
    
    -- Use GameStateManager to check menu and inventory status
    local inMenu = gameState.inMenu
    local isInventoryPDA = gameState.isInventoryPDA
    
    -- Check if in menu or inventory or PDA
    if not inMenu and not isInventoryPDA then
        -- Reset variable for weapon zone Firemode switch
        if inputState.LTrigger < 10 then
            inputState.LTriggerWasPressed = 0
        end
        if inputState.RTrigger < 10 then
            inputState.RTriggerWasPressed = 0
        end
        
        -- Disable buttons for different hand modes
        if isRhand or isLeftHandModeTriggerSwitchOnly then
            if lShoulder and SwapLShoulderLThumb then
                inputState:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
            end
        else
            if rShoulder and SwapLShoulderLThumb then
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
            end
        end
        
        -- Left Hand config (currently not used)
        if not isRhand then
            if not isLeftHandModeTriggerSwitchOnly then
                inputState:setLeftTrigger(RTrigger)
                inputState:setRightTrigger(LTrigger)
                inputState:unpressButton(XINPUT_GAMEPAD_B)
                inputState:unpressButton(XINPUT_GAMEPAD_A)
                inputState:unpressButton(XINPUT_GAMEPAD_X)
                inputState:unpressButton(XINPUT_GAMEPAD_Y)
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                inputState:unpressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
                if Ybutton then
                    inputState:pressButton(XINPUT_GAMEPAD_X)
                end
                if Bbutton then
                    inputState:pressButton(XINPUT_GAMEPAD_A)
                end
                if Xbutton then
                    inputState:pressButton(XINPUT_GAMEPAD_Y)
                end
                if Abutton then
                    inputState:pressButton(XINPUT_GAMEPAD_B)
                end
                
                if lShoulder then
                    inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                end
                if rShoulder then
                    inputState:pressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                end
                if lThumb then
                    inputState:pressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
                end
                if rThumb then
                    inputState:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                end
            end
        end
        --pressdpad--
        if inputState.isDpadUp then
            inputState:pressButton(XINPUT_GAMEPAD_DPAD_UP)
            inputState.isDpadUp=false
        end
        if inputState.isDpadRight then
            inputState:pressButton(XINPUT_GAMEPAD_DPAD_RIGHT)
            inputState.isDpadRight=false
        end
        if inputState.isDpadLeft then
            inputState:pressButton(XINPUT_GAMEPAD_DPAD_LEFT)
            inputState.isDpadLeft=false
        end
        if inputState.isDpadDown then
            inputState:pressButton(XINPUT_GAMEPAD_DPAD_DOWN)
            inputState.isDpadDown=false
        end
        if inputState.isButtonX then
            inputState:pressButton(XINPUT_GAMEPAD_X)
            inputState.isButtonX=false
        end
        if inputState.isButtonB then
            inputState:pressButton(XINPUT_GAMEPAD_B)
            inputState.isButtonB=false
        end
        if inputState.isButtonA then
            inputState:pressButton(XINPUT_GAMEPAD_A)
            inputState.isButtonA=false
        end
        if inputState.isButtonY then
            inputState:pressButton(XINPUT_GAMEPAD_Y)
            inputState.isButtonY=false
        end
        
        -- Unpress when in Zone
        if isRhand or isLeftHandModeTriggerSwitchOnly then	
            if inputState.RZone ~=0 then
                inputState:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_THUMB)
            end
        else
            if gestureController.LZone ~= 0 then
                inputState:unpressButton(XINPUT_GAMEPAD_LEFT_SHOULDER)
                inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
                inputState:unpressButton(XINPUT_GAMEPAD_LEFT_THUMB)
            end
        end
        
        -- Disable Trigger for mode switch
        if gestureController.RWeaponZone == 2 then
            inputState:setLeftTrigger(0)
        end
        
        if gestureController.LWeaponZone == 3 then
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
                inputState.isRShoulderHeadR= false
            end
        end
        if inputState.isRShoulderHeadL == true then
            inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
            if inputState.lGrabActive == false then
                inputState.isRShoulderHeadL= false
            end
        end
        
        if inputState.isReloading then
            inputState:pressButton(XINPUT_GAMEPAD_X)
            inputState.isReloading=false
        end
        
        --Grab activation
        if rShoulder then
            inputState.rGrabActive= true
            inputState:unpressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
        else rGrabActive =false
        end
        if lShoulder  then
            lGrabActive =true
        else lGrabActive=false
        end
        
        pawn=api:get_local_pawn(0)
        
        -- Using GameStateManager to send key commands
        if Key1 and not rGrabActive then
            gameState:SendKeyUp('1')
            Key1=false
        end
        if Key2 and not rGrabActive then
            gameState:SendKeyUp('2')
            Key2=false
        end
        if Key3 and not rGrabActive then
            gameState:SendKeyUp('3')
            Key3=false
        end
        if Key4 and not rGrabActive then
            gameState:SendKeyUp('4')
            Key4=false
        end
        if Key5 and not rGrabActive then
            gameState:SendKeyUp('5')
            Key5=false
        end
        if Key6 and not rGrabActive then
            gameState:SendKeyUp('6')
            Key6=false
        end
        if Key7 and not rGrabActive then
            gameState:SendKeyUp('7')
            Key7=false
        end
        if KeyM and not rGrabActive then
            gameState:SendKeyUp('M')
            KeyM=false
        end
        if KeyI ==true  then
            gameState:SendKeyUp('I')
            KeyI=false
        end
        if KeyB then
            gameState:SendKeyUp('B')
            KeyB=false
        end
        if KeyCtrl then
            gameState:SendKeyUp('0xA2')
            KeyCtrl=false
        end
        if KeySpace then
            gameState:SendKeyUp('0x20')
            KeySpace=false
        end

        -- Get vertical axis value from GestureController
        local vecy = gestureController:GetJoystickVerticalAxis(isRhand, isLeftHandModeTriggerSwitchOnly)

        if math.abs(vecy)< 0.1 and isJump==true then
            isJump=false
            
        end
        if math.abs(vecy)< 0.1 and isCrouch==true then
            isCrouch=false
            
        end
        if vecy > 0.8 and isJump==false then
            
            KeySpace=true
            gameState:SendKeyDown('0x20')
            isJump=true
            
        end
        
        if vecy <-0.8 and isCrouch == false then
            KeyCtrl=true
            gameState:SendKeyDown('0xA2')
            isCrouch=true
        end
        
        
        if GrenadeReady then
            if rGrabActive==false then
                gameState:SendKeyDown('G')
                GrenadeReady=false
                KeyG=true
            end
        end
        
        if isRShoulder then
            inputState:pressButton(XINPUT_GAMEPAD_RIGHT_SHOULDER)
        end
            
        --CONTROL REMAP:
        if isRhand or isLeftHandModeTriggerSwitchOnly then	
            if lShoulder and SwapLShoulderLThumb then
                if gestureController.LZone == 0 or gestureController.LZone == 5 and gestureController.RWeaponZone==0 then
                    inputState:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                end
            end
        else
            if rShoulder and SwapLShoulderLThumb then
                if gestureController.RZone == 0 or gestureController.RZone == 5 and gestureController.LWeaponZone==0 then
                    inputState:pressButton(XINPUT_GAMEPAD_LEFT_THUMB)
                end
            end
        end
    end	
end)

-- Removed redundant controller/location variables - now using GestureController

uevr.sdk.callbacks.on_pre_engine_tick(
	function(engine, delta)
	local pawn = gameState:GetLocalPawn() -- Using GameStateManager to get pawn

	-- Update GestureController to calculate all zones
	gestureController:Update()
	
	-- Get the zones from GestureController
	local RZone = gestureController.RZone
	local LZone = gestureController.LZone
	local RWeaponZone = gestureController.RWeaponZone
	local LWeaponZone = gestureController.LWeaponZone
	
	if gestureController.RHandLocation and gestureController.LHandLocation and gestureController.HmdLocation then
		-- Code to equip
		if isRhand then
			if RZone== 1 and rGrabActive and RWeaponZone==0 then
				Key3=true
				gameState:SendKeyDown('3')
			elseif RZone== 2 and rGrabActive then
				Key4=true
				gameState:SendKeyDown('4')
			elseif RZone== 4 and rGrabActive then
				Key2=true
				gameState:SendKeyDown('2')
			elseif RZone== 5 and rGrabActive then
				Key1=true
				gameState:SendKeyDown('1')
			elseif LZone== 1 and lGrabActive and RWeaponZone==0 then
				isDpadLeft=true
			elseif RZone== 8 and rGrabActive then
				Key1=true
				gameState:SendKeyDown('1')
			elseif RZone== 6 and rGrabActive then
				Key6=true
				gameState:SendKeyDown('6')
			elseif RZone== 7 and rGrabActive  then
				Key5=true
				gameState:SendKeyDown('5')
			elseif LZone==2 and lGrabActive and RWeaponZone==0 then
				KeyI=true
				gameState:SendKeyDown('I')
			elseif RZone == 3 and rGrabActive and isRShoulderHeadR== false then
				if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
					isRShoulderHeadR=true
				end
			elseif LZone ==3 and lGrabActive and isRShoulderHeadL==false then
				if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
					isRShoulderHeadL=true
				end
			elseif LZone==7 and lGrabActive and RWeaponZone==0 then
				KeyM=true
				gameState:SendKeyDown('M')
			elseif LZone==6 and lGrabActive and RWeaponZone==0 then
				Key7=true
				gameState:SendKeyDown('7')
			end
		else 
			if LZone == 2 and lGrabActive then
				Key3=true
				gameState:SendKeyDown('3')
			elseif LZone== 1 and lGrabActive then
				Key4=true
				gameState:SendKeyDown('4')
			elseif LZone== 5 and lGrabActive then
				Key2=true
				gameState:SendKeyDown('2')
			elseif RZone == 3 and rGrabActive and isRShoulderHeadR== false then
				if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
					isRShoulderHeadR=true
				end
			elseif LZone ==3 and lGrabActive and isRShoulderHeadL==false then
				if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "1" then
					isRShoulderHeadL=true
				end
			elseif LZone== 8 and lGrabActive then
				Key1=true
				gameState:SendKeyDown('1')
			elseif LZone== 6 and lGrabActive then
				Key5=true
				gameState:SendKeyDown('5')
			elseif LZone== 7 and lGrabActive then
				Key6=true
				gameState:SendKeyDown('6')
			elseif RZone==1 and rGrabActive and LWeaponZone==0 then
				KeyI=true
				gameState:SendKeyDown('I')
			elseif RZone==2 and rGrabActive and LWeaponZone==0 then
				isDpadLeft=true
			elseif LZone==4 and lGrabActive then
				Key1=true
				gameState:SendKeyDown('1')
			elseif RZone==7 and rGrabActive and LWeaponZone==0 then
				Key7=true
				gameState:SendKeyDown('7')
			elseif RZone==6 and rGrabActive and LWeaponZone==0 then
				KeyM=true
				gameState:SendKeyDown('M')
			end
			
		end
		
		-- Code to trigger Weapon
		if isRhand then
			if RWeaponZone ==1 and lGrabActive then
				isReloading=true
			elseif RWeaponZone == 2 and LTrigger > 230 and LTriggerWasPressed ==0 then
				KeyB=true
				gameState:SendKeyDown('B')
				LTriggerWasPressed=1
			elseif RWeaponZone==3 and lThumbOut then
				if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "2" then
					isRShoulder=true
				end
			end
		else
		
			if LWeaponZone==1 then
				if rGrabActive then
					isReloading = true
				else isReloading = false
				end
			elseif LWeaponZone== 2 and RTrigger > 230 and RTriggerWasPressed ==0 then
				KeyB=true
				gameState:SendKeyDown('B')
				RTriggerWasPressed=1
			elseif LWeaponZone ==3 and rThumbOut then
				if string.sub(uevr.params.vr:get_mod_value("VR_AimMethod"),1,1) == "3" then
					isRShoulder=true
				end
			end
		end
	end
end)