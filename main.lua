local composer = require( 'composer' )
local app      = require( 'lib.app' )
local settings = require( 'settings' ) 
local loadsave = require( 'lib.loadsave')

local myData = {}

myData.settings = loadsave.loadTable( 'settings.json' )
 
if myData.settings then
	myData.settings = {}
	loadsave.saveTable( myData.settings, 'settings.json' )
end

composer.gotoScene( 'scene.menu' )