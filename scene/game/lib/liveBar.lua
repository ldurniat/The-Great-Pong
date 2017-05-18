--
-- Moduł reprezentujący pasek z życiami 
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local mMax, mMin = math.max, math.min

function M.new(options)

  -- Domyślne opcje
  options = options or {}
  local image = options.image
  local max = options.max or 2
  local spacing = options.spacing or 20
  local w, h = options.width or 10, options.heigt or 55

  --  Tworzy grupę zawierającą wszystkie wizualne obiekty 
  local group = display.newGroup()
  local lives = {}
  for i = 1, max do 
    lives[ i ] = display.newRect( 0, 0, w, h )  
    lives[ i ].x = (i-1) * ( w + spacing )
    lives[ i ].y = 0
    group:insert( lives[ i ] )
  end  
  group.count = max

  function group:damage(amount)
    group.count = mMin( max, mMax( 0, group.count - ( amount or 1 ) ) )
    for i = 1, max do
      if i <= group.count then 
        lives[i].alpha = 1
      else 
        lives[i].alpha =  0.2
      end
    end
    return group.count
  end

  function group:heal(amount)
    self:damage(-(amount or 1))
  end  

  return group
end

return M