--
-- Scena z rozgrywką
--
-- Wymagane moduły
local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local preference = require( 'preference' )
local fx         = require( 'com.ponywolf.ponyfx' )
local deltatime  = require( 'lib.deltatime' ) 
local ball       = require( 'scene.game.lib.ball' )
local paddle     = require( 'scene.game.lib.paddle' )
local background = require( 'scene.game.lib.background' )
local scoring    = require( 'scene.game.lib.score' )

math.randomseed( os.time() )  

-- Lokalne zmienne
local mClamp  = math.clamp

-- Lokalne zmienne
local squareBall, player, computer 
local playerScore, computerScore
local maxScore = 1

local scene = composer.newScene()   

-- Główna pętla gry 
local function loop()
   local dt = deltatime.getTime()

   squareBall:update( dt )
   computer:update( dt )
end

-- Obsługa ruchu paletki gracza
local function drag( event )
   if ( event.phase == 'began' ) then
      display.getCurrentStage():setFocus( player )
      player.isFocus = true
      player.markY = player.y
   elseif ( player.isFocus ) then
      if ( event.phase == 'moved' ) then
         player.y = mClamp( event.y - event.yStart + player.markY, 
            player.height * player.yScale * player.anchorY, 
            _H - player.height * ( 1 - player.anchorY ) * player.yScale )
      elseif ( event.phase == 'ended' or event.phase == 'cancelled' ) then
        display.getCurrentStage():setFocus( nil )
        player.isFocus = false
      end
   end
 
   return true
end   

local function gameOver()
   app.playSound( scene.sounds.lost )
   local textId = playerScore:get() == maxScore and 'win' or 'lost'
   app.removeAllRuntimeEvents()
   -- Resetowanie fokusa. Bez tego polecenia pzyciski w 
   -- oknie dialogowym nie reagowały  
   drag( { phase='ended'} )
   --transition.pause( )
   local screen = display.getCurrentStage()
   fx.shake( screen )
   timer.performWithDelay( 500, function() 
      composer.showOverlay("scene.result", { isModal=true,
         effect="fromTop", params={textId=textId, newScore=playerScore:get()} } )
      end ) 
end   

local function touchEdge( event )
   local edge = event.edge
   local x = event.x
   local y = event.y

   app.playSound(scene.sounds.wall)

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
   -- ustawia wybraną piłeczke
   local ballInUse = preference:get( 'ballInUse' )
   local balls = preference:get( 'balls' )

   -- dodanie piłeczki
   squareBall = ball.new( balls[ballInUse].params )
   scene.squareBall = squareBall
   squareBall:serve()

   scene.view:insert( squareBall )

   deltatime.restart()
   app.addRuntimeEvents( {'enterFrame', loop, 'touch', drag, 'touchEdge', touchEdge} )
end   

function scene:create( event ) 
   local sceneGroup = self.view
   local offset = 120

   local sndDir = 'scene/game/sfx/'
   scene.sounds = {
      wall = audio.loadSound( sndDir .. 'wall.wav' ),
      hit  = audio.loadSound( sndDir .. 'hit.wav' ),
      lost = audio.loadSound( sndDir .. 'lost.wav' )    
   }

   -- usuwa poprzednią scene
   local prevScene = composer.getSceneName( 'previous' ) 
   composer.removeScene( prevScene )

   -- dodaje planszę
   local board = background.new()

   -- dodaje paletkę gracza 
   player = paddle.new()
   scene.player = player
   player.x, player.y = player.width + offset, _CY

   -- dodaje paletkę komputerowego przeciwnika
   computer = paddle.new()
   scene.computer = computer
   computer.x, computer.y = _W - offset, _CY  
   
   -- dodanie obiektu przechowującego wynik dla obu graczy
   playerScore = scoring.new()
   playerScore.x, playerScore.y = _CX - 100, _T + 100
   app.setRP( playerScore, 'CenterRight')

   computerScore = scoring.new( {align='left'} )
   computerScore.x, computerScore.y = _CX + 100, _T + 100
   app.setRP( computerScore, 'CenterLeft')

   -- dodanie obiekty do sceny we właściwej kolejności
   sceneGroup:insert( board )
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

   audio.stop()
   for s,v in pairs( self.sounds ) do
      audio.dispose( v )
      self.sounds[s] = nil
   end
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene