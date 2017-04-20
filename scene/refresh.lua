--
-- Scena przejściowa
--
-- Wymagane moduły
local composer = require( 'composer' )

-- Lokalne zmienne
local scene = composer.newScene()
local prevScene = composer.getSceneName( 'previous' )   

function scene:show( event )

  local phase = event.phase
  local options = { params = event.params }

  -- Przekierowuję do następnej sceny (domyślnie jest nią poprzednia scena)
  if ( phase == 'will' ) then
    composer.removeScene( prevScene )
  elseif ( phase == 'did' ) then
    composer.gotoScene( prevScene, options )      
  end
end

scene:addEventListener( 'show', scene )

return scene