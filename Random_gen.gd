extends Node

signal boss(bossRoom)

var directions = [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT]
var position = Vector2.ZERO
var map = []
var rooms = []
var queue = []
var rng := RandomNumberGenerator.new()
var roomsNum = 20
var n = 0
var szer = 512
var dl = 288
var gen = 0
var scene = load("res://Scenes/Levels/Room.tscn")
var player = load("res://Scenes/Actors/Player.tscn")

func draw(map):
	var oneDoorRooms = []
	var furthestRoom = [Vector2.ZERO]
	for i in range(len(map)):
		var doors = 0
		var room = scene.instance()
		add_child(room)
		var tilemap = room.get_node("TileMap")
		room.position.x = map[i].x * szer
		room.position.y = map[i].y * dl
		if not map[i] + Vector2.DOWN in map:
			tilemap.set_cell(6,8,28)
			tilemap.set_cell(7,8,29)
			tilemap.set_cell(8,8,30)
			tilemap.set_cell(7,7,31)
			doors += 1
		if not map[i] + Vector2.UP in map:
			tilemap.set_cell(6,0,24)
			tilemap.set_cell(7,0,25)
			tilemap.set_cell(8,0,26)
			tilemap.set_cell(7,1,27)
			doors += 1
		if not map[i] + Vector2.RIGHT in map:
			tilemap.set_cell(14,3,20)
			tilemap.set_cell(14,4,21)
			tilemap.set_cell(14,5,22)
			tilemap.set_cell(13,4,23)
			doors += 1
		if not map[i] + Vector2.LEFT in map:
			tilemap.set_cell(0,3,16)
			tilemap.set_cell(0,4,17)
			tilemap.set_cell(0,5,18)
			tilemap.set_cell(1,4,19)
			doors += 1
		rooms.append(room)
		if doors == 3:
			oneDoorRooms.append([map[i], room])
	for room in oneDoorRooms:
		if abs(room[0].length()) > abs(furthestRoom[0].length()):
			furthestRoom = room
	emit_signal("boss", furthestRoom[0])

func generate():
	var oneDoor = 0
	map.append(Vector2(0,0))
	rng.randomize()
	gen = rng.randi_range(1,4)
	while n < roomsNum - 1:
		if n != 0:
			gen = rng.randi_range(1,2)
		directions.shuffle()
		for i in gen:
			step(directions[i])
			n += 1
			if n >= roomsNum - 1:
				break
		if queue:
			position = queue.pop_front()
		else:
			map = []
			queue = []
			position = Vector2.ZERO
			n = 0
			oneDoor = 0
			generate()
	for room in map:
		if not room == Vector2.ZERO:
			var doors = 0
			if not room + Vector2.DOWN in map:
				doors += 1
			if not room + Vector2.UP in map:
				doors += 1
			if not room + Vector2.RIGHT in map:
				doors += 1
			if not room + Vector2.LEFT in map:
				doors += 1
			if doors == 3:
				oneDoor += 1
	if oneDoor > 0:
		draw(map)
	else:
		map = []
		queue = []
		position = Vector2.ZERO
		n = 0
		oneDoor = 0
		generate()

func step(direction):
	var target_position = position + direction
	if not target_position in map:
		map.append(target_position)
		queue.append(target_position)
	else:
		n -= 1

func _ready():
	generate()

#func _physics_process(delta):
#	if Input.is_action_pressed("ui_accept"):
#		for room in rooms:
#			room.queue_free()
#		rooms = []
#		map = []
#		queue = []
#		position = Vector2.ZERO
#		n = 0
#		generate()
