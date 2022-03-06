extends Camera2D

#DO NAPRAWY

var grid_size = Vector2(512,288) #rozmiar kawałka siatki kamery
var grid_position = Vector2()

onready var parent = get_parent() #Odwołanie do playera

func _ready():
	zoom.x = 1 #ustawienia zoom'a kamery
	zoom.y = 1
	set_as_toplevel(true)
	update_grid_position()
	
func update_grid_position(): #sprawdzanie czy player wyszedł poza granice siatki, jeżeli tak to przełącza kamerę w nową pozycję
	var x = round(parent.position.x / grid_size.x) 
	var y = round(parent.position.y / grid_size.y)
	var new_grid_position = Vector2(x,y)
	if grid_position == new_grid_position:
		return 
	grid_position = new_grid_position 
	position = grid_position * grid_size
	
func _physics_process(delta):
	update_grid_position()
