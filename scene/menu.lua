--
-- Scena z głównym menu
--
-- Wymagane moduły
local composer     = require( 'composer' )
local tiled        = require( 'com.ponywolf.ponytiled' )
local json         = require( 'json' )
local app          = require( 'lib.app' )
local preference   = require( 'preference' )
local fx           = require( 'com.ponywolf.ponyfx' )
local translations = require( 'translations' )

-- Lokalne zmienne
local scene = composer.newScene() 
local menu, ui

function scene:create( event )
   local sceneGroup = self.view
   local prevScene = composer.getSceneName( 'previous' ) 
   
   if prevScene then  
      composer.removeScene( prevScene )
   end
      
   -- Wczytanie mapy
   local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/title.json', system.ResourceDirectory ) )
   menu = tiled.new( uiData, 'scene/menu/ui' )
   menu.x, menu.y = _CX - menu.designedWidth * 0.5, _CY - menu.designedHeight * 0.5

   -- Obsługa przycisków
   menu.extensions = 'scene.menu.lib.'
   menu:extend('button', 'label')

   function ui( event )
      local phase = event.phase
      local name = event.buttonName

      if phase == 'released' then
         app.playSound( 'button' )
         
         if ( name == 'play' ) then
            transition.cancel()
            fx.fadeOut( function()
                  composer.gotoScene( 'scene.game', { params = {} } )
               end )
         elseif ( name == 'settings' ) then  
            fx.fadeOut( function()
                  composer.gotoScene( 'scene.settings', { params = {} } )
               end )
         elseif ( name == 'buyBalls' ) then  
            --fx.fadeOut( function()
               composer.showOverlay( 'scene.chooseball', { effect='fade', time=200, isModal=true,  params={} } )   
            --end )
        elseif ( name == 'donate' ) then  
            system.openURL( "https://www.paypal.me/ldurniat" )
         elseif ( name == 'help' ) then  
            --fx.fadeOut( function()
               composer.showOverlay( 'scene.help', { effect='fade', time=200, isModal=true,  params={} } )   
            --end )   
         end
      end
      return true 
   end

   local playerButton = menu:findObject( 'play' )
   playerButton.transitionUp = function() 
      transition.to( playerButton, { transition=easing.outSine, y=(playerButton.y+10), onComplete=playerButton.transitionBottom, time=1200} )
   end   

   playerButton.transitionBottom = function()  
      transition.to( playerButton, { transition=easing.outSine, y=(playerButton.y-10), onComplete=playerButton.transitionUp, time=1200} )
   end

   sceneGroup:insert( menu )
end
 
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
      local totalPoints = preference:get( 'totalPoints' )
      local labelPoints = menu:findObject( 'totalpoints' )
      local lang = preference:get( 'language' )
      labelPoints.text = translations[lang]['totalPoints'] .. totalPoints

      local gamesPlayed = preference:get( 'gamesPlayed' )
      local labelGamesPlayed = menu:findObject( 'gamesPlayed' )
      labelGamesPlayed.text = translations[lang]['gamesPlayed'] .. gamesPlayed
   elseif ( phase == 'did' ) then
      app.playMusic( 'music' )

      local playerButton = menu:findObject( 'play' )
      playerButton.transitionUp()
      app.addRuntimeEvents( {'ui', ui} )
   end
end
 
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
      app.removeAllRuntimeEvents()
   elseif ( phase == 'did' ) then
      transition.cancel()
   end
end
 
function scene:destroy( event )
 
   local sceneGroup = self.view
   app.removeAllRuntimeEvents()
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene