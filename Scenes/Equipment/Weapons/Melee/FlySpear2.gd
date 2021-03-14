extends Node2D

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 100 #Zasięg ataku
var timer #Stoper
var damage
var a = 1

func _physics_process(delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.1)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FlySpear2.png")
		$AttackCollision.scale.x = 1
		$AttackCollision.scale.y = 1
		$AttackCollision.position.x = 1
		$AttackCollision.position.y = 1		
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
			$WeaponSprite.rotation_degrees=-90 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=90 #Obróć broń ostrzem do góry
func _on_Player_attacked():
	if !attack: #Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		var mouse_position = get_local_mouse_position()
		var move : float = sqrt(pow((position.x-mouse_position.x),2)+pow((position.y-mouse_position.y),2))
		var ticks = 30
		for n in ticks:
			attack_vector = Vector2((move/ticks) * cos(rotation),(move/ticks) * sin(rotation))
			position += attack_vector
			if rotation < -PI/2 or rotation > PI/2:
				$WeaponSprite.rotation_degrees = -90
			else:
				$WeaponSprite.rotation_degrees = 90
			yield(get_tree().create_timer(0.001), "timeout")
		$AttackCollision.disabled = true
		attack = false



func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body): #Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
