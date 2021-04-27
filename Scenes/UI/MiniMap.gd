extends MarginContainer

onready var player = get_tree().get_root().find_node("Player", true, false)
#onready var room = get_node("/root/Room")#get_tree().get_root().find_node("Enemies", true, false)

onready var map = []
var grid_map = []
var activeRooms = []

var active_room_sprite = preload("res://Assets/UI/Minimap/room_active.png")

export var zoom = 0.5 #Zmienna określająca przybliżenie minimapy

#Zmienne przypisujące elementy MiniMapy 
onready var grid = $MarginContainer/Grid
onready var player_marker = $MarginContainer/Grid/Hero
onready var room_marker= $MarginContainer/Grid/Room
var fullscreen_map = false 
onready var tiles = [] #Zmienna przechowująca wszystkie kafelki ściany

var grid_scale
var markers = {}

var playerMovement = Vector2.ZERO

func _ready():
	player.connect("player_moved", self, "_on_player_movement")
#	room.connect("visited", self, "_on_visited")
	player_marker.position = grid.rect_size / 2 #Wyśrodkowanie pozycji ikony gracza na mapie
	grid_scale = grid.rect_size / (get_viewport_rect().size * zoom) #Skalowanie wielkości minimapy

func mapping():
	var map_objects = map #Pobranie wszystkich kafelków ściany
	for item in map_objects:
		var new_marker = room_marker.duplicate() #Tworzy nową ikonę dla każdego kafelka
		grid.add_child(new_marker) #Dodaje do mapy ikonę
		new_marker.show()
		markers[new_marker] = Vector2(item.x*16*4,item.y*9*4) #Przypisuje pozycję na mapie kafelkom
	grid_map = markers
	markers.keys()[0].set_texture(active_room_sprite)
	
	
func _physics_process(delta):
	for item in markers: #Pętla ustala położenie ikon względem gracza
		item.position = (grid.rect_size/2 + markers[item])
		markers[item] -= Vector2(playerMovement.x/16/1.7, playerMovement.y/9/5.5)/((get_viewport_rect().size)/(grid.rect_size*zoom))
		
		if item in activeRooms:
			print("Activated ", grid_map[item])
			item.set_texture(active_room_sprite)
	
#func _on_visited(active_rooms):
#	activeRooms = active_rooms
#	print("Active rooms: ", activeRooms)
	
func _on_player_movement(movement_vec):
	playerMovement = movement_vec
		
func _on_map_generated(gen_map):
	map = gen_map
	mapping()
		
		
func _unhandled_input(event): #Funckcja mapy
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_M:
			match fullscreen_map:
				true:
					self.visible = true  
					fullscreen_map = false                         
				false:
					self.visible = false                  
					fullscreen_map = true
			
			
		

