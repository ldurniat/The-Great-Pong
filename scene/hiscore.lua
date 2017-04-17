--
-- Ekran z końcowym wynikiem
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local composer = require( 'composer' )
local fx       = require( 'com.ponywolf.ponyfx' ) 
local tiled    = require( 'com.ponywolf.ponytiled' )
local json     = require( 'json' ) 
local preference = require( 'preference' ) 

-- Lokalne zmienne
local scene = composer.newScene()
local hiscore, scores, ui

local function saveHighScore( newScore )
    if  preference:get( 'highScoreEndlessMode' ) < newScore then
      preference:set( 'highScoreEndlessMode', newScore )
    end   

    preference:save()
end  

function scene:create( event )
  local sceneGroup = self.view 

  -- Wczytanie mapy
  local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/highScore.json', system.ResourceDirectory ) )
  hiscore = tiled.new( uiData, 'scene/menu/ui' )
  hiscore.x, hiscore.y = display.contentCenterX - hiscore.designedWidth/2, display.contentCenterY - hiscore.designedHeight/2
  
  -- Obsługa przycisków
  hiscore.extensions = 'scene.menu.lib.'
  hiscore:extend( 'button', 'label' )

  function ui( event )
    local phase = event.phase
    local name = event.buttonName
    if phase == 'released' then 
      if name == 'restart' then
				--audio.play(parent.sounds.bail)		
        fx.fadeOut( function()
            composer.hideOverlay()
            composer.gotoScene( 'scene.refresh', { params = {} } )
          end )
      end
    end
    return true	
  end

  sceneGroup:insert(hiscore)

end

function scene:show( event )
  local phase = event.phase
  local params = event.params or {}
  if ( phase == 'will' ) then
    local newScore = params.newScore

    saveHighScore( newScore )

    local newHighScore = preference:get( 'highScoreEndlessMode' )

    hiscore:findObject('myScore').text = newScore
    hiscore:findObject('myHighScore').text = newHighScore
  elseif ( phase == 'did' ) then
    app.addRuntimeEvents( { 'ui', ui } )		    
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == 'will' ) then
    app.removeAllRuntimeEvents( )
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