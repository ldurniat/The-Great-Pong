local composer = require( "composer" )
local app      = require( "lib.app" )
local Ball     = require( "ball" )
local Player   = require( "player" )
local Computer = require( "computer" )

local ball 
local player 
local computer

local _W, _H

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals()

local scene = composer.newScene()

math.randomseed( os.time() ) 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
local function init( )

   player.spriteinstance.x = player.width
   player.spriteinstance.y = ( _H - player.height ) * 0.5
   computer.spriteinstance.x = _W - ( player.width + computer.width )
   computer.spriteinstance.y = ( _H - computer.height ) * 0.5
   ball:serve(1, player, computer)
end   

local function loop( )

   ball:update( player, computer )
   computer:update( ball )
end

-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
   print( _W, _H )

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   ball = Ball( nil, {} )
   player = Player( nil, {} )
   computer = Computer( nil, {} )

   player:addDrag( )

   init()
end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
      Runtime:addEventListener( "enterFrame", loop )
   end
end
 
-- "scene:hide()"
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------
 
return scene