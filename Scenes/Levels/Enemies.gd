extends Node

onready var all_weapons = get_tree().get_root().find_node("Weapons", true, false).all_weapons #Wczytanie z niewidzialnego node wszystkich broni
var level = load("res://Scenes/Levels/Level_gen.gd").new()
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
var bossScene = [load("res://Scenes/Actors/MageBoss/MageBoss.tscn"),
	load("res://Scenes/Actors/PandoBoss/PandaBoss.tscn"),
	load("res://Scenes/Actors/OctoBoss/OctoBoss.tscn")]
var id_list = [] #Lista ID pokojów, w których był już player
var current_id #ID aktualnego pokoju
var ilosc_enemy #aktualna ilosc przeciwnikow
var boss = false #czy to jest pokoj z bossem
var item
var popups = {}
onready var main := get_tree().get_root().find_node("Main", true, false)
onready var generation = get_node("../../../Main") #pobranie maina

func _ready():
	pass # Replace with function body.
	
func close_door():
	$level_node.close_door()
	
