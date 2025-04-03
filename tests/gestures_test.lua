-- Basic gestures test module
require("luatest")
local TestHelpers = require("test_helpers")
local gestures = require("gestures")
print("\nRunning test suite...")

-- -- Test 1: Both hands near head with grip
RunTest("RH FlashLight Gesture Happy Case", function()
    TestHelpers.resetTestState()
    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)

    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) -- Ensure the mock engine is set up
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "L_down should be 0 before the test starts")

    TestHelpers.handStates.right.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1) 
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "L_down should be 0 before the test starts")

    TestHelpers.handStates.right.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "Gesture Will activate only if grip will be active in zone")

    TestHelpers.handStates.right.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "Grip Deactivate but gesture Wasn't active yet")

    TestHelpers.handStates.right.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], 1, "L_down should be 1 after the gesture is activated")
    AssertEquals(TestHelpers.keyEvents["L_up"], nil, "L_up should not exist after the gesture is activated")

    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], 1, "Gesture Remains active")
    AssertEquals(TestHelpers.keyEvents["L_up"], nil, "L_up should not exist while gesture is active")

    TestHelpers.handStates.right.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], 1, "count does not change as gesture deactivated")
    AssertEquals(TestHelpers.keyEvents["L_up"], 1, "When gesture is inactive we will send Key Up")
    AssertEquals(TestHelpers.hapticEvents["left_joystick"] or 0, 0, "Haptic event for left joystick should be triggered")
    AssertEquals(TestHelpers.hapticEvents["right_joystick"] or 0, 1, "Haptic event for right joystick should not be triggered")

    return true
end)

-- Test 2: Left hand flashlight gesture
RunTest("LH FlashLight Gesture Happy Case", function()
    TestHelpers.resetTestState()
    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)

    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "L_down should be 0 before the test starts")

    TestHelpers.handStates.left.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "L_down should be 0 before the test starts")

    TestHelpers.handStates.left.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "Gesture Will activate only if grip will be active in zone")
    
    TestHelpers.handStates.left.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], nil, "Grip Deactivate but gesture Wasn't active yet")
    
    TestHelpers.handStates.left.gripActive = true
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], 1, "L_down should be 1 after the gesture is activated")
    AssertEquals(TestHelpers.keyEvents["L_up"], nil, "L_up should not exist after the gesture is activated")
    
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], 1, "Gesture Remains active")
    AssertEquals(TestHelpers.keyEvents["L_up"], nil, "L_up should not exist while gesture is active")

    TestHelpers.handStates.left.gripActive = false
    TestHelpers.preEngineTickCallback(TestHelpers.mockEngine, 0.1)
    AssertEquals(TestHelpers.keyEvents["L_down"], 1, "count does not change as gesture deactivated")
    AssertEquals(TestHelpers.keyEvents["L_up"], 1, "When gesture is inactive we will send Key Up")
    AssertEquals(TestHelpers.hapticEvents["right_joystick"] or 0, 0, "Haptic event for right joystick should be triggered")
    AssertEquals(TestHelpers.hapticEvents["left_joystick"] or 0, 1, "Haptic event for left joystick should not be triggered")
    
    return true
end)
