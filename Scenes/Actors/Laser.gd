# Fireball.gd
extends KinematicBody2D
# UWAGA WORK IN PROGRESS
# NIE DZIAŁA TAK JAK POWINNO
# UWAGA WORK IN PROGRESS
const FIREBALL_SPEED = 100

onready var direction = Vector2.ZERO
var player_Pos = Vector2.ZERO
onready var origin = self.position
var dps = 50

func _ready():
	#player_Pos = get_tree().get_root().find_node("Player", true, false).position
	rotation = (player_Pos - origin).normalized().angle()
	
	set_physics_process(true)
	
	
func _on_Atak_body_entered(body):
	if body.name == "Player":
		body.take_dmg(self)
		
		
func _on_Lifetime_timeout():
	pass
	
