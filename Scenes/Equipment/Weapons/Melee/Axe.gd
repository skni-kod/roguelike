extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)
var StatusBar_node = get_tree().get_root().find_node("StatusBar", true, false)
var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage
var weaponKnockback
var a = 1
var weaponName = "axe"
var smoothing = 1
var spell = 0

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var attack_speed = 0
var swing_to = 0.2
var swing_back = 0.4
var animation_step = 0.01

#do um1
var active_ability1 = false
var active_ability2 = false
var ability1rotation = 530
var ability1range = 10
var tmpdmg
var tmpknockback
var ability1damagemultipler = 10

#do um2
var ability2healamount = 50
var tmpspeed
var tmpattack_speed
var speedmultipler = 1.5
var dmgmultipler = 2
var attack_speedmultipler = 2
var ability2duration = 5


func _physics_process(delta):
	if a:#Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/axe.png")
		$AttackCollision.scale.x = 0.8
		$AttackCollision.scale.y = 0.5
		$AttackCollision.position.x = 14
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
		if active_ability1==false and active_ability2==false and player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				attack = true
				active_ability1 = true
				$AttackCollision.disabled = false
				attack_vector = Vector2(attack_range *ability1range* cos(rotation), attack_range *ability1range* sin(rotation))
				tmpdmg = damage
				damage *= ability1damagemultipler
				tmpknockback = weaponKnockback
				weaponKnockback = 0
				timer.start()
				spell = 0
		
		
	if Input.is_action_just_pressed("use_ability_2"):
		if active_ability1==false and active_ability2==false and player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()):
				player_node.on_skill_used(2,50)
				spell = 1
				StatusBar_node.immune = true
				tmpspeed = player_node.speed
				player_node.speed *= speedmultipler
				tmpdmg = damage
				damage *= dmgmultipler
				tmpattack_speed = attack_speed
				attack_speed *= attack_speedmultipler
				
				var t = Timer.new()   			
				t.set_wait_time(ability2duration)
				t.set_one_shot(true)			
				self.add_child(t)				
				t.start()						
				yield(t, "timeout")
				t.queue_free()
				
				player_node.speed = tmpspeed
				damage = tmpdmg
				attack_speed = tmpattack_speed
				StatusBar_node.immune = false
				spell = 0
		
func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
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
			if active_ability1 == true:
				$WeaponSprite.rotation_degrees += -ability1rotation * (animation_step/swing_to)
			else:
				$WeaponSprite.rotation_degrees += -90 * (animation_step/swing_to)
		else:
			if active_ability1 == true:
				$WeaponSprite.rotation_degrees += ability1rotation * (animation_step/swing_to)
			else:
				$WeaponSprite.rotation_degrees += 90 * (animation_step/swing_to)
		
	elif attack_speed > swing_back:
		position -= attack_vector
		$WeaponSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		if active_ability1 == true:
			damage = tmpdmg
			weaponKnockback = tmpknockback
		active_ability1 = false
		attack_speed = 0
		timer.stop()
		reset_pivot()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):#Zadaje obrażenia przy kolizji z przeciwnikiem
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
