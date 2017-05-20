--
-- Okno z wyborem piłeczki 
--
-- Wymagane moduły
local composer   = require( "composer" )
local app        = require( "lib.app" )
local tiled      = require( 'com.ponywolf.ponytiled' )
local json       = require( 'json' )
local fx         = require( 'com.ponywolf.ponyfx' ) 
local deltatime  = require( 'lib.deltatime' )
local preference = require( 'preference' )
local ball       = require( 'scene.game.lib.ball' )

 
-- Lokalne zmienne
local mClamp  = math.clamp
local mRandom = math.random
local mPi     = math.pi
local mCos    = math.cos
local mSin    = math.sin

-- Lokalne zmienne
local scene = composer.newScene()
local menu, ui, balls, numOfBalls
local indexBall = 1 
local ballFrame, ballInUse, ballName, questionMark
local ballImages = {}   

local function showBall()
    local points = preference:get( 'totalPoints' )
    -- ukrywanie miniaturek
    for i=1, #ballImages do ballImages[i].alpha = 0 end 

    -- nazwy piłeczki
    print( indexBall )
    ballName.text = balls[indexBall].name

    -- liczba punktów
    if balls[indexBall].buy then
        pointsLabel.text = ''
        ballImages[indexBall].alpha = 1
        questionMark.alpha = 0
        ballFrame:setFillColor( 0.2, 0.3, 0.4 ) 
    else
        pointsLabel.text = points .. '/' .. balls[indexBall].points
        questionMark.alpha = 1
        ballFrame:setFillColor( 1 )    
    end   
end    

local function pickBall()
    local points = preference:get( 'totalPoints' )
    -- zaznaczam piłeczkę jako zakupioną
    balls[indexBall].buy = true    

    points = points - balls[indexBall].points
    preference:set( 'totalPoints', points )

    showBall()
end 

local function prevBall()
    indexBall = indexBall - 1 < 1 and numOfBalls or (indexBall - 1)
    showBall()
end   

local function nextBall()
    indexBall = indexBall + 1 > numOfBalls and 1 or (indexBall + 1)
    showBall()
end   

function scene:create( event )
    local sceneGroup = self.view

    balls = preference:get( 'balls' )

    -- Wczytanie mapy
    local uiData = json.decodeFile( system.pathForFile( 'scene/menu/ui/chooseBall.json', system.ResourceDirectory ) )
    menu = tiled.new( uiData, 'scene/menu/ui' )
    menu.x, menu.y = display.contentCenterX - menu.designedWidth/2, display.contentCenterY - menu.designedHeight/2

    -- Obsługa przycisków
    menu.extensions = 'scene.menu.lib.'
    menu:extend( 'button', 'label' )

    function ui( event )
        local phase = event.phase
        local name = event.buttonName

        if phase == 'released' then
            app.playSound( 'button' )
         
            if ( name == 'left' ) then
                prevBall()
            elseif ( name == 'right' ) then
                nextBall()
            elseif ( name == 'ok' ) then 
                timer.performWithDelay( 100, function() 
                    composer.showOverlay( 'scene.info', { isModal=true, effect='fromTop',  params={} } )
                    end ) 
            elseif ( name == 'ballFrame' ) then
                pickBall()
            end
        end

        return true 
    end

    numOfBalls = #balls

    for i=1, numOfBalls do ballImages[i] = menu:findObject( 'ball' .. i ) end

    ballFrame = menu:findObject( 'ballFrame' )   
    ballName = menu:findObject( 'ballName' )
    pointsLabel = menu:findObject( 'points' )
    questionMark = menu:findObject( 'questionMark' ) 

    sceneGroup:insert( menu )  
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      prevBall()  
      app.addRuntimeEvents( {'ui', ui} )
    elseif ( phase == "did" ) then     
    end
end
 
function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        app.removeAllRuntimeEvents() 
        preference:set( 'ballInUse', indexBall )
    elseif ( phase == "did" ) then
      
    end
end
 
function scene:destroy( event )

end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene