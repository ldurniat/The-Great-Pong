--
-- Ekran wyświetlający wyniki.
--
-- Wymagane moduły
local app        = require( 'lib.app' )
local preference = require( 'preference' )
local composer   = require( 'composer' )
local fx         = require( 'com.ponywolf.ponyfx' ) 
local tiled      = require( 'com.ponywolf.ponytiled' )
local json       = require( 'json' ) 

-- Lokalne zmienne
local scene = composer.newScene()
local info, ui 

function scene:create( event )
    local sceneGroup = self.view  
    local buttonSound = audio.loadSound( 'scene/endless/sfx/select.wav' ) 

    -- Wczytanie mapy
    local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/result.json', system.ResourceDirectory ) )
    info = tiled.new( uiData, 'scene/menu/ui' )
    info.x, info.y = display.contentCenterX - info.designedWidth/2, display.contentCenterY - info.designedHeight/2

    -- Obsługa przycisków
    info.extensions = 'scene.menu.lib.'
    info:extend( 'button', 'label' )

    function ui( event )
        local phase = event.phase
        local name = event.buttonName
        if phase == 'released' then 
            app.playSound( buttonSound )
            
            if ( name == 'restart' ) then
                fx.fadeOut( function()
                    composer.hideOverlay()
                    composer.gotoScene( 'scene.refresh', { params = {} } )
                    end )
            elseif ( name == 'menu' ) then
                fx.fadeOut( function()
                    composer.hideOverlay()
                    composer.gotoScene( 'scene.menu', { params = {} } )
                    end )
            end
        end

        return true	
    end

    sceneGroup:insert( info )
end

function scene:show( event )
    local phase = event.phase
    local message = event.params.message
    local newScore = event.params.newScore

    if ( phase == 'will' ) then
        if message then
            info:findObject('message').text = message

            -- zlicza wszystkie zdobyte punkty
            local totalPoints = preference:get( 'totalPoints' )
            totalPoints = totalPoints + newScore
            preference:set('totalPoints', totalPoints )
        end  
    elseif ( phase == 'did' ) then
        app.addRuntimeEvents( {'ui', ui} )		    
    end
end

function scene:hide( event )
    local phase = event.phase
    local previousScene = event.parent

    if ( phase == 'will' ) then
        app.removeAllRuntimeEvents()
        previousScene:resumeGame()
    elseif ( phase == 'did' ) then

    end
end

function scene:destroy( event )
    audio.stop()
    audio.dispose( buttonSound )
  --collectgarbage()
end

scene:addEventListener( 'create' ) 
scene:addEventListener( 'show' )
scene:addEventListener( 'hide' )
scene:addEventListener( 'destroy' )

return scene