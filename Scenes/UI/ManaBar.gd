extends Control

export (Color) var color := Color.darkturquoise #definicja koloru many

onready var manaOver := $HealthOver #przypisanie do zmiennej paska życia u góry

func _ready(): #funckja wywoływana po zainicjowaniu obiektu
	var player_node := get_tree().get_root().find_node("Player", true, false) #wyszukanie i przypisanie gracza
	var _c = player_node.connect("mana_updated", self, "on_Player_mana_updated") #połaczenie sygnałów

func on_mana_updated(mana): #funkcja aktualizująca pasek życia
	manaOver.value = mana #przypisanie nowej ilości pkt życia
	manaOver.tint_progress = color
	
func on_Player_mana_updated(mana): #funkcja odpowiadająca za połączenie sygnałem między graczem a paskiem życia
	if find_parent("UI"):
		on_mana_updated(mana)
