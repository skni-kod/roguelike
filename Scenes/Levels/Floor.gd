extends TileMap

var arr = [] #Pusta tablica dla losowych liczb
var names = [] #Pusta tablica dla nazw broni
var j = 0 #Zmienna przechowująca indeks dla zmiennej arr

func _ready():
	var weapon #Zmienna przechowująca scenę broni
	var weapons #Zmienna przechowująca bronie pobrane z pliku .json
	var tiles = get_used_cells_by_id(0) #Pobiera wszystkie kafelki o id 0 użyte na mapie
	var file = File.new() #Tworzy zmienną plik
	file.open("res://Jsons/ItemStats.json", file.READ) #Otwiera plik i go wczytuje
	var text = {
	"Weapons": {
		"Blade": {
			"attack": "7.5",
			"spd": "1",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Axe": {
			"attack": "10",
			"spd": "0.5",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Katana": {
			"attack": "25",
			"spd": "0.4",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Knife": {
			"attack": "3",
			"spd": "1.5",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Hammer": {
			"attack": "30",
			"spd": "0.3",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Spear": {
			"attack": "15",
			"spd": "0.75",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		},
		"Fire Scepter": {
			"attack": "10",
			"spd": "1",
			"knc": "0",
			"range": "magic",
			"effect": "none"
		},
		 "BloodSword": {
			"attack": "20",
			"spd": "0.6",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		}
		,
		 "FMS": {
			"attack": "22",
			"spd": "0.5",
			"knc": "0",
			"range": "melee",
			"effect": "none"
		}
		
	}
}
	weapons = JSON.parse(text).result #Dane typu json trzeba sparsować na typ właściwy dla języka
	file.close() #Zamknięcie połączenia pliku
	weapons = weapons["Weapons"] #Przypisanie wszystkich broni do zmiennej
	for i in weapons: #Pętla przypisująca nazwy do zmiennej
		names.append(i)
	rand_num(0,len(names)) #Wywołanie funkcji rand_num()

	for i in tiles:
		weapon = load("res://Scenes/Loot/Weapon.tscn") #Ładuje scenę broni do zmiennej 
		weapon = weapon.instance()
		weapon.WeaponName = names[arr[j]] #Przypisuje nazwę broni dla losowego indeksu zmiennej names 
		j+=1
		weapon.position = Vector2(i.x*16+50,i.y*16+8) #Przypisuje pozycję broni
		add_child(weapon) #Tworzy broń na podłodze

func rand_num(from,to):
	randomize() #Pobiera ziarno dla funkcji losowych
	for i in range(from,to): #Pętla dodaje do zmiennej arr wszystkie liczby od "from" do "to"
		   arr.append(i)
	arr.shuffle() #Funkcja losuje kolejność dla elementów w zmiennej arr
