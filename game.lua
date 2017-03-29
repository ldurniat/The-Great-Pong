local composer = require( 'composer' )
local app      = require( 'lib.app' )
local collision = require( 'lib.collision' )
local effects = require( 'lib.effects' )
local Ball     = require( 'ball' )
local Player   = require( 'player' )
local Computer = require( 'computer' )
local utils = require( "lib.utils" ) 

local dt = require( "lib.deltatime" )

local ball 
local player 
local computer

local _W, _H, _CX, _CY

local mRandom 
local mPi
local mSin
local mCos
local mAbs
local mClamp = math.clamp

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals( )


local lineWidth = 4
local shrinkScale = 0.85

local score

local scene = composer.newScene( )

math.randomseed( os.time() ) 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
local function init( )
   local offset = 120

   player.spriteinstance.x = player.width + offset
   player.spriteinstance.y = ( _H - player.height ) * 0.5
   computer.spriteinstance.x = _W - ( player.width + computer.width ) - offset
   computer.spriteinstance.y = ( _H - computer.height ) * 0.5

   ball:serve()
end   

local function loop( )
   dt.setDeltaTime( )
   local deltatime = dt.getDeltaTime( )

   ball:update( deltatime )
   computer:update( ball, deltatime )
   player:tail( deltatime )
end

local function drag( event )
   local self = player.spriteinstance

   --local self = event.target
   if ( event.phase == "began" ) then
      -- first we set the focus on the object
      display.getCurrentStage():setFocus( self, event.id )
      self.isFocus = true

      -- then we store the original x and y position
      --self.markX = self.x
      self.markY = self.y
   elseif ( self.isFocus ) then
      if ( event.phase == "moved" ) then
        -- then drag our object
        --self.x = event.x - event.xStart + self.markX
         if ( event.y - event.yStart + self.markY > self.height * self.yScale * self.anchorY and 
            event.y - event.yStart + self.markY < _H - self.height * ( 1 - self.anchorY ) * self.yScale ) then
            self.y = event.y - event.yStart + self.markY
            --player.cat.y = self.y + self.height * 0.5
         else
            self.y = mClamp(self.y, self.height * self.yScale * self.yScale + 1, _H - self.height * ( 1 - self.yScale ) * self.yScale - 1 )
         end
      elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
        -- we end the movement by removing the focus from the object
        display.getCurrentStage():setFocus( self, nil )
        self.isFocus = false
      end
   end
 
   -- return true so Corona knows that the touch event was handled propertly
   return true
end   

local function shrink( event )
   player.spriteinstance:scale( 1, shrinkScale )
end   

local function scoreup( event )
   score.text = tostring(score.text) + 1
end 

-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
  
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   player = Player( nil, {} )
   computer = Computer( nil, {} )

   local update = function( self, dt )  
      self:tail( dt )
      self:rotate( dt )

      self.x = self.x + self.velX * dt
      self.y = self.y + self.velY * dt
      
      self.spriteinstance.x = self.x 
      self.spriteinstance.y = self.y

      self:checkCollisionWithScreenEdges( lineWidth )
      
      local pdle = self.x < self.screenWidth * 0.5 and player or computer
      
      if ( collision.AABBIntersect( pdle.spriteinstance, self.spriteinstance ) ) then
         self.x = pdle.spriteinstance.x + ( self.velX > 0 and -1 or 1 ) * pdle.spriteinstance.width * 0.5
        
         local i = pdle == player and -1 or 1
         local x1 = 0.5 * ( pdle.spriteinstance.height + self.side )
         local n = ( 1 / ( 2 * x1 ) ) * ( pdle.spriteinstance.y - self.y ) + ( x1 / ( 2 * x1 ) )
         local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
         local smash = mAbs( phi ) > 0.2 * mPi and 1.5 or 1

         local mSign = math.sign
        
         self.velX = - mSign( self.velX ) * smash  * self.speed * mCos( phi )
         self.velY = smash * mSign( self.velY ) * self.speed * mAbs( mSin( phi ) )
      end
   end   
   
   ball = Ball( nil, {x=_CX, y=_CY, update=update, tail='linesRandomColors'} )

   score = display.newText( sceneGroup, '0', _CX - 100, 100, native.systemFont, 70 )
   --computer.enemyId = 5

   init()

   listen( 'collisionedgewest', shrink)
   listen( 'collisionedgeeast', scoreup)
end

function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Rysuje krótkie linie na środku ekranu
      local round = math.round
      local lineLenght = 20 
      -- Wyznaczam położenie pierwszej linii od krawędzi ekranu tak aby 
      -- odległość od obu krawędzi była równa
      local tmp = round( _H / lineLenght )
      tmp = tmp % 2 == 0 and tmp - 1 or tmp
      local startY = round( ( _H - lineLenght * tmp ) * 0.5 )

      for i=startY, _H,  2 * lineLenght do
         local line = display.newLine( sceneGroup, _CX, i, _CX, i + lineLenght )
         line.strokeWidth = lineWidth
      end   

      local verticles = 
       { {0 , 0}, 
         {_W, 0},
         {_W, _H},
         {0 , _H},
         {0 , 0}, }

      for i=1, #verticles - 1 do
         local line = display.newLine( sceneGroup, verticles[i][1], verticles[i][2], verticles[i + 1][1], verticles[i + 1][2] )
         line.strokeWidth = lineWidth * 2
      end  
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

      Runtime:addEventListener( "enterFrame", loop )
      Runtime:addEventListener( "touch", drag )
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
      Runtime:removeEventListener( "enterFrame", loop )
      Runtime:removeEventListener( "touch", drag )
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