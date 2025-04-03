-- Basic gestures test module
local TestHelpers = require("test_helpers")

print("\nRunning test suite...")

TestHelpers.runTest("Left Grip Action", function()
    TestHelpers.resetTestState()

    local MotionControllerGestures = require("gestures.MotionControllerGestures")
    local leftGripAction = MotionControllerGestures.LeftGripAction

    leftGripAction:Reset()
    local executed = false
    leftGripAction:SetActivationCallback(function(gesture, context)
        executed = true
    end)

    TestHelpers.handStates.left.gripActive = false

    leftGripAction:Update({}, {})
    assert(not leftGripAction:JustDeactivated(), "Left grip action should not report as just deactivated when never active")
    -- Create a new visited table for first update
    leftGripAction:Update({}, {})
    -- Check the isActive property directly
    assert(not leftGripAction.isActive, "Left grip action should not be active when grip button is not pressed")
    assert(not leftGripAction:JustDeactivated(), "Left grip action should not report as just deactivated when never active")

    leftGripAction:Execute({})
    assert(not executed, "Left grip action callback should not execute when grip is not active")

    -- Now let's test activation
    TestHelpers.handStates.left.gripActive = true

    -- Create a new visited table for second update
    leftGripAction:Update({}, {})
    assert(leftGripAction.isActive, "Left grip action should become active when grip button is pressed")
    assert(leftGripAction:JustActivated(), "Left grip action should report as just activated when grip becomes active")

    leftGripAction:Execute({})
    assert(executed, "Left grip action callback should execute when grip is active")

    leftGripAction:SetActivationCallback(nil)
    return true
end)

TestHelpers.runTest("Right Grip Action", function()
    TestHelpers.resetTestState()

    local MotionControllerGestures = require("gestures.MotionControllerGestures")
    local rightGripAction = MotionControllerGestures.RightGripAction

    rightGripAction:Reset()
    local executed = false
    rightGripAction:SetActivationCallback(function(gesture, context)
        executed = true
    end)

    TestHelpers.handStates.right.gripActive = false

    rightGripAction:Update({}, {})
    assert(not rightGripAction:JustDeactivated(), "Right grip action should not report as just deactivated when never active")
    -- Create a new visited table for first update
    rightGripAction:Update({}, {})
    -- Check the isActive property directly
    assert(not rightGripAction.isActive, "Right grip action should not be active when grip button is not pressed")
    assert(not rightGripAction:JustDeactivated(), "Right grip action should not report as just deactivated when never active")

    rightGripAction:Execute({})
    assert(not executed, "Right grip action callback should not execute when grip is not active")

    -- Now let's test activation
    TestHelpers.handStates.right.gripActive = true

    -- Create a new visited table for second update
    rightGripAction:Update({}, {})
    assert(rightGripAction.isActive, "Right grip action should become active when grip button is pressed")
    assert(rightGripAction:JustActivated(), "Right grip action should report as just activated when grip becomes active")

    rightGripAction:Execute({})
    assert(executed, "Right grip action callback should execute when grip is active")

    rightGripAction:SetActivationCallback(nil)
    return true
end)

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
    headZoneRH:SetActivationCallback(function(gesture, context)
        print("Right Hand Head Zone Executed")
        rhExecuted = true
    end)

    actors:Update(TestHelpers.mockEngine)
    headZoneRH:Update({}, {})

    assert(headZoneRH.isActive, "Right hand should be detected in head zone when positioned at head level")

    TestHelpers.handStates.right.location.z = 100.0
    headZoneRH:Update({}, {})
    assert(not headZoneRH.isActive, "Right hand should not be detected in head zone when far above head level")
    
    -- Reset right hand position
    TestHelpers.handStates.right.location.z = 1.7
    
    -- Test left hand head zone
    headZoneLH:Reset()
    local lhExecuted = false
    headZoneLH:SetActivationCallback(function(gesture, context)
        print("Left Hand Head Zone Executed")
        lhExecuted = true
    end)
    
    actors:Update(TestHelpers.mockEngine)
    headZoneLH:Update({}, {})
    
    assert(headZoneLH.isActive, "Left hand should be detected in head zone when positioned at head level")
    
    TestHelpers.handStates.left.location.z = 100.0
    headZoneLH:Update({}, {})
    assert(not headZoneLH.isActive, "Left hand should not be detected in head zone when far above head level")

    return true
end)
