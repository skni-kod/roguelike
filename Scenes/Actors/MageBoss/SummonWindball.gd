extends Area2D

onready var direction = Vector2.ZERO # kąt odchylenia toru pocisku
var player_Pos = Vector2.ZERO # pozycja gracza w którego celuje
onready var origin = self.position  # miejsce startowe pocisku
var dps = 6.0 # damage, który pocisk zadaje
const ball_speed = 100 #prędkość pocisku
onready var statusEffect = get_tree().get_root().find_node("StatusBar", true, false)

var projectileKnockback = 0.1

func _ready():
	direction = (player_Pos - origin).normalized() # ustawiam kąt jako znormalizowany wektor pozycji gracza i strzelca
	
func _physics_process(delta):
	self.position += (direction * delta * ball_speed)

func _on_Windball_body_entered(body):
	if body.name == "Player":
		body.take_dmg(dps, projectileKnockback, player_Pos)		# jeśli pocisk natrafi na body playera to zadaje mu damage o wartości dps
		statusEffect.weakness = true
		queue_free() # usuw
	else:
		queue_free()
