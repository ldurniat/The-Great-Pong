--
-- Scena wyświetla menu z wyborem trybu rozgrywki
--
-- Wymagane moduły
local composer = require( "composer" )
local tiled    = require( "com.ponywolf.ponytiled" )
local json     = require( "json" )
local app      = require( 'lib.app' )
local fx       = require( "com.ponywolf.ponyfx" )

-- Lokalne zmienne
local scene = composer.newScene()
local menu

function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Wczytanie mapy
   local uiData = json.decodeFile( system.pathForFile( "scene/mode/ui/mode.json", system.ResourceDirectory ) )
   menu = tiled.new( uiData, "scene/mode/ui" )
   menu.x, menu.y = display.contentCenterX - menu.designedWidth/2, display.contentCenterY - menu.designedHeight/2

   -- Obsługa przycisków
   menu.extensions = "scene.menu.lib."
   menu:extend("button")

   function ui(event)
      local phase = event.phase
      local name = event.buttonName
     
      if phase == "released" then
         --audio.play(buttonSound)
         if name == "endless" then
            fx.fadeOut( function()
                  local prevScene = composer.getSceneName( 'previous' )   
                  composer.removeScene( prevScene )
                  composer.gotoScene( "scene.endless", { params = {} } )
               end )
         end
      end
      return true 
   end

   sceneGroup:insert( menu )
end
 
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
   
   elseif ( phase == "did" ) then
      app.addRuntimeEvents( { 'ui', ui } )
   end
end
 
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
   
   elseif ( phase == "did" ) then
      app.removeAllRuntimeEvents()
   end
end
 
function scene:destroy( event )
   --app.removeAllRuntimeEvents()
end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene