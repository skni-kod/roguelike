extends Node

var arr = [] #Pusta tablica dla losowych liczb
var names = [] #Pusta tablica dla nazw broni



onready var all_weapons = get_tree().get_root().find_node("Weapons", true, false).all_weapons #Wczytanie z niewidzialnego node wszystkich broni

onready var tilemap = get_node("../TileMap") #Wczytanie tilemapy
onready var biom = get_parent().get_parent().BIOM
var rand = RandomNumberGenerator.new() #Losowa generacja numeru

var wrogowie = [
	{ # standardowy/podziemia
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
	},
	{ # ul
		0 : preload("res://Scenes/Actors/pszczola/roj.tscn"),
		1 : preload("res://Scenes/Actors/osa/osa.tscn")
	},
	{ # dżungla
		0 : preload("res://Scenes/Actors/kwiatek/kwiatek.tscn"),
		1 : preload("res://Scenes/Actors/kaktus/kaktus.tscn"),
	},
	]
	}
var all_armors = {
	'BlackArmor' : preload("res://Scenes/Equipment/Armors/BlackArmor.tscn"),
	"Angel" : preload("res://Scenes/Equipment/Armors/Angel.tscn"),
	"Amogus" : preload("res://Scenes/Equipment/Armors/Amogus.tscn"),
	"Ninja" : preload("res://Scenes/Equipment/Armors/Ninja.tscn"),
	"Cactus" : preload("res://Scenes/Equipment/Armors/Cactus.tscn"),
	"Knight" : preload("res://Scenes/Equipment/Armors/Knight.tscn"),
}

var armor_drop_chance = 80 # szansa na to że wydropi jakiś armor po zabiciu wszystkich potworów w pokoju

var armors_drop_chances = { # szansa na drop kazdego z armorów
	'BlackArmor' : 50,
	"Angel" : 10,
	"Amogus" : 2,
	"Cactus" : 15,
	"Knight" : 70,
	"Ninja" : 20,
}
var bossScene = [load("res://Scenes/Actors/MageBoss/MageBoss.tscn"),
	load("res://Scenes/Actors/PandoBoss/PandaBoss.tscn"),
	load("res://Scenes/Actors/OctoBoss/OctoBoss.tscn"),
	load("res://Scenes/Actors/szerszen/Szerszen.tscn"),
	load("res://Scenes/Actors/trojkwiat/trojkwiat.tscn")]
var id_list = [] #Lista ID pokojów, w których był już player
var current_id #ID aktualnego pokoju
var down = Vector2(7,8) #Pozycja dolnych drzwi
var up = Vector2(7,0) #Pozycja górnych drzwi
var right = Vector2(14,4) #Pozycja prawych drzwi
var left = Vector2(0,4) #Pozycja lewych drzwi
var drzwi = [true,true,true,true] #Lista determinująca, czy drzwi są otwarte czy zamknięte
var boss = false #czy to jest pokoj z bossem
var item
var popups = {}

onready var main := get_tree().get_root().find_node("Main", true, false)

onready var generation = get_node("../../../Main") #pobranie maina aby podpinac do niego pokoje

func _ready():
	generation.connect("boss", self, "check_boss") #polaczenie sygnalu z generacji aby przekazac pokoj z bossem
	
func check_boss(room): #sprawdza czy dany pokoj jest pokojem z bossem
	if room.x == int(round(self.global_position.x/512)) and room.y == int(round(self.global_position.y/288)):
		boss = true

