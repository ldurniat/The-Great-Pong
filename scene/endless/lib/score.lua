--
-- Moduł do przechowywania wyników (punktów)
--

-- Wymagane moduły
require( 'lib.utils' )

-- Deklaracja modułu
local M = {}

function M.new( options )

	-- Domyślne opcje
	options = options or {}
	local label = options.label or ""
	local x, y = options.x or 0, options.y or 0
	local font = options.font or native.systemFont
	local size = options.size or 70
	local align = options.align or "right"
	local color = options.color or { 1, 1, 1, 1 }
	local width = options.width or 256

	local score
	local num = options.score or 0
	local textOptions = { x = x, y = y, text = label .. " " .. num, width = width, font = font, fontSize = size, align = align }

	score = display.newEmbossedText( textOptions )
	score.num = num

	score:setFillColor( unpack( color ) )

	function score:add( points )
		score.num = score.num + ( points or 0 )
		score.text = label .. " " .. ( score.num or 0 )
	end
  
	function score:get() return score.num or 0 end

	return score
end

return M
