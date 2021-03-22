extends Node

onready var tilemap = get_node("../TileMap")
var rand = RandomNumberGenerator.new()
var all_enemies = {
		0 : preload("res://Scenes/Actors/Big Devil.tscn"),
		1 : preload("res://Scenes/Actors/cuck.tscn"),
		2 : preload("res://Scenes/Actors/cuckshooter.tscn"),
		3 : preload("res://Scenes/Actors/goblin_shaman.tscn"),
		4 : preload("res://Scenes/Actors/Lil Devil.tscn"),
		5 : preload("res://Scenes/Actors/Little_Goblin.tscn"),
		6 : preload("res://Scenes/Actors/Potato.tscn"),
		7 : preload("res://Scenes/Actors/Slime.tscn"),
		8 : preload("res://Scenes/Actors/Snot.tscn")
	}
var bossScene = load("res://Scenes/Actors/MageBoss/MageBoss.tscn")
var id_list = []
var current_id
var down = Vector2(7,8)
var up = Vector2(7,0)
var right = Vector2(14,4)
var left = Vector2(0,4)
var drzwi = [true,true,true,true]
var ilosc_enemy
var boss = false
onready var generation = get_node("../../../Main")

func _ready():
	generation.connect("boss", self, "check_boss")

func check_boss(room):
	if room.x == int(round(self.global_position.x/512)) and room.y == int(round(self.global_position.y/288)):
		boss = true

func close_door():
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

func _on_Node2D_body_entered(body):
	if body.name == "Player":
		ilosc_enemy = 5
		if tilemap.get_cellv(left) == 1:
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
		print(drzwi)
		current_id = get_instance_id()
		if not current_id in id_list and not boss:
			for i in range(0,5):
				rand.randomize()
#				var enemy = all_enemies[rand.randi_range(0,8)].instance()
				var enemy = all_enemies[4].instance()
				rand.randomize()
				enemy.position.x = rand.randf_range(-180,180)
				rand.randomize()
				enemy.position.y = rand.randf_range(-80,80)
				add_child(enemy)
				print(enemy.get_tree())
				enemy.connect("died", self, "open")
		elif boss:
			ilosc_enemy = 1
			var bossIns = bossScene.instance()
			add_child(bossIns)
			bossIns.connect("died", self, "open")
			close_door()
		id_list.append(current_id)
	if body.is_in_group("Enemy"):
		close_door()
	
func open(body):
	print(body)
	if body.health <= 0:
		ilosc_enemy -= 1
	if ilosc_enemy == 0:
		if drzwi[3]:
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
	print(ilosc_enemy)
