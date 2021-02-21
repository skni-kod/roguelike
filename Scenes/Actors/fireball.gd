# Fireball.gd
extends KinematicBody2D

const FIREBALL_SPEED = 100

onready var direction = Vector2.ZERO # kąt odchylenia toru fireballa
var player_Pos = Vector2.ZERO # pozycja playera w którego celuje
onready var origin = self.position # miejsce startowe fireballa
var dps = 15 # damage, który fireball zadaje

func _ready():
	#player_Pos = get_tree().get_root().find_node("Player", true, false).position
	direction = (player_Pos - origin).normalized() # ustawiam kąt jako znormalizowany (jednostkowy) wektor pozycji player_Pos i origin
	
	set_physics_process(true)
	
func _physics_process(delta):
	if move_and_collide(direction * delta * FIREBALL_SPEED):
		queue_free() # usuwam daną instancję fireballa jeśli natrafi na coś co jest w jego masce kolizji
	
func _on_Atak_body_entered(body):
	if body.name == "Player":
		body.take_dmg(self) # jeśli fireball natrafi na body playera to zadaje mu damage o wartości dps
		
		
