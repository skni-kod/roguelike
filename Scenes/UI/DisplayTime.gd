extends Label

# zmienne początkowe - placeholdery dla typów zmiennych
var time = 0 
var timer_on = false

func _process(delta):
	var timer = "%d" % [$Lifetime.time_left] # timer to string o formacie inta sekund pozostałego "czasu życia" efektu
	text = timer # wpisuję timer do labela
