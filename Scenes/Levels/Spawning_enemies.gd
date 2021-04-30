extends Node

var arr = [] #Pusta tablica dla losowych liczb
var names = [] #Pusta tablica dla nazw broni

onready var all_weapons = get_tree().get_root().find_node("Weapons", true, false).all_weapons #Wczytanie z niewidzialnego node wszystkich broni
onready var tilemap = get_node("../TileMap") #Wczytanie tilemapy
var rand = RandomNumberGenerator.new() #Losowa generacja numeru
var all_enemies = {
		0 : preload("res://Scenes/Actors/Big Devil.tscn"),
		1 : preload("res://Scenes/Actors/cuck.tscn"),
		2 : preload("res://Scenes/Actors/cuckshooter.tscn"),
		3 : preload("res://Scenes/Actors/goblin_shaman.tscn"),
		4 : preload("res://Scenes/Actors/Lil Devil.tscn"),
		5 : preload("res://Scenes/Actors/Little_Goblin.tscn"),
		6 : preload("res://Scenes/Actors/Potato.tscn"),
		7 : preload("res://Scenes/Actors/Slime.tscn"),
		8 : preload("res://Scenes/Actors/Snot.tscn"),
		9 : preload("res://Scenes/Actors/Orc.tscn"),
	}
var bossScene = load("res://Scenes/Actors/MageBoss/MageBoss.tscn")
var id_list = [] #Lista ID pokojów, w których był już player
var current_id #ID aktualnego pokoju
var down = Vector2(7,8) #Pozycja dolnych drzwi
var up = Vector2(7,0) #Pozycja górnych drzwi
var right = Vector2(14,4) #Pozycja prawych drzwi
var left = Vector2(0,4) #Pozycja lewych drzwi
var drzwi = [true,true,true,true] #Lista determinująca, czy drzwi są otwarte czy zamknięte
var ilosc_enemy #aktualna ilosc przeciwnikow
var boss = false #czy to jest pokoj z bossem
onready var generation = get_node("../../../Main") #pobranie maina aby podpinac do niego pokoje

func _ready():
	generation.connect("boss", self, "check_boss") #polaczenie sygnalu z generacji aby przeazac pokoj z bossem

func check_boss(room): #sprawdza czy dany pokoj jest pokojem z bossem
	if room.x == int(round(self.global_position.x/512)) and room.y == int(round(self.global_position.y/288)):
		boss = true

func close_door(): #Podmiana tekstur na zamknięte drzwi
	tilemap.set_cell(6,8,28)
	tilemap.set_cell(7,8,29)
	tilemap.set_cell(8,8,30)
	tilemap.set_cell(7,7,31)
	tilemap.set_cell(6,0,24)
	tilemap.set_cell(7,0,25)
	tilemap.set_cell(8,0,26)
	tilemap.set_cell(7,1,27)
	tilemap.set_cell(14,3,20)
	tilemap.set_cell(14,4,21)
	tilemap.set_cell(14,5,22)
	tilemap.set_cell(13,4,23)
	tilemap.set_cell(0,3,16)
	tilemap.set_cell(0,4,17)
	tilemap.set_cell(0,5,18)
	tilemap.set_cell(1,4,19)

