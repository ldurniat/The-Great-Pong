local Class  = require( "lib.class" )
local app    = require( "lib.app" )
local colors = require( "lib.colors" ) 
local CBE = require("CBE.CBE")

local Ball = Class.new( ) 

local _W, _H, _CX, _CY

local mRandom 
local mPi
local mSin
local mCos
local mAbs 

app.setLocals()
   
-- helper function to check intesectiont between two
-- axis aligned bounding boxex (AABB)
local function AABBIntersect(ax, ay, aw, ah, bx, by, bw, bh) 
		return ( ax < bx + bw and ay < by + bh and bx < ax + aw and by < ay + ah )
end

--shaking effect
local function shake()

	local stage = display.getCurrentStage()
	local originalX = stage.x
	local originalY = stage.y
	local moveRightFunction
	local moveLeftFunction
	local rightTrans
	local leftTrans
	local originalTrans
	local shakeTime = 50
	local shakeRange = {min = 1, max = 3}
	local endShake   	
	 
	moveRightFunction = function(event) rightTrans = transition.to(stage, {x = math.random(shakeRange.min,shakeRange.max), y = math.random(shakeRange.min, shakeRange.max), time = shakeTime, onComplete=moveLeftFunction}); end 
	 
	moveLeftFunction = function(event) leftTrans = transition.to(stage, {x = math.random(shakeRange.min,shakeRange.max) * -1, y = math.random(shakeRange.min,shakeRange.max) * -1, time = shakeTime, onComplete=endShake});  end 

	endShake = function(event) originalTrans = transition.to(stage, {x = originalX, y = originalY, time = 0}); end

	moveRightFunction();
end
--end shaking effect

