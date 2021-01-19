# Fireball.gd
extends KinematicBody2D

const FIREBALL_SPEED = 10

onready var direction = Vector2.ZERO
onready var player_Pos = Vector2.ZERO
onready var origin = get_parent().position
var dps = 10
var hp = 1

func _ready():
	self.position = origin
	player_Pos = get_tree().get_root().find_node("Player", true, false).position
	direction = (player_Pos - origin).normalized()
	
	set_physics_process(true)
	
func _physics_process(delta):
	print(direction)
	move_and_collide(direction * delta * FIREBALL_SPEED)
	
func _on_Atak_body_entered(body):
	if body.name == "Player":
		body.take_dmg(self)