func close_door(): #Podmiana tekstur na zamknięte drzwi
	if obecniPrzeciwnicy():
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
			for _i in range(0, (5 + (Bufor.poziom - Bufor.poziom % 5) / 5)):
				rand.randomize()
				var enemy = wrogowie[biom][rand.randi_range(0,len(wrogowie[biom])-1)].instance() #rodzaj przeciwnika
				rand.randomize()
				enemy.position.x = rand.randf_range(-180,180) #pozycja x
				rand.randomize()
				enemy.position.y = rand.randf_range(-80,80) #pozycja y
				call_deferred('add_child', enemy) #dodawanie sceny przeciwnika
				enemy.connect("died", self, "open") #polaczenie sygnalu ktory otwiera drzwi po pokonaniu wszystkich przeciwnikow
		elif boss: #respienie boss'a
			var bossIns
			bossIns = bossScene[Bufor.poziom % len(bossScene)].instance()
			call_deferred("add_child",bossIns) #dodawanie sceny boss'a
			bossIns.connect("died", self, "open") #polaczenie sygnalu ktory otwiera drzwi po zabiciu bossa
			close_door() #zamkniecie drzwi
		#elif is_sklep:
		#	if odwiedzony == false:
		#		weapon()
		#		potion()
		#		var popup = load("res://Scenes/UI/Sklep_ceny.tscn")
		#		popup = popup.instance()
		#		popup.rect_scale.x = 0.5
		#		popup.rect_scale.y = 0.5
		#		call_deferred("add_child", popup)
		#		popups[body] = popup
		#		odwiedzony = true
		#	Bufor.in_sklep = true
		#elif is_sklep == false:
		#	if body in popups:
		#		popups[body].call_deferred('free')
		#	Bufor.in_sklep = false
		id_list.append(current_id)
	if body.is_in_group("Enemy"): #zamykanie drzwi po wejsciu do pokoju
		close_door()

func potion():
		var ptn
		ptn = load("res://Scenes/Loot/60healthPotion.tscn")
		ptn = ptn.instance()
		ptn.position = self.global_position + Vector2(-60,60)
		main.call_deferred("add_child", ptn)
		
func weapon():
	var weapon #Zmienna przechowująca scenę broni
	var weapons #Zmienna przechowująca bronie
	weapons = all_weapons["Weapons"] #Przypisanie wszystkich broni do zmiennej
	for i in weapons: #Pętla przypisująca nazwy do zmiennej
		names.append(i)
	for i in weapons: #Pętla przypisująca nazwy do zmiennej
		if int(weapons[i]["plus"])==0: 
			names.append(i)
	rand_num(0,len(names)) #Wywołanie funkcji rand_num()

	weapon = load("res://Scenes/Loot/Weapon.tscn") #Ładuje scenę broni do zmiennej 
	weapon = weapon.instance()
	weapon.WeaponName = names[arr[0]] #Przypisuje nazwę broni dla losowego indeksu zmiennej names
	if weapon.WeaponName == "Fire Scepter":
		weapon.WeaponName = names[arr[1]]
	weapon.position = Vector2(60,60) #Przypisuje pozycję broni
	call_deferred('add_child', weapon) #Tworzy broń na podłodze

func armor():
	var armor = null
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var n = rng.randi_range(0, 100)
	
	if n < armors_drop_chances['Amogus']:
		armor = all_armors['Amogus']
	
	elif n < armors_drop_chances['Angel']:
		armor = all_armors['Angel']
	

		
	elif n < armors_drop_chances['Cactus']:
		armor = all_armors['Cactus']
	
	
	elif n < armors_drop_chances['Ninja']:
		armor = all_armors['Ninja']
	
	elif n < armors_drop_chances['BlackArmor']:
		armor = all_armors['BlackArmor']
	
	elif n < armors_drop_chances['Knight']:
		armor = all_armors['Knight']
		
	if armor != null:
		armor = armor.instance()
		armor.position = self.global_position + Vector2(-80,80)
		main.call_deferred("add_child", armor)
	
	

func rand_num(from,to):
	randomize() #Pobiera ziarno dla funkcji losowych
	for i in range(from,to): #Pętla dodaje do zmiennej arr wszystkie liczby od "from" do "to"
		   arr.append(i)
	arr.shuffle() #Funkcja losuje kolejność dla elementów w zmiennej arr

func obecniPrzeciwnicy(): # sprawdza czy w pokoju są obecni przeciwnicy
	var ilosc_enemy = -1 # open jest wywoływana przed usunięciem umierającego przeciwnika ze sceny
	for i in get_children():
		if i.is_in_group("Enemy") and not i.is_in_group("Ignored"):
			ilosc_enemy += 1
	if ilosc_enemy <= 0:
		return false
	else:
		return true

func open(_body): #funkcja otwierania drzwi po pokonaniu przeciwników
	if not obecniPrzeciwnicy(): #jeżeli nie ma przeciwników
		rand.randomize()
		if rand.randf_range(0,100) <= 100: #drop broni
			weapon()
		if rand.randf_range(0,100) <= armor_drop_chance: #drop zbroi
			armor()
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
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		if not obecniPrzeciwnicy(): #jeżeli nie ma przeciwników
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
