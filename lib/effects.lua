--
-- Moduł z efektami wizualnymi
--
-- Wymagane moduły
local app = require( 'lib.app' )

-- Deklaracja modułu
local M = { }

-- Lokalne zmienne
local mRandom  

-- Nadaje wartość pomocniczym zmiennym powyżej
app.setLocals()

-- Definicja efektu shake
--
-- Code based on code of Jorge Sanchez from
-- https://forums.coronalabs.com/topic/15325-shaking-effect/
local function  sanchez( self, time )

	local originalX = self.x
	local originalY = self.y
	local moveRightFunction
	local moveLeftFunction
	local rightTrans
	local leftTrans
	local originalTrans
	local shakeTime = time or 50
	local shakeRange = { min = 1, max = 3 }
	local endShake   	
	 
	moveRightFunction = function( event ) 
		rightTrans = transition.to( self, {
			x = mRandom( shakeRange.min, shakeRange.max ), 
			y = mRandom( shakeRange.min, shakeRange.max ), 
			time = shakeTime, 
			onComplete = moveLeftFunction } )
		end 
	 
	moveLeftFunction = function( event ) 
		leftTrans = transition.to( self, {
			x = mRandom( shakeRange.min, shakeRange.max ) * -1, 
			y = mRandom( shakeRange.min, shakeRange.max ) * -1, 
			time = shakeTime, 
			onComplete = endShake } )  
		end 

	endShake = function( event ) 
		originalTrans = transition.to( self, {
			x = originalX, 
			y = originalY, 
			time = 0 } ) 
		end

	moveRightFunction( )
end

-- Code based on code of Danny from
-- https://forums.coronalabs.com/topic/17277-create-a-shake-effect-on-a-object/
local function danny( self, time ) 
	
	local function doShake(target, onCompleteDo)
		local firstTran, secondTran, thirdTran
		--Third Transition
		thirdTran = function()
			if ( target.shakeType == "Loop" ) then
				transition.to( target, { transition = inOutExpo, time = time, rotation = 0, onComplete = firstTran } )
			else
				transition.to( target, { transition = inOutExpo, time = time, rotation = 0, onComplete = onCompleteDo } )
			end
		end
			
		--Second Transition
		secondTran = function()
			transition.to( target, { transition = inOutExpo, time = time, alpha = 1, rotation = -5, onComplete = thirdTran } )
		end

		--First Transtion
		firstTran = function( )
			transition.to( target, { transition = inOutExpo, time = time, rotation = 5, onComplete = secondTran } )
		end

		--Do the first transition
		firstTran( )
	end

	doShake( self )
end

-- Code based on code of Roaming Gamer from
-- http://roaminggamer.com/camera-shake-for-corona-sdk/
roaminggamer = function( self, time )
	
	local shakeCount = 0
	local xShake = 8
	local yShake = 4
	local shakePeriod = 2

	local function shake()
	   if(shakeCount % shakePeriod == 0 ) then
	      self.x = self.x0 + mRandom( -xShake, xShake )
	      self.y = self.y0 + mRandom( -yShake, yShake )
	   end
	   shakeCount = shakeCount + 1
	end

	local function startShake()
	   self.x0 = self.x
	   self.y0 = self.y
	   shakeCount = 0
	   Runtime:addEventListener( "enterFrame", shake )
	end

	local function stopShake()
	   Runtime:removeEventListener( "enterFrame", shake )
	   timer.performWithDelay( 50, 
	   function() 
	      self.x = self.x0 
	      self.y = self.y0
	   end )
	end 

	startShake()
	 
	timer.performWithDelay( time, stopShake )
end	

local shakes = {
	sanchez = sanchez,
	danny = danny,
	roaminggamer = roaminggamer
}

-- koniec definicji efektu shake

