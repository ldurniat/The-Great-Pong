-- Słownik z tłumaczeniami

local M = {}

local english = {
	['help'] 		= "You start on the left side of the screen. Drag paddle to start moving it.\n\nCollect points from each match and buy new balls.",
	['ok'] 			= 'OK',
	['chooseBall']  = 'Choose Ball',
	['winMessage']  = 'You WIN. Your Total Points: ',
	['loseMessage'] = 'You lost. Your Total Points: ',
	['sounds'] 		= 'Sounds:',
	['music'] 		= 'Music:',
	['languages']   = 'Select language:', 
	['back'] 		= 'Back',
	['totalPoints'] = "Total Points : ",
	['menu']        = 'Menu',
	['restart']     = 'Restart',
	['gamesPlayed'] = 'Games Played : ',
}

local polski = {
	['help'] 		= 'Rozpoczynasz grę po lewej stronie ekranu. Naciśnij i poruszaj aby kierować paletką.\n\nZbieraj punkt z meczy aby móc kupować nowe piłki.',
	['ok'] 			= 'OK',
	['chooseBall']  = 'Wybór piłki',
	['winMessage']  = 'Wygrałeś. Twój wynik: ',
	['loseMessage'] = 'Przegrałeś. Twój wynik: ',
	['sounds'] 		= 'Dzwięki:',
	['music'] 		= 'Muzyka:',
	['languages']   = 'Wybór języka:', 
	['back'] 		= 'Wróć',
	['totalPoints'] = "Wynik : ",
	['menu']        = 'Menu',
	['restart']     = 'Nowa gra',
	['gamesPlayed'] = 'Liczba meczy : ',
}

M = {
	['en'] = english,
	['pl'] = polski
}

return M