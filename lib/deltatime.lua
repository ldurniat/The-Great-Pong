local M = { }

local getTimer = system.getTimer
local lastTime = 0

M.deltatime = 0 

function M.setDeltaTime( )
   local curTime = getTimer()

   local dt = curTime - lastTime
   dt = dt / ( 1000 / display.fps)

   lastTime = curTime

  M.deltatime = dt
end

function M.getDeltaTime( )
	return M.deltatime
end	

return M