-- definicja efektu tail
--
local function lines( group, dt ) 

	local img = group.img
	local line = display.newLine( group, img.lastX, img.lastY, img.x, img.y )
	line.alpha = 0.8
	line:setStrokeColor( 0.25, 0.25, 0.25 )
	line.strokeWidth = img.contentHeight 

	img.lastX, img.lastY = img.x, img.y
	img:toFront()

	transition.to( line, { alpha=0.05, strokeWidth=1, time=1000, onComplete=display.remove } )
end

local function rects( group, dt )

	local img = group.img

	for i = 1, 3 do
		local rect = display.newRect( group,
			img.x + mRandom( -2, 2 ), img.y + mRandom( -2, 2 ), 
			img.contentWidth * 0.5, img.contentHeight * 0.5 )
		rect.alpha = 0.5
		rect:setFillColor( 0.25, 0.25, 0.25 )
	
		img:toFront()

		transition.to( rect, { alpha=0.05, xScale=0.5, yScale=0.5, 
			time=1000, onComplete=display.remove } )
	end
end

local function circles( group, dt )

	local img = group.img

	for i = 1, 3 do
		local circle = display.newCircle( group,
			img.x + mRandom( -2, 2 ), img.y + mRandom( -2, 2 ), 
			img.contentWidth * 0.5 )
		circle.alpha = 0.5
		circle:setFillColor( 0.25, 0.25, 0.25 )

		img:toFront()
		transition.to( circle, { alpha=0.05, xScale=0.5, yScale=0.5, 
			time=1000, onComplete=display.remove } )
	end  
end

local function rectsRandomColors( group, dt )

	local img = group.img

	for i = 1, 3 do
		local rect = display.newRect( group,
			img.x + mRandom( -2, 2 ), img.y + mRandom( -2, 2 ), 
			img.contentWidth * 0.5, img.contentHeight * 0.5 )
		rect.alpha = 0.5
		rect:setFillColor( mRandom(), mRandom(), mRandom() ) 

		img:toFront()

		transition.to( rect, { alpha=0.05, xScale=0.5, yScale=0.5, 
			time=1000, onComplete=display.remove } )
	end 
end

local function circlesRandomColors( group, dt )

	local img = group.img

	for i = 1, 3 do
		local circle = display.newCircle( group,
			img.x + mRandom( -2, 2 ), img.y + mRandom( -2, 2 ), 
			img.contentWidth * 0.25 )
		circle.alpha = 0.5
		circle:setFillColor( mRandom(), mRandom(), mRandom() ) 

		img:toFront()

		transition.to( circle, { alpha=0.05, xScale=0.5, yScale=0.5, 
			time=1000, onComplete=display.remove } )
	end 
end

local function linesRandomColors( group, dt )

	local img = group.img
	local line = display.newLine( group, img.lastX, img.lastY, img.x, img.y )
	line.alpha = 0.8
	line:setStrokeColor(mRandom(), mRandom(), mRandom()) 
	line.strokeWidth = img.contentHeight * 0.5

	img:toFront()
	img.lastX, img.lastY = img.x, img.y

	transition.to( line, { alpha=0.05, strokeWidth=1, 
		time=1000, onComplete=display.remove } )
end

local tails = {
	lines = lines,
	rects = rects,
	circles = circles,
	rectsRandomColors = rectsRandomColors,
	circlesRandomColors = circlesRandomColors,
	linesRandomColors = linesRandomColors
}

-- koniec definicji efektu tail

function M.shake( options )

	options = options or {}
	local name = options.name or 'roaminggamer'
	local object = options.object or display.getCurrentStage()
	local onComplete = options.onComplete or function() end
	local time = options.time or 300
	if shakes[name] then 
		shakes[name]( object, time )
		timer.performWithDelay( time, onComplete, 1 )
	end	
end	

function M.addTail( group, options )

	options = options or {}
	local name = options.name or 'lines'
	local dt = options.dt or 1

	if tails[name] then
		tails[name]( group, dt )
	end	
end

return M