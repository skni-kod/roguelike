extends Area2D

var move = Vector2.ZERO
var look_vec = Vector2.ZERO
var player = null
var speed = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	look_vec = player.position - global_position
	
func _physics_process(delta):
	move = Vector2.ZERO
	
	move = move.move_toward(look_vec,delta)
	move = move.normalized() * speed
	position += move	



