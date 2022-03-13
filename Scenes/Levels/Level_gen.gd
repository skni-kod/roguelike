extends Node2D

var Room = preload("res://Scenes/Levels/Room_new.tscn")
var Player = preload("res://Scenes/Actors/Player.tscn")
onready var Map = $TileMap

var tile_size = 32 #rozmiar tile'a
var room_num = 30 #ilość pokoi (przed usunięciem)
var min_size = 10 #minimalny rozmiar pokoju
var max_size = 12 #max rozmiar pokoju
var cull = 0.5 #szansa na usunięcie pokoju podczas generacji
var path #zmienna przechowująca najkrótszą ścieżkę
var world_size_tl
var world_size_br

var start_room = null #zmienna przechowująca początkowy pokój
var end_room = null #zmienna przechowująca końcowy pokój

func _ready():
	randomize()
	make_rooms()

func make_rooms(): #tworzenie pokojów
	for i in range(room_num):
		var pos = Vector2(0, 0)
		var r = Room.instance()
		var w = min_size + randi()%(max_size-min_size) #szerokość
		var h = min_size + randi()%(max_size-min_size) #wysokość
		r.make_room(pos, Vector2(w,h) * tile_size)
		$Rooms.add_child(r)
	yield(get_tree().create_timer(2),"timeout") #zatrzymuje funkcje i wykonuje w tym czasie przerwe (inne rzeczy się dzieją w tym momencie)
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC #zmiana trybu kolizji pokoju na statyczny (żeby się nie poruszał więcej)
			room_positions.append(Vector3(room.position.x,
				room.position.y, 0)) #musi być Vector3 bo tego wymaga algorytm szykania najkrótszej drogi
	yield(get_tree(),"idle_frame")
	path = find_mst(room_positions)
	make_map()
	global_tiles()
	doors()

func _process(delta):
	update()
	
func _input(event):
	if event.is_action_pressed("ui_select"): #naciśnięcie spacji - tworzenie nowej mapy
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		make_rooms()
	if event.is_action_pressed("ui_focus_next"): #naciśnięcie tab - zmienienie korytarzy
		make_map()
		global_tiles()
		doors()

func find_mst(nodes): #szukanie najkrótszej drogi
	var path = AStar.new() 
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	while nodes:
		var min_dist = INF #minimalny dystans
		var min_p = null #pozycja node'a
		var p = null #obecna pozycja
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			for p2 in nodes:
				if p1.distance_to(p2)<min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
	return path

func make_map(): #tworzenie mapy z dostępnych pokoi
	Map.clear()
	find_start_room()
	find_end_room()
	$Player.position = start_room.position
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size,
			room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	world_size_tl = topleft
	world_size_br = bottomright
#	for x in range(topleft.x, bottomright.x): #ustawienie tła
#		for y in range(topleft.y, bottomright.y):
#			Map.set_cell(x,y,44)
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size/tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position/tile_size).floor() - s
		for x in range(2, s.x * 2 - 2): #rysowanie pokoju
			for y in range(2, s.y * 2 - 2):
				Map.set_cell(ul.x + x, ul.y + y, 11)
		for x in range(1, s.x * 2-2): #rysowanie ścian pokoju
			if(Map.get_cell(ul.x + x, ul.y + 1) != 11):
				Map.set_cell(ul.x + x, ul.y + 1, 45)
			if(Map.get_cell(ul.x + x, ul.y + s.y * 2 - 2) != 11):
				Map.set_cell(ul.x + x, ul.y + s.y * 2 - 2, 60)
		for y in range(1, s.y * 2-2):
			if(Map.get_cell(ul.x + 1, ul.y + y) != 11):
				Map.set_cell(ul.x + 1, ul.y + y, 63)
			if(Map.get_cell(ul.x + s.x * 2 - 2, ul.y + y) != 11):
				Map.set_cell(ul.x + s.x * 2 - 2, ul.y + y, 47)
