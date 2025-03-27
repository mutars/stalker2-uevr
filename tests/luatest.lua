--[[
    luatest.lua
    A simple test framework for Lua scripts
]]--

local LuaTest = {}

-- Test results counters
LuaTest.passed = 0
LuaTest.failed = 0
LuaTest.total = 0

-- Store test cases
LuaTest.tests = {}

-- Colors for console output if supported
local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m"
}

-- Add a test case
function LuaTest.test(name, testFn)
    table.insert(LuaTest.tests, {name = name, fn = testFn})
end

-- Assert functions
function LuaTest.assertEquals(expected, actual, message)
    LuaTest.total = LuaTest.total + 1
    if expected == actual then
        LuaTest.passed = LuaTest.passed + 1
        return true
    else
        LuaTest.failed = LuaTest.failed + 1
        local msg = message or "Expected: " .. tostring(expected) .. ", got: " .. tostring(actual)
        print(colors.red .. "FAIL: " .. msg .. colors.reset)
        return false
    end
end

function LuaTest.assertTrue(value, message)
    return LuaTest.assertEquals(true, value, message)
end

function LuaTest.assertFalse(value, message)
    return LuaTest.assertEquals(false, value, message)
end

-- Run all registered tests
function LuaTest.runAll()
    print(colors.blue .. "Running " .. #LuaTest.tests .. " tests..." .. colors.reset)
    
    for _, test in ipairs(LuaTest.tests) do
        print(colors.yellow .. "Test: " .. test.name .. colors.reset)
        local success, error = pcall(test.fn)
        
        if not success then
            LuaTest.failed = LuaTest.failed + 1
            LuaTest.total = LuaTest.total + 1
            print(colors.red .. "ERROR: " .. error .. colors.reset)
        end
    end
    
    -- Print summary
    print(colors.blue .. "Test Summary:" .. colors.reset)
    print("  Total:  " .. LuaTest.total)
    print(colors.green .. "  Passed: " .. LuaTest.passed .. colors.reset)
    if LuaTest.failed > 0 then
        print(colors.red .. "  Failed: " .. LuaTest.failed .. colors.reset)
    else
        print("  Failed: " .. LuaTest.failed)
    end
    
    return LuaTest.failed == 0
end

-- Reset test counters
function LuaTest.reset()
    LuaTest.passed = 0
    LuaTest.failed = 0
    LuaTest.total = 0
    LuaTest.tests = {}
end

return LuaTest