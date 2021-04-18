extends Node2D

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage
var weaponKnockback
var a = 1

var smoothing = 1

var attack_speed = 0
var swing_to = 0.2
var swing_back = 0.3
var animation_step = 0.02

func _physics_process(delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(animation_step)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/blade.png")
		$AttackCollision.scale.x = 1.5
		$AttackCollision.scale.y = 0.3
		$AttackCollision.position.x = 10
		$AttackCollision.position.y = 0
		a = 0
	if !attack: #Jeżeli nie atakuje to się porusza
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * smoothing
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * smoothing
		else:
			rotation += mouse_position.angle() * smoothing
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.y = -1
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry


func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281


func _on_Player_attacked():
	if !attack:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()


func _on_Timer_timeout(): #Wykonuje się kiedy zejdzie cooldown ataku
	attack_speed += animation_step
	if attack_speed <= swing_to:
		position += attack_vector * (animation_step/swing_to)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90 * (animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90 * (animation_step/swing_to)
		
	elif attack_speed > swing_back:
		position -= attack_vector
		$WeaponSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		attack_speed = 0
		timer.stop()
		reset_pivot()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body): #Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		body.get_dmg(damage, weaponKnockback)
