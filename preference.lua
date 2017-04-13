local loadsave = require( 'lib.loadsave')

local M = {}

M.settings = {}

function M:save()
	loadsave.saveTable( self.settings, 'settings.json' )
end	

function M:get( name )
	return self.settings[ name ]
end	

function M:set( name, value )
	self.settings[ name ] = value
end	

function M:load()
	local settings = loadsave.loadTable( 'settings.json' )
	
	if settings == nil then
		self:set( 'highScoreEndlessMode', 0 )
		self:set( 'highScoreMatchMode', 0 )

		loadsave.saveTable( self.settings, 'settings.json' )
	end

	self.settings = settings
end	

return M