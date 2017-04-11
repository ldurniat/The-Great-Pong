local composer = require( "composer" )
local tiled    = require( "com.ponywolf.ponytiled" )
local json     = require( "json" )
local app      = require( 'lib.app' )
local fx       = require( "com.ponywolf.ponyfx" )

local scene = composer.newScene()
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
local menu

---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   local uiData = json.decodeFile( system.pathForFile( "scene/menu/ui/buttons.json", system.ResourceDirectory ) )
   menu = tiled.new( uiData, "scene/menu/ui" )
   menu.x, menu.y = display.contentCenterX - menu.designedWidth/2, display.contentCenterY - menu.designedHeight/2

   menu.extensions = "scene.menu.lib."
   menu:extend("button")

   function ui(event)
      local phase = event.phase
      local name = event.buttonName
      print (phase, name)
      if phase == "released" then
         --audio.play(buttonSound)
         if name == "endless" then
            fx.fadeOut( function()
                  composer.gotoScene( "scene.game", { params = {} } )
               end )
         end
      end
      return true 
   end

   sceneGroup:insert( menu )
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
      app.addRtEvents( { 'ui', ui } )
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