func _on_Node2D_body_entered(body): #Funkcja,która się aktywuje po wejsciu w kolizje playere z polem("area")
	if body.name == "Player": 
		ilosc_enemy = 5
		if tilemap.get_cellv(left) == 1: #Sprawdzanie, czy drzwi są otwarte czy zamknięte
			drzwi[0] = true
		else:
			drzwi[0] = false
		if tilemap.get_cellv(up) == 9:
			drzwi[1] = true
		else:
			drzwi[1] = false
		if tilemap.get_cellv(right) == 5:
			drzwi[2] = true
		else:
			drzwi[2] = false
		if tilemap.get_cellv(down) == 13:
			drzwi[3] = true
		else:
			drzwi[3] = false
		current_id = get_instance_id() #pobieranie aktualnego ID pokoju
		if int(round(self.global_position.x/512)) == 0 and int(round(self.global_position.y/288)) == 0: #jezeli startowy pokoj
			id_list.append(current_id) #Dodawanie pokoju do listy odwiedzonych
		if not current_id in id_list and not boss: #losowanie przeciwników do poziomu
			for i in range(0,5):
				rand.randomize()
				var enemy = all_enemies[rand.randi_range(0,9)].instance() #rodzaj przeciwnika
				rand.randomize()
				enemy.position.x = rand.randf_range(-180,180) #pozycja x
				rand.randomize()
				enemy.position.y = rand.randf_range(-80,80) #pozycja y
				add_child(enemy) #dodawanie sceny przeciwnika
				enemy.connect("died", self, "open") #polaczenie sygnalu ktory otwiera drzwi po pokonaniu wszystkich przeciwnikow
		elif boss: #respienie boss'a
			ilosc_enemy = 1
			var bossIns = bossScene.instance()
			add_child(bossIns) #dodawanie sceny boss'a
			bossIns.connect("died", self, "open") #polaczenie sygnalu ktory otwiera drzwi po zabiciu bossa
			close_door() #zamkniecie drzwi
		id_list.append(current_id)
	if body.is_in_group("Enemy"): #zamykanie drzwi po wejsciu do pokoju
		close_door()
	
	

func weapon():
	var weapon #Zmienna przechowująca scenę broni
	var weapons #Zmienna przechowująca bronie
	weapons = all_weapons["Weapons"] #Przypisanie wszystkich broni do zmiennej
	for i in weapons: #Pętla przypisująca nazwy do zmiennej
		names.append(i)
	rand_num(0,len(names)) #Wywołanie funkcji rand_num()

	weapon = load("res://Scenes/Loot/Weapon.tscn") #Ładuje scenę broni do zmiennej 
	weapon = weapon.instance()
	weapon.WeaponName = names[arr[0]] #Przypisuje nazwę broni dla losowego indeksu zmiennej names
	if weapon.WeaponName == "Fire Scepter":
		weapon.WeaponName = names[arr[1]]
	weapon.position = Vector2(rand.randf_range(-180,180),rand.randf_range(-80,80)) #Przypisuje pozycję broni
	add_child(weapon) #Tworzy broń na podłodze

func rand_num(from,to):
	randomize() #Pobiera ziarno dla funkcji losowych
	for i in range(from,to): #Pętla dodaje do zmiennej arr wszystkie liczby od "from" do "to"
		   arr.append(i)
	arr.shuffle() #Funkcja losuje kolejność dla elementów w zmiennej arr

func open(body): #funckja otwierania drzwi po pokonaniu przeciwników
	if body.health <= 0: #jeżeli życie przeciwnika spadnie poniżej 0
		ilosc_enemy -= 1 #odejmij o 1 ilość przeciwników
	if ilosc_enemy == 0: #jeżeli nie ma przeciwników
		rand.randomize()
		if rand.randf_range(0,100) <= 100: #drop broni
			weapon()
		if drzwi[3]: #otwieranie drzwi
			tilemap.set_cell(6,8,12)
			tilemap.set_cell(7,8,13)
			tilemap.set_cell(8,8,14)
			tilemap.set_cell(7,7,15)
		if drzwi[1]:
			tilemap.set_cell(6,0,8)
			tilemap.set_cell(7,0,9)
			tilemap.set_cell(8,0,10)
			tilemap.set_cell(7,1,11)
		if drzwi[2]:
			tilemap.set_cell(14,3,4)
			tilemap.set_cell(14,4,5)
			tilemap.set_cell(14,5,6)
			tilemap.set_cell(13,4,7)
		if drzwi[0]:
			tilemap.set_cell(0,3,0)
			tilemap.set_cell(0,4,1)
			tilemap.set_cell(0,5,2)
			tilemap.set_cell(1,4,3)
