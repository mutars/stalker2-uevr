-- Basic gestures test module
package.path = "/workspaces/stalker2-uevr/artifact/scripts/?.lua;/workspaces/stalker2-uevr/artifact/scripts/?/init.lua;" .. package.path

local TestHelpers = require("tests.test_helpers")
local gestures = require("gestures")
print("\nRunning test suite...")

-- -- Test 1: Both hands near head with grip
TestHelpers.runTest("RH FlashLight Gesture Happy Case", function()
    TestHelpers.resetTestState()
    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)

    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) -- Ensure the mock engine is set up
    assert(not TestHelpers.keyEvents["L_down"], "L_down should be 0 before the test starts")

    TestHelpers.handStates.right.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) 
    assert(not TestHelpers.keyEvents["L_down"], "L_down should be 0 before the test starts")

    TestHelpers.handStates.right.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(not TestHelpers.keyEvents["L_down"], "Gesture Will activate only if grip will be active in zone")
    TestHelpers.handStates.right.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) -- Re-update the state to ensure the grip is released
    assert(not TestHelpers.keyEvents["L_down"], "Grip Deactivate but gesture Wasn't active yet")
    TestHelpers.handStates.right.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) -- Re-update the state to ensure the grip is active
    assert(TestHelpers.keyEvents["L_down"] == 1, "L_down should be 1 after the gesture is activated")
    assert(not TestHelpers.keyEvents["L_up"], "L_down should be 1 after the gesture is activated")
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(TestHelpers.keyEvents["L_down"] == 1, "Gesture Remains active")
    assert(not TestHelpers.keyEvents["L_up"], "Gesture Remains active")

    TestHelpers.handStates.right.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) -- Re-update the state to ensure the grip is released
    assert(TestHelpers.keyEvents["L_down"] == 1, "cound does not change as gesture deactivated")
    assert(TestHelpers.keyEvents["L_up"] == 1, "When gesture is inactive we will send Key Up")
    return true
end)

-- Test 2: Left hand flashlight gesture
TestHelpers.runTest("LH FlashLight Gesture Happy Case", function()
    TestHelpers.resetTestState()
    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)

    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(not TestHelpers.keyEvents["L_down"], "L_down should be 0 before the test starts")

    TestHelpers.handStates.left.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(not TestHelpers.keyEvents["L_down"], "L_down should be 0 before the test starts")

    TestHelpers.handStates.left.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(not TestHelpers.keyEvents["L_down"], "Gesture Will activate only if grip will be active in zone")
    
    TestHelpers.handStates.left.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(not TestHelpers.keyEvents["L_down"], "Grip Deactivate but gesture Wasn't active yet")
    
    TestHelpers.handStates.left.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(TestHelpers.keyEvents["L_down"] == 1, "L_down should be 1 after the gesture is activated")
    assert(not TestHelpers.keyEvents["L_up"], "L_down should be 1 after the gesture is activated")
    
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(TestHelpers.keyEvents["L_down"] == 1, "Gesture Remains active")
    assert(not TestHelpers.keyEvents["L_up"], "Gesture Remains active")

    TestHelpers.handStates.left.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    assert(TestHelpers.keyEvents["L_down"] == 1, "count does not change as gesture deactivated")
    assert(TestHelpers.keyEvents["L_up"] == 1, "When gesture is inactive we will send Key Up")
    return true
end)
