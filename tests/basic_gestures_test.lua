package.path = "/workspaces/stalker2-uevr/artifact/scripts/?.lua;/workspaces/stalker2-uevr/artifact/scripts/?/init.lua;" .. package.path

-- Define minimal UEVR environment
local preEngineTickCallback = nil
local scriptResetCallback = nil

-- Mock UEVR_UObjectHook
_G.UEVR_UObjectHook = {
    on_post_uobject_hook = function(callback)
        return true
    end,
    get_or_add_motion_controller_state = function()
        return {
            motionSource = "motionSource",
            renderComponent = {},
            hand = 0,
            set_hand = function(self, hand)
                self.hand = hand
            end,
            set_permanent = function(self, permanent)
                self.permanent = permanent
            end
        }
    end,
    exists = function() return true end
}

-- Mock Vector3f
_G.Vector3f = {
    new = function(x, y, z)
        return {x = x or 0, y = y or 0, z = z or 0}
    end
}

-- Hand state variables that can be modified before each test
local handStates = {
    left = {
        location = Vector3f.new(0, 0, 0),
        rotation = Vector3f.new(0, 0, 0),
        gripActive = false
    },
    right = {
        location = Vector3f.new(0, 0, 0),
        rotation = Vector3f.new(0, 0, 0),
        gripActive = false
    },
    hmd = {
        location = Vector3f.new(0, 0, 0),
        rotation = Vector3f.new(0, 0, 0)
    }
}

-- Mock StructObject for Vector3f operations
_G.StructObject = {
    new = function(self)
        return {
            Translation = Vector3f.new(0, 0, 0),
            Rotation = {
                X = 0,
                Y = 0,
                Z = 0,
                W = 1
            },
            Scale3D = Vector3f.new(1, 1, 1)
        }
    end
}

-- Create mock static classes that will be returned by find_static_class
local mockStatics = {
    BeginDeferredActorSpawnFromClass = function(self, world_context, actor_class, transform, collision_method, owner)
        return {
            K2_DestroyActor = function() end
        }
    end,
    FinishSpawningActor = function(self, actor, transform)
        return actor
    end,
    Conv_StringToName = function(self, str)
        return str
    end
}

-- Mock required objects that will be returned by find_required_object
local mockRequiredObject = {
    name = "MockObject",
    position = Vector3f.new(0, 0, 0),
    getComponent = function(self, componentName)
        return {
            name = componentName,
            enabled = true,
            setEnabled = function(enabled) end
        }
    end
}

-- Override package.loaded to provide our mocked modules
package.loaded["common.utils"] = {
    find_required_object = function(path)
        return mockRequiredObject
    end,
    find_static_class = function(path)
        return mockStatics
    end
}

-- Set up mock UEVR SDK with API
_G.uevr = {
    sdk = {
        callbacks = {
            on_pre_engine_tick = function(callback)
                preEngineTickCallback = callback
                return true
            end,
            on_script_reset = function(callback)
                scriptResetCallback = callback
                return true
            end
        }
    },
    api = {
                find_uobject = function(path)
            return {
                get_full_name = function() return path end,
                get_class = function() return "MockClass" end,
                is_valid = function() return true end,
                get_class_default_object = function()
                    return {
                        get_full_name = function() return "MockClass_CDO" end,
                        get_class = function() return "MockClass" end,
                        is_valid = function() return true end
                    }
                end,
                K2_GetActorLocation = function()
                    return Vector3f.new(0, 0, 0)
                end
            }
        end,
        get_local_pawn = function(index)
            return {
                K2_GetActorLocation = function()
                    return Vector3f.new(0, 0, 0)
                end
            }
        end,
        add_component_by_class = function(actor, class)
            local component = {
                K2_GetComponentLocation = function(self)
                    if self.MotionSource == "Left" then  -- Left hand
                        return handStates.left.location
                    elseif  self.MotionSource == "Right" then
                        return handStates.right.location
                    else
                        return handStates.hmd.location
                    end
                end,
                K2_GetComponentRotation = function(self)
                    if actor.Hand == 0 then  -- Left hand
                        return handStates.left.rotation
                    else  -- Right hand
                        return handStates.right.rotation
                    end
                end,
                MotionSource = "",
                Hand = actor.Hand or 0,
                isActive = true  -- Ensure the component is marked as active
            }
            
            -- Store components for test manipulation
            if actor.Hand == 0 then
                leftHandComponent = component
            else
                rightHandComponent = component
            end
            
            return component
        end
    },
    params = {
        vr = {
            get_action_handle = function(handle_name)
                return handle_name
            end,
            get_left_joystick_source = function()
                return "left_joystick"
            end,
            get_right_joystick_source = function()
                return "right_joystick"
            end,
            is_action_active = function(handle, controller)
                if handle == "/actions/default/in/Grip" then
                    if controller == "left_joystick" then
                        return handStates.left.gripActive
                    elseif controller == "right_joystick" then
                        return handStates.right.gripActive
                    end
                end
                return false
            end
        }
    }
}

-- Create mock engine for testing with proper GameViewport structure
local mockEngine = {
    deltaTime = 0.016,
    GameViewport = {
        World = {
            actors = {},
            getActor = function(self, id)
                return self.actors[id]
            end,
            addActor = function(self, actor)
                self.actors[actor.id] = actor
            end,
            removeActor = function(self, id)
                self.actors[id] = nil
            end
        }
    }
}

print("Loading gestures module...")

-- Load the gestures module
local status, err = pcall(function()
    require("gestures")  -- Load the main gestures module which sets up the callbacks
end)

if not status then
    print("Error loading gestures module: " .. tostring(err))
    return false
end

if not preEngineTickCallback then
    print("Error: pre-engine tick callback was not registered")
    return false
end


-- Reset test state before each test
local function resetTestState()
    -- Reset hand states to default positions
    handStates.left.location = Vector3f.new(0, 0, 0)
    handStates.left.rotation = Vector3f.new(0, 0, 0)
    handStates.left.gripActive = false
    
    handStates.right.location = Vector3f.new(0, 0, 0)
    handStates.right.rotation = Vector3f.new(0, 0, 0)
    handStates.right.gripActive = false
end

-- Run a single test with given hand states
local function runTest(testName, testFn)
    print("\nRunning test: " .. testName)
    if  not testFn() then
        print("✗ Test failed: " .. testName)
    else
        print("✓ Test passed: " .. testName)
    end
end

-- Example test cases
print("\nRunning test suite...")
local flashlight = require("gestures.FlashlightGesture")

runTest("Left Grip Action", function()
    resetTestState()

    local MotionControllerGestures = require("gestures.MotionControllerGestures")
    local leftGripAction = MotionControllerGestures.LeftGripAction

    leftGripAction:Reset()
    local executed = false
    leftGripAction:SetExecutionCallback(function(gesture, context)
        executed = true
    end)

    handStates.left.gripActive = false

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
    handStates.left.gripActive = true

    -- Create a new visited table for second update
    leftGripAction:Update({}, {})
    assert(leftGripAction.isActive, "Left Grip Action should now be active")
    assert(leftGripAction:JustActivated(), "Left Grip Action should have just activated")

    leftGripAction:Execute({})
    assert(executed, "Left Grip Action should have executed")

    leftGripAction:SetExecutionCallback(nil)
    return true
end)

-- -- Test 1: Both hands near head with grip
runTest("Both hands near head with grip", function()
    resetTestState()
    -- Set up left hand
    handStates.left.location = Vector3f.new(0.0, 0.0, 1.7)
    handStates.left.rotation = Vector3f.new(0, 45, 0)
    handStates.left.gripActive = true
    
    -- Set up right hand
    handStates.right.location = Vector3f.new(-0.0, 0.0, 1.7)
    handStates.right.rotation = Vector3f.new(0, -45, 0)
    handStates.right.gripActive = true

    handStates.hmd.location = Vector3f.new(0, 0, 1.7)
    handStates.hmd.rotation = Vector3f.new(0, 0, 0)

    local MotionControllerGestures = require("gestures.BodyZones")
    local headZoneRH = MotionControllerGestures.headZoneRH
    local actors = require("gestures.MotionControllerActors")

    headZoneRH:Reset()
    local executed = false
    headZoneRH:SetExecutionCallback(function(gesture, context)
        print("Left Grip Action Executed")
        executed = true
    end)

    actors:Update(mockEngine)
    headZoneRH:Update({}, {})

    assert(headZoneRH.isActive, "Head zone should be active")

    handStates.right.location.z = 100.0
    headZoneRH:Update({}, {})
    assert(not headZoneRH.isActive, "Head zone should not be active")


    return true

end)

runTest("Right Grip Action", function()
    resetTestState()

    local MotionControllerGestures = require("gestures.MotionControllerGestures")
    local rightGripAction = MotionControllerGestures.RightGripAction

    rightGripAction:Reset()
    local executed = false
    rightGripAction:SetExecutionCallback(function(gesture, context)
        executed = true
    end)

    handStates.right.gripActive = false

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
    handStates.right.gripActive = true

    -- Create a new visited table for second update
    rightGripAction:Update({}, {})
    assert(rightGripAction.isActive, "Right Grip Action should now be active")
    assert(rightGripAction:JustActivated(), "Right Grip Action should have just activated")

    rightGripAction:Execute({})
    assert(executed, "Right Grip Action should have executed")

    rightGripAction:SetExecutionCallback(nil)
    return true
end)
