extends KinematicBody2D

var move = Vector2.ZERO
var look_vec = Vector2.ZERO #kierunek pocisku
var speed = 1 #predkosc pocisku
var dps = 5 #zadawany damage przez pocisk
onready var statusEffect = get_node("../UI/StatusBar")

# === KNOCKBACK === #
var projectileKnockback = 0.1
# === ========= === #

func _ready():
	look_vec = Bufor.PLAYER.global_position - global_position #kierunek wektora
	
func _physics_process(delta):
	move = Vector2.ZERO
	self.rotation += PI/6
	move = move.move_toward(look_vec,delta) #Zmiana położenia o wektor look_vec w czasie delta.
	move = move.normalized() * speed #Wyrównanie długości wektora nie zależnie od kierunku, ale lepiej sobie zobaczyć na necie
	position += move	


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"): 
		body.take_dmg(dps, projectileKnockback, self.global_position) #jezeli pocisk trafi w playera to zadaje dmg o wartosci dps
		statusEffect.freezing = true
	queue_free()
