extends MarginContainer

export (NodePath) var player
export var zoom = 0.5 #Zmienna określająca przybliżenie minimapy

#Zmienne przypisujące elementy MiniMapy 
onready var grid = $MarginContainer/Grid
onready var player_marker = $MarginContainer/Grid/Hero
onready var wall_marker = $MarginContainer/Grid/Wall
onready var chest_marker = $MarginContainer2/Grid/ChestMarker
onready var icons  = {"chest": chest_marker}
var fullscreen_map = false
onready var tiles = [] #Zmienna przechowująca wszystkie kafelki ściany

var grid_scale
var markers = {}

func _ready():
	rect_size.x = get_viewport().size.x/2
	rect_size.y = get_viewport().size.y/2
	self.rect_position.x = (get_viewport().size.x - rect_size.x)/2
	self.rect_position.y = (get_viewport().size.y - rect_size.y)/2
	player_marker.position = rect_size / 2 #Wyśrodkowanie pozycji ikony gracza na mapie
	grid_scale = grid.rect_size / (get_viewport_rect().size * zoom) #Skalowanie wielkości minimapy
	var map_objects = get_tree().get_nodes_in_group("walls") #Pobranie wszystkich kafelków ściany
	for item in map_objects:
		tiles = item.get_used_cells() #Przypisuje pozycje wszystkich kafelków
		for i in tiles:
			var new_marker = wall_marker.duplicate() #Tworzy nową ikonę dla każdego kafelka
			grid.add_child(new_marker) #Dodaje do mapy ikonę
			new_marker.show()
			markers[new_marker] = Vector2(i.x*16,i.y*16) #Przypisuje pozycję na mapie kafelkom
			
			
		#var news_marker = chest_marker.duplicate() #Bierze ikonę skrzyni
		#grid.add_child(news_marker) #Dodaje
		#news_marker.show()          #Wyświetla
		
		
func _process(delta):
	if !player: #Jeżeli nie znaleziono węzła gracza to zakończ dałanie funkcji
		return
	for item in markers: #Pętla ustala położenie ikon względem gracza
		var obj_pos = (markers[item] - get_node(player).position) * grid_scale + grid.rect_size/2
		item.position = obj_pos
		
		
func _unhandled_input(event): #Funckcja mapy
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_M:  #Jeżeli nacisnął przycisk mapy
			match fullscreen_map:
				true:
					self.visible = false 
					fullscreen_map = false                       
				false:
					self.visible = true                   
					fullscreen_map = true
			
			
		



