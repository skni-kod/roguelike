extends Control

export (Color) var color := Color.darkturquoise #definicja koloru many

onready var health_over := $HealthOver #przypisanie do zmiennej paska życia u góry
onready var health_under := $HealthUnder #przypisanie do zmiennej paska życia na dole
onready var update_tween := $UpdateTween #przypisanie do zmiennej animacji zmiany ilości życia
onready var pulse_tween := $PulseTween #przypisanie do zmiennej pierwszej animacji pulsowania
onready var flash_tween := $FlashTween #przypisanie do zmiennej drugiej animacji pulsowania

func _ready(): #funckja wywoływana po zainicjowaniu obiektu
	var player_node := get_tree().get_root().find_node("Player", true, false) #wyszukanie i przypisanie gracza
	player_node.connect("mana_updated", self, "on_Player_mana_updated") #połaczenie sygnałów

func on_mana_updated(health): #funkcja aktualizująca pasek życia
	health_over.value = health #przypisanie nowej ilości pkt życia
	health_over.tint_progress = color
	update_tween.interpolate_property(health_under, "value", health_under.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT) #ustawienie parametrów animacji
	update_tween.start()#uruchomienie animacji

func on_Player_mana_updated(health): #funkcja odpowiadająca za połączenie sygnałem między graczem a paskiem życia
	if find_parent("UI"):
		on_mana_updated(health)
