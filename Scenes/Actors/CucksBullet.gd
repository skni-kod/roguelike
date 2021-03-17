extends KinematicBody2D

onready var statusEffect = get_node("../UI/StatusBar")

var move = Vector2.ZERO
var look_vec = Vector2.ZERO
var player = null
var speed = 3
var dps = 15

func _ready():
	look_vec = player.position - global_position #kierunek wektora
	
func _physics_process(delta):
	move = Vector2.ZERO
	
	move = move.move_toward(look_vec,delta) #Zmiana położenia o wektor look_vec w czasie delta.
	move = move.normalized() * speed #Wyrównanie długości wektora nie zależnie od kierunku, ale lepiej sobie zobaczyć na necie
	position += move	


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		statusEffect.freezing = true
		body.take_dmg(dps)
	queue_free()
