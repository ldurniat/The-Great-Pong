--
-- Moduł reprezentujący cząsteczki 
--
-- Wymagane moduły
local CBE    = require( 'CBE.CBE' )
local app    = require( 'lib.app' )

-- Wektory działania grawitacji
local gravity = {
	left  = { -0.5, 0 },
	right = { 0.5, 0 },
	up    = { 0, -0.5 },
	down  = { 0, 0.5 },
}

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local mRandom = math.random

function M.new( options )

	local instance
	local build = function() 
		local size = mRandom( 5, 10 ) 
		return display.newRect( 0, 0, size, size )  
	end
	-- Domyślne opcje
	options = options or {}
	options.present = options.present or 'sparks'
	options.emitDelay = options.emitDelay or 0
	options.perEmit = options.perEmit or 10
	options.color = options.color or { {255 / 255, 255 / 255, 255 / 255} }
	options.onEmitEnd = options.onEmitEnd or function() instance:stop() end
	options.build = options.build or build
	
	instance = CBE.newVent( options )

	function instance:setGravityAt( name )
		self:setGravity( unpack(gravity[name]) )	
	end

	function instance:moveAt( x, y )
		self.emitX, self.emitY = x, y 
	end

	function instance:startAt( name, x, y )
		self:setGravityAt( name )
		self:moveAt( x, y )
		self:start()	
	end

	return instance
end
	
return M