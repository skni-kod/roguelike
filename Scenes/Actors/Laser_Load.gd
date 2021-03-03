# Laser_Load.gd
extends KinematicBody2D
# UWAGA WORK IN PROGRESS
# NIE DZIAŁA TAK JAK POWINNO
# UWAGA WORK IN PROGRESS

onready var origin = self.position
var dps = 0

func _ready():
	set_physics_process(true)
	$Lifetime.start()
	
func _on_Lifetime_timeout():
	print("Loaded")
	queue_free()
	
	
