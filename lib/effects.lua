local M = { }

local shakes = {
	-- Code based on code of Jorge Sanchez from
	-- https://forums.coronalabs.com/topic/15325-shaking-effect/
	sanchez = function( self, time )
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
				x = math.random( shakeRange.min, shakeRange.max ), 
				y = math.random( shakeRange.min, shakeRange.max ), 
				time = shakeTime, 
				onComplete = moveLeftFunction } )
			end 
		 
		moveLeftFunction = function( event ) 
			leftTrans = transition.to( self, {
				x = math.random( shakeRange.min, shakeRange.max ) * -1, 
				y = math.random( shakeRange.min, shakeRange.max ) * -1, 
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
	end,
	danny = function( self, time ) 
		-- Code based on code of Danny from
		-- https://forums.coronalabs.com/topic/17277-create-a-shake-effect-on-a-object/
		-- shaking effect
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
	end,
	roaminggamer = function( self, time )
		-- Code based on code of Roaming Gamer from
		-- http://roaminggamer.com/camera-shake-for-corona-sdk/
		-- shaking effect

		local shakeCount = 0
		local xShake = 8
		local yShake = 4
		local shakePeriod = 2

		local function shake()
		   if(shakeCount % shakePeriod == 0 ) then
		      self.x = self.x0 + math.random( -xShake, xShake )
		      self.y = self.y0 + math.random( -yShake, yShake )
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

		-- Start the shake
		startShake()
		 
		-- Stop it in 1/2 second.
		timer.performWithDelay( time, stopShake )
	end	
}

local tails = {
	lines = function( self, dt ) 
		local img = self.img
		local tmp = display.newLine( self, img.lastX, img.lastY, img.x, img.y )
		img.lastX = img.x
		img.lastY = img.y

		tmp.alpha = 0.8
		tmp:setStrokeColor(0.25,0.25,0.25)
		--tail:toBack()
		img:toFront()
		tmp.strokeWidth = img.contentHeight 
		transition.to( tmp, { alpha = 0.05, strokeWidth = 1, time = 1000, onComplete = display.remove } )
	end,
	rects = function( self, dt )
		local img = self.img

		for i = 1, 3 do
			local tmp = display.newRect( self,
				                         img.x + math.random(-2,2), img.y + math.random(-2,2), 
				                         img.contentWidth * 0.5, img.contentHeight * 0.5 )
			tmp.alpha = 0.5
			tmp:setFillColor(0.25,0.25,0.25)
			--tmp:toBack()
			img:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end
	end,
	circles = 	function( self, dt )
		local img = self.img

		for i = 1, 3 do
			local tmp = display.newCircle( self,
				                         img.x + math.random(-2,2), img.y + math.random(-2,2), 
				                         img.contentWidth * 0.5 )
			tmp.alpha = 0.5
			tmp:setFillColor(0.25,0.25,0.25)
			--tmp:toBack()
			img:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end  
	end,
	rectsRandomColors = function( self, dt )
		local img = self.img

		for i = 1, 3 do
			local tmp = display.newRect( self,
				                         img.x + math.random(-2,2), img.y + math.random(-2,2), 
				                         img.contentWidth * 0.5, img.contentHeight * 0.5 )
			tmp.alpha = 0.5
			tmp:setFillColor(math.random(), math.random(), math.random()) 
			--tmp:toBack()
			img:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end 
	end,
	circlesRandomColors = function( self, dt )
		local img = self.img

		for i = 1, 3 do
			local tmp = display.newCircle( self,
				                         img.x + math.random(-2,2), img.y + math.random(-2,2), 
				                         img.contentWidth * 0.25)
			tmp.alpha = 0.5
			tmp:setFillColor(math.random(), math.random(), math.random()) 
			--tmp:toBack()
			img:toFront()
			transition.to( tmp, { alpha = 0.05, xScale = 0.5, yScale = 0.5, time = 1000, onComplete = display.remove })
		end 
	end,
	linesRandomColors = function( self, dt )
		local img = self.img
		local tmp = display.newLine( self, img.lastX, img.lastY, img.x, img.y)

		--tmp:toFront( )
		img:toFront()

		img.lastX = img.x
		img.lastY = img.y

		tmp.alpha = 0.8
		tmp:setStrokeColor(math.random(), math.random(), math.random()) 
		--tmp:toBack()
		tmp.strokeWidth = img.contentHeight * 0.5

		transition.to( tmp, { alpha = 0.05, strokeWidth = 1, time = 1000, onComplete = display.remove })
	end,					
}

function M.shake(self, options)
	local options = options or {}
	local name = options.name or 'roaminggamer'
	local object = options.object or display.getCurrentStage()
	local time = options.time or 300
	shakes[name]( object, time )
end	

function M.addTail(self, options)
	local options = options or {}
	local name = options.name or 'lines'
	local dt = options.dt or 1
	tails[name]( self, dt )
end

return M