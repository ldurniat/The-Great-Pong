local Class  = require( "lib.class" )
local colors = require( "lib.colors" ) 

local Player = Class.new( )

function Player:new( group, options )

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
	
	--self.spriteinstance.alpha = 0
	--self.cat:scale( -1, 1 )
	--self.cat.alpha = 0.7

	self.spriteinstance:setFillColor( unpack( colors.white ) )	
	--self.spriteinstance.anchorX = 0 
	--self.spriteinstance.anchorY = 0

	self.width = width
	self.height = height
	self.spriteinstance.lastX = 0
	self.spriteinstance.lastY = 0
end	


function Player:tail( dt )
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

return Player