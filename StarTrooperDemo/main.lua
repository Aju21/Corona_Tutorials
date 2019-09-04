-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Load Composer scene management library
local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator - because math.random will be used in the program and we want it reset everytime
math.randomseed( os.time() )
 
-- Go to the menu screen
composer.gotoScene( "menu" )