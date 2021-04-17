extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
var attack_rotation=45
export var attack_range = 5
var timer #Cooldown pomiędzy atakami
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var isWeaponReady=1 #Sprawdź czy broń jest gotowa do ataku

var smoothing = 1

var attack_speed=0 #Animacja ataku
var swing_to = 0.1
var paused = 0.15
var swing_back = 0.3
var animation_step = 0.01

func _physics_process(delta):
	if isWeaponReady==1: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/katana.png")
		#Ustaw wartość kolizji dla broni
		$AttackCollision.scale.x = 1.7
		$AttackCollision.scale.y = 0.2
		$AttackCollision.position.x = 15
		$AttackCollision.position.y = 0		
		isWeaponReady = 0
	if !attack:
		mouse_position = get_local_mouse_position()
		
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * smoothing
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * smoothing
		else:
			rotation += mouse_position.angle() * smoothing
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.y = -1
			$WeaponSprite.rotation_degrees=0
		else:
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=0


	if Input.is_action_just_pressed("use_ability_1"):
		var placeholder5 #kilkanie przycisku działa abilitki trza zrobić
	if Input.is_action_just_pressed("use_ability_2"):
		var palceholder20
		
	
func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281

func _on_Player_attacked():
	if !attack and attack_speed==0:
		attack = true
		isWeaponReady=0
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))	
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	attack_speed+=animation_step
	if attack_speed<swing_to:		
		position += attack_vector*(animation_step/swing_to)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90*(animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90*(animation_step/swing_to)
	elif attack_speed<paused:
		pass
	elif attack_speed<swing_back:
		position-=attack_vector*(animation_step/swing_back)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees -= -90*(animation_step/swing_back)
		else:
			$WeaponSprite.rotation_degrees -= 90*(animation_step/swing_back)
	else:
		$WeaponSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		attack_speed=0
		timer.stop()
		reset_pivot()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
