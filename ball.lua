local Class  = require( 'lib.class' )
local app    = require( 'lib.app' )
local colors = require( 'lib.colors' ) 
local CBE = require( 'CBE.CBE' )
local effects = require( 'lib.effects' )

local Ball = Class.new( ) 

local _W, _H, _CX, _CY

local mRandom 
local mPi
local mSin
local mCos
local mAbs 

app.setLocals()

function Ball:new( group, options )

	local x = options.x or 0
	local y = options.y or 0
	local width = options.width or 20
	local height = options.height or 20
	local speed = options.speed or 20
	local rotationSpeed = options.rotationSpeed or 5
	local screenWidth = options.screenWidth or _W
	local screenHeight = options.screenHeight or _H
	
	if group then	
		self.spriteinstance = display.newRect( group, x, y, width, height )
	else	
		self.spriteinstance = display.newRect( x, y, width, height )
	end
	
	self.spriteinstance:setFillColor( unpack( colors.white ) )	

	self.side = width
	self.speed = speed
	self.rotationSpeed = rotationSpeed
	self.lastX = screenWidth * 0.5
	self.lastY = screenHeight * 0.5
	self.screenHeight = screenHeight
	self.screenWidth = screenWidth
	self.group = group or display.getCurrentStage()
	self.update = options.update or ( function() end )

	local tails = {
		lines = function( self, dt ) 
			local tmp = display.newLine( self.group, self.lastX, self.lastY, self.spriteinstance.x, self.spriteinstance.y )
			--transition.to( tail, {alpha=0, time=1000, xScale=0, yScale=0, onComplete=display.remove} )
			self.lastX = self.spriteinstance.x
			self.lastY = self.spriteinstance.y


			tmp.alpha = 0.8
			tmp:setStrokeColor(0.25,0.25,0.25)
			--tail:toBack()
			self.spriteinstance:toFront()
			tmp.strokeWidth = self.spriteinstance.contentHeight 
			transition.to( tmp, { alpha = 0.05, strokeWidth = 1, time = 1000, onComplete = display.remove })
		end,
		rects = function( self, dt )
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
		end,
		circles = 	function( self, dt )
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
			end,
		rectsRandomColors = function( self, dt )
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
			end,
		circlesRandomColors = function( self, dt )
				for i = 1, 3 do
					local tmp = display.newCircle( self.group,
						                         self.spriteinstance.x + math.random(-2,2), self.spriteinstance.y + math.random(-2,2), 
						                         self.spriteinstance.contentWidth/4)
					tmp.alpha = 0.5
					tmp:setFillColor(math.random(), math.random(), math.random()) 
					--tmp:toBack()
					self.spriteinstance:toFront()
					transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
				end 
			end,
		linesRandomColors = function( self, dt )
				local tmp = display.newLine( self.group, self.lastX, self.lastY, self.spriteinstance.x, self.spriteinstance.y)
		
				--tmp:toFront( )
				self.spriteinstance:toFront()

				self.lastX = self.spriteinstance.x
				self.lastY = self.spriteinstance.y

				tmp.alpha = 0.8
				tmp:setStrokeColor(math.random(), math.random(), math.random()) 
				--tmp:toBack()
				tmp.strokeWidth = self.spriteinstance.contentHeight/2

				transition.to( tmp, { alpha = 0.05, strokeWidth = 1, time = 1000, onComplete = display.remove })
			end,					
	}
		
	self.tail = tails[ options.tail or 'lines' ]
end	

function Ball:checkCollisionWithScreenEdges( offset )
	
	local offset = offset or 0

	if ( self.y < offset ) then 
		self.velY = mAbs( self.velY )
		self.y = offset
	end		
	if ( self.y > self.screenHeight - offset ) then 
		self.velY = -mAbs( self.velY )
		self.y = self.screenHeight - offset
	end
	if ( self.x < offset ) then 
		self.velX = mAbs( self.velX )
		self.x = offset
		post('collisionedgewest', {} )
	end		
	if ( self.x > self.screenWidth - offset ) then 
		self.velX = -mAbs( self.velX )
		self.x = self.screenWidth - offset
		post('collisionedgeeast', {} )
	end
end	

function Ball:serve(  )
	local r = mRandom( )
	-- calculate out-angle, higher/lower on the y-axis =>
	-- steeper angle
	local phi = 0.2 * mPi * (1 - 2 * r) 
	-- set velocity direction and magnitude
	self.velX = self.speed * mCos( phi )
	self.velY = self.speed * mSin( phi )
	
	self.x = self.screenWidth * 0.5
	self.y = self.screenHeight * 0.5
end	

function Ball:rotate( dt )
	self.spriteinstance.rotation = self.spriteinstance.rotation %  360
	self.spriteinstance.rotation = self.spriteinstance.rotation + self.rotationSpeed * dt
end

return Ball