extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)
var spell = 0
var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage
var weaponKnockback
var a = 1
var skill = 0
var skill1 = 1
var skill2 = 1
var smoothing = 1
var weaponName = 'knife'

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var attack_speed = 0
var swing_to = 0.05
var swing_back = 0.1
var animation_step = 0.02

func _physics_process(_delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(animation_step)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/knife.png")
		$AttackCollision.scale.x = 0.75
		$AttackCollision.scale.y = 0.25
		$AttackCollision.position.x = 12
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
			$WeaponSprite.scale.x = 1
			$WeaponSprite.scale.y = -1
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.x = 1
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry


	if Input.is_action_just_pressed("use_ability_1"):
		if skill1 and skill2 and !skill and player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				skill = 1
				skill1 = 0
				player_node.mana -= 25
				for i in range(0,5):
					
					if !attack and attack_speed==0:
						attack = true
					if i%2 == 0:rotation += .2
					else:rotation -= .2*2
					attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
					if rotation < -PI/2 or rotation > PI/2:
						$WeaponSprite.rotation_degrees = -90#-90
					else:
						$WeaponSprite.rotation_degrees = 90#90
					$AttackCollision.disabled = false
					yield(get_tree().create_timer(.1), "timeout")
					timer.start()
				skill = 0
				yield(get_tree().create_timer(10),'timeout')
				skill1 = 1
				spell = 0
	if Input.is_action_just_pressed("use_ability_2"):
		if skill1 and skill2 and !skill and player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				skill2 = 0
				damage += 20
				player_node.speed += 20
				yield(get_tree().create_timer(10), "timeout")
				damage -= 20
				yield(get_tree().create_timer(30),'timeout')
				spell = 0
				skill2 = 1
func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
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

func _on_Timer_timeout(): #Wykonuje się kiedy zejdzie cooldown ataku
	attack_speed+=animation_step
	if attack_speed<swing_to:
		position += attack_vector*(animation_step/swing_to)
	elif attack_speed<swing_back:
		position -= attack_vector*(animation_step/swing_back)
	else:
		$AttackCollision.disabled = true
		if !skill:
			attack = false
		attack_speed=0		
		timer.stop()
		reset_pivot()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body): #Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if crit:
			damage /= crit_damage
