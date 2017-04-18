--
-- Ekran z poprzedzający rozgrywkę.
-- Informuję jak grać.
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local composer = require( 'composer' )
local fx       = require( 'com.ponywolf.ponyfx' ) 
local tiled    = require( 'com.ponywolf.ponytiled' )
local json     = require( 'json' ) 

-- Lokalne zmienne
local scene = composer.newScene()
local start, ui 

function scene:create( event )
  local sceneGroup = self.view 

  -- Wczytanie mapy
  local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/howToPlay.json', system.ResourceDirectory ) )
  start = tiled.new( uiData, 'scene/menu/ui' )
  start.x, start.y = display.contentCenterX - start.designedWidth/2, display.contentCenterY - start.designedHeight/2
  
  -- Obsługa przycisków
  start.extensions = 'scene.menu.lib.'
  start:extend( 'button', 'label' )

  function ui( event )
    local phase = event.phase
    local name = event.buttonName
    if phase == 'released' then 
      if name == 'start' then
				--audio.play(parent.sounds.bail)		
        composer.hideOverlay( "slideUp" )
      end
    end
    return true	
  end

  sceneGroup:insert(start)
end

function scene:show( event )
  local phase = event.phase
  local params = event.params or {}
  if ( phase == 'will' ) then
    
  elseif ( phase == 'did' ) then
    app.addRuntimeEvents( { 'ui', ui } )		    
  end
end

function scene:hide( event )
  local phase = event.phase
  local parent = event.parent
  if ( phase == 'will' ) then
    app.removeAllRuntimeEvents( )
    parent:resumeGame()
  elseif ( phase == 'did' ) then

  end
end

function scene:destroy( event )
  --collectgarbage()
end

scene:addEventListener('create')
scene:addEventListener('show')
scene:addEventListener('hide')
scene:addEventListener('destroy')

return scene