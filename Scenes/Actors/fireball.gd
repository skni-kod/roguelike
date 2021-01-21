# Fireball.gd
extends KinematicBody2D

const FIREBALL_SPEED = 100

onready var direction = Vector2.ZERO
var player_Pos = Vector2.ZERO
onready var origin = self.position
var dps = 10

func _ready():
	#player_Pos = get_tree().get_root().find_node("Player", true, false).position
	direction = (player_Pos - origin).normalized()
	
	set_physics_process(true)
	
func _physics_process(delta):
	if move_and_collide(direction * delta * FIREBALL_SPEED):
		queue_free()
	
func _on_Atak_body_entered(body):
	if body.name == "Player":
		body.take_dmg(self)
	elif body.is_in_group("Weapon"):
		queue_free()
		
		
