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
var swing_to = 0.4
var paused = 0.9
var swing_back = 2
var animation_step = 0.02

#do um 1
var active_ability1 = 0
var damage_multipler = 3
var knockback_multipler = 15
var range_x = 3
var range_y = 6

func _physics_process(delta):
	if a:#Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/hammer.png")
		$AttackCollision.scale.x = 1.0
		$AttackCollision.scale.y = 0.5
		$AttackCollision.position.x = 23
		$AttackCollision.position.y = 0
		a = 0
	if !attack and active_ability1!=1: #Jeżeli nie atakuje to się porusza
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * smoothing
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * smoothing
		else:
			rotation += mouse_position.angle() * smoothing
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.x = 1.3
			$WeaponSprite.scale.y = -1.3
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.x = 1.3
			$WeaponSprite.scale.y = 1.3
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry


	if Input.is_action_just_pressed("use_ability_1"):
		active_ability1 = 1
		
		var player_node := get_tree().get_root().find_node("Player", true, false)
		var equipped_weapon := get_tree().get_root().find_node("EquippedWeapon", true, false)
		
		var tmp = {
			'position_x' : $AttackCollision.position.x,
			'position_y' : $AttackCollision.position.y,
			'scale_x' : $AttackCollision.scale.x,
			'scale_y' : $AttackCollision.scale.y,
			'damage' : equipped_weapon.damage,
			'weaponKnockback' : equipped_weapon.weaponKnockback,
		}
		player_node.jump()
		
		var t = Timer.new()
		t.set_wait_time(0.75) #recznie ustawiony wait time taki sam jak na timerze 'skok' w playerze
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		
		$AttackCollision.disabled = false
		$AttackCollision.position.x = 0
		$AttackCollision.position.y = 0
		$AttackCollision.scale.x = range_x
		$AttackCollision.scale.y = range_y
		equipped_weapon.damage *= damage_multipler
		equipped_weapon.weaponKnockback *= knockback_multipler
		
		t = Timer.new()
		t.set_wait_time(0.1) 
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
	
		$AttackCollision.disabled = true
		$AttackCollision.position.x = tmp['position_x']
		$AttackCollision.position.y = tmp['position_y']
		$AttackCollision.scale.x = tmp['scale_x']
		$AttackCollision.scale.y = tmp['scale_y']
		equipped_weapon.damage = tmp['damage']
		equipped_weapon.weaponKnockback = tmp['weaponKnockback']
		
		active_ability1 = 0
		
	if Input.is_action_just_pressed("use_ability_2"):
		var palceholder20
		
	
func reset_pivot():#Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281

func _on_Player_attacked():
	if !attack:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()

func _on_Timer_timeout():#Wykonuje się kiedy zejdzie cooldown ataku
	attack_speed += animation_step
	if attack_speed <= swing_to:
		position += attack_vector * (animation_step/swing_to)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90 * (animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90 * (animation_step/swing_to)
	elif attack_speed < paused:
		pass
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

func _on_EquippedWeapon_body_entered(body):#Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		body.get_dmg(damage, weaponKnockback)
