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