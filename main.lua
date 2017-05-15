-- Copyright 2017 Łukasz Durniat
--
-- Plik uruchomieniowy gry
--
local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local preference = require( 'preference' ) 

-- Dodaje nowe funkcje do standardowych modułów 
require( 'lib.utils' ) 

-- Usunięcie paska navigacyjnego z dołu
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
  native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
  native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

-- are we running on a simulator?
local isSimulator = "simulator" == system.getInfo( "environment" )
local isMobile = ("ios" == system.getInfo("platform")) or ("android" == system.getInfo("platform"))

-- if we are load our visual monitor that let's a press of the "F"
-- key show our frame rate and memory usage, "P" to show physics
if isSimulator then 

  -- show FPS
  local visualMonitor = require( "com.ponywolf.visualMonitor" )
  local visMon = visualMonitor:new()
  visMon.isVisible = false

  -- show/hide physics
  local function debugKeys( event )
    local phase = event.phase
    local key = event.keyName
    if phase == "up" then
      if key == "p" then
        physics.show = not physics.show
        if physics.show then 
          physics.setDrawMode( "hybrid" ) 
        else
          physics.setDrawMode( "normal" )  
        end
      elseif key == "f" then
        visMon.isVisible = not visMon.isVisible 
      end
    end
  end
  Runtime:addEventListener( "key", debugKeys )
end

local function onSystemEvent( event )    
    if (event.type == "applicationStart") then

    elseif (event.type == "applicationExit") then 
        -- Zapis ustawień przed zamknięciem aplikacji
        preference:save()
        -- Usunięcie 
        app.disposeSounds()
    elseif ( event.type == "applicationSuspend" ) then
      
    elseif event.type == "applicationResume" then
        
    end
end

Runtime:addEventListener( "system", onSystemEvent )

-- Ładowanie ustawień z pliku settings.json
preference:load()

app.sound = preference:get( 'sound' )
app.music = preference:get( 'music' )
app.loadSounds()

composer.gotoScene( 'scene.menu' )