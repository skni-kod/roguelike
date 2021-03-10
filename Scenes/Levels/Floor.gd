extends TileMap

var arr = []
var names = []
var j = 0

func _ready():
	var weapon
	var weapons
	var tiles = get_used_cells_by_id(0)
	var file = File.new()
	file.open("res://Jsons/ItemStats.json", file.READ)
	var text = file.get_as_text()
	weapons = JSON.parse(text).result
	file.close()
	weapons = weapons["Weapons"]
	for i in weapons:
		names.append(i)
	rand_num(0,len(names))

	for i in tiles:
		weapon = load("res://Scenes/Loot/Weapon.tscn")
		weapon = weapon.instance()
		weapon.WeaponName = names[arr[j]]
		j+=1
		weapon.position = Vector2(i.x*16+8,i.y*16+8)
		add_child(weapon)

func rand_num(from,to):
	randomize()
	for i in range(from,to):
		   arr.append(i)
	arr.shuffle()
