local GameStateManager = {
    -- State tracking
    inMenu = false,
    isInventoryPDA = false,
    lastWorldTime = 0,
    worldTimeTick = 0,
    initialized = false,

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
    self.initialized = true
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
function GameStateManager:GetCurrentWeapon()
    local pawn = self:GetLocalPawn()
    if pawn and pawn.Inventory then
        return pawn.Inventory:GetPrimaryWeapon()
    end
    return nil
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
