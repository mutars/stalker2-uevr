--[[
    run_tests.lua
    Script to run all or specific test files
]]--

-- Usage: 
-- lua run_tests.lua                -- runs all tests
-- lua run_tests.lua test_file.lua  -- runs specific test file

-- Get command line arguments
local arg = {...}
local testToRun = arg[1]

-- Function to run a specific test file
local function runTestFile(filePath)
    print("Running test file: " .. filePath)
    local success, result = pcall(dofile, filePath)
    if not success then
        print("ERROR executing test file: " .. tostring(result))
        return false
    end
    return result
end

-- If a specific test is provided, run only that one
if testToRun then
    local path = "tests/" .. testToRun
    local success = runTestFile(path)
    if not success then
        os.exit(1)
    end
else
    -- Otherwise run all tests in the tests directory
    local testFiles = {
        "tests/test_simple_gesture.lua",
        "tests/test_zoned_gesture.lua",
        "tests/test_nested_gestures.lua"
        -- Add more test files here as you create them
    }
    
    local allSuccess = true
    for _, testFile in ipairs(testFiles) do
        local success = runTestFile(testFile)
        if not success then
            allSuccess = false
        end
    end
    
    if not allSuccess then
        print("\nSome tests failed!")
        os.exit(1)
    else
        print("\nAll tests passed!")
    end
end

print("Test execution complete.")