function Ball:new( group, options )

	local x = options.x or 0
	local y = options.y or 0
	local width = options.width or 20
	local height = options.height or 20
	local speed = options.speed or 20
	local rotationSpeed = options.rotationSpeed or 5
	local xEnlarge = options.xEnlarge or 0.01
	local yEnlarge = options.yEnlarge or 0.01
	local widthLimit = options.widthLimit or _W
	local heightLimit = options.heightLimit or _H
	
	if group then	
		self.spriteinstance = display.newRect( group, x, y, width, height )
		--self.spriteinstance = display.newImageRect( group, "images/ball.png", width, height )
	else	
		--self.spriteinstance = display.newImageRect( "images/ball.png", width, height )
		self.spriteinstance = display.newRect( x, y, width, height )
	end
	
	self.spriteinstance:setFillColor( unpack( colors.white ) )	
	--self.spriteinstance.anchorX = 0 
	--self.spriteinstance.anchorY = 0

	self.side = width
	self.speed = speed
	self.rotationSpeed = rotationSpeed
	self.xEnlarge = xEnlarge
	self.yEnlarge = yEnlarge
	self.spriteinstance.lastX = 0
	self.spriteinstance.lastY = 0
	self.tail = {}
	self.tailId = 6
	self.heightLimit = heightLimit
	self.widthLimit = widthLimit
	self.group = group


	self.vents = CBE.newVentGroup({
   {  
      preset = "sparks",
      title = "sparksLeft",
      emitDelay = 0,
      perEmit = 10,
      physics = {
			gravityX = -0.5,
			gravityY = 0,
		},
      color = {colors.lightcyan, colors.lavender, colors.lightsalmon, colors.gold},
      onEmitEnd = function() self.vents:get("sparksLeft"):stop() end,
      build = function() local size = math.random(2, 5); return display.newRect(0, 0, size, size)  end,
   },
   {
      preset = "sparks",
      title = "sparksRight",
      emitDelay = 0,
      perEmit = 10,
      physics = {
			gravityX = 0.5,
			gravityY = 0,
		},
      color = {colors.hotpink, colors.darkblue, colors.floralwhite, colors.gold}, --{{255/255, 255/255, 255/255}},
      onEmitEnd = function() self.vents:get("sparksRight"):stop() end,
      build = function() local size = math.random(2, 5); return display.newRect(0, 0, size, size) end,
   },
   {
   	preset = "burn", 
   	title="ventburn",
   	inTime=200,
   	outTime=200,
   },
   {
   preset = "evil",
   title="eviltail",
	positionType = "inRadius",
	radius = 30,
	innerRadius = 20,
	physics = {
		velocity = 0
		}
	},
	{
		preset = "fountain",
		title="fountaintail",
	perEmit = 1,
	physics = {
		autoCalculateAngles = true,
		angles = {{0, 360}, {360, 0}}, -- Add angles in form of 60-120-60
		cycleAngle = true
	}
	}
   })

	--self.ventTail = CBE.newVent( {} )	

	self.tail[1] = function( self, dt )
		local tail = display.newLine( self.group, self.spriteinstance.lastX, self.spriteinstance.lastY, self.spriteinstance.x, self.spriteinstance.y )
		--transition.to( tail, {alpha=0, time=1000, xScale=0, yScale=0, onComplete=display.remove} )
		self.spriteinstance.lastX = self.spriteinstance.x
		self.spriteinstance.lastY = self.spriteinstance.y


		tail.alpha = 0.8
		tail:setStrokeColor(0.25,0.25,0.25)
		--tail:toBack()
		self.spriteinstance:toFront()
		tail.strokeWidth = self.spriteinstance.contentHeight 
		transition.to( tail, { alpha = 0.05, strokeWidth = 1, time = 1000, onComplete = display.remove })
	end	

	self.tail[2] = function( self, dt )
		for i = 1, 3 do
			local tmp = display.newRect( self.group,
				                         self.spriteinstance.x + math.random(-2,2), self.spriteinstance.y + math.random(-2,2), 
				                         self.spriteinstance.contentWidth/2, self.spriteinstance.contentHeight/2 )
			tmp.alpha = 0.5
			tmp:setFillColor(0.25,0.25,0.25)
			--tmp:toBack()
			self.spriteinstance:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end  
	end

	self.tail[3] = function( self, dt )
		for i = 1, 3 do
			local tmp = display.newCircle( self.group,
				                         self.spriteinstance.x + math.random(-2,2), self.spriteinstance.y + math.random(-2,2), 
				                         self.spriteinstance.contentWidth/2 )
			tmp.alpha = 0.5
			tmp:setFillColor(0.25,0.25,0.25)
			--tmp:toBack()
			self.spriteinstance:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end  
	end

	self.tail[4] = function( self, dt )
		for i = 1, 3 do
			local tmp = display.newRect( self.group,
				                         self.spriteinstance.x + math.random(-2,2), self.spriteinstance.y + math.random(-2,2), 
				                         self.spriteinstance.contentWidth/2, self.spriteinstance.contentHeight/2 )
			tmp.alpha = 0.5
			tmp:setFillColor(math.random(), math.random(), math.random()) 
			--tmp:toBack()
			self.spriteinstance:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end 
	end

	self.tail[5] = function( self, dt )
		for i = 1, 3 do
			local tmp = display.newCircle( self.group,
				                         self.spriteinstance.x + math.random(-2,2), self.spriteinstance.y + math.random(-2,2), 
				                         self.spriteinstance.contentWidth/2)
			tmp.alpha = 0.5
			tmp:setFillColor(math.random(), math.random(), math.random()) 
			--tmp:toBack()
			self.spriteinstance:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end 
	end

	self.tail[6] = function( self, dt )
		--local tmp = display.newLine( self.group, self.spriteinstance.lastX, self.spriteinstance.lastY, self.spriteinstance.x, self.spriteinstance.y)
		local tmp = display.newLine( self.spriteinstance.lastX, self.spriteinstance.lastY, self.spriteinstance.x, self.spriteinstance.y)
		
		--tmp:toFront( )
		self.spriteinstance:toFront()
		

		self.spriteinstance.lastX = self.spriteinstance.x
		self.spriteinstance.lastY = self.spriteinstance.y

		tmp.alpha = 0.8
		tmp:setStrokeColor(math.random(), math.random(), math.random()) 
		--tmp:toBack()
		tmp.strokeWidth = self.spriteinstance.contentHeight/2

		transition.to( tmp, { alpha = 0.05, strokeWidth = 1, time = 1000, onComplete = display.remove })
	end
	--[[
	self.tail[7] = function( self, dt )
		--self.vents:move("ventburn", self.spriteinstance.x, self.spriteinstance.y)
		self.vents:move("eviltail", self.spriteinstance.x, self.spriteinstance.y) 
		--self.vents:move("fountaintail", self.spriteinstance.x, self.spriteinstance.y)
		--self.spriteinstance.isVisible = false
	end

	self.tail[8] = function( self, dt )
		self.vents:move("ventburn", self.spriteinstance.x, self.spriteinstance.y)
		--self.vents:move("eviltail", self.spriteinstance.x, self.spriteinstance.y) 
		--self.vents:move("fountaintail", self.spriteinstance.x, self.spriteinstance.y)
		--self.spriteinstance.isVisible = false
	end

	self.tail[9] = function( self, dt )
		--self.vents:move("ventburn", self.spriteinstance.x, self.spriteinstance.y)
		--self.vents:move("eviltail", self.spriteinstance.x, self.spriteinstance.y) 
		self.vents:move("fountaintail", self.spriteinstance.x, self.spriteinstance.y)
		--self.spriteinstance.isVisible = false
	end
	--]]

