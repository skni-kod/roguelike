extends KinematicBody2D


onready var direction = Vector2.ZERO # kąt odchylenia toru pocisku
var player_Pos = Vector2.ZERO # pozycja gracza w którego celuje
onready var origin = self.position  # miejsce startowe pocisku
var dps = 10 # damage, który pocisk zadaje
const goblin_ball_speed = 50 #prędkość pocisku

func _ready():
	direction = (player_Pos - origin).normalized() # ustawiam kąt jako znormalizowany wektor pozycji gracza i strzelca
	
func _physics_process(delta):
	if move_and_collide(direction * delta * goblin_ball_speed):
		queue_free() # usuwam daną instancję pocisk jeśli natrafi na coś co jest w jego masce kolizji
	
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.take_dmg(self)		# jeśli pocisk natrafi na body playera to zadaje mu damage o wartości dps
