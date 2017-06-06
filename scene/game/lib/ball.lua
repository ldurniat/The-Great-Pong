--
-- Moduł reprezentujący piłkę 
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 
local composer = require( 'composer' )
local fx       = require( 'com.ponywolf.ponyfx' )
local sparks   = require( 'lib.sparks' )

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local mRandom = math.random
local mPi     = math.pi
local mSin    = math.sin
local mCos    = math.cos
local mAbs    = math.abs 

-- Funkcja sprawdza czy dwa prostokąty nachodzą na siebie. 
local function AABBIntersect( rectA, rectB )
   local boundsRectA = rectA.contentBounds
   local boundsRectB = rectB.contentBounds

   -- to są liczby całkowite
   rectA.left   = boundsRectA.xMin
   rectA.right  = boundsRectA.xMax
   rectA.top    = boundsRectA.yMin
   rectA.bottom = boundsRectA.yMax

   -- to są liczby całkowite
   rectB.left   = boundsRectB.xMin
   rectB.right  = boundsRectB.xMax
   rectB.top    = boundsRectB.yMin
   rectB.bottom = boundsRectB.yMax

   return ( rectA.left < rectB.right and rectA.right > rectB.left and
     rectA.top < rectB.bottom and rectA.bottom > rectB.top )
end

function M.new( options )
	local scene = composer.getScene( composer.getSceneName('current') )
	local sceneGroup = scene.view
	local spark, trail

	-- Domyślne opcje
	options = options or {}
	local side = options.side or 20
	local speed = options.speed or 20
	local rotationSpeed = options.rotationSpeed or 5
	local enableSparks = options.enableSparks or false
	local enableTrail = options.enableTrail or false
	local trailColor = options.trailColor or colors.white
	local trailImage = options.trailImage
	local ballColor = options.ballColor or colors.white
	
	local instance = display.newRect( 0, 0, side, side )
	instance:setFillColor( unpack( ballColor ) )	
	instance.side = side
	instance.speed = speed
	instance.lastX = _W * 0.5
	instance.lastY = _H * 0.5

	if enableSparks then
		-- dodaje efekt cząsteczkowy
   		spark = sparks.new()
   		sceneGroup:insert( spark )
   	end	

   	if enableTrail then
		-- dodaje efekt śladu
   		trail = fx.newTrail( instance, {image=trailImage, color=trailColor} )
		sceneGroup:insert( trail )
   	end

	-- aktualizacja ruchów 
    function instance:update( dt ) 
		self.x = self.x + self.velX * dt 
		self.y = self.y + self.velY * dt

		self:rotate( dt )
		-- wykrywanie kolizji z krawędziami ekranu
		self:collision()

		local pdle = self.x < _W * 0.5 and scene.player or scene.computer

		-- wykrywanie kolizji między piłeczką i paletkami
		if ( AABBIntersect( pdle, self ) ) then
			app.playSound(scene.sounds.hit)
			transition.chain( pdle, {time=150, alpha=0.9, transition=easing.inCubic},
				{time=150, alpha=1})

			self.x = pdle.x + ( self.velX > 0 and -1 or 1 ) * pdle.width * 0.5

			local mSign = math.sign        
			local i = pdle == scene.player and -1 or 1
			local x1 = 0.5 * ( pdle.height + self.side )
			local n = ( 1 / ( 2 * x1 ) ) * ( pdle.y - self.y ) + ( x1 / ( 2 * x1 ) )
			local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
			local smash = mAbs( phi ) > 0.2 * mPi and 1.5 or 1

			self.velX = - mSign( self.velX ) * smash  * self.speed * mCos( phi )
			self.velY = smash * mSign( self.velY ) * self.speed * mAbs( mSin( phi ) )
		end
   end 

	-- Wykrywanie kolizji z krawędziami
	function instance:collision()
		local edge, x, y	
		-- górna krawędź
		if ( self.y < 0 ) then 
			self.velY = mAbs( self.velY )
			self.y = 0
			x = self.x
			y = 0
			edge = 'up'
		-- dolna krawędź	
		elseif ( self.y > _H ) then 
			self.velY = -mAbs( self.velY )
			self.y = _H
			x = self.x
			y = _H
			edge = 'down'
		end
		-- lewa krawędź
		if ( self.x < 0 ) then 
			self.velX = mAbs( self.velX )
			self.x = 0
			x = 0
			y = self.y
			edge = 'left'
		-- prawa krawędź	
		elseif ( self.x > _W ) then 
			self.velX = -mAbs( self.velX )
			self.x = _W
			x = _W
			y = self.y
			edge = 'right'
		end

		if edge then
			-- wyświeltenie brzegów pola gry
			local coords = {
				{0, _H * 0.5, 2, _H},
				{_W, _H * 0.5, 2, _H},
				{_W * 0.5, 0, _W, 2},
				{_W * 0.5, _H, _W, 2 }
			}
			for i=1, 4 do
				local rect = display.newRect( unpack( coords[i] ) )
				transition.to( rect, {time=500, alpha=0, onComplete=display.remove})
			end	
			app.post( 'touchEdge', {edge=edge, x=x, y=y} )
			if enableSparks then
				spark:startAt( edge, x, y )
			end	
		end	
	end	

	function instance:serve()
		local phi = 0.2 * mPi * ( 1 - 2 * mRandom() ) 
		self.velX, self.velY = self.speed * mCos( phi ), self.speed * mSin( phi )
		self.x, self.y = _W * 0.5, _H * 0.5
	end	

	function instance:rotate( dt )
		self.rotation = ( self.rotation % 360 ) + rotationSpeed * dt
	end

	function instance:finalize()
		if spark then
	    	spark:destroy()
   			spark = nil
   		end
   		if trail then
	    	display.remove( trail )
   			trail = nil
   		end	  
  	end

  	instance:addEventListener( 'finalize' )
	return instance
end	

return M