--
-- Okno z wyborem piłeczki 
--
-- Wymagane moduły
local composer  = require( "composer" )
local app       = require( "lib.app" )
local tiled     = require( 'com.ponywolf.ponytiled' )
local json      = require( 'json' )
local fx        = require( 'com.ponywolf.ponyfx' ) 
local effects   = require( 'lib.effects' )
local deltatime = require( 'lib.deltatime' )
local ball      = require( 'scene.endless.lib.ball' )

 
-- Lokalne zmienne
local _W, _H, _CX, _CY
local mSin, mCos, mPi, mRandom
local mClamp = math.clamp

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals( )

-- Lokalne zmienne
local scene = composer.newScene()
local menu, ui, tails
local indexBall = 1
local ballGroup = {}

local function updateBall( event )
    local dt = deltatime.getTime()
    ballGroup[indexBall].squareBall:update( dt )
end

local function nextBall( index )
    if ( index == 0 ) then
        index = #tails
    end 
    if ( index == #tails + 1 ) then
        index = 1
    end  

    for i=1, #ballGroup do ballGroup[i].isVisible = false end

    ballGroup[index].isVisible = true  
    indexBall = index     
end    

function scene:create( event )
   local sceneGroup = self.view
   local buttonSound = audio.loadSound( 'scene/endless/sfx/select.wav' )

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
            app.playSound( buttonSound )
         
            if ( name == 'left' ) then
                nextBall( indexBall - 1 )
            elseif ( name == 'right' ) then
                nextBall( indexBall + 1 )  
            elseif ( name == 'ok' ) then 
                timer.performWithDelay( 100, function() 
                    composer.showOverlay( 'scene.info', { isModal=true, effect='fromTop',  params={} } )
                    end ) 
                  
            end
        end

        return true 
    end

    sceneGroup:insert( menu )

    tails = effects.getTailNames()
    local width, height = 239, 247
  
    local x, y = menu:findObject( 'ballFrame' ).x, menu:findObject( 'ballFrame' ).y
    x, y = menu:localToContent( x, y )

    for i=1, #tails do
      local group = display.newGroup( )
      
      local update = function( self, dt )  
        local img = self.img
        img.x, img.y = img.x + img.velX * dt, img.y + img.velY * dt

        -- dodanie różnych efektów dla piłeczki
        self:addTail( dt, tails[i] )
        self:rotate( dt )
        -- wykrywanie kolizji z krawędziami ekranu
        self:collision()
      end

      local squareBall = ball.new( {width=width, height=height, speed=10, update=update} )
      squareBall:serve()

      --group.anchorChildren = true
      --group.anchorX = 0
      --group.anchorY = 0
      --group.x = RIGHT
      --group.y = _CY

      ballGroup[i] = group
      group.squareBall = squareBall
      -- Ustawienie prostokątnego pole w którym będzie się poruszać piłeczka
      group.x, group.y = x - width * 0.5, y - height * 0.5

      group:insert( squareBall )
      sceneGroup:insert( group )
    end   
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      nextBall( indexBall )
      deltatime.restart()
      app.addRuntimeEvents( {'ui', ui, 'enterFrame', updateBall} )
    elseif ( phase == "did" ) then     
    end
end
 
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        app.removeAllRuntimeEvents() 
    elseif ( phase == "did" ) then
      
    end
end
 
function scene:destroy( event )
    audio.stop()
    audio.dispose( buttonSound )
end
 
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene