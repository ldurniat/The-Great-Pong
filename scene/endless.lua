local composer  = require( 'composer' )
local app       = require( 'lib.app' )
local collision = require( 'lib.collision' )
local effects   = require( 'lib.effects' )
local utils     = require( 'lib.utils' ) 
local dt        = require( 'lib.deltatime' )
local Ball      = require( 'scene.endless.lib.ball' )
local Paddle    = require( 'scene.endless.lib.paddle' )
local sparks    = require( 'lib.sparks' )
local colors    = require( 'lib.colors' ) 

math.randomseed( os.time( ) )  

-- Lokalne zmienne
local _W, _H, _CX, _CY
local mClamp, mRandom, mPi, mSin, mCos, mAbs = math.clamp 

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals( )

-- Lokalne zmienne
local ball, player, computer
local lineWidth, shrinkScale = 4, 0.85
local score, collisionWithEdge
local scene = composer.newScene( )

-- Główna pętla gry 
local function loop( )
   local deltatime = dt.getDeltaTime( )

   ball:update( deltatime )
   computer:update( ball, deltatime )
end

local function drag( event )
   local self = player.img

   if ( event.phase == 'began' ) then
      -- first we set the focus on the object
      display.getCurrentStage( ):setFocus( self, event.id )
      self.isFocus = true

      -- then we store the original x and y position
      --self.markX = self.x
      self.markY = self.y
   elseif ( self.isFocus ) then
      if ( event.phase == 'moved' ) then
        -- then drag our object
         self.y = mClamp( event.y - event.yStart + self.markY, 
            self.height * self.yScale * self.anchorY, 
            _H - self.height * ( 1 - self.anchorY ) * self.yScale )
      elseif ( event.phase == 'ended' or event.phase == 'cancelled' ) then
        -- we end the movement by removing the focus from the object
        display.getCurrentStage( ):setFocus( self, nil )
        self.isFocus = false
      end
   end
 
   -- return true so Corona knows that the touch event was handled propertly
   return true
end   

local function shrink( event )
   player.img:scale( 1, shrinkScale )
end   

local function scoreup( event )
   score.text = tostring(score.text) + 1 
end 

local function gameover( event )
   local edge = event.edge
   local newScore = tonumber( score.text )

   app.removeRtEvents( { 'enterFrame', loop, 'touch', drag, 'edgeCollision', collisionWithEdge } )
   transition.pause( ) 
   --sparks.stop( edge ) 
   --transition.blink( ball, {time=200} ) 
   effects.shake( {time=500} )
   timer.performWithDelay( 500, function() 
      composer.showOverlay("scene.hiscore", { isModal = true, effect = "fromTop",  params = {newScore=newScore} } )
      end )
end   

function collisionWithEdge( event )
   local edge = event.edge
   local x = event.x
   local y = event.y

   sparks.start( edge, x, y )

   if ( edge == 'left' ) then
      if player.img.yScale < 1 then
         gameover( event )
      else   
         shrink( )
      end   
   elseif ( edge == 'right' ) then
      scoreup( )
   end   
end

function scene:create( event ) 
   local sceneGroup = self.view
   local offset = 120

   player = Paddle.new( )
   player.img.x = player.img.width + offset
   player.img.y = _CY

   computer = Paddle.new( )
   computer.img.x = _W - offset
   computer.img.y = _CY
   
   local update = function( self, dt ) 
      local img = self.img
      img.x, img.y = img.x + img.velX * dt, img.y + img.velY * dt

      effects.addTail( self, {dt=dt, name='circlesRandomColors'} )
      self:rotate( dt )
      self:collision( )
      
      local pdle = img.x < img.bounds.width * 0.5 and player.img or computer.img
      
      if ( collision.AABBIntersect( pdle, img ) ) then
         img.x = pdle.x + ( img.velX > 0 and -1 or 1 ) * pdle.width * 0.5
        
         local mSign = math.sign        
         local i = pdle == player and -1 or 1
         local x1 = 0.5 * ( pdle.height + img.side )
         local n = ( 1 / ( 2 * x1 ) ) * ( pdle.y - img.y ) + ( x1 / ( 2 * x1 ) )
         local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
         local smash = mAbs( phi ) > 0.2 * mPi and 1.5 or 1
        
         img.velX = - mSign( img.velX ) * smash  * img.speed * mCos( phi )
         img.velY = smash * mSign( img.velY ) * img.speed * mAbs( mSin( phi ) )
      end
   end   
   
   ball = Ball.new( {update=update} )
   ball:serve( )

   sparks.new( 'left', { physics = {
         gravityX = -0.5,
         gravityY = 0,
      } } ) 
   sparks.new( 'right' ) 
   sparks.new( 'top' , { physics = {
         gravityX = 0,
         gravityY = -0.5,
      } } ) 
   sparks.new( 'bottom' , { physics = {
         gravityX = 0,
         gravityY = 0.5,
      } } )  

   sceneGroup:insert( ball )
   sceneGroup:insert( computer )
   sceneGroup:insert( player )

   score = display.newText( sceneGroup, '0', _CX - 100, 100, native.systemFont, 70 )
end

function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
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
   elseif ( phase == 'did' ) then
      dt.restart()
      app.addRtEvents( { 'enterFrame', loop, 'touch', drag, 'edgeCollision', collisionWithEdge } )
   end
end
 
function scene:hide( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
   
   elseif ( phase == 'did' ) then
      app.removeAllRtEvents( )
   end
end
 
function scene:destroy( event )
   app.removeAllRtEvents( )
   sparks.removeAll( )
   sparks = nil
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene