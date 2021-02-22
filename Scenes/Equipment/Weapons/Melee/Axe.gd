extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
export var attack_range = 15
onready var timer
var damage = 1
var attack_speed = 0.0
var a = 1

func _physics_process(delta):
	if a:
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/axe.png")
		$AttackCollision.scale.x = 1
		$AttackCollision.scale.y = 1
		a = 0
	if !attack:
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * 0.1
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * 0.1
		else:
			rotation += mouse_position.angle() * 0.1
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.y = -1
		else:
			$WeaponSprite.scale.y = 1

func _on_Player_attacked():
	if !attack:
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()

func _on_Timer_timeout():
	attack_speed += 0.01
	if attack_speed <= 0.15:
		position += attack_vector * (0.01/0.15)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90 * (0.01/0.15)
		else:
			$WeaponSprite.rotation_degrees += 90 * (0.01/0.15)
		
	elif attack_speed > 0.3:
		position -= attack_vector
		$WeaponSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		attack_speed = 0
		timer.stop()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
