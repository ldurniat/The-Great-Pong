-- Słownik z tłumaczeniami

local M = {}

local english = {
	['help'] 		= "You start on the left side of the screen. Drag paddle to start moving it.\n\nCollect points from each match and buy new balls.",
	['ok'] 			= 'OK',
	['chooseBall']  = 'Choose Ball',
	['winMessage']  = 'You WIN!',
	['loseMessage'] = 'You lose!',
	['sounds'] 		= 'Sounds :',
	['music'] 		= 'Music :',
	['languages']   = 'Select language :', 
	['back'] 		= 'Back',
	['totalPoints'] = "TOTAL POINTS : ",
	['menu']        = 'Menu',
	['restart']     = 'Restart',
	['gamesPlayed'] = 'GAMES PLAYED : ',
	['pointsText']  = 'Your Total Points : ',
}

local polski = {
	['help'] 		= 'Rozpoczynasz grę po lewej stronie ekranu. Naciśnij i poruszaj aby kierować paletką.\n\nZbieraj punkt z meczy aby móc kupować nowe piłki.',
	['ok'] 			= 'OK',
	['chooseBall']  = 'Wybór piłki',
	['winMessage']  = 'Wygrałeś! ',
	['loseMessage'] = 'Przegrałeś! ',
	['sounds'] 		= 'Dzwięki :',
	['music'] 		= 'Muzyka :',
	['languages']   = 'Wybór języka :', 
	['back'] 		= 'Wróć',
	['totalPoints'] = "WYNIK : ",
	['menu']        = 'Menu',
	['restart']     = 'Nowa gra',
	['gamesPlayed'] = 'LICZBA MECZY : ',
	['pointsText']  = 'Twój wynik : ',
}

M = {
	['en'] = english,
	['pl'] = polski
}

return M