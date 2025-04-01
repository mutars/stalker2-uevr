-- Basic gestures test module
package.path = "/workspaces/stalker2-uevr/artifact/scripts/?.lua;/workspaces/stalker2-uevr/artifact/scripts/?/init.lua;" .. package.path

local TestHelpers = require("tests.test_helpers")
local FlashlightGesture = require("gestures.FlashlightGesture")
print("\nRunning test suite...")

-- -- Test 1: Both hands near head with grip
TestHelpers.runTest("LH FlashLight Gesture Happy Case", function()
    TestHelpers.resetTestState()
    -- Set up left hand
    local leftHandFlashLight = FlashlightGesture.flashlightGestureLH
    TestHelpers.handStates.left.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.handStates.left.rotation = Vector3f.new(0, 45, 0)
    TestHelpers.handStates.left.gripActive = false

    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)
    TestHelpers.handStates.hmd.rotation = Vector3f.new(0, 0, 0)

    -- Test right hand head zone
    leftHandFlashLight:Reset()
    local Executed = false
    leftHandFlashLight:SetExecutionCallback(function(gesture, context)
        print("Left Hand Flashlight Gesture Executed")
        Executed = true
    end)

    local actors = require("gestures.MotionControllerActors")
    actors:Update(TestHelpers.mockEngine)
    leftHandFlashLight:Update({}, {})

    assert(not leftHandFlashLight.isActive, "Flashlight gesture should not be active initially")
    assert(not leftHandFlashLight:JustActivated(), "Flashlight gesture should not be activated initially")
    TestHelpers.handStates.left.gripActive = true
    actors:Update(TestHelpers.mockEngine)
    leftHandFlashLight:Update({}, {})
    assert(leftHandFlashLight.isActive, "Flashlight gesture should be active when grip is pressed")
    assert(leftHandFlashLight:JustActivated(), "Flashlight gesture should be newly activated")
    assert(leftHandFlashLight.gripGesture:IsLocked(), "Grip gesture should be locked when active")

    leftHandFlashLight:Execute({})
    assert(Executed, "Flashlight gesture callback should have executed")

    TestHelpers.handStates.left.location.y = 1.0;
    leftHandFlashLight:Update({}, {})
    Executed = false
    leftHandFlashLight:Execute({})
    assert(not Executed, "Flashlight gesture should not execute when hand is out of head range")
    assert(not leftHandFlashLight.gripGesture:IsLocked(), "Grip gesture should not be locked when out of range")
    assert(not leftHandFlashLight.isActive, "Flashlight gesture should not be active when out of range")
    assert(leftHandFlashLight:JustDeactivated(), "Flashlight gesture should be deactivated when moving out of range")
    leftHandFlashLight:SetExecutionCallback(nil) -- Clear the callback to avoid side effects in subsequent tests
    return true
end)

-- Test 2: Right Hand Flashlight Gesture
TestHelpers.runTest("RH FlashLight Gesture Happy Case", function()
    TestHelpers.resetTestState()
    -- Set up right hand
    local rightHandFlashLight = FlashlightGesture.flashlightGestureRH
    TestHelpers.handStates.right.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.handStates.right.rotation = Vector3f.new(0, 45, 0)
    TestHelpers.handStates.right.gripActive = false

    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)
    TestHelpers.handStates.hmd.rotation = Vector3f.new(0, 0, 0)

    -- Test right hand head zone
    rightHandFlashLight:Reset()
    local Executed = false
    rightHandFlashLight:SetExecutionCallback(function(gesture, context)
        print("Right Hand Flashlight Gesture Executed")
        Executed = true
    end)

    local actors = require("gestures.MotionControllerActors")
    actors:Update(TestHelpers.mockEngine)
    rightHandFlashLight:Update({}, {})

    assert(rightHandFlashLight.headZone.isActive, "HMD zone should be active when HMD is in range")
    assert(not rightHandFlashLight.isActive, "Flashlight gesture should not be active initially")
    assert(not rightHandFlashLight:JustActivated(), "Flashlight gesture should not be activated initially")
    
    TestHelpers.handStates.right.gripActive = true
    actors:Update(TestHelpers.mockEngine)
    rightHandFlashLight:Update({}, {})
    assert(rightHandFlashLight.isActive, "Flashlight gesture should be active when grip is pressed")
    assert(rightHandFlashLight:JustActivated(), "Flashlight gesture should be newly activated")
    assert(rightHandFlashLight.gripGesture:IsLocked(), "Grip gesture should be locked when active")

    rightHandFlashLight:Execute({})
    assert(Executed, "Flashlight gesture callback should have executed")

    TestHelpers.handStates.right.location.y = 1.0;
    rightHandFlashLight:Update({}, {})
    Executed = false
    rightHandFlashLight:Execute({})
    assert(not Executed, "Flashlight gesture should not execute when hand is out of head range")
    assert(not rightHandFlashLight.gripGesture:IsLocked(), "Grip gesture should not be locked when out of range")
    assert(not rightHandFlashLight.isActive, "Flashlight gesture should not be active when out of range")
    assert(rightHandFlashLight:JustDeactivated(), "Flashlight gesture should be deactivated when moving out of range")
    return true
end)
