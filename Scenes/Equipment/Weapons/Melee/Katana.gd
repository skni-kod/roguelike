extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
var attack_rotation=45
export var attack_range = 5
var timer #Cooldown pomiędzy atakami
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var isWeaponReady=1 #Sprawdź czy broń jest gotowa do ataku


func _physics_process(delta):
	if isWeaponReady==1: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.2)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/Katana.png")
		#Ustaw wartość kolizji dla broni
		$AttackCollision.scale.x = 1.7
		$AttackCollision.scale.y = 0.2
		$AttackCollision.position.x = 15
		$AttackCollision.position.y = 0
		isWeaponReady = 0
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
			$WeaponSprite.rotation_degrees=-90 #Obróć broń przodem do przeciwnika			
		else:
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=90 #Obróć broń przodem do przeciwnika		

func _on_Player_attacked():
	if !attack:
		attack = true
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		position+=attack_vector
		if rotation < -PI/2 or rotation > PI/2:			
			if rotation_degrees < -120 or rotation_degrees > 0 :
				rotation_degrees -= attack_rotation
		else:
			if rotation_degrees > -60:
				rotation_degrees += attack_rotation			
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	position -= attack_vector
	$AttackCollision.disabled = true
	attack = false
	timer.stop()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
