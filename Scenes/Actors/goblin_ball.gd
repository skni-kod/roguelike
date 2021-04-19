extends KinematicBody2D

onready var statusEffect = get_node("../UI/StatusBar")
onready var direction = Vector2.ZERO # kąt odchylenia toru pocisku

var player_Pos = Vector2.ZERO # pozycja gracza w którego celuje
onready var origin = self.position  # miejsce startowe pocisku

var dps = 20 # damage, który pocisk zadaje
const goblin_ball_speed = 80 #prędkość pocisku

var projectileKnockback = 0.1

func _ready():
	direction = (player_Pos - origin).normalized() # ustawiam kąt jako znormalizowany wektor pozycji gracza i strzelca
	
func _physics_process(delta):
	if move_and_collide(direction * delta * goblin_ball_speed):
		queue_free() # usuwam daną instancję pocisk jeśli natrafi na coś co jest w jego masce kolizji
	
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		statusEffect.poison = true
		body.take_dmg(dps, projectileKnockback, self.global_position)		# jeśli pocisk natrafi na body playera to zadaje mu damage o wartości dps
