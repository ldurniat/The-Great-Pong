local getTimer = system.getTimer
local lastTime = 0

local M = {}

function M.getTime() 
	local dt = 0

	if lastTime == 0 then
		lastTime = getTimer()
	else	
		local curTime = getTimer()
		dt = curTime - lastTime
		dt = dt / ( 1000 / display.fps )
		lastTime = curTime			
	end	

	return dt
end	

function M.restart()
	lastTime = 0
end	

return M