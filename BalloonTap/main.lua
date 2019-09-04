-----------------------------------------------------------------------------------------
-- 
-- main.lua
-- Start point of program
-- Note : Everything except comments is case sensitive - even file names
-----------------------------------------------------------------------------------------



-- Step 1 : Display Content

--Initialize Variables
local tapCount = 0
--Load Background Image and align it in center
local background = display.newImageRect("Images/background.png", 360, 570)
background.x = display.contentCenterX
background.y = display.contentCenterY
--Load Platform Image and align it in center of X axis but little lower on y axis
local platform = display.newImageRect( "Images/platform.png", 300, 50 )
platform.x = display.contentCenterX
platform.y = display.contentHeight-25
--Load Balloon Image and align it in center
local balloon = display.newImageRect( "Images/balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8  --Control transparency
--Load Score Tracker
local tapText = display.newText( tapCount, display.contentCenterX, 20, native.systemFont, 40 )
tapText:setFillColor( 0, 0, 0 )

--Step 2 : Initialize and Load Physics => Loads Box2D physics engine
local physics = require("physics")
physics.start()
--Manage physics for objects - By default - all bodies are dynamic
physics.addBody(platform,"static")
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.3 } ) --If bounce 1 , it will keep bouncing with same energy

--Step 3 : Bring on the functions

local function pushBalloon()
    --Apply force in direction , it is reverse cartesian system (first quadrant is x vs -y)
    --So this command wil push the balloon upwards
    balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )
    tapCount = tapCount + 1
    tapText.text = tapCount
end

--Step 4 : Add Event listener and call function on that event
balloon:addEventListener( "tap", pushBalloon )