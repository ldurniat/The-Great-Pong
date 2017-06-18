--
-- Scena z ustawieniami
--
-- Wymagane moduły
local composer     = require( "composer" )
local tiled        = require( 'com.ponywolf.ponytiled' )
local json         = require( 'json' )
local app          = require( 'lib.app' )
local preference   = require( 'preference' ) 
local fx           = require( 'com.ponywolf.ponyfx' )
local widget       = require( 'widget' ) 

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
   local langNames = { 'en', 'pl' }
   for i=1, #langNames do   
      local languageButton = menu:findObject( langNames[i] )
      languageButton.xScale = 1
      languageButton.yScale = 1
      languageButton.alpha = 1
   end   
   -- Zaznaczam wybrany przycisk z nazwą języka
   local languageButton = menu:findObject( name )
      languageButton.xScale = 0.9
      languageButton.yScale = 0.9
      languageButton.alpha = 0.7
   -- Zapisuje wybrany język
   preference:set( 'language', name )
end   

function scene:create( event )
   composer.returnTo = 'scene.menu'
   local sceneGroup = self.view

   composer.removeScene( 'scene.menu' )

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
         elseif ( name == 'en' ) then
            markLanguage( name )
         elseif ( name == 'pl' ) then
            markLanguage( name )
         end
      end

      return true 
   end

   -- Create the widget
   local scrollView = widget.newScrollView(
       {
           top = 0,
           left = 0,
           width = 1280,
           height = 800,
           scrollWidth = 600,
           scrollHeight = 800,
           hideBackground = true,
           horizontalScrollDisabled = true,
           listener = scrollListener
       }
   )
   scrollView:insert( menu )

   sceneGroup:insert( scrollView )
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
      -- konfiguruję przyciski z językami
      local name = preference:get( 'language' )
      markLanguage( name )
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