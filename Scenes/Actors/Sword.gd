extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
export var attack_range = 15
onready var timer = $Timer

func _physics_process(delta):
	if !attack:
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * 0.1
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * 0.1
		else:
			rotation += mouse_position.angle() * 0.1
		if rotation < -PI/2 or rotation > PI/2:
			$SwordSprite.scale.y = -1
		else:
			$SwordSprite.scale.y = 1


func _on_Player_attacked(damage):
	if !attack:
		attack = true
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		position += attack_vector
		if rotation < -PI/2 or rotation > PI/2:
			$SwordSprite.rotation_degrees = -90
		else:
			$SwordSprite.rotation_degrees = 90
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	position -= attack_vector
	$SwordSprite.rotation_degrees = 0
	$AttackCollision.disabled = true
	attack = false
	timer.stop()
