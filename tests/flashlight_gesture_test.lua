-- Basic gestures test module
local TestHelpers = require("tests.test_helpers")

local FlashlightGesture = require("gestures.FlashlightGesture")
print("\nRunning test suite...")

-- -- Test 1: Both hands near head with grip
TestHelpers.runTest("FlashLight Gesture Happy Case", function()
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

    assert(not leftHandFlashLight.isActive, "Girp Is not active")
    assert(not leftHandFlashLight:JustActivated(), "Girp is not activated")
    TestHelpers.handStates.left.gripActive = true
    actors:Update(TestHelpers.mockEngine)
    leftHandFlashLight:Update({}, {})
    assert(leftHandFlashLight.isActive, "Girp Is active")
    assert(leftHandFlashLight:JustActivated(), "Girp is activated")
    assert(leftHandFlashLight.gripGesture:isLocked(), "Girp is activated")

    leftHandFlashLight:Execute({})
    assert(Executed, "Girp is not executed")

    TestHelpers.handStates.left.location.y = 1.0;
    leftHandFlashLight:Update({}, {})

    assert(not leftHandFlashLight.isActive, "Girp Is active")
    assert(leftHandFlashLight:JustDeactivated(), "Girp should not be activated when out of range")
    return true
end)
