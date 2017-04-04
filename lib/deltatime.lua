local getTimer = system.getTimer
local lastTime = 0

local M = {}

function M.getDeltaTime()
	local dt = 0

	if lastTime == 0 then
		lastTime = getTimer()
	else	
		local curTime = getTimer()
		dt = curTime - lastTime
		dt = dt / ( 1000 / display.fps)
		lastTime = curTime			
	end	

	return dt
end	

return M