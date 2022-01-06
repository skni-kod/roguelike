extends Label


var stacks = 0 setget displayStacks # w trakcie zmiany tej zmiennej (np. z 0 do 1) zostaje uruchomiona displayStacks z daną zmienną jako argument

func displayStacks(var stack):
	text = roman(stack) # tekst labela to rzymska cyfra odpowiadająca stackowi


func roman(var num):
	var romans = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']
	
	if num <= 10:
		return romans[num-1] # zwracam odpowiadającą cyfrze num cyfrę rzymską
	else:
		return romans[9] # gdy zakres jest większy od 10, to zwracam X



