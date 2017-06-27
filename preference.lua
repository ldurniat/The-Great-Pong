--
-- Moduł do zapisu/odczytu danych w formacie json. 
--
-- Wymagane moduły
local loadsave = require( 'lib.loadsave' )
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 

-- Deklaracja modułu
local M = {}

-- Tablica przechowująca wszelkie ustawienia dotyczące gry
-- w tym wynik użytkownika itp.
M.settings = {}

function M:save()
	loadsave.saveTable( self.settings, 'settings.json' )
end	

function M:get( name )
	return self.settings[name]
end	

function M:set( name, value )
	self.settings[name] = value
end	

function M:load()
	local settings = loadsave.loadTable( 'settings.json' )
	
	if ( settings == nil ) then
		-- informacje o dostępnych piłeczkach
		-- muszą odpowiadać miniaturkom na mapie
		local balls = {
			{ name='Simple Ball', points=0 , params={}, buy=true },
			{ name='Fast Ball', points=20 , params={enableSparks=true, enableTrail=false}, buy=false },
			{ name='Furoius Ball', points=40 , params={ballColor=colors.firebrick, trailColor=colors.firebrick, enableSparks=true, enableTrail=true}, buy=false },
		} 
		-- Ustawienia domyślne
		self:set( 'music', true )
		self:set( 'sound', true )
		self:set( 'ballInUse', 1 ) 
		self:set( 'totalPoints', 100 )
		self:set( 'balls', balls )  	
		self:set( 'gamesPlayed', 0 )	

		loadsave.saveTable( self.settings, 'settings.json' )
	else
		self.settings = settings	
	end
end	

return M