--
-- Ekran wyświetlający komunikat.
--
-- Wymagane moduły
local app          = require( 'lib.app' )
local preference   = require( 'preference' )
local composer     = require( 'composer' )
local fx           = require( 'com.ponywolf.ponyfx' ) 
local tiled        = require( 'com.ponywolf.ponytiled' )
local json         = require( 'json' ) 

-- Lokalne zmienne
local scene = composer.newScene()
local info, ui 
local resumeGame = false      

function scene:create( event )
    local sceneGroup = self.view  

    -- Wczytanie mapy
    local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/info.json', system.ResourceDirectory ) )
    info = tiled.new( uiData, 'scene/menu/ui' )
    info.x, info.y = _CX - info.designedWidth * 0.5, _CY - info.designedHeight * 0.5

    -- Obsługa przycisków
    info.extensions = 'scene.menu.lib.'
    info:extend( 'button', 'label' )

    function ui( event )
        local phase = event.phase
        local name = event.buttonName

        if phase == 'released' then
          app.playSound( 'button' )
           
            if ( name == 'ok' ) then	
                resumeGame = true	   
                composer.hideOverlay( 'slideUp' )
            elseif ( name == 'chooseball' ) then
                  composer.showOverlay('scene.chooseball', { isModal=true,
                    effect='fromTop', params={} } )
            end
        end
        
        return true	
    end

    sceneGroup:insert( info )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == 'will' ) then

    elseif ( phase == 'did' ) then
        app.addRuntimeEvents( {'ui', ui} )		    
    end
end

function scene:hide( event )
    local phase = event.phase
    local previousScene = event.parent

    if ( phase == 'will' ) then
        app.removeAllRuntimeEvents()
    elseif ( phase == 'did' ) then
        if resumeGame then
            previousScene:resumeGame()
        end  
    end
end

function scene:destroy( event )
  --collectgarbage()
end

scene:addEventListener( 'create' ) 
scene:addEventListener( 'show' )
scene:addEventListener( 'hide' )
scene:addEventListener( 'destroy' )

return scene