end	

function Ball:serve( whichSide, player, computer )
	--print("Ball:serve whichSide", whichSide)
	-- set the x and y position
	local r = mRandom( )

	self.spriteinstance.x = whichSide == 1 and player.spriteinstance.x + ( player.spriteinstance.width + self.side ) * 0.5  or computer.spriteinstance.x - ( computer.spriteinstance.width + self.side ) * 0.5
	self.spriteinstance.y = (self.heightLimit - self.side) * r 
	-- calculate out-angle, higher/lower on the y-axis =>
	-- steeper angle
	local phi = 0.2 * mPi * (1 - 2 * r) 
	-- set velocity direction and magnitude
	self.velX = whichSide * self.speed * mCos( phi )
	self.velY = self.speed * mSin( phi )
	--print( "NEW velX=",  self.velX, "self.velY=",  self.velY)
end	

function Ball:rotate( dt )
	self.spriteinstance.rotation = self.spriteinstance.rotation %  360
	self.spriteinstance.rotation = self.spriteinstance.rotation + self.rotationSpeed * dt
end

function Ball:enlarge( dt )
	--print( "@@@@", self.spriteinstance.xScale, self.xEnlarge )
	if ( ( self.spriteinstance.xScale > 1.5 and self.xEnlarge > 0 ) or ( self.spriteinstance.xScale < 1 and self.xEnlarge < 0 ) ) then
		self.xEnlarge = -1 * self.xEnlarge 
		self.yEnlarge = -1 * self.yEnlarge 
		--print( self.spriteinstance.xScale )
	end
		
	self.spriteinstance.xScale = self.spriteinstance.xScale + self.xEnlarge * dt
	self.spriteinstance.yScale = self.spriteinstance.yScale + self.yEnlarge * dt
end

