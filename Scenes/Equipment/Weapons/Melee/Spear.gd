extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
export var attack_range = 15
var timer #Cooldown pomiędzy atakami
onready var player_node := get_tree().get_root().find_node("Player", true, false)
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var isWeaponLoaded=0 #

func _physics_process(delta):
	if isWeaponLoaded==0: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.2)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/spear.png")
		$AttackCollision.scale.x = 1
		$AttackCollision.scale.y = 1
		isWeaponLoaded = 1
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
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		position += attack_vector
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees = -90
		else:
			$WeaponSprite.rotation_degrees = 90
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	position -= attack_vector
	$WeaponSprite.rotation_degrees = 0
	$AttackCollision.disabled = true
	attack = false
	timer.stop()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_Axe_body_entered(body):
	print('d')
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