#			if y == 1 and Map.get_cell(ul.x + 1, ul.y + y) != 11 and Map.get_cell(ul.x + s.x * 2 - 1, ul.y + y) != 11:
#				Map.set_cell(ul.x + 1, ul.y + y, 35)
#				Map.set_cell(ul.x + s.x * 2 - 1, ul.y + y, 46)
#			if y == s.y*2-1 and Map.get_cell(ul.x + 1, ul.y + y) != 11 and Map.get_cell(ul.x + s.x * 2 - 1, ul.y + y) != 11:
#				Map.set_cell(ul.x + 1, ul.y + y, 62)
#				Map.set_cell(ul.x + s.x * 2 - 1, ul.y + y, 51)
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for conn in path.get_point_connections(p): #szukanie połączeń
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x,
					path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x,
					path.get_point_position(conn).y))
				carve_path(start, end)
			corridors.append(p)

func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x) #różnica odległości pomiędzy pokojami
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: #jeżeli różnica jest równa 0, wylosuj różnicę -1 lub 1
		x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0:
		y_diff = pow(-1.0, randi() % 2)
	var x_y = pos1
	var y_x = pos2
	if(randi()%2>0):
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff): #rysowanie korytarzy
		Map.set_cell(x, x_y.y, 11)
		if (Map.get_cell(x, x_y.y+1) != 11 and Map.get_cell(x, x_y.y) == 11):
			Map.set_cell(x, x_y.y + 1, 60)
		if (Map.get_cell(x, x_y.y-1) != 11 and Map.get_cell(x, x_y.y) == 11):
			Map.set_cell(x, x_y.y - 1, 45)
		if x == pos1.x:
			if (Map.get_cell(x+1, x_y.y) != 11):
				Map.set_cell(x+1, x_y.y, 47)
			if (Map.get_cell(x-1, x_y.y) != 11):
				Map.set_cell(x-1, x_y.y, 63)
#		if(Map.get_cell(x, x_y.y) == 11 and Map.get_cell(x, x_y.y+1) == 60 and
#			Map.get_cell(x+1, x_y.y) == 47):
#				Map.set_cell(x+1, x_y.y+1, 51)
#		if(Map.get_cell(x, x_y.y) == 11 and Map.get_cell(x, x_y.y-1) == 45 and
#			Map.get_cell(x-1, x_y.y) == 63):
#				Map.set_cell(x-1, x_y.y-1, 35)
#		if(Map.get_cell(x, x_y.y) == 11 and Map.get_cell(x, x_y.y-1) == 45 and
#			Map.get_cell(x+1, x_y.y) == 47):
#				Map.set_cell(x+1, x_y.y-1, 46)
#		if(Map.get_cell(x, x_y.y) == 11 and Map.get_cell(x, x_y.y+1) == 60 and
#			Map.get_cell(x-1, x_y.y) == 63):
#				Map.set_cell(x-1, x_y.y+1, 62)
	
	for y in range(pos1.y, pos2.y, y_diff): #rysowanie korytarzy
		Map.set_cell(y_x.x, y, 11)
		if (Map.get_cell(y_x.x+1, y) != 11 and Map.get_cell(y_x.x, y) == 11):
			Map.set_cell(y_x.x+1, y, 47)
		if (Map.get_cell(y_x.x-1, y) != 11 and Map.get_cell(y_x.x, y) == 11):
			Map.set_cell(y_x.x-1, y, 63)
		if y == pos1.y:
			if (Map.get_cell(y_x.x, y+1) != 11):
				Map.set_cell(y_x.x, y+1, 60)
			if (Map.get_cell(y_x.x, y-1) != 11):
				Map.set_cell(y_x.x, y-1, 45)
