--
-- Moduł reprezentujący piłkę 
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 
local composer = require( 'composer' )
local fx       = require( 'com.ponywolf.ponyfx' )

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

	-- Domyślne opcje
	options = options or {}
	local side = options.side or 20
	local speed = options.speed or 20
	local rotationSpeed = options.rotationSpeed or 5
	local bounds = { width=options.width or _W, height=options.height or _H }
	
	local instance = display.newRect( 0, 0, side, side )
	instance:setFillColor( unpack( colors.white ) )	
	instance.side = side
	instance.speed = speed
	instance.lastX = bounds.width * 0.5
	instance.lastY = bounds.height * 0.5
	instance.bounds = bounds

	local trail = fx.newTrail( instance )
	scene.view:insert( trail )

	-- definicja funkcji piłeczki do aktualizacji jej ruchów 
    function instance:update( dt ) 
      self.x, self.y = self.x + self.velX * dt, self.y + self.velY * dt

      self:rotate( dt )
      -- wykrywanie kolizji z krawędziami ekranu
      self:collision()
      
      local pdle = self.x < self.bounds.width * 0.5 and scene.player or scene.computer
      
      -- wykrywanie kolizji między piłeczką i paletkami
      if ( AABBIntersect( pdle, self ) ) then
         app.playSound(scene.sounds.hit)

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
		-- górna krawędź
		if ( self.y < 0 ) then 
			self.velY = mAbs( self.velY )
			self.y = 0

			app.post( 'touchEdge', {edge='up', x=self.x, y=0} )
		-- dolna krawędź	
		elseif ( self.y > bounds.height ) then 
			self.velY = -mAbs( self.velY )
			self.y = bounds.height

			app.post( 'touchEdge', {edge='down', x=self.x, y=bounds.height} )
		end

		-- lewa krawędź
		if ( self.x < 0 ) then 
			self.velX = mAbs( self.velX )
			self.x = 0

			app.post( 'touchEdge', {edge='left', x=0, y=self.y} )
		-- prawa krawędź	
		elseif ( self.x > bounds.width ) then 
			self.velX = -mAbs( self.velX )
			self.x = bounds.width
			
			app.post( 'touchEdge', {edge='right', x=bounds.width, y=self.y} )
		end
	end	

	function instance:serve()
		-- calculate out-angle, higher/lower on the y-axis =>
		-- steeper angle
		local phi = 0.2 * mPi * ( 1 - 2 * mRandom() ) 
		-- set velocity direction and magnitude
		self.velX, self.velY = self.speed * mCos( phi ), self.speed * mSin( phi )
		self.x, self.y = bounds.width * 0.5, bounds.height * 0.5
	end	

	function instance:rotate( dt )
		self.rotation = ( self.rotation % 360 ) + rotationSpeed * dt
	end

	return instance
end	

return M