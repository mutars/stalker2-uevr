-- Vector3f = {x=0, y=0, z=0}
-- Vector3f.new = function(self, x, y, z)
--     return {x=x, y=y, z=z}
-- end

local gestureSet = require("gestures.GestureSet")
local flashlight = require("gestures.FlashlightGesture")

gestureSet = gestureSet:new(
    {
        -- Initialize the gesture set with the flashlight gestures for both hands
        rootGestures = {
            flashlight.flashlightGestureRH,
            flashlight.flashlightGestureLH
        }
    }
)

gestureSet:Update(
    {
    }
)