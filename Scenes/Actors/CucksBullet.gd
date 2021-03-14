extends KinematicBody2D

var move = Vector2.ZERO
var look_vec = Vector2.ZERO #kierunek pocisku
var player = null 
var speed = 3 #predkosc pocisku
var dps = 20 #zadawany damage przez pocisk

func _ready():
	look_vec = player.position - global_position #kierunek wektora
	
func _physics_process(delta):
	move = Vector2.ZERO
	
	move = move.move_toward(look_vec,delta) #Zmiana położenia o wektor look_vec w czasie delta.
	move = move.normalized() * speed #Wyrównanie długości wektora nie zależnie od kierunku, ale lepiej sobie zobaczyć na necie
	position += move	


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"): 
		body.take_dmg(self) #jezeli pocisk trafi w playera to zadaje dmg o wartosci dps
	queue_free()
