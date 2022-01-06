extends Control

export (Color) var color := Color.darkturquoise #definicja koloru many

onready var health_over := $HealthOver #przypisanie do zmiennej paska życia u góry

func _ready(): #funckja wywoływana po zainicjowaniu obiektu
	var player_node := get_tree().get_root().find_node("Player", true, false) #wyszukanie i przypisanie gracza
	player_node.connect("mana_updated", self, "on_Player_mana_updated") #połaczenie sygnałów

func on_mana_updated(health): #funkcja aktualizująca pasek życia
	health_over.value = health #przypisanie nowej ilości pkt życia
	health_over.tint_progress = color
	
func on_Player_mana_updated(health): #funkcja odpowiadająca za połączenie sygnałem między graczem a paskiem życia
	if find_parent("UI"):
		on_mana_updated(health)
