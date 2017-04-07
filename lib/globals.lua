-- Zmienne i funkcję, które mają być dostepne globalnie

local app = require( 'lib.app' )

local getTimer = system.getTimer
local pairs = _G.pairs

_G.listen = function( name, listener ) app.addRtEvents( name, listener ) end
_G.ignore = function( name, listener ) app.removeRtEvents( name, listener ) end
_G.post = function( name, params )
   local params = params or {}
   local event = { name = name }
   for k,v in pairs( params ) do
      event[k] = v
   end
   if( not event.time ) then event.time = getTimer() end
   Runtime:dispatchEvent( event )
end