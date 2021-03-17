# Fireball.gd
extends KinematicBody2D

const FIREBALL_SPEED = 100
onready var statusEffect = get_node("../UI/StatusBar")

onready var direction = Vector2.ZERO # kąt odchylenia toru fireballa
var player_Pos = Vector2.ZERO # pozycja playera w którego celuje
onready var origin = self.position # miejsce startowe fireballa
var dmg = 10 # damage, który fireball zadaje

func _ready():
	direction = (player_Pos - origin).normalized() # ustawiam kąt jako znormalizowany (jednostkowy) 
												   # wektor pozycji player_Pos i origin
	
	set_physics_process(true)
	
func _physics_process(delta):
	if move_and_collide(direction * delta * FIREBALL_SPEED):
		queue_free() # usuwam daną instancję fireballa jeśli natrafi na coś co jest w jego masce kolizji
	
func _on_Atak_body_entered(body):
	if body.name == "Player":
		statusEffect.burning = true # w trakcie kolizji fireballa z playerem, ten zostaje podpalony z prawdopodobieństwem
		body.take_dmg(dmg) # jeśli fireball natrafi na body playera to zadaje mu damage o wartości dmg
    