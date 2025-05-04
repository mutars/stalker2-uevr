require(".\\Base\\Trackers\\Trackers")
require("common.assetloader")
require("Config.CONFIG")
local utils = require("common.utils")
local GameState = require("stalker2.gamestate")
local api = uevr.api
local vr = uevr.params.vr

local emissive_material_amplifier = 2.0
local fov = 2.0
local desiredFOV=60 --needs to pull from game later

local emissive_mesh_material_name = "Material /Engine/EngineMaterials/EmissiveMeshMaterial.EmissiveMeshMaterial"


local ScopeController = {
    ftransform_c = nil,
    flinearColor_c = nil,
    hitresult_c = nil,
    game_engine_class = nil,
    Statics = nil,
    Kismet = nil,
    KismetMaterialLibrary = nil,
    AssetRegistryHelpers = nil,
    actor_c = nil,
    staic_mesh_component_c = nil,
    staic_mesh_c = nil,
    scene_capture_component_c = nil,
    MeshC = nil,
    StaticMeshC = nil,
    CameraManager_c = nil,

    -- Instance variables
    scope_actor = nil,
    scope_plane_component = nil,
    scene_capture_component = nil,
    render_target = nil,
    reusable_hit_result = nil,
    temp_vec3 = Vector3d.new(0, 0, 0),
    temp_vec3f = Vector3f.new(0, 0, 0),
    zero_color = nil,
    zero_transform = nil,

    -- state variables
    current_weapon = nil,
    scope_mesh = nil,
    scope_material = nil,
}

function ScopeController:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    self:InitStatic()
    return instance
end

function ScopeController:InitStatic()
    -- Try to initialize all required objects
    self.ftransform_c = utils.find_required_object("ScriptStruct /Script/CoreUObject.Transform")
    if not self.ftransform_c then return false end

    self.flinearColor_c = utils.find_required_object("ScriptStruct /Script/CoreUObject.LinearColor")
    if not self.flinearColor_c then return false end

    self.hitresult_c = utils.find_required_object("ScriptStruct /Script/Engine.HitResult")
    if not self.hitresult_c then return false end

    self.game_engine_class = utils.find_required_object("Class /Script/Engine.GameEngine")
    if not self.game_engine_class then return false end

    self.Statics = utils.find_static_class("Class /Script/Engine.GameplayStatics")
    if not self.Statics then return false end

    self.Kismet = utils.find_static_class("Class /Script/Engine.KismetRenderingLibrary")
    if not self.Kismet then return false end

    self.KismetMaterialLibrary = utils.find_static_class("Class /Script/Engine.KismetMaterialLibrary")
    if not self.KismetMaterialLibrary then return false end

    self.AssetRegistryHelpers = utils.find_static_class("Class /Script/AssetRegistry.AssetRegistryHelpers")
    if not self.AssetRegistryHelpers then return false end

    self.actor_c = utils.find_required_object("Class /Script/Engine.Actor")
    if not self.actor_c then return false end

    self.staic_mesh_component_c = utils.find_required_object("Class /Script/Engine.StaticMeshComponent")
    if not self.staic_mesh_component_c then return false end

    self.staic_mesh_c = utils.find_required_object("Class /Script/Engine.StaticMesh")
    if not self.staic_mesh_c then return false end

    self.scene_capture_component_c = utils.find_required_object("Class /Script/Engine.SceneCaptureComponent2D")
    if not self.scene_capture_component_c then return false end

    self.MeshC = utils.find_required_object("Class /Script/Engine.SkeletalMeshComponent")
    if not self.MeshC then return false end

    self.StaticMeshC = utils.find_required_object("Class /Script/Engine.StaticMeshComponent")
    if not self.StaticMeshC then return false end

    self.CameraManager_c = utils.find_required_object("Class /Script/Stalker2.CameraManager")
    if not self.CameraManager_c then return false end

    -- Initialize reusable objects
    self.reusable_hit_result = StructObject.new(self.hitresult_c)
    if not self.reusable_hit_result then return false end

    self.zero_color = StructObject.new(self.flinearColor_c)
    if not self.zero_color then return false end

    self.zero_transform = StructObject.new(self.ftransform_c)
    if not self.zero_transform then return false end
    self.zero_transform.Rotation.W = 1.0
    self.zero_transform.Scale3D = self.temp_vec3:set(1.0, 1.0, 1.0)

    return true
end

