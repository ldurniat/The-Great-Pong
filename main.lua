-- Copyright 2017 Łukasz Durniat
--
-- Plik uruchomieniowy gry
--
local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local preference = require( 'preference' ) 

-- Dodaje nowe funkcje do standardowych modułów 
require( 'lib.utils' ) 

-- Ładowanie ustawień z pliku settings.json
preference:load()

composer.gotoScene( 'scene.menu' )