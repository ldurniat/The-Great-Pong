local Class  = require( "lib.class" )
local colors = require( "lib.colors" )
local app    = require( "lib.app" ) 

require( "lib.utils" ) 


local Computer = Class.new( )

local _H
local _W

local mMin
local mMax
local mExp
local mClamp = math.clamp

app.setLocals()

local randomOffset

function Computer:new( group, options )

	local x = options.x or 0
	local y = options.y or 0
	local width = options.width or 20
	local height = options.height or 100
	
	if group then	
		--self.cat = display.newImage( group, "images/cathand.png", x, y )
		self.spriteinstance = display.newRect( group, x, y, width, height )
	else
		--self.cat = display.newImage( "images/cathand.png", x, y )	
		self.spriteinstance = display.newRect( x, y, width, height )
	end
	
	--self.cat.alpha = 0.7
	--self.cat.anchorX, self.cat.anchorY = 0, 0

	self.spriteinstance:setFillColor( unpack( colors.white ) )	
	--self.spriteinstance.anchorX = 0 
	--self.spriteinstance.anchorY = 0
	--self.spriteinstance.alpha = 0

	self.width = width
	self.height = height
	self.enemyId = 1
	self.randomOffset = 0
	self.spriteinstance.lastX = 0
	self.spriteinstance.lastY = 0
end	

function Computer:tail( dt )
	local tail = display.newLine( self.spriteinstance.lastX, self.spriteinstance.lastY, self.spriteinstance.x, self.spriteinstance.y )
	--transition.to( tail, {alpha=0, time=1000, xScale=0, yScale=0, onComplete=display.remove} )
	self.spriteinstance.lastX = self.spriteinstance.x
	self.spriteinstance.lastY = self.spriteinstance.y


	tail.alpha = 0.8
	tail:setStrokeColor(0.25,0.25,0.25)
	tail:toBack()
	tail.strokeWidth = self.spriteinstance.contentWidth
	transition.to( tail, { alpha = 0.05, strokeWidth = 1, time = 500, onComplete = display.remove })
end	

-- touch listener function
function Computer:update( ball, dt )

	self:tail( dt )

	if self.enemyId == 1 then
		if ( ball.spriteinstance.x > 400 and ball.velX > 0 ) then
			-- calculate ideal position
			local desty = ball.spriteinstance.y - ( self.height - ball.side ) * 0.5	
			-- ease the movement towards the ideal position
			local delta = ( desty - self.spriteinstance.y ) * 0.1
			delta = mMin( delta, 170 ) * dt
			--print( dt )
			self.spriteinstance.y = self.spriteinstance.y + delta 
		end	
	elseif self.enemyId == 2 then
		if ( ball.spriteinstance.x > 200 and ball.velX > 0 ) then
			--print("Before", self.spriteinstance.y, "Roznica", ball.spriteinstance.y, self.spriteinstance.y, ( ball.spriteinstance.y - self.spriteinstance.y ) * mMax( 1, mExp( ball.spriteinstance.x / _W ) ))
			self.spriteinstance.y = self.spriteinstance.y + ( ball.spriteinstance.y - self.spriteinstance.y ) * dt * mMin( 1.5, mExp( ball.spriteinstance.x / _W ) )
			--print("", self.spriteinstance.y,  "exp", mMax( 1, mExp( ball.spriteinstance.x / _W ) ) )
		end
	elseif self.enemyId == 3 then
		-- calculate ideal position
		local desty = ball.spriteinstance.y - ( self.height - ball.side ) * 0.5	
		-- ease the movement towards the ideal position
		self.spriteinstance.y = self.spriteinstance.y + mClamp( ( desty - self.spriteinstance.y ) * 0.1, -5, 5 )
	elseif self.enemyId == 4 then
		self.spriteinstance.y = ball.spriteinstance.y * 0.9	
	elseif self.enemyId == 5 then
		if ( ball.velX > 0 ) then
			self.spriteinstance.y = ball.spriteinstance.y * 0.9	
		end		
	end	

	-- keep the paddle inside of the canvas
	self.spriteinstance.y = mMax( mMin( self.spriteinstance.y, _H - self.height ), 0 )
	--self.cat.y = self.spriteinstance.y
end

return Computer