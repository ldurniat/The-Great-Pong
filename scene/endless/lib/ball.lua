--
-- Moduł reprezentujący piłkę 
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 
local effects  = require( 'lib.effects' )
local composer = require( 'composer' )

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local _W, _H, _CX, _CY
local mRandom, mPi, mSin, mCos, mAbs  

-- Nadaje wartość pomocniczym zmiennym powyżej
app.setLocals()

function M.new( options )
	local scene = composer.getScene(composer.getSceneName("current"))

	-- Domyślne opcje
	options = options or {}
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

	-- Wykrywanie kolizji z krawędziami
	function instance:collision()
		local img = self.img
		
		-- górna krawędź
		if ( img.y < 0 ) then 
			img.velY = mAbs( img.velY )
			img.y = 0

			scene.sparks:startAt( 'up', img.x, 0 )
		-- dolna krawędź	
		elseif ( img.y > bounds.height ) then 
			img.velY = -mAbs( img.velY )
			img.y = bounds.height

			scene.sparks:startAt( 'down', img.x, bounds.height )
		end

		-- lewa krawędź
		if ( img.x < 0 ) then 
			img.velX = mAbs( img.velX )
			img.x = 0

			scene.sparks:startAt( 'left', 0, img.y )
			-- gracz przegrał?
			if ( scene.lives:damage( 1 ) == 0 ) then
				app.removeAllRuntimeEvents()
				transition.pause( ) 
				effects.shake( {time=500} )
				timer.performWithDelay( 500, function() 
					composer.showOverlay("scene.hiscore", { isModal=true,
				  		effect="fromTop", params={newScore=scene.score:get()} } )
					end )
			end	
		-- prawa krawędź	
		elseif ( img.x > bounds.width ) then 
			img.velX = -mAbs( img.velX )
			img.x = bounds.width

			scene.sparks:startAt( 'right', bounds.width, img.y )
			scene.score:add( 1 )
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
		img.rotation = ( img.rotation % 360 ) + rotationSpeed * dt
	end

	function instance:addTail( dt, name )
		effects.addTail( self, { dt=dt, name=name } )
	end

	return instance
end	

return M