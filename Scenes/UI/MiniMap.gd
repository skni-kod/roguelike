extends MarginContainer

# === POTRZEBNE NODE I PRELOAD === #
onready var player = get_tree().get_root().find_node("Player", true, false)
var seen_room_sprite = preload("res://Assets/UI/Minimap/room_active.png")
# === ======================== === #

# === ZMIENNE MINIMAPY === #
onready var map = [] # Lista przechowująca pozycje gridowe pokoi z generacji mapy
onready var grid = $MarginContainer/Grid # Siatka na której wyświetlane są elementy
var markers = {} # Słownik przechowujący element oraz jego pozycję na minimapie
export var zoom = 0.5 # Zmienna określająca przybliżenie minimapy
var room_pos
#var fullscreen_map = false 
# === ================ === #

# === ZMIENNE POTRZEBNE DO WIZUALIZACJI ELEMENTÓW === #
var playerMovement = Vector2.ZERO
onready var player_marker = $MarginContainer/Grid/Hero
onready var room_marker= $MarginContainer/Grid/Room
# === =========================================== === #

func _ready():
	player.connect("player_moved", self, "_on_player_movement") # Połączenie sygnału player_moved z _on_player_movement w celu uzyskania wektora poruszania się gracza
	player_marker.position = grid.rect_size / 2 #Wyśrodkowanie pozycji ikony gracza na mapie


# === FUNKCJA WYŚWIETLANIA ELEMENTÓW NA MINIMAPIE === #
func mapping():
	var map_objects = map #Pobranie wszystkich kafelków ściany
	for item in map_objects:
		var new_marker = room_marker.duplicate() # Tworzy nową ikonę dla każdego znaczka
		grid.add_child(new_marker) # Dodaje do mapy ikonę
		new_marker.show() # Pokazanie wszystkich pokoi na mapie
		markers[new_marker] = Vector2(item.x*16*4,item.y*9*4) # Ustalenie nowych pozycji znaczników pokoi w skali mapy
# === =========================================== === #

func _physics_process(_delta):
	# === USTAWIANIE POZYCJI I TEKSTURY POKOI NA MAPIE === #
	for item in markers:
		item.position = (grid.rect_size/2 + markers[item]) # Ustawienie pozycji pokoju
		# Przesuwanie o dostosowany do skali mapy wektor poruszania się gracza
		markers[item] -= Vector2(playerMovement.x/16/1.75, playerMovement.y/9/5.6)/((get_viewport_rect().size)/(grid.rect_size*zoom))
		
		if abs(player_marker.position.x - item.position.x) <= 32 and abs(player_marker.position.y - item.position.y) <= 18 and item.get_texture() != seen_room_sprite:
			item.set_texture(seen_room_sprite)
	# === ============================================ === #
	
	
# === POBIERANIE WEKTORA PRZESUNIĘCIA === #
func _on_player_movement(movement_vec):
	playerMovement = movement_vec
# === =============================== === #
		
		
# === ODEBRANIE SYGNAŁU WYGENEROWANIA MAPY === #
func _on_map_generated(gen_map):
	map = gen_map
	mapping()
# === ==================================== === #
		
		
# === INPUT === #
#func _unhandled_input(event):
#	if event is InputEventKey:
#		if event.pressed and event.scancode == KEY_M:
#			# === FUNKCJA DUŻEJ MAPY === #
#			# Do implementacji później
#			match fullscreen_map:
#				true:
#					self.visible = true (funkcjonalność dużej mapy tymczasowo zablokowana)
#					fullscreen_map = false                         
#				false:
#					self.visible = false (funkcjonalność dużej mapy tymczasowo zablokowana)                 
#					fullscreen_map = true
			# === ================== === #
# === ===== === #
