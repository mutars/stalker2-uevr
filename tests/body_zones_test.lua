-- Basic gestures test module
local TestHelpers = require("tests.test_helpers")

print("\nRunning test suite...")

-- -- Test 1: Both hands near head with grip
TestHelpers.runTest("HeadZone test", function()
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
