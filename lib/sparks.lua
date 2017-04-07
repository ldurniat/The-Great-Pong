local CBE    = require( 'CBE.CBE' )
local colors = require( 'lib.colors' ) 

sparks = {}

local M = {}

function M.new( name, options )
	local options = options or {}
	local name    = name or 'default'
	local default = {
		preset    = 'sparks',
		emitDelay = 0,
		perEmit   = 10,
		physics   = {
			gravityX = 0.5,
			gravityY = 0,
		},
		color     = {{255/255, 255/255, 255/255}}, --{ colors.lightcyan, colors.lavender, colors.lightsalmon, colors.gold },
		onEmitEnd = function() sparks[ name ]:stop() end,
		build     = function() local size = math.random(5, 10); return display.newRect(0, 0, size, size)  end,
	}

	for key, value in pairs( default ) do
		options[ key ] = options[ key ] or value
	end	

	local vent = CBE.newVent( options )
	sparks[ name ] = vent

	return vent
end

function M.remove( name )
	if sparks[ name ] then
		sparks[ name ]:destroy()
		sparks[ name ] = nil
		return true
	else	
		return false
	end	
end	

function M.removeAll()
	for key, value in pairs( sparks ) do
		sparks[ key ].remove()
	end
end

function M.start( name , x, y )
	local spark = sparks[ name ]
	if spark then
		if x and y then
			spark.emitX, spark.emitY = x, y
		end	
		spark:start()

		return true
	else	
		return false
	end	
end
		
return M