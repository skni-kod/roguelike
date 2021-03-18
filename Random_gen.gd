extends Node

var directions = [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT]
var position = Vector2.ZERO
var map = []
var rooms = []
var queue = []
var rng := RandomNumberGenerator.new()
var ilosc_pok = 20
var n = 0
var szer = 512
var dl = 288
var gen = 0
var scene = load("res://Scenes/Levels/Room.tscn")

func generate():
	rng.randomize()
	var pokoj = scene.instance()
	add_child(pokoj)
	map.append(pokoj.position)
	gen = rng.randi_range(1,4)
	while n < ilosc_pok - 1:
		rng.randomize()
		randomize()
		if n != 0:
			gen = rng.randi_range(1,2)
		directions.shuffle()
		for i in range(gen):
			step(directions[i])
			n += 1
			if n >= ilosc_pok - 1:
				break
		if queue:
			position = queue.pop_front()

func step(direction):
	var target_position = position + direction
	if not target_position in map:
		var pokoj = scene.instance()
		add_child(pokoj)
		pokoj.position.x = target_position.x * szer
		pokoj.position.y = target_position.y * dl
		rooms.append(pokoj)
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
		map = []
		rooms = []
		queue = []
		position = Vector2.ZERO
		n = 0
		generate()
