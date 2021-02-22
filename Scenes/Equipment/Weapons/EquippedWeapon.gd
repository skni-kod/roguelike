extends Node2D

onready var timer = $Timer
onready var player_node := get_tree().get_root().find_node("Player", true, false)

func _ready():
	player_node.connect("attacked", self, "_on_Player_attacked")

func _physics_process(delta):
	pass

