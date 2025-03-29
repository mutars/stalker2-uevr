--[[
    test_nested_gestures.lua
    Tests to verify that nested gestures are evaluated in the correct order
]]--

local LuaTest = require("tests.luatest")
local GestureBase = require("GestureBase")
local GestureSet = require("GestureSet")

-- Create mock gestures that track their evaluation order
local evaluationOrder = {}

local function createOrderedGesture(name, dependencies)
    local gesture = GestureBase:new({
        name = name,
        dependencies = dependencies or {},
        evaluationCount = 0
    })

    function gesture:EvaluateInternal(context)
        self.evaluationCount = self.evaluationCount + 1
        table.insert(evaluationOrder, self.name)
        return true
    end

    return gesture
end

-- Test basic dependency chain
LuaTest.test("Basic dependency chain evaluation order", function()
    -- Clear evaluation order
    evaluationOrder = {}
    
    -- Create a chain of dependent gestures
    local leafGesture = createOrderedGesture("Leaf")
    local middleGesture = createOrderedGesture("Middle", {leafGesture})
    local rootGesture = createOrderedGesture("Root", {middleGesture})
    
    -- Create a gesture set and add the root gesture
    local gestureSet = GestureSet:new()
    gestureSet:Init()
    table.insert(gestureSet.rootGestures, rootGesture)
    
    -- Update the gesture set
    gestureSet:Update({})
    
    -- Verify evaluation order
    LuaTest.assertEquals("Leaf", evaluationOrder[1], "Leaf gesture should be evaluated first")
    LuaTest.assertEquals("Middle", evaluationOrder[2], "Middle gesture should be evaluated second")
    LuaTest.assertEquals("Root", evaluationOrder[3], "Root gesture should be evaluated last")
    LuaTest.assertEquals(3, #evaluationOrder, "All gestures should be evaluated exactly once")
end)

-- Test diamond dependency pattern
LuaTest.test("Diamond dependency pattern evaluation", function()
    -- Clear evaluation order
    evaluationOrder = {}
    
    -- Create a diamond pattern of dependencies:
    --      Root
    --     /    \
    --   Left  Right
    --     \    /
    --      Base
    local baseGesture = createOrderedGesture("Base")
    local leftGesture = createOrderedGesture("Left", {baseGesture})
    local rightGesture = createOrderedGesture("Right", {baseGesture})
    local rootGesture = createOrderedGesture("Root", {leftGesture, rightGesture})
    
    -- Create a gesture set and add the root gesture
    local gestureSet = GestureSet:new()
    gestureSet:Init()
    table.insert(gestureSet.rootGestures, rootGesture)
    
    -- Update the gesture set
    gestureSet:Update({})
    
    -- Verify the base gesture is evaluated only once
    local baseCount = 0
    for _, name in ipairs(evaluationOrder) do
        if name == "Base" then
            baseCount = baseCount + 1
        end
    end
    LuaTest.assertEquals(1, baseCount, "Base gesture should be evaluated exactly once")
    LuaTest.assertEquals("Base", evaluationOrder[1], "Base gesture should be evaluated first")
    LuaTest.assertEquals(4, #evaluationOrder, "All gestures should be evaluated exactly once")
end)

-- Test multiple root gestures with shared dependencies
LuaTest.test("Multiple root gestures with shared dependencies", function()
    -- Clear evaluation order
    evaluationOrder = {}
    
    -- Create two root gestures that share a common dependency
    local sharedDep = createOrderedGesture("Shared")
    local root1 = createOrderedGesture("Root1", {sharedDep})
    local root2 = createOrderedGesture("Root2", {sharedDep})
    
    -- Create a gesture set and add both root gestures
    local gestureSet = GestureSet:new()
    gestureSet:Init()
    table.insert(gestureSet.rootGestures, root1)
    table.insert(gestureSet.rootGestures, root2)
    
    -- Update the gesture set
    gestureSet:Update({})
    
    -- Verify the shared dependency is evaluated only once
    local sharedCount = 0
    for _, name in ipairs(evaluationOrder) do
        if name == "Shared" then
            sharedCount = sharedCount + 1
        end
    end
    LuaTest.assertEquals(1, sharedCount, "Shared dependency should be evaluated exactly once")
    LuaTest.assertEquals("Shared", evaluationOrder[1], "Shared dependency should be evaluated first")
    LuaTest.assertEquals(3, #evaluationOrder, "All gestures should be evaluated exactly once")
end)

-- Run all the tests and print results
local success = LuaTest.runAll()
return success