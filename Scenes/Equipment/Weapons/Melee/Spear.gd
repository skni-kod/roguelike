extends Node2D

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
export var attack_range = 15
var timer #Cooldown pomiędzy atakami
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var weaponKnockback
var isWeaponReady=1 #Sprawdź czy broń jest gotowa do ataku

var smoothing = 1

var attack_speed = 0 #Zmienna służąca do animacji 
var swing_to = 0.3
var paused = 0.4
var swing_back = 0.5
var animation_step = 0.02

func _physics_process(delta):
	if isWeaponReady==1: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/spear.png")
		#Ustaw wartość kolizji dla broni
		$AttackCollision.scale.x = 1
		$AttackCollision.scale.y = 0.5
		$AttackCollision.position.x= 20
		$AttackCollision.position.y= 0	
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
			$WeaponSprite.rotation_degrees=-90 #Obróć broń przodem do przeciwnika
		else:
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=90 #Obróć broń przodem do przeciwnika
			
func reset_pivot():#Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281

func _on_Player_attacked():
	if !attack and attack_speed==0:
		attack = true
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees = -90#-90
		else:
			$WeaponSprite.rotation_degrees = 90#90
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	attack_speed+=animation_step
	if attack_speed<swing_to:
		position += attack_vector*(animation_step/swing_to)
	elif attack_speed<paused:
		pass
	elif attack_speed<swing_back:
		position -= attack_vector*(animation_step/swing_back)
	else:
		$AttackCollision.disabled = true
		attack = false
		attack_speed=0		
		timer.stop()
		reset_pivot()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage, weaponKnockback)
