local Class  = require( "lib.class" )
local app    = require( "lib.app" )
local colors = require( "lib.colors" ) 

local Ball = Class.new( ) 

local _W, _H

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

function Ball:new( group, options )

	local x = options.x or 0
	local y = options.y or 0
	local width = options.width or 20
	local height = options.height or 20
	local speed = options.speed or 12
	
	if group then	
		self.spriteinstance = display.newRect( group, x, y, width, height )
	else	
		self.spriteinstance = display.newRect( x, y, width, height )
	end
	
	self.spriteinstance:setFillColor( unpack( colors.white ) )	
	self.spriteinstance.anchorX = 0 
	self.spriteinstance.anchorY = 0

	self.side = width
	self.speed = speed
end	

function Ball:serve( whichSide, player, computer )
	--print("Ball:serve whichSide", whichSide)
	-- set the x and y position
	local r = mRandom( )

	self.spriteinstance.x = whichSide == 1 and player.spriteinstance.x + player.width or computer.spriteinstance.x - self.side
	self.spriteinstance.y = (_H - self.side) * r 
	-- calculate out-angle, higher/lower on the y-axis =>
	-- steeper angle
	local phi = 0.1 * mPi * (1 - 2 * r) 
	-- set velocity direction and magnitude
	self.velX = whichSide * self.speed * mCos( phi )
	self.velY = self.speed * mSin( phi )
	--print( "NEW velX=",  self.velX, "self.velY=",  self.velY)
end	

function Ball:update( player, computer )
	--print( "x=", self.spriteinstance.x, "y=", self.spriteinstance.y,
		--"velX=", self.velX, "velY=", self.velY )
	-- update position with current velocity
	self.spriteinstance.x = self.spriteinstance.x + self.velX
	self.spriteinstance.y = self.spriteinstance.y + self.velY
	-- check if out of the canvas in the y direction
	if ( 0 > self.spriteinstance.y or self.spriteinstance.y + self.side > _H) then
		-- calculate and add the right offset, i.e. how far
		-- inside of the canvas the ball is
		local offset = self.velY < 0 and 0 - self.spriteinstance.y or _H - (self.spriteinstance.y + self.side)
		self.spriteinstance.y = self.spriteinstance.y + 2 * offset
		-- mirror the y velocity
		self.velY = -1 * self.velY
	end
	-- check againts target paddle to check collision in x
	-- direction
	local pdle = self.velX < 0 and player or computer
	if ( AABBIntersect( pdle.spriteinstance.x, pdle.spriteinstance.y, pdle.width, pdle.height,
			self.spriteinstance.x, self.spriteinstance.y, self.side, self.side ) ) then	
		print( pdle.spriteinstance.x, pdle.spriteinstance.y, pdle.width, pdle.height,
			self.spriteinstance.x, self.spriteinstance.y, self.side, self.side )
		-- set the x position and calculate reflection angle
		self.spriteinstance.x = pdle == player and player.spriteinstance.x + player.width or computer.spriteinstance.x - self.side
		local n = (self.spriteinstance.y + self.side - pdle.spriteinstance.y) / (pdle.height + self.side)
		local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
		-- calculate smash value and update velocity
		local smash = mAbs( phi ) > 0.2 * mPi and 1.5 or 1
		self.velX = smash * (pdle == player and 1 or -1) * self.speed * mCos( phi )
		self.velY = smash * self.speed * mSin( phi )
		print( "Collision n=", n, " phi=", phi, " smash=", smash )
	end
	-- reset the ball when ball outside of the canvas in the
	-- x direction
	if ( 0 > self.spriteinstance.x + self.side or self.spriteinstance.x > _W ) then
		--print( "Ball out of screen" )
		self:serve( pdle == player and 1 or -1, player, computer )
	end
end	

return Ball