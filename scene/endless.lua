--
-- Scena z rozgrywką endless
--
-- Wymagane moduły
local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local collision  = require( 'lib.collision' )
local effects    = require( 'lib.effects' )
local deltatime  = require( 'lib.deltatime' )
local colors     = require( 'lib.colors' ) 
local ball       = require( 'scene.endless.lib.ball' )
local paddle     = require( 'scene.endless.lib.paddle' )
local background = require( 'scene.endless.lib.background' )
local lives      = require( 'scene.endless.lib.liveBar' )
local sparks     = require( 'lib.sparks' )
local scoring    = require( 'scene.endless.lib.score' )

math.randomseed( os.time() )  

-- Lokalne zmienne
local _W, _H, _CX, _CY, _T
local mClamp, mRandom, mPi, mSin, mCos, mAbs = math.clamp 

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals()

-- Lokalne zmienne
local squareBall, player, computer
local lineWidth, shrinkScale, collisionWithEdge = 4, 0.85
local scene = composer.newScene()

-- Główna pętla gry 
local function loop()
   local dt = deltatime.getTime()

   squareBall:update( dt )
   computer:update( squareBall, dt )
end

-- Obsługa ruchu paletki gracza
local function drag( event )

   local self = player.img

   if ( event.phase == 'began' ) then
      display.getCurrentStage():setFocus( self, event.id )
      self.isFocus = true
      self.markY = self.y
   elseif ( self.isFocus ) then
      if ( event.phase == 'moved' ) then
         self.y = mClamp( event.y - event.yStart + self.markY, 
            self.height * self.yScale * self.anchorY, 
            _H - self.height * ( 1 - self.anchorY ) * self.yScale )
      elseif ( event.phase == 'ended' or event.phase == 'cancelled' ) then
        display.getCurrentStage():setFocus( self, nil )
        self.isFocus = false
      end
   end
 
   return true
end   

-- rozpocznij grę od nowa
function scene:resumeGame()
   deltatime.restart()
   app.addRuntimeEvents( {'enterFrame', loop, 'touch', drag} )
end   

function scene:create( event ) 
   local sceneGroup = self.view
   local offset = 120

   -- usuwa poprzednią scene
   local prevScene = composer.getSceneName( 'previous' ) 
   composer.removeScene( prevScene )

   -- dodaje planszę
   local board = background.new()

   -- dodaje paletkę gracza 
   player = paddle.new()
   player.img.x, player.img.y = player.img.width + offset, _CY

   -- dodaje paletkę komputerowego przeciwnika
   computer = paddle.new()
   computer.img.x, computer.img.y = _W - offset, _CY
   
   -- definicja funkcji piłeczki do aktualizacji jej ruchów 
   local update = function( self, dt ) 
      local img = self.img
      img.x, img.y = img.x + img.velX * dt, img.y + img.velY * dt

      -- dodanie różnych efektów dla piłeczki
      effects.addTail( self, {dt=dt, name='circlesRandomColors'} )
      self:rotate( dt )
      self:collision()
      
      local pdle = img.x < img.bounds.width * 0.5 and player.img or computer.img
      
      -- wykrywanie kolizji między piłeczką i paletkami
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
   
   -- dodanie piłeczki
   squareBall = ball.new( {update=update} )
   squareBall:serve()

   -- dodanie paska z życiem
   scene.lives = lives.new()
   local live = scene.lives
   live.x, live.y = _CX + 100, _T + 100

   -- Ze względu na brak możliwości zmiany własności fizycznych sparks
   -- tworze 4 na każdą krawędz ekranu
   scene.sparks = sparks
   sparks.new( 'left', { physics={ gravityX=-0.5, gravityY=0} } ) 
   sparks.new( 'right' ) 
   sparks.new( 'top', { physics={ gravityX=0, gravityY=-0.5 } } ) 
   sparks.new( 'bottom', { physics={ gravityX=0, gravityY=0.5 } } )  

   -- dodanie obiektu przechowującego wynik
   scene.score = scoring.new()
   local score = scene.score
   score.x, score.y = _CX - score.width, _T + 100

   -- dodanie obiekty do sceny we właściwej kolejności
   sceneGroup:insert( board )
   sceneGroup:insert( squareBall )
   sceneGroup:insert( computer )
   sceneGroup:insert( player )
   sceneGroup:insert( score )
   sceneGroup:insert( live )
end

function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
      
   elseif ( phase == 'did' ) then
      composer.showOverlay( "scene.start", { isModal = true, effect = "fromTop",  params = { } } )
   end
end
 
function scene:hide( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
   
   elseif ( phase == 'did' ) then
      app.removeAllRuntimeEvents()
   end
end
 
function scene:destroy( event )
   app.removeAllRuntimeEvents()
   sparks.removeAll()
   sparks = nil
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene