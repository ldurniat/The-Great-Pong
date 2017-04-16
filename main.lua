-- Copyright 2017 Łukasz Durniat
--
-- Plik uruchomieniowy gry
--
local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local preference = require( 'preference' ) 

-- Ładowanie ustawień z pliku settings.json
preference:load()

composer.gotoScene( 'scene.menu' )