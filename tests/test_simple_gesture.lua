--[[
    test_simple_gesture.lua
    Basic example of how to test gestures using our test framework
]]--

local LuaTest = require("tests.luatest")
local GestureBase = require("GestureBase")

-- A simple test gesture for demonstration
local SimpleGesture = GestureBase:new({
    name = "Simple Test Gesture",
    testValue = false
})

function SimpleGesture:EvaluateInternal(context)
    -- This gesture is simply controlled by the testValue property
    return self.testValue
end

-- Test the simple gesture
LuaTest.test("SimpleGesture creation", function()
    local gesture = SimpleGesture:new({ name = "Test Instance" })
    LuaTest.assertEquals("Test Instance", gesture.name, "Gesture name should be set correctly")
    LuaTest.assertFalse(gesture.isActive, "Gesture should start inactive")
    LuaTest.assertFalse(gesture.wasActive, "Gesture wasActive should start false")
end)

-- Test the simple gesture
LuaTest.test("Multiple Instances creation", function()
    local gesture = SimpleGesture:new({ name = "Test Instance" })
    local gesture2 = SimpleGesture:new({ name = "Test Instance 2" })
    LuaTest.assertEquals("Test Instance", gesture.name, "Gesture name should be set correctly")
    LuaTest.assertEquals("Test Instance 2", gesture2.name, "Gesture name should be set correctly")
    LuaTest.assertFalse(gesture.id == gesture2.id, "Gesture IDs should be unique")
end)

LuaTest.test("SimpleGesture activation", function()
    local gesture = SimpleGesture:new()
    local context = {}
    
    -- Initially the gesture should be inactive
    LuaTest.assertFalse(gesture.isActive, "Gesture should start inactive")
    
    -- Setting testValue to true should activate the gesture on the next evaluation
    gesture.testValue = true
    gesture:Evaluate(context)
    LuaTest.assertTrue(gesture.isActive, "Gesture should be active after setting testValue to true")
    LuaTest.assertTrue(gesture:JustActivated(), "JustActivated should be true")
    
    -- Run evaluate again, the gesture should still be active but not "just activated"
    gesture:Evaluate(context)
    LuaTest.assertTrue(gesture.isActive, "Gesture should remain active")
    LuaTest.assertFalse(gesture:JustActivated(), "JustActivated should be false on second frame")
    
    -- Now deactivate and test
    gesture.testValue = false
    gesture:Evaluate(context)
    LuaTest.assertFalse(gesture.isActive, "Gesture should be inactive after setting testValue to false")
    LuaTest.assertTrue(gesture:JustDeactivated(), "JustDeactivated should be true")
end)

-- Run all the tests and print results
local success = LuaTest.runAll()
return success