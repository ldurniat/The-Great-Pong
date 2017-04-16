--
-- Moduł reprezentujący paletkę 
--
-- Wymagane moduły
local colors = require( 'lib.colors' )
local app    = require( 'lib.app' ) 

require( 'lib.utils' ) 

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local _H, _W 
local mClamp, mMin, mMax, mExp = math.clamp

-- Nadaje wartość pomocniczym zmiennym powyżej
app.setLocals()

function M.new( options )
	local options = options or {}
	local width = options.width or 20
	local height = options.height or 100
	
	local instance = display.newGroup()
	instance.img = display.newRect( instance, 0, 0, width, height )
	instance.img:setFillColor( unpack( colors.white ) )	
	instance.img.width = width
	instance.img.height = height
	instance.img.enemyId = 1
	instance.img.lastX = 0
	instance.img.lastY = 0	
	
	function instance:update( ball, dt )
		local imgb = ball.img
		local imgc = self.img

		-- Logika komputerowego przeciwnika
		if imgc.enemyId == 1 then
			if ( imgb.x > 400 and imgb.velX > 0 ) then
				-- calculate ideal position
				local desty = imgb.y -- - ( height - imgb.side ) * 0.5	
				-- ease the movement towards the ideal position
				local delta = ( desty - imgc.y ) * 0.1
				--print( 'delta=', delta )
				delta = mMin( delta, 50 ) * dt
				if ( imgc.y + delta > imgc.height * imgc.yScale * imgc.anchorY and 
	            imgc.y + delta < _H - imgc.height * ( 1 - imgc.anchorY ) * imgc.yScale ) then
	            	imgc.y = imgc.y + delta 
				end	
			end	
		elseif imgc.enemyId == 2 then
			if ( imgb.x > 200 and imgb.velX > 0 ) then
				imgc.y = imgc.y + ( imgb.y - imgc.y ) * dt * mMin( 1.5, mExp( imgb.x / _W ) )
			end
		elseif imgc.enemyId == 3 then
			-- calculate ideal position
			local desty = imgb.y - ( height - imgb.side ) * 0.5	
			-- ease the movement towards the ideal position
			imgc.y = imgc.y + mClamp( ( desty - imgc.y ) * 0.1, -5, 5 )
		elseif imgc.enemyId == 4 then
			imgc.y = imgb.y * 0.9	
		elseif imgc.enemyId == 5 then
			if ( imgb.velX > 0 ) then
				imgc.y = imgb.y * 0.9	
			end		
		end	

		-- Utrzymuje obiekt w obrębie ekranu
		imgc.y = mMax( mMin( imgc.y, _H - height ), 0 )
	end

	return instance
end

return M	