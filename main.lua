local composer   = require( 'composer' )
local app        = require( 'lib.app' )
local preference = require( 'preference' ) 

preference:load()

composer.gotoScene( 'scene.menu' )