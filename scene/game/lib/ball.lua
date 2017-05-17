--
-- Moduł reprezentujący piłkę 
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 
local composer = require( 'composer' )

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local _W, _H, _CX, _CY
local mRandom, mPi, mSin, mCos, mAbs  

-- Nadaje wartość pomocniczym zmiennym powyżej
app.setLocals()

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
	
	local instance = display.newGroup()
	instance.img = display.newRect( instance, 0, 0, side, side )
	instance.img:setFillColor( unpack( colors.white ) )	
	instance.img.side = side
	instance.img.speed = speed
	instance.img.lastX = bounds.width * 0.5
	instance.img.lastY = bounds.height * 0.5
	instance.img.bounds = bounds

	-- definicja funkcji piłeczki do aktualizacji jej ruchów 
    function instance:update( dt ) 
      local img = self.img
      img.x, img.y = img.x + img.velX * dt, img.y + img.velY * dt

      self:rotate( dt )
      -- wykrywanie kolizji z krawędziami ekranu
      self:collision()
      
      local pdle = img.x < img.bounds.width * 0.5 and scene.player.img or scene.computer.img
      
      -- wykrywanie kolizji między piłeczką i paletkami
      if ( AABBIntersect( pdle, img ) ) then
         app.playSound(scene.sounds.hit)

         img.x = pdle.x + ( img.velX > 0 and -1 or 1 ) * pdle.width * 0.5
        
         local mSign = math.sign        
         local i = pdle == scene.player and -1 or 1
         local x1 = 0.5 * ( pdle.height + img.side )
         local n = ( 1 / ( 2 * x1 ) ) * ( pdle.y - img.y ) + ( x1 / ( 2 * x1 ) )
         local phi = 0.25 * mPi * (2 * n - 1) -- pi/4 = 45
         local smash = mAbs( phi ) > 0.2 * mPi and 1.5 or 1
        
         img.velX = - mSign( img.velX ) * smash  * img.speed * mCos( phi )
         img.velY = smash * mSign( img.velY ) * img.speed * mAbs( mSin( phi ) )
      end
   end 

	-- Wykrywanie kolizji z krawędziami
	function instance:collision()
		local img = self.img
		
		-- górna krawędź
		if ( img.y < 0 ) then 
			img.velY = mAbs( img.velY )
			img.y = 0

			app.post( 'touchEdge', {edge='up', x=img.x, y=0} )
		-- dolna krawędź	
		elseif ( img.y > bounds.height ) then 
			img.velY = -mAbs( img.velY )
			img.y = bounds.height

			app.post( 'touchEdge', {edge='down', x=img.x, y=bounds.height} )
		end

		-- lewa krawędź
		if ( img.x < 0 ) then 
			img.velX = mAbs( img.velX )
			img.x = 0

			app.post( 'touchEdge', {edge='left', x=0, y=img.y} )
		-- prawa krawędź	
		elseif ( img.x > bounds.width ) then 
			img.velX = -mAbs( img.velX )
			img.x = bounds.width
			
			app.post( 'touchEdge', {edge='right', x=bounds.width, y=img.y} )
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

	return instance
end	

return M