extends Control

export (Color) var color := Color.yellow #definicja koloru many


onready var armor_over := $ArmorOver 



func _ready(): #funckja wywoływana po zainicjowaniu obiektu
	var player_node := get_tree().get_root().find_node("Player", true, false) #wyszukanie i przypisanie gracza
	player_node.connect("armor_updated", self, "on_Player_armor_updated") #połaczenie sygnałów
	

func on_armor_updated(armor_durability): #funkcja aktualizująca pasek życia
	armor_over.value = armor_durability
	armor_over.tint_progress = color
	
	
func on_Player_armor_updated(armor_durability): #funkcja odpowiadająca za połączenie sygnałem między graczem a paskiem życia
	if find_parent("UI"):
		on_armor_updated(armor_durability)
