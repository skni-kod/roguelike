extends Node

var directions = [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT]
var position = Vector2.ZERO
var map = []
var rooms = []
var queue = []
var rng := RandomNumberGenerator.new()
var roomsNum = 30
var n = 0
var szer = 512
var dl = 288
var gen = 0
var scene = load("res://Scenes/Levels/Room.tscn")

func draw(map):
	for i in range(len(map)):
		var room = scene.instance()
		add_child(room)
		room.position.x = map[i].x * szer
		room.position.y = map[i].y * dl
		rooms.append(room)

func generate():
	var Room = scene.instance()
	add_child(Room)
	map.append(Room.position)
	rooms.append(Room)
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
			for room in rooms:
				room.queue_free()
				rooms = []
				map = []
				queue = []
				position = Vector2.ZERO
				n = 0
				generate()
	draw(map)

func step(direction):
	var target_position = position + direction
	if not target_position in map:
		map.append(target_position)
		queue.append(target_position)
	else:
		n -= 1

func _ready():
	generate()

func _physics_process(delta):
	if Input.is_action_pressed("ui_accept"):
		for room in rooms:
			room.queue_free()
		rooms = []
		map = []
		queue = []
		position = Vector2.ZERO
		n = 0
		generate()
