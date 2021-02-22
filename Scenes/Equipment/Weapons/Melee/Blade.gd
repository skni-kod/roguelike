extends Node2D

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage = 20 #dps
var a = 1

func _physics_process(delta):
	if a:
		print('a')
		timer.set_wait_time(0.25)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/blade.png")
		$AttackCollision.scale.x = 1
		$AttackCollision.scale.y = 1
		a = 0
	if !attack: #Jeżeli nie atakuje to się porusza
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
	if !attack: #Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		position += attack_vector
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees = -90
		else:
			$WeaponSprite.rotation_degrees = 90
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout(): #Wykonuje się kiedy zejdzie cooldown ataku
	position -= attack_vector
	$WeaponSprite.rotation_degrees = 0
	$AttackCollision.disabled = true
	attack = false
	timer.stop()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body): #Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
