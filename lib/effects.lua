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

print( "shakes=", type( shakes['roaminggamer'] ) )

function M.shake(self, options)
	local name = options.name or 'roaminggamer'
	local object = options.object or display.getCurrentStage()
	local time = options.time or 300
	shakes[name]( object, time )
end	

return M