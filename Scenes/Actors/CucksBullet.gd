extends KinematicBody2D

var move = Vector2.ZERO
var look_vec = Vector2.ZERO
var player = null
var speed = 3
var dps = 20

func _ready():
	look_vec = player.position - global_position
	
func _physics_process(delta):
	move = Vector2.ZERO
	
	move = move.move_toward(look_vec,delta)
	move = move.normalized() * speed
	position += move	


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.take_dmg(self)
	queue_free()