function ScopeController:ResetStatic()
    self.ftransform_c = nil
    self.flinearColor_c = nil
    self.hitresult_c = nil
    self.game_engine_class = nil
    self.Statics = nil
    self.Kismet = nil
    self.KismetMaterialLibrary = nil
    self.AssetRegistryHelpers = nil
    self.actor_c = nil
    self.staic_mesh_component_c = nil
    self.staic_mesh_c = nil
    self.scene_capture_component_c = nil
    self.MeshC = nil
    self.StaticMeshC = nil
    self.CameraManager_c = nil
    self.reusable_hit_result = nil
    self.zero_color = nil
    self.zero_transform = nil
end

function ScopeController:get_scope_mesh(parent_mesh)
    if not parent_mesh then return nil end

    local child_components = parent_mesh.AttachChildren
    if not child_components then return nil end

    for _, component in ipairs(child_components) do
        if component:is_a(self.StaticMeshC) and string.find(component:get_fname():to_string(), "scope") then
            return component
        end
    end

    return nil
end


function ScopeController:get_render_target(world)
    self.render_target = utils.validate_object(self.render_target)
    if self.render_target == nil then
        self.render_target = self.Kismet:CreateRenderTarget2D(world, 512, 512, 6, self.zero_color, false)
        -- render_target.bHDR = 0;
        -- render_target.SRGB = 0;
    end
    return self.render_target
end

function ScopeController:spawn_scope_plane(world, owner, pos, rt)
    local local_scope_mesh = self.scope_actor:AddComponentByClass(self.staic_mesh_component_c, false, self.zero_transform, false)
    if local_scope_mesh == nil then
        print("Failed to spawn scope mesh")
        return
    end

    local wanted_mat = utils.find_required_object(emissive_mesh_material_name)
    if wanted_mat == nil then
        print("Failed to find material")
        return
    end
    wanted_mat.BlendMode = 7
    wanted_mat.TwoSided = 0
    --     wanted_mat.bDisableDepthTest = true
    --     --wanted_mat.MaterialDomain = 0
    --     --wanted_mat.ShadingModel = 0

    local plane = utils.find_required_object_no_cache(self.staic_mesh_c, "StaticMesh /Engine/BasicShapes/Cylinder.Cylinder")

    if plane == nil then
        print("Failed to find plane mesh")
        -- api:dispatch_custom_event("LoadAsset", "StaticMesh /Engine/BasicShapes/Cylinder.Cylinder")
        local fAssetData = CreateAssetData("/Engine/BasicShapes/Cylinder", "/Engine/BasicShapes", "Cylinder", "/Script/Engine", "StaticMesh")
        plane =  GetLoadedAsset(fAssetData)
        if plane == nil then
            print("Failed to load asset plane mesh")
            return
        end
    end
    local_scope_mesh:SetStaticMesh(plane)
    local_scope_mesh:SetVisibility(false)
    -- local_scope_mesh:SetHiddenInGame(false)
    local_scope_mesh:SetCollisionEnabled(0)

    local dynamic_material = local_scope_mesh:CreateDynamicMaterialInstance(0, wanted_mat, "ScopeMaterial")

    dynamic_material:SetTextureParameterValue("LinearColor", rt)
    local color = StructObject.new(self.flinearColor_c)
    color.R = Config.scopeBrightnessAmplifier
    color.G = Config.scopeBrightnessAmplifier
    color.B = Config.scopeBrightnessAmplifier
    color.A = Config.scopeBrightnessAmplifier
    dynamic_material:SetVectorParameterValue("Color", color)
    self.scope_plane_component = local_scope_mesh
    self.scope_material = dynamic_material
end

function ScopeController:SetScopeBrightness(value)
    if self.scope_material then
        local color = StructObject.new(self.flinearColor_c)
        color.R = value
        color.G = value
        color.B = value
        color.A = value
        self.scope_material:SetVectorParameterValue("Color", color)
    end
end

function ScopeController:spawn_scene_capture_component(world, owner, pos, fov, rt)
    local local_scene_capture_component = self.scope_actor:AddComponentByClass(self.scene_capture_component_c, false, self.zero_transform, false)
    if local_scene_capture_component == nil then
        print("Failed to spawn scene capture")
        return
    end
    local_scene_capture_component.TextureTarget = rt
    local_scene_capture_component.FOVAngle = fov
    local_scene_capture_component.bCacheVolumetricCloudsShadowMaps = true;
    -- local_scene_capture_component.bCachedDistanceFields = 1;
    local_scene_capture_component.bUseRayTracingIfEnabled = false;
    -- local_scene_capture_component.PrimitiveRenderMode = 2; -- 0 - legacy, 1 - other
    -- local_scene_capture_component.CaptureSource = 1;
    local_scene_capture_component.bAlwaysPersistRenderingState = true;
    local_scene_capture_component.bEnableVolumetricCloudsCapture = false;
    local_scene_capture_component.bCaptureEveryFrame = 1;

    -- post processing
    local_scene_capture_component.PostProcessSettings.bOverride_MotionBlurAmount = true
    local_scene_capture_component.PostProcessSettings.MotionBlurAmount = 0.0 -- Disable motion blur
    local_scene_capture_component.PostProcessSettings.bOverride_ScreenSpaceReflectionIntensity = true
    local_scene_capture_component.PostProcessSettings.ScreenSpaceReflectionIntensity = 0.0 -- Disable screen space reflections
    local_scene_capture_component.PostProcessSettings.bOverride_AmbientOcclusionIntensity = true
    local_scene_capture_component.PostProcessSettings.AmbientOcclusionIntensity = 0.0 -- Disable ambient occlusion
    local_scene_capture_component.PostProcessSettings.bOverride_BloomIntensity = true
    local_scene_capture_component.PostProcessSettings.BloomIntensity = 0.0
    local_scene_capture_component.PostProcessSettings.bOverride_LensFlareIntensity = true
    local_scene_capture_component.PostProcessSettings.LensFlareIntensity = 0.0 -- Disable lens flares
    local_scene_capture_component.PostProcessSettings.bOverride_VignetteIntensity = true
    local_scene_capture_component.PostProcessSettings.VignetteIntensity = 0.0 -- Disable vignette

    local_scene_capture_component:SetVisibility(false)
    self.scene_capture_component = local_scene_capture_component
end

function ScopeController:spawn_scope(game_engine, pawn)
    local viewport = game_engine.GameViewport
    if viewport == nil then
        print("Viewport is nil")
        return
    end

    local world = viewport.World
    if world == nil then
        print("World is nil")
        return
    end

    if not pawn then
        -- print("pawn is nil")
        return
    end

    local rt = self:get_render_target(world)

    if rt == nil then
        print("Failed to get render target destroying actors")
        self.scope_actor = utils.destroy_actor(self.scope_actor)
        self.scope_plane_component = nil
        self.scene_capture_component = nil
        return
    end

    local pawn_pos = pawn:K2_GetActorLocation()
    if not utils.validate_object(self.scope_actor) then
        self.scope_actor = utils.destroy_actor(self.scope_actor)
        self.scope_plane_component = nil
        self.scene_capture_component = nil
        self.scope_actor = utils.spawn_actor(world, self.actor_c, self.temp_vec3:set(0, 0, 0), 1, nil)
        if self.scope_actor == nil then
            print("Failed to spawn scope actor")
            return
        end
    end

    if not utils.validate_object(self.scope_plane_component) then
        print("scope_plane_component is invalid -- recreating")
        self:spawn_scope_plane(world, nil, pawn_pos, rt)
    end

    if not utils.validate_object(self.scene_capture_component) then
        print("spawn_scene_capture_component is invalid -- recreating")
        self:spawn_scene_capture_component(world, nil, pawn_pos, fov, rt)
    end

end


function ScopeController:attach_components_to_weapon(weapon_mesh)
    if not weapon_mesh then return end

    -- Attach scene capture to weapon
    if self.scene_capture_component ~= nil then
        -- scene_capture:DetachFromParent(true, false)
        -- "AimSocket"
        -- print("Attaching scene_capture_component to weapon:" .. weapon_mesh:get_fname():to_string())
        self.scene_capture_component:K2_AttachToComponent(
            weapon_mesh,
            "Muzzle",
            2, -- Location rule
            2, -- Rotation rule
            0, -- Scale rule
            true -- Weld simulated bodies
        )
        self.scene_capture_component:K2_SetRelativeRotation(self.temp_vec3:set(0, 0, 90), false, self.reusable_hit_result, false)
        self.scene_capture_component:K2_SetRelativeLocation(self.temp_vec3:set(0.5, 0, 0), false, self.reusable_hit_result, false)
        self.scene_capture_component:SetVisibility(false)
    end

    -- Attach plane to weapon
    if self.scope_plane_component then
        self.scope_mesh = self:get_scope_mesh(weapon_mesh)
        if self.scope_mesh == nil then
            print("Failed to find scope mesh")
            return
        end
        -- OpticCutoutSocket
        self.scope_mesh:SetScalarParameterValueOnMaterials("SightMaskScale", 0.0)
        self.scope_plane_component:K2_AttachToComponent(
            self.scope_mesh,
            "OpticCutoutSocket",
            2, -- Location rule
            2, -- Rotation rule
            2, -- Scale rule
            true -- Weld simulated bodies
        )
        self.scope_plane_component:K2_SetRelativeRotation(self.temp_vec3:set(0, 90, 90), false, self.reusable_hit_result, false)
        self.scope_plane_component:K2_SetRelativeLocation(self.temp_vec3:set(Config.cylinderDepth, 0, 0), false, self.reusable_hit_result, false)
        self.scope_plane_component:SetWorldScale3D(self.temp_vec3:set(0.025, 0.025, Config.cylinderDepth))
        self.scope_plane_component:SetVisibility(false)
    end
end

function ScopeController:is_scope_active(pawn)
    if not pawn then return false end
    local optical_scope = pawn.PlayerOpticScopeComponent
    if not optical_scope then return false end
    local scope_active = optical_scope:read_byte(0xA8, 1)
    if scope_active > 0 then
        return true
    end
    return false
end

function ScopeController:switch_scope_state(pawn)
    local current_scope_state = self:is_scope_active(pawn)
    -- if current_scope_state == last_scope_state then
    --     return
    -- end
    if self.scope_plane_component ~= nil then
        self.scope_plane_component:SetVisibility(current_scope_state)
    end
    if self.scene_capture_component ~= nil then
        self.scene_capture_component:SetVisibility(current_scope_state)
    end
end

function ScopeController:Get_ScopeHmdDistance()
	local scope_plane_position = self.scope_plane_component:K2_GetComponentLocation()
	local hmdPos = hmd_component:K2_GetComponentLocation()
	local Diff= math.sqrt((hmdPos.x-scope_plane_position.x)^2+(hmdPos.y-scope_plane_position.y)^2+(hmdPos.z-scope_plane_position.z)^2)
	--if Diff <=2.5 then
	--	Diff=2.5
	--end
	return Diff
end

function ScopeController:Recalculate_FOV(c_pawn)
	if self.scene_capture_component ~=nil then
		if self:Get_ScopeHmdDistance()>=5.5 then
			--pcall(function()
			fov= 30*(desiredFOV* (2* math.atan(2.5/self:Get_ScopeHmdDistance())/(90/180*math.pi)))/94
			--end)
		else
		--pcall(function()
			fov= 30*(desiredFOV* (2* math.atan(2.5/self:Get_ScopeHmdDistance())/(90/180*math.pi)))/(94-(5.5-self:Get_ScopeHmdDistance())*3^2.7)
		--end)
		end
			--print(Get_ScopeHmdDistance())
        self.scene_capture_component.FOVAngle = fov
	end
end


function ScopeController:Update(engine)
    local c_pawn = api:get_local_pawn(0)
    local weapon_mesh = GameState:GetEquippedWeapon()
    if weapon_mesh then
        -- fix_materials(weapon_mesh)
        local weapon_changed = not self.current_weapon or weapon_mesh.AnimScriptInstance ~= self.current_weapon.AnimScriptInstance
        local scope_changed = (not self.scope_mesh or not self.scope_mesh.AttachParent) and self:is_scope_active(c_pawn)
        if weapon_changed or scope_changed then
            print("Weapon changed")
            print("Previous weapon: " .. (self.current_weapon and self.current_weapon:get_fname():to_string() or "none"))
            print("New weapon: " .. weapon_mesh:get_fname():to_string())

            -- Update current weapon reference
            self.current_weapon = weapon_mesh

            -- Attempt to attach components
            self:spawn_scope(engine, c_pawn)
            self:attach_components_to_weapon(weapon_mesh)
        end
    else
        -- Weapon was removed/unequipped
        if self.current_weapon then
            print("Weapon unequipped")
            self.current_weapon = nil
            self.scope_mesh = nil
        end
    end
    self:switch_scope_state(c_pawn)
    self:Recalculate_FOV(c_pawn)
end

function ScopeController:Reset()
    self.scope_actor = utils.destroy_actor(self.scope_actor)
    self.scope_plane_component = nil
    self.scene_capture_component = nil
    self.render_target = nil
    self.scope_mesh = nil
    self.current_weapon = nil
    self.scope_material = nil
end

function ScopeController:SetScopePlaneScale(depth)
    if self.scope_plane_component then
        self.scope_plane_component:SetWorldScale3D(self.temp_vec3:set(0.025, 0.025, depth))
        self.scope_plane_component:K2_SetRelativeLocation(self.temp_vec3:set(depth, 0, 0), false, self.reusable_hit_result, false)
    end
end

local scope_controller = ScopeController:new()

uevr.sdk.callbacks.on_pre_engine_tick(
	function(engine, delta)
        if GameState:IsLevelChanged(engine) then
            scope_controller:Reset()
        end
        scope_controller:Update(engine)
    end
)


uevr.sdk.callbacks.on_script_reset(function()
    print("Resetting")
    scope_controller:Reset()
    scope_controller:ResetStatic()
end)


return scope_controller
