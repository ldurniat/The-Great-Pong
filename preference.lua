--
-- Moduł do zapisu/odczytu danych w formacie json. 
--
-- Wymagane moduły
local loadsave = require( 'lib.loadsave' )

-- Deklaracja modułu
local M = {}

-- Tablica przechowująca wszelkie ustawienia dotyczące gry
-- w tym wynik użytkownika itp.
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
	
	if ( settings == nil ) then
		-- Ustawienia domyślne
		self:set( 'highScoreEndlessMode', 0 )
		self:set( 'highScoreMatchMode', 0 )

		loadsave.saveTable( self.settings, 'settings.json' )
	end

	self.settings = settings
end	

return M