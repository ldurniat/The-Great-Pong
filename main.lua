-- Copyright 2017 Łukasz Durniat
--
-- Plik uruchomieniowy gry
--
local composer     = require( 'composer' )
local app          = require( 'lib.app' )
local preference   = require( 'preference' ) 
local translations = require( 'translations' )

-- Dodaje nowe funkcje do standardowych modułów 
require( 'lib.utils' ) 

-- Dodanie zmiennych globalnych
_W  = display.contentWidth
_H  = display.contentHeight
_T  = display.screenOriginY
_B  = display.viewableContentHeight - display.screenOriginY
_L  = display.screenOriginX
_R  = display.viewableContentWidth - display.screenOriginX
_CX = display.contentCenterX
_CY = display.contentCenterY

-- Usunięcie paska navigacyjnego z dołu
if system.getInfo( 'androidApiLevel' ) and system.getInfo( 'androidApiLevel' ) < 19 then
 	native.setProperty( 'androidSystemUiVisibility', 'lowProfile' )
else
 	native.setProperty( 'androidSystemUiVisibility', 'immersiveSticky' ) 
end

-- czy uruchomiony w simulatorze ?
local isSimulator = app.isSimulator
local isMobile = app.isAndroid or app.isiOS

-- jezeli widoczny to przycisk 'F' wyświetla fps oraz zuzycie pamięci
-- przycisk 'P' wyświetla fizykę w trybie debug 
if isSimulator then 
	-- show FPS
	local visualMonitor = require( 'com.ponywolf.visualMonitor' )
	local visMon = visualMonitor:new()
	visMon.isVisible = false

	-- wyświetl/ukryj fizykę
	local function debugKeys( event )
		local phase = event.phase
		local key = event.keyName
		if phase == 'up' then
			if ( key == 'p' ) then
				physics.show = not physics.show
				if physics.show then 
				 	physics.setDrawMode( 'hybrid' ) 
				else
				 	physics.setDrawMode( 'normal' )  
				end
			elseif ( key == 'f' ) then
				visMon.isVisible = not visMon.isVisible 
			end
		end
	end
	Runtime:addEventListener( 'key', debugKeys )
end

local function onSystemEvent( event )    
	if (event.type == 'applicationStart') then

	elseif (event.type == 'applicationExit') then 
		-- Zapis ustawień przed zamknięciem aplikacji
		preference:save()
		-- Usunięcie 
		app.disposeSounds()
	elseif ( event.type == 'applicationSuspend' ) then
	  
	elseif event.type == 'applicationResume' then
		
	end
end

-- Obsługa przycisku BACK
local function onKeyEvent( event )
   local phase = event.phase
   local keyName = event.keyName
 
	if ( 'back' == keyName and phase == 'up' ) then
		local lastScene = composer.returnTo
		if lastScene then
			composer.gotoScene( lastScene, { effect='crossFade', time=500 } )
		else
			native.requestExit()
		end
		return true
   	end
 	return false  
end

-- Ładowanie ustawień z pliku settings.json
preference:load()

-- ustawienie języka
if not preference:get( 'language' ) then
	-- detekcja systemowego języka
	local languageCode = system.getPreference( 'locale', 'language' ):lower()
	if not translations[languageCode] then
		-- domyślny język
		languageCode = 'en' 
	end	
	-- ustawia język dla aplikacji
	preference:set( 'language', languageCode )
end	

app.sound = preference:get( 'sound' )
app.music = preference:get( 'music' )
app.loadSounds()

app.font = 'scene/menu/font/zektonfree.ttf'

Runtime:addEventListener( 'key', onKeyEvent )   
Runtime:addEventListener( 'system', onSystemEvent )

composer.gotoScene( 'scene.menu' )