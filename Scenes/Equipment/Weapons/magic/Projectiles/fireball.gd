# Fireball.gd
extends KinematicBody2D

const FIREBALL_SPEED = 100 #szybkość poruszania się fireballa

var dps = 20 # damage, który fireball zadaje
var velocity

func _ready():
	velocity = Vector2(FIREBALL_SPEED, 0).rotated(rotation) #Określa kierunek fireballa zgodnie z rotacją broni

	
func _physics_process(delta):
	move_and_collide(velocity * delta)
	
func _on_Atak_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(dps) # jeśli fireball natrafi na body playera to zadaje mu damage o wartości dps
		queue_free()
	else:
		queue_free()
		
		
