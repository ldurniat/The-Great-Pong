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
local menu, ui
local index       = preference:get( 'ballInUse' ) 
local totalPoints = preference:get( 'totalPoints' )
local balls       = preference:get( 'balls' )
local widgets, last, selected = { images={} }, #balls, index 

local function hide( object )
    object.alpha = 0
end  

local function show( object )
    object.alpha = 1
end

local function markBall()
    widgets.frame:setFillColor( 0.2, 0.3, 0.4 )
end 

local function unMarkBall()
    widgets.frame:setFillColor( 1 )
end 

local function showBall()
    -- ukrywanie miniaturek
    for i=1, #widgets.images do hide( widgets.images[i] ) end 

    -- zmiana nazwy piłeczki
    widgets.title.text = balls[index].name

    -- (nie) wyświetlenie liczby punktów
    if balls[index].buy then
        widgets.points.text = ''
        show( widgets.images[index] )
        hide( widgets.noBuyImage )
    else
        widgets.points.text = totalPoints .. '/' .. balls[index].points
        show( widgets.noBuyImage )    
    end 

    -- (nie) dodanie wyróźnienia
    if ( index == selected ) then
        markBall()
    else
        unMarkBall()    
    end  
end      

local function pickBall()
    if ( balls[index].buy == false and balls[index].points <= totalPoints ) then
        -- zaznaczam piłeczkę jako zakupioną
        balls[index].buy = true    
        selected = index
        totalPoints = totalPoints - balls[index].points

        markBall()
        showBall()
    end
end 

local function prevBall()
    index = index - 1 < 1 and last or (index - 1)
    showBall()
end   

local function nextBall()
    index = index + 1 > last and 1 or (index + 1)
    showBall()
end   

function scene:create( event )
    local sceneGroup = self.view
    local names = { 'frame', 'title', 'points', 'noBuyImage' }

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
                composer.showOverlay( 'scene.info', { isModal=true, effect='fromTop',  params={} } )
            elseif ( name == 'frame' ) then
                pickBall()
            end
        end

        return true 
    end

    for i=1, last do widgets.images[i] = menu:findObject( 'ball' .. i ) end
    for i=1, #names do widgets[ names[i] ] = menu:findObject( names[i] ) end

    sceneGroup:insert( menu )  
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      showBall()  
      app.addRuntimeEvents( {'ui', ui} )
    elseif ( phase == "did" ) then     
    end
end
 
function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        app.removeAllRuntimeEvents() 
        preference:set( 'ballInUse', selected )
        preference:set( 'totalPoints', totalPoints )
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