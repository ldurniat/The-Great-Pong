--
-- Moduł reprezentujący paletkę 
--
-- Wymagane moduły
local colors   = require( 'lib.colors' )
local app      = require( 'lib.app' ) 
local composer = require( 'composer' )

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local mMin, mMax = math.min, math.max

function M.new( options )
	local scene = composer.getScene( composer.getSceneName('current') )
	
	-- Domyślne opcje
	options = options or {}
	local width = options.width or 20
	local height = options.height or 100
	
	local instance = display.newRect( 0, 0, width, height )
	instance:setFillColor( unpack( colors.white ) )	
	instance.lastX = 0
	instance.lastY = 0	
	
	function instance:update( dt )
		-- Logika komputerowego przeciwnika
		if ( scene.squareBall.x > 400 and scene.squareBall.velX > 0 ) then
			-- calculate ideal position
			local desty = scene.squareBall.y 
			-- ease the movement towards the ideal position
			local delta = ( desty - self.y ) * 0.1
			delta = mMin( delta, 50 ) * dt
			if ( self.y + delta > self.height * self.yScale * self.anchorY and 
            self.y + delta < _H - self.height * ( 1 - self.anchorY ) * self.yScale ) then
            	self.y = self.y + delta 
			end	
		end	
		-- Utrzymuje obiekt w obrębie ekranu
		self.y = mMax( mMin( self.y, _H - height ), 0 )
	end

	return instance
end

return M	