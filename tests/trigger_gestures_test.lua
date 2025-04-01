-- Basic gestures test module
local TestHelpers = require("tests.test_helpers")

print("\nRunning test suite...")

TestHelpers.runTest("Left Grip Action", function()
    TestHelpers.resetTestState()

    local MotionControllerGestures = require("gestures.MotionControllerGestures")
    local leftGripAction = MotionControllerGestures.LeftGripAction

    leftGripAction:Reset()
    local executed = false
    leftGripAction:SetExecutionCallback(function(gesture, context)
        executed = true
    end)

    TestHelpers.handStates.left.gripActive = false

    leftGripAction:Update({}, {})
    assert(not leftGripAction:JustDeactivated(), "Left Grip Action should not be active")
    -- Create a new visited table for first update
    leftGripAction:Update({}, {})
    -- Check the isActive property directly
    assert(not leftGripAction.isActive, "Left Grip Action should not be active")
    assert(not leftGripAction:JustDeactivated(), "Left Grip Action should not be recently deactivated")

    leftGripAction:Execute({})
    assert(not executed, "Left Grip Action should not have executed")

    -- Now let's test activation
    TestHelpers.handStates.left.gripActive = true

    -- Create a new visited table for second update
    leftGripAction:Update({}, {})
    assert(leftGripAction.isActive, "Left Grip Action should now be active")
    assert(leftGripAction:JustActivated(), "Left Grip Action should have just activated")

    leftGripAction:Execute({})
    assert(executed, "Left Grip Action should have executed")

    leftGripAction:SetExecutionCallback(nil)
    return true
end)

TestHelpers.runTest("Right Grip Action", function()
    TestHelpers.resetTestState()

    local MotionControllerGestures = require("gestures.MotionControllerGestures")
    local rightGripAction = MotionControllerGestures.RightGripAction

    rightGripAction:Reset()
    local executed = false
    rightGripAction:SetExecutionCallback(function(gesture, context)
        executed = true
    end)

    TestHelpers.handStates.right.gripActive = false

    rightGripAction:Update({}, {})
    assert(not rightGripAction:JustDeactivated(), "Right Grip Action should not be active")
    -- Create a new visited table for first update
    rightGripAction:Update({}, {})
    -- Check the isActive property directly
    assert(not rightGripAction.isActive, "Right Grip Action should not be active")
    assert(not rightGripAction:JustDeactivated(), "Right Grip Action should not be recently deactivated")

    rightGripAction:Execute({})
    assert(not executed, "Right Grip Action should not have executed")

    -- Now let's test activation
    TestHelpers.handStates.right.gripActive = true

    -- Create a new visited table for second update
    rightGripAction:Update({}, {})
    assert(rightGripAction.isActive, "Right Grip Action should now be active")
    assert(rightGripAction:JustActivated(), "Right Grip Action should have just activated")

    rightGripAction:Execute({})
    assert(executed, "Right Grip Action should have executed")

    rightGripAction:SetExecutionCallback(nil)
    return true
end)


-- -- Test 1: Both hands near head with grip
TestHelpers.runTest("Both hands near head with grip", function()
    TestHelpers.resetTestState()
    -- Set up left hand
    TestHelpers.handStates.left.location = Vector3f.new(0.0, 0.0, 1.7)
    TestHelpers.handStates.left.rotation = Vector3f.new(0, 45, 0)
    TestHelpers.handStates.left.gripActive = true
    
    -- Set up right hand
    TestHelpers.handStates.right.location = Vector3f.new(-0.0, 0.0, 1.7)
    TestHelpers.handStates.right.rotation = Vector3f.new(0, -45, 0)
    TestHelpers.handStates.right.gripActive = true

    TestHelpers.handStates.hmd.location = Vector3f.new(0, 0, 1.7)
    TestHelpers.handStates.hmd.rotation = Vector3f.new(0, 0, 0)

    local MotionControllerGestures = require("gestures.BodyZones")
    local headZoneRH = MotionControllerGestures.headZoneRH
    local headZoneLH = MotionControllerGestures.headZoneLH
    local actors = require("gestures.MotionControllerActors")

    -- Test right hand head zone
    headZoneRH:Reset()
    local rhExecuted = false
    headZoneRH:SetExecutionCallback(function(gesture, context)
        print("Right Hand Head Zone Executed")
        rhExecuted = true
    end)

    actors:Update(TestHelpers.mockEngine)
    headZoneRH:Update({}, {})

    assert(headZoneRH.isActive, "Right hand head zone should be active")

    TestHelpers.handStates.right.location.z = 100.0
    headZoneRH:Update({}, {})
    assert(not headZoneRH.isActive, "Right hand head zone should not be active")
    
    -- Reset right hand position
    TestHelpers.handStates.right.location.z = 1.7
    
    -- Test left hand head zone
    headZoneLH:Reset()
    local lhExecuted = false
    headZoneLH:SetExecutionCallback(function(gesture, context)
        print("Left Hand Head Zone Executed")
        lhExecuted = true
    end)
    
    actors:Update(TestHelpers.mockEngine)
    headZoneLH:Update({}, {})
    
    assert(headZoneLH.isActive, "Left hand head zone should be active")
    
    TestHelpers.handStates.left.location.z = 100.0
    headZoneLH:Update({}, {})
    assert(not headZoneLH.isActive, "Left hand head zone should not be active")

    return true
end)
