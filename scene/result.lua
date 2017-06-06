--
-- Ekran wyświetlający wyniki.
--
-- Wymagane moduły
local app          = require( 'lib.app' )
local preference   = require( 'preference' )
local composer     = require( 'composer' )
local fx           = require( 'com.ponywolf.ponyfx' ) 
local tiled        = require( 'com.ponywolf.ponytiled' )
local json         = require( 'json' ) 
local translations = require( 'translations' )

-- Lokalne zmienne
local scene = composer.newScene()
local info, ui  

function scene:create( event )
    local sceneGroup = self.view  
    
    -- Wczytanie mapy
    local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/result.json', system.ResourceDirectory ) )
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
    local textId = event.params.textId
    local newScore = event.params.newScore
    local totalPoints = preference:get( 'totalPoints' )
    local lang = preference:get( 'language' )

    if ( phase == 'will' ) then
            totalPoints = totalPoints + newScore
            local message = {
                win = translations[lang]['winMessage'] .. totalPoints,
                lost = translations[lang]['loseMessage'] .. totalPoints,
            }

            info:findObject('message').text = message[textId]
            -- zlicza wszystkie zdobyte punkty
            preference:set('totalPoints', totalPoints ) 
    elseif ( phase == 'did' ) then
        app.addRuntimeEvents( {'ui', ui} )		    
    end
end

function scene:hide( event )
    local phase = event.phase

    if ( phase == 'will' ) then
        app.removeAllRuntimeEvents()
    elseif ( phase == 'did' ) then

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