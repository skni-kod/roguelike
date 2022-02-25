extends Node2D

var Room = preload("res://Scenes/Levels/Room_new.tscn")
var Player = preload("res://Scenes/Actors/Player.tscn")
onready var Map = $TileMap

var tile_size = 32
var room_num = 50
var min_size = 4
var max_size = 10 
var hspread = 400
var cull = 0.6
var path

func _ready():
	randomize()
	make_rooms()

func make_rooms():
	for i in range(room_num):
		var pos = Vector2(0, 0)
		var r = Room.instance()
		var w = min_size + randi()%(max_size-min_size)
		var h = min_size + randi()%(max_size-min_size)
		r.make_room(pos, Vector2(w,h) * tile_size)
		$Rooms.add_child(r)
	yield(get_tree().create_timer(1.5),"timeout") #zatrzymuje funkcje i wykonuje w tym czasie przerwe
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(Vector3(room.position.x,
				room.position.y, 0))
	yield(get_tree(),"idle_frame")
	path = find_mst(room_positions)
	make_map()

func _process(delta):
	update()
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		make_rooms()
	if event.is_action_pressed("ui_focus_next"):
		make_map()

func find_mst(nodes): #algorytm Prima
	var path = AStar.new()
	path.add_point(path.get_available_point_id(),nodes.pop_front())
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

func make_map():
	Map.clear()
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size,
			room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	
#	for x in range(topleft.x, bottomright.x):
#		for y in range(topleft.y, bottomright.y):
#			Map.set_cell(x,y,56)
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size/tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position/tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(ul.x + x, ul.y + y, 11)
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x,
					path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x,
					path.get_point_position(conn).y))
				carve_path(start, end)
			corridors.append(p)

func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0:
		x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0:
		y_diff = pow(-1.0, randi() % 2)
	var x_y = pos1
	var y_x = pos2
	if(randi()%2>0):
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(x, x_y.y, 11)
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(y_x.x, y, 11)
