--[[
    test_zoned_gesture.lua
    Tests for the ZonedGestures implementation
]]--

local LuaTest = require("tests.luatest")
local GestureBase = require("artifact.scripts.gestures.GestureBase")
local ZonedGestures = require("artifact.scripts.gestures.ZonedGestures")

-- Create a mock location gesture for testing
local MockLocationGesture = GestureBase:new({
    name = "Mock Location Gesture",
    location = { x = 0, y = 0, z = 0 }
})

function MockLocationGesture:SetLocation(x, y, z)
    self.location = { x = x, y = y, z = z }
    self.isActive = true
end

-- Test the BodyZoneGesture
LuaTest.test("BodyZoneGesture creation", function()
    local mockLocation = MockLocationGesture:new()
    local zoneGesture = ZonedGestures.BodyZoneGesture:new({
        name = "Test Body Zone",
        locationGesture = mockLocation,
        minX = -1, maxX = 1,
        minY = -1, maxY = 1,
        minZ = -1, maxZ = 1
    })
    
    LuaTest.assertEquals("Test Body Zone", zoneGesture.name)
    LuaTest.assertEquals(mockLocation, zoneGesture.locationGesture)
end)

LuaTest.test("BodyZoneGesture evaluation inside boundaries", function()
    local mockLocation = MockLocationGesture:new()
    local zoneGesture = ZonedGestures.BodyZoneGesture:new({
        locationGesture = mockLocation,
        minX = -1, maxX = 1,
        minY = -1, maxY = 1,
        minZ = -1, maxZ = 1
    })
    
    -- Test a point inside the boundaries
    mockLocation:SetLocation(0, 0, 0)
    zoneGesture:Evaluate({})
    LuaTest.assertTrue(zoneGesture.isActive, "Gesture should be active when point is inside zone")
    
    -- Test points at the boundaries
    mockLocation:SetLocation(-1, 0, 0)
    zoneGesture:Evaluate({})
    LuaTest.assertTrue(zoneGesture.isActive, "Gesture should be active at minimum X boundary")
    
    mockLocation:SetLocation(1, 1, 1)
    zoneGesture:Evaluate({})
    LuaTest.assertTrue(zoneGesture.isActive, "Gesture should be active at maximum boundaries")
end)

LuaTest.test("BodyZoneGesture evaluation outside boundaries", function()
    local mockLocation = MockLocationGesture:new()
    local zoneGesture = ZonedGestures.BodyZoneGesture:new({
        locationGesture = mockLocation,
        minX = -1, maxX = 1,
        minY = -1, maxY = 1,
        minZ = -1, maxZ = 1
    })
    
    -- Test points outside the boundaries
    mockLocation:SetLocation(-1.1, 0, 0)
    zoneGesture:Evaluate({})
    LuaTest.assertFalse(zoneGesture.isActive, "Gesture should be inactive when X is below minimum")
    
    mockLocation:SetLocation(0, 1.5, 0)
    zoneGesture:Evaluate({})
    LuaTest.assertFalse(zoneGesture.isActive, "Gesture should be inactive when Y is above maximum")
    
    mockLocation:SetLocation(0, 0, -2)
    zoneGesture:Evaluate({})
    LuaTest.assertFalse(zoneGesture.isActive, "Gesture should be inactive when Z is below minimum")
end)

-- Create a mock weapon location gesture for testing
local MockWeaponLocationGesture = GestureBase:new({
    name = "Mock Weapon Location Gesture",
    weaponLocation = { x = 0, y = 0, z = 0 }
})

function MockWeaponLocationGesture:SetLocation(x, y, z)
    self.weaponLocation = { x = x, y = y, z = z }
    self.isActive = true
end

-- Test the WeaponZoneGesture
LuaTest.test("WeaponZoneGesture evaluation", function()
    local mockWeaponLocation = MockWeaponLocationGesture:new()
    local weaponZoneGesture = ZonedGestures.WeaponZoneGesture:new({
        weaponLocationGesture = mockWeaponLocation,
        minX = -1, maxX = 1,
        minY = -1, maxY = 1,
        minZ = -1, maxZ = 1
    })
    
    -- Test a point inside the boundaries
    mockWeaponLocation:SetLocation(0.5, 0.5, 0.5)
    weaponZoneGesture:Evaluate({})
    LuaTest.assertTrue(weaponZoneGesture.isActive, "Weapon zone should be active when point is inside zone")
    
    -- Test a point outside the boundaries
    mockWeaponLocation:SetLocation(1.5, 0.5, 0.5)
    weaponZoneGesture:Evaluate({})
    LuaTest.assertFalse(weaponZoneGesture.isActive, "Weapon zone should be inactive when point is outside zone")
end)

-- Run all the tests and print results
local success = LuaTest.runAll()
return success