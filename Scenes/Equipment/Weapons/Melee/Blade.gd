extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)
var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage
var weaponKnockback
var a = 1
var weaponName = "Blade"
var smoothing = 1

var attack_speed = 0
var swing_to = 0.2
var swing_back = 0.3
var animation_step = 0.02

var active_ability2 = 0
var active_ability1 = 0
#zmienne do wirka miecza
var wirek_range = 25
var wirek_smoothing = 0.01
var wirek_speed = 0.3
var wirek_time = 100

#zmienne do um2
var hits_amount = 3
var hits_speed = 0.05

func _physics_process(delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(animation_step)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/blade.png")
		$AttackCollision.scale.x = 2.2
		$AttackCollision.scale.y = 0.4
		$AttackCollision.position.x = 10
		$AttackCollision.position.y = 0
		a = 0
	if !attack: #Jeżeli nie atakuje to się porusza
		if active_ability1!=1:
			mouse_position = get_local_mouse_position()
			if rotation < -PI:
				rotation = PI + mouse_position.angle() * smoothing
			elif rotation > PI:
				rotation = -PI + mouse_position.angle() * smoothing
			else:
				rotation += mouse_position.angle() * smoothing
			if rotation < -PI/2 or rotation > PI/2:
				$WeaponSprite.scale.x = 1.2
				$WeaponSprite.scale.y = -1.2
				$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
			else:
				$WeaponSprite.scale.x = 1.2
				$WeaponSprite.scale.y = 1.2
				$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry

	
	
	if Input.is_action_just_pressed("use_ability_1"):
		if active_ability1!=1 and active_ability2!=1 and player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				active_ability1 = 1;
				$WeaponSprite/WirMiecza.emitting = true
				$AttackCollision.disabled = false
				$WeaponSprite.position.x=wirek_range
				for o in range(wirek_time):
													#----------------------
					var t = Timer.new()   			# Timer do wirka
					t.set_wait_time(wirek_smoothing)#
					t.set_one_shot(true)			#
					self.add_child(t)				#
					t.start()						#
					yield(t, "timeout")				#
													#----------------------
					rotation += wirek_speed
					
					if rotation < -PI/2 or rotation > PI/2:
						$WeaponSprite.scale.x = 1.2
						$WeaponSprite.scale.y = -1.2
						$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
					else:
						$WeaponSprite.scale.x = 1.2
						$WeaponSprite.scale.y = 1.2
						$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
			
			
			$WeaponSprite/WirMiecza.emitting = false
			$WeaponSprite.position.x=13
			$WeaponSprite.position.y=0
			$AttackCollision.disabled = true
			active_ability1 = 0;
			
	if Input.is_action_just_pressed("use_ability_2"):
		if active_ability1!=1 and active_ability2!=1 and player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				active_ability2 = 1;
				swing_to = hits_speed
				swing_back = hits_speed
				animation_step = 0.01
				timer.set_wait_time(animation_step)
				
				
				for o in range(hits_amount):
					_on_Player_attacked()
					var t = Timer.new() 
					t.set_wait_time(0.25)
					t.set_one_shot(true)
					self.add_child(t)
					t.start()
					yield(t, "timeout")	
					
				
				swing_to = 0.2
				swing_back = 0.3
				animation_step = 0.02
				timer.set_wait_time(animation_step)
				active_ability2 = 0;
		


func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281


func _on_Player_attacked():
	if !attack and active_ability1!=1:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()


func _on_Timer_timeout(): #Wykonuje się kiedy zejdzie cooldown ataku
	attack_speed += animation_step
	if attack_speed <= swing_to:
		if active_ability2 == 1: $WeaponSprite/TrzystronneCiecie.emitting = true
		position += attack_vector * (animation_step/swing_to)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90 * (animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90 * (animation_step/swing_to)
		
	elif attack_speed > swing_back:
		if active_ability2 == 1: $WeaponSprite/TrzystronneCiecie.emitting = false
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
