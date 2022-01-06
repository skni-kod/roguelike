# Laser_Load.gd
extends KinematicBody2D

onready var origin = self.position

var emit := false setget set_is_emitting # emit przypisana jako zmienna bool, set_is_emitting wykonuje się w trakcie zmiany emit

func _ready():
	pass


func set_is_emitting(var emit):
	var emitter = emit
	if emitter:
		$Particles2D.emitting = true # jeśli emit jest prawdą, Particles2D zaczyna emitować
		#podświetlenie
		$Light2D.visible = true
		get_parent().get_node("LightOccluder2D").visible = false
	else:
		$Particles2D.emitting = false # jeśli emit jest prawdą, Particles2D zaczyna emitować
		#podświetlenie
		$Light2D.visible = false
		get_parent().get_node("LightOccluder2D").visible = true
