--
-- Scena z ustawieniami
--
-- Wymagane moduły
local composer   = require( "composer" )
local tiled      = require( 'com.ponywolf.ponytiled' )
local json       = require( 'json' )
local app        = require( 'lib.app' )
local preference = require( 'preference' ) 
local fx         = require( 'com.ponywolf.ponyfx' ) 

-- Lokalne zmienne
local scene = composer.newScene()
local menu, ui

-- Od/zaznacza pola 
local function toggleCheckbox( name )
   app[name] = not app[name]
   local isEnabled = app[name]

   local checkBox = menu:findObject( name )
   checkBox.isVisible = isEnabled

   preference:set( name, isEnabled )
end  

function scene:create( event )
   local sceneGroup = self.view

   local buttonSound = audio.loadSound( 'scene/game/sfx/select.wav' ) 

   -- Wczytanie mapy
   local uiData = json.decodeFile( system.pathForFile( 
      'scene/settings/ui/settings.json', 
      system.ResourceDirectory ) )
   menu = tiled.new( uiData, 'scene/settings/ui' )
   menu.x, menu.y = display.contentCenterX - menu.designedWidth/2, display.contentCenterY - menu.designedHeight/2

   -- Obsługa przycisków
   menu.extensions = 'scene.menu.lib.'
   menu:extend( 'button', 'label' )

   function ui( event )
      local phase = event.phase
      local name = event.buttonName
     
      if phase == 'released' then
         app.playSound( buttonSound )
         
         if ( name == 'sound' ) then
            toggleCheckbox( 'sound' )
         elseif ( name == 'music' ) then
            toggleCheckbox( 'music' )  
         elseif ( name == 'back' ) then
            fx.fadeOut( function()
               composer.hideOverlay()
               composer.gotoScene( 'scene.menu', { params = {} } )
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
      -- konfiguruje stan początkowy checkbox-ów
      local checkboxNames = { 'music', 'sound' }
      for i=1, #checkboxNames do
            local checkbox = menu:findObject( checkboxNames[i] )
            -- włączony == widoczny, wyłączony == nie widoczny
            checkbox.isVisible = app[ checkboxNames[i] ] 
            checkbox.isHitTestable = true  
      end 
   elseif ( phase == "did" ) then
      app.addRuntimeEvents( {'ui', ui} )
   end
end
 
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      
   elseif ( phase == "did" ) then
      preference:save()
   end
end
 
function scene:destroy( event )
   audio.stop()
   audio.dispose( buttonSound )
end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene