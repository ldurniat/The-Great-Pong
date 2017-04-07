local app     = require( 'lib.app' )
local colors  = require( 'lib.colors' ) 
local effects = require( 'lib.effects' )

local M = {}

local _W, _H, _CX, _CY
local mRandom, mPi, mSin, mCos, mAbs  

app.setLocals()

function M.new( options )
	local options = options or {}
	local side = options.side or 20
	local speed = options.speed or 20
	local rotationSpeed = options.rotationSpeed or 5
	local bounds = { width=options.width or _W, height=options.height or _H }
	
	local instance = display.newGroup()

	instance.img = display.newRect( instance, 0, 0, side, side )
	instance.img:setFillColor( unpack( colors.white ) )	
	instance.img.side = side
	instance.img.speed = speed
	instance.img.lastX = bounds.width * 0.5
	instance.img.lastY = bounds.height * 0.5
	instance.img.bounds = bounds
	instance.update = options.update or function() end 	

	function instance:collision()
		local img = self.img
		
		if ( img.y < 0 ) then 
			img.velY = mAbs( img.velY )
			img.y = 0

			post( 'edgeCollision', {edge='top', x=img.x, y=0}  )	
		elseif ( img.y > bounds.height ) then 
			img.velY = -mAbs( img.velY )
			img.y = bounds.height

			post( 'edgeCollision', {edge='bottom', x=img.x, y=bounds.height}  )
		end

		if ( img.x < 0 ) then 
			img.velX = mAbs( img.velX )
			img.x = 0

			post( 'edgeCollision', {edge='left', x=0, y=img.y} )	
		elseif ( img.x > bounds.width ) then 
			img.velX = -mAbs( img.velX )
			img.x = bounds.width

			post( 'edgeCollision', {edge='right', x=bounds.width, y=img.y}  )
		end
	end	

	function instance:serve()
		local img = self.img
		local r = mRandom()
		-- calculate out-angle, higher/lower on the y-axis =>
		-- steeper angle
		local phi = 0.2 * mPi * ( 1 - 2 * r ) 
		-- set velocity direction and magnitude
		img.velX, img.velY = img.speed * mCos( phi ), img.speed * mSin( phi )
		img.x, img.y = bounds.width * 0.5, bounds.height * 0.5
	end	

	function instance:rotate( dt )
		local img = self.img
		img.rotation = ( img.rotation %  360 ) + rotationSpeed * dt
	end

	return instance
end	

return M