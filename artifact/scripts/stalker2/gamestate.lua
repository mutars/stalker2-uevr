local utils = require("common.utils")

local GameStateManager = {
    -- State tracking
    inMenu = false,
    isInventoryPDA = false,
    lastWorldTime = 0,
    worldTimeTick = 0,
    initialized = false,
    last_level = nil,
    StaticMeshC = nil,
    -- API reference
    api = nil
}

-- Initialize the GameStateManager
function GameStateManager:Init()
    self.api = uevr.api
    self.inMenu = false
    self.isInventoryPDA = false
    self.lastWorldTime = 0
    self.worldTimeTick = 0
    self.last_level = nil
    self.initialized = true
    self.StaticMeshC = utils.find_required_object("Class /Script/Engine.StaticMeshComponent")
    print("GameStateManager initialized")
end

-- Reset the GameStateManager state
function GameStateManager:Reset()
    self:Init()
    print("GameStateManager reset")
end

-- Update function to be called on engine tick
function GameStateManager:Update()
    self:CheckMenuState()
    self:CheckInventoryPDAState()
end

-- Check if the player is in a menu
function GameStateManager:CheckMenuState()
    local worldTime = self:GetWorldTime()

    if worldTime == self.lastWorldTime then
        self.worldTimeTick = self.worldTimeTick + 1
        if self.worldTimeTick >= 50 then
            self.inMenu = true
        end
    else
        self.inMenu = false
        self.worldTimeTick = 0
    end

    self.lastWorldTime = worldTime
end

-- Check if player is in inventory or PDA
function GameStateManager:CheckInventoryPDAState()
    local pawn = self:GetLocalPawn()
    if pawn and pawn.Mesh and pawn.Mesh.AnimScriptInstance and
       pawn.Mesh.AnimScriptInstance.HandItemData then
        local check1 = pawn.Mesh.AnimScriptInstance.HandItemData.bHasItemInHands
        local check2 = pawn.Mesh.AnimScriptInstance.HandItemData.bIsUsesLeftHand
        local check3 = pawn.Mesh.AnimScriptInstance.HandItemData.bIsUsesRightHand
        if check1 and check2 and check3 then
            self.isInventoryPDA = true
        else
            self.isInventoryPDA = false
        end
    end
end


function GameStateManager:is_scope_active(pawn)
    if not pawn then return false end
    local optical_scope = pawn.PlayerOpticScopeComponent
    if not optical_scope then return false end
    local scope_active = optical_scope:read_byte(0xA8, 1)
    if scope_active > 0 then
        return true
    end
    return false
end

function GameStateManager:get_scope_mesh(parent_mesh)
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

-- Get current world time
function GameStateManager:GetWorldTime()
    local engine = self.api:get_engine()
    if engine and engine.GameViewport and engine.GameViewport.World and
       engine.GameViewport.World.GameState then
        return engine.GameViewport.World.GameState.ReplicatedWorldTimeSeconds
    end
    return 0
end

-- Get local player pawn
function GameStateManager:GetLocalPawn()
    return self.api:get_local_pawn(0)
end

function GameStateManager:IsLevelChanged(engine)
    local viewport = engine.GameViewport
    if viewport then
        local world = viewport.World
        if world then
            local level = world.PersistentLevel
            if self.last_level ~= level then
                self.last_level = level
                return true
            end
        end
    end
    return false
end

-- Send a key press (down or up)
function GameStateManager:SendKeyPress(key_value, key_up)
    local key_up_string = "down"
    if key_up == true then
        key_up_string = "up"
    end

    self.api:dispatch_custom_event(key_value, key_up_string)
end

-- Send key down
function GameStateManager:SendKeyDown(key_value)
    self:SendKeyPress(key_value, false)
end

-- Send key up
function GameStateManager:SendKeyUp(key_value)
    self:SendKeyPress(key_value, true)
end

-- Get current equipped weapon
function GameStateManager:GetEquippedWeapon()
    local pawn = self:GetLocalPawn()
    if not pawn then return nil end
    local sk_mesh = pawn.Mesh
    if not sk_mesh then return nil end
    local anim_instance = sk_mesh.AnimScriptInstance
    if not anim_instance then return nil end
    local weapon_mesh = anim_instance.WeaponData.WeaponMesh
    return weapon_mesh
end

-- Get game engine
function GameStateManager:GetEngine()
    return self.api:get_engine()
end

-- Create a new instance
function GameStateManager:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance:Init()
    return instance
end

return GameStateManager
