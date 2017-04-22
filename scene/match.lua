--
-- Scena z rozgrywką endless
--
-- Wymagane moduły
local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local collision  = require( 'lib.collision' )
local effects    = require( 'lib.effects' )
local deltatime  = require( 'lib.deltatime' ) 
local ball       = require( 'scene.endless.lib.ball' )
local paddle     = require( 'scene.endless.lib.paddle' )
local background = require( 'scene.endless.lib.background' )
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
local spark, playerScore, computerScore
local maxScore = 2
local message = {
   win = 'You WIN.',
   lost = 'You lost.'
}
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

local function gameOver()
   local message = playerScore:get() == maxScore and message.win or message.lost
   app.removeAllRuntimeEvents()
   transition.pause( ) 
   effects.shake( {time=500} )
   timer.performWithDelay( 500, function() 
      composer.showOverlay("scene.result", { isModal=true,
         effect="fromTop", params={message=message} } )
      end ) 
end   

local function touchEdge( event )
   local edge = event.edge
   local x = event.x
   local y = event.y

   spark:startAt( edge, x, y )

   if ( edge == 'right' ) then
      playerScore:add( 1 )   
   elseif ( edge == 'left' ) then
      computerScore:add( 1 )   
   end   

   -- sprawdza czy mecz dobiegł końca
   if ( computerScore:get() == maxScore or playerScore:get() == maxScore ) then
      gameOver()
   end   
end   

-- rozpoczyna grę od nowa
function scene:resumeGame()
   deltatime.restart()
   app.addRuntimeEvents( {'enterFrame', loop, 'touch', drag, 'touchEdge', touchEdge} )
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
      self:addTail( dt )
      self:rotate( dt )
      -- wykrywanie kolizji z krawędziami ekranu
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

   -- dodaje efekt cząsteczkowy
   spark = sparks.new()
   
   -- dodanie obiektu przechowującego wynik dla obu graczy
   playerScore = scoring.new()
   playerScore.x, playerScore.y = _CX - 100, _T + 100
   app.setRP( playerScore, 'CenterRight')

   computerScore = scoring.new( {align='left'} )
   computerScore.x, computerScore.y = _CX + 100, _T + 100
   app.setRP( computerScore, 'CenterLeft')

   -- dodanie obiekty do sceny we właściwej kolejności
   sceneGroup:insert( spark )
   sceneGroup:insert( board )
   sceneGroup:insert( squareBall )
   sceneGroup:insert( computer )
   sceneGroup:insert( player )
   sceneGroup:insert( playerScore )
   sceneGroup:insert( computerScore )
end

function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == 'will' ) then
      
   elseif ( phase == 'did' ) then
      composer.showOverlay( "scene.info", { isModal=true, effect="fromTop",  params={} } )
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
   spark:destroy()
   spark = nil
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene