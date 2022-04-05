extends Particles2D


const GRAV_CONST = 10


func _physics_process(_delta: float) -> void:
	if Bufor.PLAYER != null:
		process_material.gravity = Vector3(GRAV_CONST * global_position.direction_to(Bufor.PLAYER.global_position).x, GRAV_CONST *  global_position.direction_to(Bufor.PLAYER.global_position).y, 0) 