function Ball:update( player, computer, dt )
	--print( "x=", self.spriteinstance.x, "y=", self.spriteinstance.y,
		--"velX=", self.velX, "velY=", self.velY )
	self:rotate( dt )
	--self:enlarge( dt )
	self.tail[self.tailId]( self, dt )

	-- update position with current velocity
	self.spriteinstance.x = self.spriteinstance.x + self.velX * dt
	self.spriteinstance.y = self.spriteinstance.y + self.velY * dt
	-- check if out of the canvas in the y direction
	if ( self.side * 0.5 > self.spriteinstance.y or self.spriteinstance.y + self.side * 0.5 > self.heightLimit ) then
		-- calculate and add the right offset, i.e. how far
		-- inside of the canvas the ball is
		--local offset = self.velY < 0 and 0 - self.spriteinstance.y or _H - (self.spriteinstance.y + self.side)
		--self.spriteinstance.y = self.spriteinstance.y + 2 * offset
		-- mirror the y velocity
		self.velY = ( self.spriteinstance.y < self.heightLimit * 0.5 and 1 or -1 ) * mAbs( self.velY )
		-- Krawędź znika.Efekt 1
		-- local border = display.newRect( _CX, self.spriteinstance.y < _CY and 0 or _H, _W, 10 )
		-- transition.to( border, {time=1000, alpha=0, onComplete=display.remove} )
		-- Krawędź znika.Efekt 2
		local border = display.newRect( self.spriteinstance.x, self.spriteinstance.y < self.heightLimit * 0.5 and 0 or self.heightLimit, 20, 10 )
		border:setFillColor( colors.white )
		transition.to( border, {time=1000, onComplete=display.remove,} )
		-- Krawędź znika.Efekt 3
		-- local border = display.newCircle( self.spriteinstance.x, self.spriteinstance.y < _CY and 0 or _H, 30)
		-- transition.to( border, {y=self.spriteinstance.y < _CY and -30 or _H + 30, time=1000, alpha=0, yScale=0.01, xScale=0.01, onComplete=display.remove, transition=easing.inSine} )
		--shake()
	end
	-- check againts target paddle to check collision in x
	-- direction
	--local pdle = self.velX < 0 and player or computer
	local pdle = self.spriteinstance.x < self.widthLimit * 0.5 and player or computer
	if pdle then
		print( "asdadas" )
	else
		print( "brak" )	
	end	
	if ( AABBIntersect( pdle.spriteinstance.x - pdle.spriteinstance.width * 0.5, pdle.spriteinstance.y - pdle.spriteinstance.height * 0.5, pdle.width, pdle.height,
			self.spriteinstance.x - self.side * 0.5, self.spriteinstance.y - self.side * 0.5, self.side, self.side ) ) then	
		--print( " Kolizja self.velX=", self.velX, pdle.spriteinstance.x, pdle.spriteinstance.y, self.spriteinstance.x, self.spriteinstance.y )
		-- set the x position and calculate reflection angle
		--self.spriteinstance.x = pdle == player and player.spriteinstance.x + ( player.spriteinstance.width + self.side ) * 0.5  or computer.spriteinstance.x - ( computer.spriteinstance.width + self.side ) * 0.5
		self.spriteinstance.x = pdle.spriteinstance.x + ( self.velX > 0 and -1 or 1 ) * pdle.spriteinstance.width * 0.5
			print( "kolizja" )
		--transition.to( self.spriteinstance, {time=200, onStart=function() self.spriteinstance:setFillColor(0, 0.1, 0.4) end, onComplete=function() self.spriteinstance:setFillColor(1, 1, 1) end} )
		--print( pdle.spriteinstance.x .x )
		local i = pdle == player and -1 or 1
		-- Sprawdzam kierunek predkosci ale znaki sa odwrotnie niz powinny bo wyzej zmieniam znaki po kolizji
		if ( ( pdle == player and self.velX < 0 ) or 
			( pdle == computer and self.velX > 0 ) ) then
			transition.to( pdle.spriteinstance, {time=500, alpha=0.5, x=(pdle.spriteinstance.x + i * 20), transition=easing.outCubic, onComplete=function()
				transition.to( pdle.spriteinstance, {time=500, alpha=1, x=(pdle.spriteinstance.x - i * 20), transition=easing.outCubic } )
			end } )
		end	

		--local n = (self.spriteinstance.y + self.side - pdle.spriteinstance.y) / (pdle.height + self.side)
		--local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
		-- Ustawiam  phi stala wartość aby szybko sprawdzic zmiany
		--local n = ( 1 / ( self.side + pdle.height ) ) * ( pdle.spriteinstance.y - self.spriteinstance.y ) + ( pdle.height / ( self.side + pdle.height ) )
		--local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
		local x1 = 0.5 * ( pdle.spriteinstance.height + self.side )
		local n = ( 1 / ( 2 * x1 ) ) * ( pdle.spriteinstance.y - self.spriteinstance.y ) + ( x1 / ( 2 * x1 ) )
		local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
		--print( "n=" .. n, "phi=" .. phi, "x1=" .. x1, "roznica=" .. ( pdle.spriteinstance.y - self.spriteinstance.y ) )
		-- calculate smash value and update velocity
		local smash = mAbs( phi ) > 0.2 * mPi and 1.5 or 1
		--self.velX = smash * (pdle == player and 1 or -1) * self.speed * mCos( phi )
		self.velX = -1 * mAbs(self.velX) / self.velX * smash  * self.speed * mCos( phi )
		self.velY = smash * self.speed * mAbs( mSin( phi ) ) * self.velY/mAbs( self.velY )
		
		--print( "self.velX=", self.velX )

		if ( pdle == player ) then
			self.vents:move("sparksLeft", pdle.spriteinstance.x + pdle.spriteinstance.width, pdle.spriteinstance.y + pdle.spriteinstance.height * 0.5)
			self.vents:start("sparksLeft")
		else
			self.vents:move("sparksRight", pdle.spriteinstance.x, pdle.spriteinstance.y + pdle.spriteinstance.height * 0.5)
			self.vents:start("sparksRight")
		end	
		--print( "self.velX=", self.velX )
	end
	-- reset the ball when ball outside of the canvas in the
	-- x direction
	if ( self.side * 0.5 > self.spriteinstance.x  or self.spriteinstance.x > self.widthLimit - self.side * 0.5 ) then
		--self:serve( pdle == player and 1 or -1, player, computer )
		self.velX = ( self.spriteinstance.x < self.widthLimit * 0.5 and 1 or -1 ) * mAbs( self.velX )
		-- Krawędź znika. Efekt 1
		-- local border = display.newRect( self.spriteinstance.x < _CX and 0 or _W, _CY,  10, _H)
		-- transition.to( border, {time=1000, alpha=0, onComplete=display.remove} )
		-- Krawędź znika.Efekt 2
		local border = display.newRect( self.spriteinstance.x < self.widthLimit * 0.5 and 0 or self.widthLimit, self.spriteinstance.y, 20, 10)
		border:setFillColor( colors.black )
		transition.to( border, {time=1000, xScale=0.01, onComplete=display.remove, } )
		--shake()
	end
end	

return Ball