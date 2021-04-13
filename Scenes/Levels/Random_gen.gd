extends Node

signal boss(bossRoom)

var directions = [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT]
var position = Vector2.ZERO
var map = [] #lista zawierająca współrzedne pokojów
var rooms = [] #lista pokojów
var queue = [] #kolejka do przechowywania koordynatów do generowania pokojów
var rng := RandomNumberGenerator.new()
var roomsNum = 20 #ilość pokojów
var n = 0 #zmiennna pomocnicza do funkcji generate
var szer = 512 #szerokość pokoju
var dl = 288 #długość pokoju
var gen = 0
var oneDoor = 0
var drawn = false
var scene = load("res://Scenes/Levels/Room.tscn") #wczytywanie sceny pokoju
var player = load("res://Scenes/Actors/Player.tscn") #wczytywanie sceny playera

func draw(map): #rysowanie poziomu na podstawie wygenerowanych koordynatów pokojów
	var oneDoorRooms = [] #lista pokojów z jednymi otwartymi drzwiami
	var furthestRoom = [Vector2.ZERO] #najdalszy pokój
	for i in range(len(map)): #respienie pokojów
		var doors = 0
		var room = scene.instance()
		add_child(room) #dodawanie sceny pokoju
		var tilemap = room.get_node("TileMap")
		room.position.x = map[i].x * szer #przypisywanie pozycji x pokoju 
		room.position.y = map[i].y * dl #przypisywanie pozycji y pokoju
		if not map[i] + Vector2.DOWN in map: #jeżeli nie ma pokoju pod pokojem, zamknij drzwi
			tilemap.set_cell(6,8,28)
			tilemap.set_cell(7,8,29)
			tilemap.set_cell(8,8,30)
			tilemap.set_cell(7,7,31)
			doors += 1
		if not map[i] + Vector2.UP in map: #jeżeli nie ma pokoju nad pokojem, zamknij drzwi
			tilemap.set_cell(6,0,24)
			tilemap.set_cell(7,0,25)
			tilemap.set_cell(8,0,26)
			tilemap.set_cell(7,1,27)
			doors += 1
		if not map[i] + Vector2.RIGHT in map: #jeżeli nie ma pokoju na prawo od pokoju, zamknij drzwi
			tilemap.set_cell(14,3,20)
			tilemap.set_cell(14,4,21)
			tilemap.set_cell(14,5,22)
			tilemap.set_cell(13,4,23)
			doors += 1
		if not map[i] + Vector2.LEFT in map: #jeżeli nie ma pokoju na lewo od pokoju, zamknij drzwi
			tilemap.set_cell(0,3,16)
			tilemap.set_cell(0,4,17)
			tilemap.set_cell(0,5,18)
			tilemap.set_cell(1,4,19)
			doors += 1
		rooms.append(room)
		if doors == 3:
			oneDoorRooms.append([map[i], room]) #dodawanie do listy pokoju z tylko jednymi drzwiami
	for room in oneDoorRooms: #szukanie najdalszego pokoju
		if abs(room[0].length()) > abs(furthestRoom[0].length()):
			furthestRoom = room
	emit_signal("boss", furthestRoom[0])

func generate(): #funkcja generująca poziom (położenia pokojów)
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
			generate()
	oneDoor = 0
	for room in map: #określanie ile jest zamkniętych drzwi w pokoju
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
	if oneDoor > 0 and not drawn:
		draw(map)
		drawn = true
	elif not drawn:
		map = []
		queue = []
		position = Vector2.ZERO
		n = 0
		oneDoor = 0
		generate()

func step(direction): #funkcja, która określa w którą stronę może zostać wygenerowany pokój
	var target_position = position + direction
	if not target_position in map:
		map.append(target_position)
		queue.append(target_position)
	else:
		n -= 1

func _ready():
	MusicController.stop_music()
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
