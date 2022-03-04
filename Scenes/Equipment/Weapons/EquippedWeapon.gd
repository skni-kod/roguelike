extends Node2D

#Inicjuje działanie broni posiadanej przez playera na stacie poziomu (potem jest bezużyteczny)
onready var timer = $Timer
onready var player_node := get_tree().get_root().find_node("Player", true, false)


func _ready():
	var _c = player_node.connect("attacked", self, "_on_Player_attacked")

func _physics_process(_delta):
	pass

