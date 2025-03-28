--[[
    FlashlightGesture.lua
    Gesture that activates when a motion controller is near the head and grip button is pressed
]]--

local GestureBase = require("artifact.scripts.gestures.GestureBase")

-- FlashlightGesture: Activates when controller is near head with grip pressed
local FlashlightGesture = GestureBase:new({
    name = "Flashlight Gesture",
    
    -- The grip gesture to check for grip button
    gripGesture = nil,
    
    -- The zone around the head to detect
    headZone = nil,
})

function FlashlightGesture:new(config)
    if not config.gripGesture or not config.headZone then
        error("gripGesture and headZone are required for FlashlightGesture")
    end
    
    -- Set up dependencies
    config.dependencies = {
        config.gripGesture,
        config.headZone
    }

    setmetatable(config, self)
    self.__index = self
    return config
end

function FlashlightGesture:EvaluateInternal(context)
    if self.gripGesture:isLocked() then
        return
    end
    self.isActive = self.gripGesture:JustActivated() and self.headZone:isActive()
    if self.isActive and not self.wasActive then
        self.gripGesture:Lock()
    end
end

return {
    FlashlightGesture = FlashlightGesture
}