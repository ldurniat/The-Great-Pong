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

local function markLanguage( name )
   -- Odznaczam wszystkie przyciski
   local langNames = { 'english', 'polski' }
   for i=1, #langNames do
      local languageButton = menu:findObject( langNames[i] )
      languageButton:setFillColor( 1 )
   end   
   -- Zaznaczam wybrany przycisk z nazwą języka
   local languageButton = menu:findObject( name )
   languageButton:setFillColor( 0, 170 / 255, 212 / 255 )
   -- Zapisuje wybrany język
   preference:set( 'language', name )
end   

function scene:create( event )
   local sceneGroup = self.view

   -- Wczytanie mapy
   local uiData = json.decodeFile( system.pathForFile( 
      'scene/settings/ui/settings.json', 
      system.ResourceDirectory ) )
   menu = tiled.new( uiData, 'scene/settings/ui' )
   menu.x, menu.y = _CX - menu.designedWidth * 0.5, _CY - menu.designedHeight * 0.5

   -- Obsługa przycisków
   menu.extensions = 'scene.menu.lib.'
   menu:extend( 'button', 'label' )

   function ui( event )
      local phase = event.phase
      local name = event.buttonName
     
      if phase == 'released' then
         app.playSound( 'button' )
         
         if ( name == 'sound' ) then
            toggleCheckbox( 'sound' )
         elseif ( name == 'music' ) then
            toggleCheckbox( 'music' )  
         elseif ( name == 'back' ) then
            fx.fadeOut( function()
               composer.hideOverlay()
               composer.gotoScene( 'scene.menu', { params = {} } )
             end )
         elseif ( name == 'english' ) then
            markLanguage( name )
         elseif ( name == 'polski' ) then
            markLanguage( name )
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
      -- konfiguruję przyciski z językami
      local name = preference:get( 'language' )
      markLanguage( name )
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

end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene