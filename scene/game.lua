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

local function stretch( object )
   transition.chain( object, {time=100, xScale=0.8, yScale=1.2},
      {time=100, xScale=1.1, yScale=0.9},
      {time=100, xScale=0.95, yScale=1.05},
      {time=100, xScale=1, yScale=1} )   
end   

-- Główna pętla gry 
local function loop()
   local dt = deltatime.getTime()

   squareBall:update( dt )
   computer:update( dt )
end

-- Obsługa ruchu paletki gracza
local function drag( event )
   if ( event.phase == 'began' ) then
      player.isFocus = true
      player.markY = player.y
   elseif ( player.isFocus ) then
      if ( event.phase == 'moved' ) then
         player.y = mClamp( event.y - event.yStart + player.markY, 
            player.height * player.yScale * player.anchorY, 
            _H - player.height * ( 1 - player.anchorY ) * player.yScale )
      elseif ( event.phase == 'ended' or event.phase == 'cancelled' ) then
        player.isFocus = false
      end
   end
 
   return true
end   

local function gameOver()
   app.playSound( 'lost' )
   local gamesPlayed = preference:get( 'gamesPlayed' )
   preference:set( 'gamesPlayed', gamesPlayed + 1 )
   local textId = playerScore:get() == maxScore and 'win' or 'lost'
   app.removeAllRuntimeEvents()
   local screen = display.getCurrentStage()
   fx.shake( screen )
   timer.performWithDelay( 500, function() 
      composer.showOverlay("scene.result", { isModal=true,
         effect="crossFade", params={textId=textId, newScore=playerScore:get()} } )
      end ) 
end   

local function touchEdge( event )
   local edge = event.edge
   local x = event.x
   local y = event.y

   app.playSound( 'wall' )

   if ( edge == 'right' ) then
      playerScore:add( 1 )   
      stretch( playerScore )
   elseif ( edge == 'left' ) then
      computerScore:add( 1 ) 
      stretch( computerScore )
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
   local offset = 120

   -- dodanie piłeczki
   squareBall = ball.new( balls[ballInUse].params )
   scene.squareBall = squareBall
   squareBall:serve()

   scene.view:insert( squareBall )

   transition.to( scene.board, {transition=easing.outBack, delay=200, time=500, yScale=1} )
   transition.to( playerScore, {transition=easing.outBack, time=500, y=_T + 100} )
   transition.to( computerScore, {transition=easing.outBack, time=500, y=_T + 100} )

   transition.to( player, {transition=easing.outBack, time=500, x=player.width + offset} )
   transition.to( computer, {transition=easing.outBack, time=500, x= _W - offset, 
      onComplete=function() 
            deltatime.restart()
            app.addRuntimeEvents( {'enterFrame', loop, 'touch', drag, 'touchEdge', touchEdge} )
         end  } )
end   

function scene:create( event ) 
   composer.returnTo = 'scene.menu'
   local sceneGroup = self.view

   -- usuwa poprzednią scene
   local prevScene = composer.getSceneName( 'previous' ) 
   composer.removeScene( prevScene )

   -- dodaje planszę
   local board = background.new()
   board.yScale = 0.001
   scene.board = board

   -- dodaje paletkę gracza 
   player = paddle.new()
   scene.player = player
   player.x, player.y = _L - player.width, _CY

   -- dodaje paletkę komputerowego przeciwnika
   computer = paddle.new()
   scene.computer = computer 
   computer.x, computer.y = _R + _W + player.width, _CY 
   
   -- dodanie obiektu przechowującego wynik dla obu graczy
   playerScore = scoring.new({font=app.font})
   playerScore.x, playerScore.y = _CX - 100, _T - player.height 
   app.setRP( playerScore, 'CenterRight')

   computerScore = scoring.new( {align='left', font=app.font} )
   computerScore.x, computerScore.y = _CX + 100, _T - player.height 
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
      --composer.showOverlay( "scene.info", { isModal=true, effect="crossFade",  params={} } )
      self:resumeGame()
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
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene