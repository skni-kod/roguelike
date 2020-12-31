extends Node2D

var mouse_position

func _physics_process(delta):
	mouse_position = get_local_mouse_position()
	if rotation < -PI:
		rotation = PI + mouse_position.angle()
	elif rotation > PI:
		rotation = -PI + mouse_position.angle()
	else:
		rotation += mouse_position.angle()
	print(rotation)
