local Class  = require( "lib.class" )
local colors = require( "lib.colors" )
local app    = require( "lib.app" )  

local Computer = Class.new( )

local _H

local mMin
local mMax

app.setLocals()

function Computer:new( group, options )

	local x = options.x or 0
	local y = options.y or 0
	local width = options.width or 20
	local height = options.height or 100
	
	if group then	
		self.spriteinstance = display.newRect( group, x, y, width, height )
	else	
		self.spriteinstance = display.newRect( x, y, width, height )
	end
	
	self.spriteinstance:setFillColor( unpack( colors.white ) )	
	self.spriteinstance.anchorX = 0 
	self.spriteinstance.anchorY = 0

	self.width = width
	self.height = height
end	

-- touch listener function
function Computer:update( ball )

	-- calculate ideal position
	local desty = ball.spriteinstance.y - (self.height - ball.side) * 0.5	
	-- ease the movement towards the ideal position
	self.spriteinstance.y = self.spriteinstance.y + (desty - self.spriteinstance.y) * 0.1
	-- keep the paddle inside of the canvas
	self.spriteinstance.y = mMax( mMin( self.spriteinstance.y, _H - self.height ), 0 )
end

return Computer