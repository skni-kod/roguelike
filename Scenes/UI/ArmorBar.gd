extends Control

export (Color) var color := Color.yellow #definicja koloru many

onready var helmet_over := $HelmetOver 
onready var breastplate_over := $BreastplateOver 
onready var pants_over := $PantsOver 


func _ready(): #funckja wywoływana po zainicjowaniu obiektu
	var player_node := get_tree().get_root().find_node("Player", true, false) #wyszukanie i przypisanie gracza
	player_node.connect("armor_updated", self, "on_Player_armor_updated") #połaczenie sygnałów
	

func on_armor_updated(helmet_durability, breastplate_durability, pants_durability): #funkcja aktualizująca pasek życia
	helmet_over.value = helmet_durability
	helmet_over.tint_progress = color
	
	breastplate_over.value = breastplate_durability
	breastplate_over.tint_progress = color
	
	pants_over.value = pants_durability
	pants_over.tint_progress = color
	
	
	
func on_Player_armor_updated(helmet_durability, breastplate_durability, pants_durability): #funkcja odpowiadająca za połączenie sygnałem między graczem a paskiem życia
	if find_parent("UI"):
		on_armor_updated(helmet_durability, breastplate_durability, pants_durability)
