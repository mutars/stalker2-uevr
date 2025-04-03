local TestHelpers = require("test_helpers")
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
    local Executed = 0
    leftHandFlashLight:SetActivationCallback(function(gesture, context)
        print("Left Hand Flashlight Gesture Executed")
        Executed = Executed + 1
    end)

    leftHandFlashLight:SetDeactivationCallback(function(gesture, context)
        print("Left Hand Flashlight Gesture Executed")
        Executed = Executed - 1
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

    leftHandFlashLight:Execute({})
    assert(Executed == 1, "Flashlight gesture callback should have executed")

    leftHandFlashLight:Update({}, {})
    leftHandFlashLight:Execute({})
    assert(Executed == 1, "We execute gesture only once when it just activated")

    TestHelpers.handStates.left.location.y = 6.0;
    leftHandFlashLight:Update({}, {})
    leftHandFlashLight:Execute({})
    assert(not leftHandFlashLight.isActive, "Flashlight gesture should not be active when out of range")
    assert(leftHandFlashLight:JustDeactivated(), "Flashlight gesture should be deactivated when moving out of range")
    assert(Executed == 0, "Deactivating Gesture once")

    leftHandFlashLight:Update({}, {})
    leftHandFlashLight:Execute({})
    assert(Executed == 0, "Deactivating Gesture once")

    leftHandFlashLight:SetActivationCallback(nil) -- Clear the callback to avoid side effects in subsequent tests
    leftHandFlashLight:SetDeactivationCallback(nil) -- Clear the callback to avoid side effects in subsequent tests
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
    local Executed = 0
    rightHandFlashLight:SetActivationCallback(function(gesture, context)
        print("Right Hand Flashlight Gesture Executed")
        Executed = Executed + 1
    end)

    rightHandFlashLight:SetDeactivationCallback(function(gesture, context)
        print("Right Hand Flashlight Gesture Deactivated")
        Executed = Executed - 1
    end)

    local actors = require("gestures.MotionControllerActors")
    actors:Update(TestHelpers.mockEngine)
    rightHandFlashLight:Update({}, {})

    assert(not rightHandFlashLight.isActive, "Flashlight gesture should not be active initially")
    assert(not rightHandFlashLight:JustActivated(), "Flashlight gesture should not be activated initially")
    TestHelpers.handStates.right.gripActive = true
    actors:Update(TestHelpers.mockEngine)
    rightHandFlashLight:Update({}, {})
    assert(rightHandFlashLight.isActive, "Flashlight gesture should be active when grip is pressed")
    assert(rightHandFlashLight:JustActivated(), "Flashlight gesture should be newly activated")

    rightHandFlashLight:Execute({})
    assert(Executed == 1, "Flashlight gesture callback should have executed once")

    rightHandFlashLight:Update({}, {})
    rightHandFlashLight:Execute({})
    assert(Executed == 1, "We execute gesture only once when it just activated")

    TestHelpers.handStates.right.location.y = 10.0;
    rightHandFlashLight:Update({}, {})
    rightHandFlashLight:Execute({})
    assert(not rightHandFlashLight.isActive, "Flashlight gesture should not be active when out of range")
    assert(rightHandFlashLight:JustDeactivated(), "Flashlight gesture should be deactivated when moving out of range")
    assert(Executed == 0, "Deactivating Gesture once")

    rightHandFlashLight:Update({}, {})
    rightHandFlashLight:Execute({})
    assert(Executed == 0, "Deactivating Gesture once")

    rightHandFlashLight:SetActivationCallback(nil) -- Clear the callback to avoid side effects in subsequent tests
    rightHandFlashLight:SetDeactivationCallback(nil) -- Clear the callback to avoid side effects in subsequent tests
    return true
end)
