local Class  = require( "lib.class" )
local colors = require( "lib.colors" ) 

local Player = Class.new( )

function Player:new( group, options )

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
function Player.drag( event )

	local self = event.target
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
		elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
		  -- we end the movement by removing the focus from the object
		  display.getCurrentStage():setFocus( self, nil )
		  self.isFocus = false
		end
 	end
 
	-- return true so Corona knows that the touch event was handled propertly
	return true
end

function Player:addDrag( )
	self.spriteinstance:addEventListener("touch", self.drag)
end	

return Player