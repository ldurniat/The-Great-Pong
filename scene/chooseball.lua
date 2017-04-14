local composer = require( "composer" )
local app      = require( "lib.app" )
local effects  = require( 'lib.effects' )
local colors   = require( "lib.colors" )
local Ball     = require( "ball" )
local dt       = require( "lib.deltatime" )

local scene = composer.newScene()
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
local _W, _H, _CX, _CY
local mSin, mCos, mPi, mRandom

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals( )

local leftArrow
local rightArrow 
local border

local items = {}
local xLeftArrow = 70
local smallSizeRect = 300
local xScaleSmallRect = 0.7
local xScaleBigRect = 1.2
local LEFT = 2 * xLeftArrow + 0.5 * 200
local CENTER = _CX
local RIGHT = _W - ( 2 * xLeftArrow + 0.5 * 200 )
local isTransitioning = false
local itemIndex = 2

--local player, computer
---------------------------------------------------------------------------------

local function onTransitionComplete( event )
    isTransitioning = false
end

local function enterFrame(event)
   local deltatime = dt.getDeltaTime()

   for i=1, #items do
      if ( itemIndex - 2 < i and i < 2 + itemIndex ) then
         items[i].ball:update( deltatime )
      end
   end
end

--------------------------------------------------------------------------------
-- Add Listeners
--------------------------------------------------------------------------------
 
local function handleSwipe( event )
    if ( event.phase == "moved" and not isTransitioning ) then
        local dX = event.x - event.xStart
        print( event.x, event.xStart, dX )
        -- Przesuwam w PRAWO
        if ( dX > 10 and itemIndex > 1 ) then
            isTransitioning = true
            if ( itemIndex > 2 ) then
               transition.to( items[itemIndex - 2], { time=500, alpha=1, onComplete=onTransitionComplete } )
            end
            transition.to( items[itemIndex - 1], { time=500, x=CENTER, xScale=xScaleBigRect, yScale=xScaleBigRect, onComplete=onTransitionComplete } )
            transition.to( items[itemIndex], { time=500, x=RIGHT,  xScale=xScaleSmallRect, yScale=xScaleSmallRect, onComplete=onTransitionComplete } )
            transition.to( items[itemIndex + 1], { time=500, alpha=0, onComplete=onTransitionComplete } )

            itemIndex = itemIndex - 1
         -- Przesuwam w LEWO
        elseif ( dX < -10 and itemIndex < #items ) then
            isTransitioning = true
            if ( itemIndex < #items ) then
               transition.to( items[itemIndex - 1], { time=500, alpha=0, onComplete=onTransitionComplete } )
            end
            transition.to( items[itemIndex], { time=500, x=LEFT,  xScale=xScaleSmallRect, yScale=xScaleSmallRect, onComplete=onTransitionComplete } )
            transition.to( items[itemIndex + 1], { time=500, x=CENTER,  xScale=xScaleBigRect, yScale=xScaleBigRect, onComplete=onTransitionComplete } )
            transition.to( items[itemIndex + 2], { time=500, alpha=1, onComplete=onTransitionComplete } )

            itemIndex = itemIndex + 1
        end
    end
    return true
end

function scene:create( event )
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   local r = 50
   
   -- Wierzchołki strzałki - lewej i prawej
   local verts = { 
      r * mCos( mPi / 3 ), r * mSin( mPi / 3 ), 
      r * mCos( - mPi / 3 ), r * mSin( - mPi / 3 ), 
      r * mCos( mPi ), r * mSin( mPi ), 
   }

   leftArrow = display.newPolygon( sceneGroup, xLeftArrow, _CY, verts )
   leftArrow:setFillColor( colors.black )
   leftArrow.strokeWidth = 3 
   rightArrow = display.newPolygon( sceneGroup, _W - xLeftArrow, _CY, verts )
   rightArrow:setFillColor( colors.black )
   rightArrow.strokeWidth = 3 

   rightArrow.xScale = -1

   local tails = { 'lines', 'rects', 'circles', 'rectsRandomColors', 'circlesRandomColors', 'linesRandomColors' }

   for i=1, #tails do
      local group = display.newGroup( )
      local text = display.newText( group, "Ball " .. i, smallSizeRect * 0.5, -50, native.systemFont, 30 )
      local rect = display.newRect( group, 0, 0, smallSizeRect, smallSizeRect )
      rect:setFillColor( 0,0,0 )
      rect.anchorX, rect.anchorY, rect.strokeWidth  = 0, 0, 5

      local update = function( self, dt )  
         local img = self.img
         img.x, img.y = img.x + img.velX * dt, img.y + img.velY * dt

         effects.addTail( self, {dt=dt, name=tails[ i ]} )
         self:rotate( dt )
         self:collision()
      end

      local ball = Ball.new( {width=smallSizeRect, height=smallSizeRect, speed=10, update=update} )
      ball:serve()

      group.anchorChildren = true
      group.anchorX = 0.5
      group.anchorY = 0.5  
      group.x = RIGHT
      group.y = _CY

      items[i] = group
      group.ball = ball
      group:scale( xScaleSmallRect, xScaleSmallRect )

      group:insert( ball )
      sceneGroup:insert( group )
   end   

   items[1].x = LEFT
   items[2].x = CENTER

   for i=1, #items do
      if itemIndex + 1 < i then
         items[i].alpha = 0
      end
      if i == itemIndex then
         items[i]:scale( 2, 2 )
      end 
   end   

   Runtime:addEventListener( "touch", handleSwipe )
end
 
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
      Runtime:addEventListener("enterFrame", enterFrame)
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end
 
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------
 
return scene