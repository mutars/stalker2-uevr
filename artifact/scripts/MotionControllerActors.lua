local MotionControllerActors = {}

-- Helper functions for finding objects
local function find_required_object(name)
    local obj = uevr.api:find_uobject(name)
    if not obj then
        error("Cannot find " .. name)
        return nil
    end

    return obj
end

local function find_static_class(name)
    local c = find_required_object(name)
    return c:get_class_default_object()
end

-- Initialize the module
function MotionControllerActors:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self

    instance.hmd_actor = nil
    instance.left_hand_actor = nil
    instance.right_hand_actor = nil
    instance.left_hand_component = nil
    instance.right_hand_component = nil
    instance.hmd_component = nil
    
    -- Required UObject classes
    instance.game_engine_class = find_required_object("Class /Script/Engine.GameEngine")
    instance.actor_c = find_required_object("Class /Script/Engine.Actor")
    instance.motion_controller_component_c = find_required_object("Class /Script/HeadMountedDisplay.MotionControllerComponent")
    instance.scene_component_c = find_required_object("Class /Script/Engine.SceneComponent")
    instance.ftransform_c = find_required_object("ScriptStruct /Script/CoreUObject.Transform")
    instance.temp_transform = StructObject.new(instance.ftransform_c)
    instance.kismet_string_library = find_static_class("Class /Script/Engine.KismetStringLibrary")
    instance.statics = find_static_class("Class /Script/Engine.GameplayStatics")

    return instance
end

-- Spawn an actor at the given location
function MotionControllerActors:spawn_actor(world_context, actor_class, location, collision_method, owner)
    self.temp_transform.Translation = location
    self.temp_transform.Rotation.W = 1.0
    self.temp_transform.Scale3D = Vector3f.new(1.0, 1.0, 1.0)

    local actor = self.statics:BeginDeferredActorSpawnFromClass(world_context, actor_class, self.temp_transform, collision_method, owner)

    if actor == nil then
        print("Failed to spawn actor")
        return nil
    end

    self.statics:FinishSpawningActor(actor, self.temp_transform)

    return actor
end

-- Get the game world
function MotionControllerActors:GetWorld()
    local engine = UEVR_UObjectHook.get_first_object_by_class(self.game_engine_class)
    
    if not engine then
        return nil
    end

    local viewport = engine.GameViewport
    if not viewport then
        return nil
    end

    return viewport.World
end

-- Reset all hand actors
function MotionControllerActors:Reset()
    -- We are using pcall on this because for some reason the actors are not always valid
    -- even if exists returns true
    if self.left_hand_actor ~= nil and UEVR_UObjectHook.exists(self.left_hand_actor) then
        pcall(function()
            if self.left_hand_actor.K2_DestroyActor ~= nil then
                self.left_hand_actor:K2_DestroyActor()
            end
        end)
    end

    if self.right_hand_actor ~= nil and UEVR_UObjectHook.exists(self.right_hand_actor) then
        pcall(function()
            if self.right_hand_actor.K2_DestroyActor ~= nil then
                self.right_hand_actor:K2_DestroyActor()
            end
        end)
    end

    if self.hmd_actor ~= nil and UEVR_UObjectHook.exists(self.hmd_actor) then
        pcall(function()
            if self.hmd_actor.K2_DestroyActor ~= nil then
                self.hmd_actor:K2_DestroyActor()
            end
        end)
    end

    self.left_hand_actor = nil
    self.right_hand_actor = nil
    self.hmd_actor = nil
    self.left_hand_component = nil
    self.right_hand_component = nil
    self.hmd_component = nil
end

-- Check if any hand actors have been deleted and return if they need to be respawned
function MotionControllerActors:Validate()
    if self.left_hand_actor ~= nil and not UEVR_UObjectHook.exists(self.left_hand_actor) then
        self.left_hand_actor = nil
        self.left_hand_component = nil
    end

    if self.right_hand_actor ~= nil and not UEVR_UObjectHook.exists(self.right_hand_actor) then
        self.right_hand_actor = nil
        self.right_hand_component = nil
    end

    if self.hmd_actor ~= nil and not UEVR_UObjectHook.exists(self.hmd_actor) then
        self.hmd_actor = nil
        self.hmd_component = nil
    end
    
    return self.left_hand_actor == nil or self.right_hand_actor == nil or self.hmd_actor == nil
end

-- Initialize hand actors
function MotionControllerActors:Init()
    local world = self:GetWorld()
    if not world then
        print("World is nil")
        return false
    end

    local pawn = uevr.api:get_local_pawn(0)
    if not pawn then
        print("Pawn is nil")
        return false
    end

    local pos = pawn:K2_GetActorLocation()

    -- Create actors
    self.left_hand_actor = self:spawn_actor(world, self.actor_c, pos, 1, nil)
    self.right_hand_actor = self:spawn_actor(world, self.actor_c, pos, 1, nil)
    self.hmd_actor = self:spawn_actor(world, self.actor_c, pos, 1, nil)

    if not self.left_hand_actor or not self.right_hand_actor or not self.hmd_actor then
        print("Failed to spawn actors")
        return false
    end

    -- Add scene components
    self.left_hand_component = uevr.api:add_component_by_class(self.left_hand_actor, self.motion_controller_component_c)
    self.right_hand_component = uevr.api:add_component_by_class(self.right_hand_actor, self.motion_controller_component_c)
    self.hmd_component = uevr.api:add_component_by_class(self.hmd_actor, self.scene_component_c)

    if not self.left_hand_component or not self.right_hand_component or not self.hmd_component then
        print("Failed to add components")
        return false
    end

    -- Set up motion sources
    self.left_hand_component.MotionSource = self.kismet_string_library:Conv_StringToName("Left")
    self.right_hand_component.MotionSource = self.kismet_string_library:Conv_StringToName("Right")

    -- Not all engine versions have the Hand property
    if self.left_hand_component.Hand ~= nil then
        self.left_hand_component.Hand = 0
        self.right_hand_component.Hand = 1
    end

    -- The HMD is the only one we need to add manually as UObjectHook doesn't support motion controller components as the HMD
    local hmdstate = UEVR_UObjectHook.get_or_add_motion_controller_state(self.hmd_component)
    if hmdstate then
        hmdstate:set_hand(2) -- HMD
        hmdstate:set_permanent(true)
    end

    return true
end

-- Get hand component by index (0=HMD, 1=Left, 2=Right)
function MotionControllerActors:GetHandComponent(index)
    if index == 0 then
        return self.hmd_component
    elseif index == 1 then
        return self.left_hand_component
    elseif index == 2 then
        return self.right_hand_component
    end
    return nil
end

-- Get location by index (0=HMD, 1=Left, 2=Right)
function MotionControllerActors:GetLocationByIndex(index)
    local component = self:GetHandComponent(index)
    if component then
        return component:K2_GetComponentLocation()
    end
    return Vector3f.new(0, 0, 0)
end

-- Get rotation by index (0=HMD, 1=Left, 2=Right)
function MotionControllerActors:GetRotationByIndex(index)
    local component = self:GetHandComponent(index)
    if component then
        return component:K2_GetComponentRotation()
    end
    return Vector3f.new(0, 0, 0)
end

-- Legacy functions for compatibility
function MotionControllerActors:GetLeftHand()
    return self.left_hand_component
end

function MotionControllerActors:GetRightHand()
    return self.right_hand_component
end

function MotionControllerActors:GetHMD()
    return self.hmd_component
end

-- Return the module
return MotionControllerActors
