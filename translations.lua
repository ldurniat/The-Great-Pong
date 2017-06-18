-- Słownik z tłumaczeniami

local M = {}

local english = {
	['help'] 		= 'You are on the left side. Drag paddle to start moving.',
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
	['help'] 		= 'Znajdujesz się po lewej stronie. Naciśnij i poruszaj aby kierować.',
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