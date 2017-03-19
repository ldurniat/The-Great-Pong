local composer = require( "composer" )
local app      = require( "lib.app" )
local Ball     = require( "ball" )
local Player   = require( "player" )
local Computer = require( "computer" )
local widget   = require( "widget" )

local ball 
local player 
local computer

local _W, _H, _CX

-- Nadaj odpowiednie wartości predefinowanym zmiennym (_W, _H, ...) 
app.setLocals( )

local getTimer = system.getTimer
local lastTime 

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

   --computer.cat.x = computer.spriteinstance.x

   ball:serve(1, player, computer)
end   

local function getDelta( )
   local curTime = getTimer()

   local dt = curTime - lastTime
   dt = dt / ( 1000 / display.fps)

   lastTime = curTime

   return dt
end

local function loop( )
   local dt = getDelta( )

   ball:update( player, computer ,dt)
   computer:update( ball, dt )
   player:tail( dt )
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
        self.y = event.y - event.yStart + self.markY
        --player.cat.y = self.y + self.height * 0.5
      elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
        -- we end the movement by removing the focus from the object
        display.getCurrentStage():setFocus( self, nil )
        self.isFocus = false
      end
   end
 
   -- return true so Corona knows that the touch event was handled propertly
   return true
end   

-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
   --print( _W, _H )

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   ball = Ball( nil, {} )
   player = Player( nil, {} )
   computer = Computer( nil, {} )

   --computer.enemyId = 5

   init()
end
 
local function buttonHandler(event)
   --print( event.target.id )
   --computer.enemyId = tonumber(event.target.id)
   ball.tailId = tonumber(event.target.id)
end  

-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      for i = 1, #ball.tail do
         widget.newButton( {x=_CX, y=i * 70, width= 150, height=50, id=tostring(i), label=tostring(i), shape="rect", onRelease=buttonHandler} )
      end
      
      local length = 20 
      local i = length

      print( length )
      while ( i + length < _H ) do
         local line = display.newLine( _CX, i, _CX, i + length )
         line.strokeWidth = 4
         i = i + length * 2
      end 

      local verticles = { 
         {0, 0}, 
         {_W, 0},
         {_W, _H},
         {0, _H},
         {0, 0},
                        }

      for i=1, #verticles - 1 do
         local line = display.newLine( verticles[i][1], verticles[i][2], verticles[i + 1][1], verticles[i + 1][2] )
         line.strokeWidth = 4
      end  
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

      lastTime = getTimer( )
      Runtime:addEventListener( "enterFrame", loop )
      Runtime:addEventListener( "touch", drag )

      ball.vents:start("ventburn")
      ball.vents:start("eviltail")
      ball.vents:start("fountaintail")
   end
end
 
-- "scene:hide()"
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
 
-- "scene:destroy()"
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