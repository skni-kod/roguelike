# Fireball.gd
extends KinematicBody2D

const FIREBALL_SPEED = 100

var mouse_position = get_global_mouse_position() - global_position# pozycja playera w którego celuje
var dps = 20 # damage, który fireball zadaje
var velocity

func _ready():
	print(get_global_mouse_position() - global_position)
	velocity = Vector2(FIREBALL_SPEED, 0).rotated(rotation)

	
func _physics_process(delta):
	move_and_collide(velocity * delta)
	
func _on_Atak_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(dps) # jeśli fireball natrafi na body playera to zadaje mu damage o wartości dps
		queue_free()
	else:
		queue_free()
		
		
