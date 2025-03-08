local api = uevr.api

--Config Recoil
local isUpRecoilActive= true --on /off
-- local variables for Recoil
local VertDiff=0
local RotDiff=0
local DefaultOffset= uevr.params.vr:get_mod_value("VR_ControllerPitchOffset")
local LastTickRot=0
local GunFiringState = 0
local RotStart= 0
local SkipTick=false
local VertTickCount=0
local StoppedShooting= false
local RotDiffLast=0
local VertDiffLast=0

-- Cache required classes
local function find_required_object(name)
    local obj = api:find_uobject(name)
    if not obj then
        error("Cannot find " .. name)
        return nil
    end
    return obj
end

-- Required classes
local kismet_math_library = find_required_object("Class /Script/Engine.KismetMathLibrary"):get_class_default_object()
local KismetMaterialLibrary = find_required_object("Class /Script/Engine.KismetMaterialLibrary"):get_class_default_object()
local CameraManager_c = find_required_object("Class /Script/Stalker2.CameraManager")


-- State tracking
local current_weapon = nil
local default_socket_location = nil
local offset_socket_location = nil

-- Helper function to get equipped weapon
local function get_equipped_weapon(pawn)
    if not pawn then return nil end
    local sk_mesh = pawn.Mesh
    if not sk_mesh then return nil end
    local anim_instance = sk_mesh.AnimScriptInstance
    if not anim_instance then return nil end
    return anim_instance.WeaponData.WeaponMesh
end

local function fix_effects(world)
    if not KismetMaterialLibrary then
        print("cached objects are null")
        return
    end
    local game_encamera_manager = UEVR_UObjectHook.get_first_object_by_class(CameraManager_c)
    if not game_encamera_manager then return end
    local fov_mpc = game_encamera_manager.FovMPC
    if not fov_mpc then return end
    local fov_collection = fov_mpc.Collection
    if not fov_collection then return end
    KismetMaterialLibrary:SetScalarParameterValue(world, fov_collection, "IsFOVEnabled", 0.0)
end

-- Helper function to calculate socket offset
local function update_weapon_offset(weapon_mesh)
    if not weapon_mesh then return end

    local attach_socket_name = weapon_mesh.AttachSocketName

    -- Get socket transforms
    local default_transform = weapon_mesh:GetSocketTransform(attach_socket_name, 2)
    local offset_transform = weapon_mesh:GetSocketTransform("jnt_offset", 2)
    local location_diff = kismet_math_library:Subtract_VectorVector(
        default_transform.Translation,
        offset_transform.Translation
    )
    -- from UE to UEVR X->Z Y->-X, Z->-Y
    -- Z - forward, X - negative right, Y - negative up
    local lossy_offset = Vector3f.new(-location_diff.y, -location_diff.z+VertDiff, location_diff.x)
    -- Apply the offset to the weapon using motion controller state
    UEVR_UObjectHook.get_or_add_motion_controller_state(weapon_mesh):set_hand(1)
    UEVR_UObjectHook.get_or_add_motion_controller_state(weapon_mesh):set_location_offset(lossy_offset)
    UEVR_UObjectHook.get_or_add_motion_controller_state(weapon_mesh):set_permanent(true)
end

-- Tick callback to check for weapon changes
uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
    local viewport = engine.GameViewport
    if viewport then
        local world = viewport.World
        if world then
            fix_effects(world)
        end
    end
    local pawn = api:get_local_pawn(0)
    local weapon_mesh = get_equipped_weapon(pawn)
    if pawn and weapon_mesh then
        update_weapon_offset(weapon_mesh)
    end
end)

-- Reset callback
uevr.sdk.callbacks.on_script_reset(function()
    print("Resetting weapon offset script")
end)
-- Helper Function for recoil calculation

function PositiveIntegerMask(text)
	return text:gsub("[^%-%d]", "")
end



local function ApplyRecoilRecovery()
	if GunFiringState ~= 1 then		
		local durationa=20
		 
		if VertTickCount<durationa then
			local decrementVert = VertDiffLast / durationa
			local decrementRot  = RotDiffLast / durationa 
			VertTickCount=VertTickCount+1
			VertDiff = VertDiffLast-decrementVert*VertTickCount
			RotDiff = RotDiffLast - decrementRot*VertTickCount
		elseif VertTickCount>=durationa then
				VertDiff=0 
				RotDiff=0
		end
		local FinalAngle=tostring(PositiveIntegerMask(DefaultOffset)/1000000-RotDiff)
		uevr.params.vr.set_mod_value("VR_ControllerPitchOffset", FinalAngle)
	else VertTickCount=0	
	end
end

local function GetGunFiringState()
	local pawn = api:get_local_pawn(0)
	pcall(function()
	GunFiringState = pawn.Mesh.AnimScriptInstance.WeaponPushbackData.State
	end)
	
end

local function UpdateOnStoppedShooting()
	if GunFiringState==3 and StoppedShooting==false then
		RotDiffLast= RotDiff
		--VertDiffLast= VertDiff
		
		StoppedShooting= true
	elseif GunFiringState ~= 3 then
		StoppedShooting=false
	end
end

local function ApplyRecoil()

	--if SkipTick then
	uevr.params.vr.set_mod_value("VR_AimMethod" , "2")
	--SkipTick=false
	--end
	
	if RotDiff~=0 then
			uevr.params.vr.set_mod_value("VR_AimMethod" , "0")
	--else	SkipTick=true   
	end
				
	if GunFiringState == 1 then
		local FinalAngle=tostring(PositiveIntegerMask(DefaultOffset)/1000000-RotDiff)
		uevr.params.vr.set_mod_value("VR_ControllerPitchOffset", FinalAngle)
		VertDiff = math.tan(RotDiff*math.pi/180)* 25
		VertDiffLast=VertDiff
	end
end



----------------------------------------------



--Callback for calculating Recoil
uevr.params.sdk.callbacks.on_early_calculate_stereo_view_offset(
function(device, view_index, world_to_meters, position, rotation, is_double)
	
	
	
	GetGunFiringState()
	--print(GunFiringState)
	if GunFiringState== 0 then	
		RotStart= rotation.x
	end
	RotDiff = RotStart - rotation.x
	
	
	--calculate rot to last tick		
	
	if isUpRecoilActive then
		ApplyRecoil()
		UpdateOnStoppedShooting()
		ApplyRecoilRecovery()	
	end	
	
end)

--callback to disable up down with stick while shooting
uevr.sdk.callbacks.on_xinput_get_state(
function(retval, user_index, state)


	if GunFiringState	~=0 then
		state.Gamepad.sThumbRY =0
	end
	
	
end)										 