#		if (Map.get_cell(y_x.x, y) == 11 and Map.get_cell(y_x.x+1, y) == 44 and 
#			Map.get_cell(y_x.x, y+1) == 44):
#				Map.set_cell(y_x.x+1, y+1, 51)
#		if (Map.get_cell(y_x.x, y) == 11 and Map.get_cell(y_x.x-1, y) == 44 and 
#			Map.get_cell(y_x.x, y-1) == 44):
#				Map.set_cell(y_x.x-1, y-1, 35)
#		if (Map.get_cell(y_x.x, y) == 11 and Map.get_cell(y_x.x+1, y) == 44 and 
#			Map.get_cell(y_x.x, y-1) == 44):
#				Map.set_cell(y_x.x+1, y-1, 46)
#		if (Map.get_cell(y_x.x, y) == 11 and Map.get_cell(y_x.x-1, y) == 44 and 
#			Map.get_cell(y_x.x, y+1) == 44):
#				Map.set_cell(y_x.x-1, y+1, 62)
func find_start_room(): #szukanie pokoju startowego
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x
	
func find_end_room(): #szukanie pokoju końcowego
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x

func doors(): #ustawianie drzwi
	for room in $Rooms.get_children():
		var s = (room.size/tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position/tile_size).floor() - s
		for x in range(1, s.x * 2 + 1):
			if(Map.get_cell(ul.x + x - 1, ul.y + 1) == 45 and 
				Map.get_cell(ul.x + x + 1, ul.y + 1) == 45 and
				Map.get_cell(ul.x + x, ul.y + 1) == 11):
					Map.set_cell(ul.x + x, ul.y + 1, 9)
			if(Map.get_cell(ul.x + x - 1, ul.y + s.y * 2 - 1 ) == 60 and
				Map.get_cell(ul.x + x + 1, ul.y + s.y * 2 - 1 ) == 60 and
				Map.get_cell(ul.x + x, ul.y + s.y * 2 - 1) == 11):
					Map.set_cell(ul.x + x, ul.y + s.y * 2 - 1, 13)
		for y in range(1, s.y * 2 + 1):
			if(Map.get_cell(ul.x + 1, ul.y + y - 1) == 63 and 
				Map.get_cell(ul.x + 1, ul.y + y + 1) == 63 and 
				Map.get_cell(ul.x + 1, ul.y + y) == 11):
					Map.set_cell(ul.x + 1, ul.y + y, 1)
			if(Map.get_cell(ul.x + s.x * 2 - 1, ul.y + y - 1) == 47 and 
				Map.get_cell(ul.x + s.x * 2 - 1, ul.y + y + 1) == 47 and 
				Map.get_cell(ul.x + s.x * 2 - 1, ul.y + y) == 11):
					Map.set_cell(ul.x + s.x * 2 - 1, ul.y + y, 5)
	
func global_tiles(): #funkcja wykonująca się po wygenerowaniu całej mapy, nie działa na korytarz (why???)
	for x in range(world_size_tl.x, world_size_br.x):
		for y in range(world_size_tl.y, world_size_br.y):
			if (Map.get_cell(x + 1, y) == 45 and
				Map.get_cell(x, y + 1) == 63):
					Map.set_cell(x, y, 35)
			if (Map.get_cell(x - 1, y) == 60 and 
				Map.get_cell(x, y - 1) == 47):
					Map.set_cell(x, y, 51)
			if (Map.get_cell(x + 1, y) == 60 and 
				Map.get_cell(x, y - 1) == 63):
					Map.set_cell(x, y, 62)
			if (Map.get_cell(x - 1, y) == 45 and 
				Map.get_cell(x, y + 1) == 47):
					Map.set_cell(x, y, 46)
			
			if (Map.get_cell(x + 1, y) == 60 and
				Map.get_cell(x, y + 1) == 47):
					Map.set_cell(x, y, 35)
			if (Map.get_cell(x - 1, y) == 45 and 
				Map.get_cell(x, y - 1) == 63):
					Map.set_cell(x, y, 51)
			if (Map.get_cell(x + 1, y) == 45 and 
				Map.get_cell(x, y - 1) == 47):
					Map.set_cell(x, y, 62)
			if (Map.get_cell(x - 1, y) == 60 and 
				Map.get_cell(x, y + 1) == 63):
					Map.set_cell(x, y, 46)
