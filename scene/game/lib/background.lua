--
-- Moduł reprezentujący plansze
--
-- Wymagane moduły
local app      = require( 'lib.app' )
local colors   = require( 'lib.colors' ) 

-- Deklaracja modułu
local M = {}

-- Lokalne zmienne
local mFloor = math.floor

function M.new(options)

  -- Domyślne opcje
  options = options or {}
  local lineWidth = options.lineWidth or 4
  local lineLenght = options.lineLenght or 20

  --  Tworzy grupę zawierającą wszystkie wizualne obiekty 
  local group = display.newGroup()

  -- Rysuje krótkie linie na środku ekranu
  --
  -- Wyznaczam położenie pierwszej linii od krawędzi ekranu tak aby 
  -- odległość od obu krawędzi (dolnej i górnej) była równa
  local num = mFloor( _H / lineLenght )
  -- Dla parzytej liczby ciąg linii rozpoczyna się od linii a kończy przerwą
  num = num % 2 == 0 and num - 1 or num
  local startY = mFloor( ( _H - lineLenght * num ) * 0.5 )

  for i=startY, _H,  2 * lineLenght do
     local line = display.newLine( group, _CX, i, _CX, i + lineLenght )
     line.strokeWidth = lineWidth
  end    

  return group
end

return M