local M = { }

-- Funkcja sprawdza czy dwa prostokąty pokrywają się. 
-- Współrzędne punktów leżą w górnym lewym rogu prostokąta.
function M.AABBIntersect( rect1, rect2 )
	local x1, y1 = rect1.x, rect1.y
	local width1, height1 = rect1.width * rect1.xScale, rect1.height * rect1.yScale
	local anchorX1, anchorY1 = rect1.anchorX, rect1.anchorY

	local x2, y2 = rect2.x, rect2.y
	local width2, height2 = rect2.width * rect2.xScale, rect2.height * rect2.yScale
	local anchorX2, anchorY2 = rect2.anchorX, rect2.anchorY 

	local ax, ay = x1 - width1 * anchorX1, y1 - height1 * anchorY1 
	local aw, ah = width1, height1
	local bx, by = x2 - width2 * anchorX2, y2 - height2 * anchorY2 
	local bw, bh = width2, height2

	return ( ax < bx + bw and ay < by + bh and bx < ax + aw and by < ay + ah )
end	

return M
		