extends Node

var BIOM = 0
# 0 - standardowy/podziemia, 1 - ul, 2 - dżungla

signal boss(bossRoom)
signal map_generated(map)

var directions = [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT]
var position = Vector2.ZERO
export var map = [] #lista zawierająca współrzedne pokojów
var rooms = [] #lista pokojów
var queue = [] #kolejka do przechowywania koordynatów do generowania pokojów
var rng := RandomNumberGenerator.new()
var roomsNum = 3 #ilość pokojów
var n = 0 #zmiennna pomocnicza do funkcji generate
var szer = 512 #szerokość pokoju
var dl = 288 #długość pokoju
var gen = 0
var oneDoor = 0
var drawn = false
var scene = load("res://Scenes/Levels/Room.tscn") #wczytywanie sceny pokoju
var random_room_nr = RandomNumberGenerator.new()
var room_variations = [
{
	1 : load("res://Assets/TileMap/Room2.tres"),
	2 : load("res://Assets/TileMap/Room3.tres"),
	3 : load("res://Assets/TileMap/Room4.tres"),
	4 : load("res://Assets/TileMap/Room1.tres")
},
{
	1 : load("res://Assets/TileMap/room7.tres"),
},
{
	1 : load("res://Assets/TileMap/room6.tres"),
}
]
var current_room_type


func _ready():
	get_node("UI").set_process_input(false)
	match Bufor.POZIOM:
		0:
			current_room_type = 1
		1:
			current_room_type = 2
		2:
			current_room_type = 3
		_:
			current_room_type = random_room_nr.randi_range(1, room_variations.size())
			
	MusicController.stop_music() #zapauzowanie muzyki z menu
	generate() #generacja mapy
	MusicController.play_game_music()


func draw(map): #rysowanie poziomu na podstawie wygenerowanych koordynatów pokojów
	var oneDoorRooms = [] #lista pokojów z jednymi otwartymi drzwiami
	var furthestRoom = [Vector2.ZERO] #najdalszy pokój
	for i in range(len(map)): #respienie pokojów
		var doors = 0
		var room = scene.instance()
		add_child(room) #dodawanie sceny pokoju
		var tilemap = room.get_node("TileMap")
		tilemap.tile_set = room_variations[BIOM][current_room_type]
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
	emit_signal("map_generated", map)
	
func generate(): #funkcja generująca poziom (położenia pokojów)
	map.append(Vector2(0,0)) #dodanie pierwszego pokoju do mapy
	rng.randomize()
	gen = rng.randi_range(1,4) #wylosowanie ilosci pokoi odchodzacych od startowego
	while n < roomsNum - 1: #petla tworzaca reszte pokoi
		if n != 0:
			gen = rng.randi_range(1,2) #wylosowanie ilosci pokoi odchodzacych od aktualnie zakolejkowanego pokoju
		directions.shuffle() #wylosowanie kierunkow generacji pokoi
		for i in gen:
			step(directions[i]) #wywolanie generacji pokoju z wylosowaanym kierunkiem
			n += 1
			if n >= roomsNum - 1:
				break
		if queue:
			position = queue.pop_front() #wybranie kolejnego z kolejki pokoju do generacji
		else: #jezeli kolejka jest pusta to od nowa wygeneruj mape
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
	if oneDoor > 0 and not drawn: #jezeli sa pokoje z 1 drzwiami i nie narysowano mapy to ja narysuj
		draw(map)
		drawn = true
	elif not drawn: #jezeli nie ma pokoju z 1 drzwiami i nie narysowano to jeszcze raz wygeneruj mape
		map = []
		queue = []
		position = Vector2.ZERO
		n = 0
		oneDoor = 0
		generate()

func step(direction): #funkcja, która określa w którą stronę może zostać wygenerowany pokój
	var target_position = position + direction #pozycja w ktorej chcemy dodac pokoj
	if not target_position in map: #jezeli taki pokoj nie istnieje jeszcze w mapie
		map.append(target_position) #dodaj go do mapy
		queue.append(target_position) #dodaj go do kolejki generowania
	else: #jezeli jest juz w mapie to zmniejszamy "n" poniewaz nie wygenerowalismy pokoju
		n -= 1

func _ready():
	match Bufor.poziom:
		0:
			current_room_type = 1
		1:
			current_room_type = 2
		2:
			current_room_type = 3
		_:
			var b =  RandomNumberGenerator.new()
			b.randomize()
			BIOM = b.randi_range(0,2)
			current_room_type = 1
			if BIOM == 0:
				current_room_type = random_room_nr.randi_range(1, room_variations.size())
			
	MusicController.stop_music() #zapauzowanie muzyki z menu
	generate() #generacja mapy
