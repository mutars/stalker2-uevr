-- System variables
local api = uevr.api
local log = uevr.params.functions.log_info

local function GetFirstInstance(class_to_search)
    local obj_class = uevr.api:find_uobject(class_to_search)
    if obj_class == nil then 
        print(class_to_search, "was not found") 
        return nil
    end

    return obj_class:get_first_object_matching(false)
end

uevr.sdk.callbacks.on_xinput_get_state(function(retval, user_index, state)

    -- Open PDA when DPAD-UP is pressed
    if (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_UP) ~= 0 and (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_LEFT) == 0 and (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_RIGHT) == 0 then
        local pda = GetFirstInstance("Class /Script/Stalker2.PDAView")

        -- Only emulate BACK press if not in PDA
        if not pda or not pda:IsVisible() then
            state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_BACK
            state.Gamepad.wButtons = state.Gamepad.wButtons & ~XINPUT_GAMEPAD_DPAD_UP
        end
    end
end)