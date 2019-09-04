-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

--Load Box2D physics engine
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 ) --Disable Gravity in both x-y axis

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet (Sprite Sheet)
-- Software TexturePacker can be used to create image/sprite sheets : https://www.codeandweb.com/texturepacker 
-- Give coordinates in a way to cut the images out of the big image- order/numbering is useful 
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
--Load the image sheet
local objectSheet = graphics.newImageSheet( "Images/gameObjects.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}
 
local ship
local gameLoopTimer
local livesText
local scoreText

-- Set up display groups
-- order is important - keep it back to front
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load n Display the background - assign to display group
local background = display.newImageRect( backGroup, "Images/background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Display the ship => Number 4 sprite (Order Prevails :D) - rest is size of the ship as per the sprite img
ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100 --contentHeight =>  maximum y coordinate of the content area (bottom edge of the screen)
physics.addBody( ship, { radius=30, isSensor=true } ) --Sensor property will help us to detect collision
ship.myName = "ship"

-- Display lives and score
-- .. is concantenation in Lua
livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 ) 
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

-- Hide the status bar => useful to hide phone top bar
display.setStatusBar( display.HiddenStatusBar )

-- Update Score and Lives
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- Automatic Loading of the Asteriods
local function createAsteroid()
    local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 ) --Sprite no 1
    table.insert( asteroidsTable, newAsteroid ) --table to collect all asteriods
    physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } ) --like balloon bouncy with reduced energy
    newAsteroid.myName = "asteroid"

    local whereFrom = math.random( 3 ) --get random number till 3

    if ( whereFrom == 1 ) then
        -- From the left (out of the screen- Surprise !!!) , y till 500 - so it can come from top portion only
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) ) --Move it Move it
    elseif ( whereFrom == 2 ) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    --Rotate it
    newAsteroid:applyTorque( math.random( -6,6 ) ) 
end

-- Bring on the laser
local function fireLaser()
    local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } ) --Sense Collision
    newLaser.isBullet = true --ensure continous collision detection.
    newLaser.myName = "laser"

    --Wherever the ship goes, laser follows
    newLaser.x = ship.x
    newLaser.y = ship.y

    newLaser:toBack() -- to prevent overlap with ship, sends the laser back of the display group
    -- Opposite will be toFront()
 
    -- manages how far n fast the object travels
    -- onComplete => to free up memory - don't want stack of lasers at top (outside) of screen
    transition.to( newLaser, { y=-40, time=500,onComplete = function() display.remove( newLaser ) end
    } )
end

local function dragShip(event)
    local ship = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
        -- ship.touchOffsetY = event.y - ship.y  --if there is need to both in y axis too
    elseif ( "moved" == phase ) then
        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX
        -- ship.y = event.y - ship.touchOffsetY --if there is need to both in y axis too
    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        display.currentStage:setFocus( nil )
    end

    return true  -- Prevents touch propagation to underlying objects
end

local function gameLoop()
    -- Create new asteroid
    createAsteroid()
 
    -- Remove asteroids which have drifted off screen
    -- # gives count of table elements
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )

--Event Listeners
ship:addEventListener( "tap", fireLaser )
ship:addEventListener( "touch", dragShip )

local function restoreShip()
 
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end


local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
            ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
        then
            if ( died == false ) then
                died = true
                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives
                if ( lives == 0 ) then
                    display.remove( ship )
                    local GameOver = display.newText( uiGroup, "Game Over !!!", display.contentCenterX, display.contentCenterY, native.systemFont, 40 )
                else
                    ship.alpha = 0
                    timer.performWithDelay( 1000, restoreShip ) 
                end
            end
        end
    end
end

Runtime:addEventListener( "collision", onCollision )