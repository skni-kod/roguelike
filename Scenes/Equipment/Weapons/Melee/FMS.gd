extends Node2D

const M = preload("Moon_particles.tscn") #pobieramy particle do umiejek
var main = get_tree().get_root().find_node("Main", true, false) # odwołanie do node Main, potrzebne do particli

var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var ability1ManaCost=1 #koszt do zmiany w balansie
var ability2ManaCost=1 #koszt do zmiany w balansie
var damage
var weaponKnockback
var a = 1
var weaponName = "FMS"
var smoothing = 1

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var attack_speed = 0
var swing_to = 0.2
var swing_back = 0.8
var animation_step = 0.02
var ability = 0

var mc = 0
var ph = 0
var basedmg
var basespd

func _physics_process(delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(animation_step)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS0.png")
		$AttackCollision.scale.x = 1.8
		$AttackCollision.scale.y = 0.3
		$AttackCollision.position.x = 13
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
			$WeaponSprite.scale.x = 1.0
			$WeaponSprite.scale.y = -1.0
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.x = 1.0
			$WeaponSprite.scale.y = 1.0
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry

	if Input.is_action_just_pressed("use_ability_1"):
		if player_node.mana>=ability1ManaCost and !ability:
			player_node.updateMana(-ability1ManaCost)
			ability1()
		else:
			print("Insufficient mana, " + String(ability1ManaCost) +" required to cast ability")
	
	if Input.is_action_just_pressed("use_ability_2"):
		if player_node.mana>=ability2ManaCost and !ability:
			player_node.updateMana(-ability2ManaCost)
			ability2()
		else:
			print("Insufficient mana, " + String(ability2ManaCost) +" required to cast ability")


	if mc == 20:
		ph+=1
		mc = 0
		if ph == 6: ph=0
		match ph:
			0:
				$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS0.png")
			1:
				$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS1.png")
				basedmg = damage
				damage = damage*1.2
			2:
				$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS2.png")
				damage = basedmg*1.4
			3:
				$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS3.png")
				damage = basedmg*1.6
			4:
				$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS4.png")
				damage = basedmg*1.8
			5:
				$WeaponSprite.texture = load("res://Assets/Loot/Weapons/FMS5.png")
				damage = basedmg*2


	if Input.is_action_just_pressed("use_ability_1"):
		var placeholder5 #kilkanie przycisku działa abilitki trza zrobić
	if Input.is_action_just_pressed("use_ability_2"):
		var palceholder20
		
	

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
		mc+=1
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if crit:
			damage /= crit_damage

func ability1(): # "Thirst" na krótki czas zwiększa prędkośc ataku i lifesteal
		if player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				basespd = player_node.speed
				player_node.speed += 100
				yield(get_tree().create_timer(10), "timeout")
				player_node.speed = basespd
func ability2(): # "Gluttony" seria 4 ataków, każdy zadaje większe obrażenia na większej powierzchni, kosztuje życie
	if !ability and player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(2,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				ability = 1
				$AttackCollision.disabled = false
				var Beam = M.instance() #towrzymy jedną instancję animacji krwi
				Beam.position = (get_tree().get_root().find_node("Player", true, false).global_position + Vector2(0,-70)) #ustawiamy jej pozycję jako pozycja gracza + wektor kierunku broni
				main.add_child(Beam) #dodajemy krew do sceny
				Beam.scale = 2*Beam.scale  #dostosowujemy wielkość krwi, używamy iteracji by była ona takiej samej wielkości co hitboxy
				$AttackCollision.scale.x = 6
				$AttackCollision.scale.y = 3
				$AttackCollision.position.x = 0
				$AttackCollision.position.y = -1
				damage = damage*3
				weaponKnockback = weaponKnockback*3
				basespd = player_node.speed
				player_node.speed -= player_node.speed
				player_node.knockbackResistance = 10
				player_node.immortal = 1
				yield(get_tree().create_timer(10), "timeout") #czas pomiędzy atakami
				Beam.queue_free()
				$AttackCollision.scale.x = 1.8
				$AttackCollision.scale.y = 0.3
				$AttackCollision.position.x = 13
				$AttackCollision.position.y = 0
				damage = damage/3
				weaponKnockback = weaponKnockback/3
				player_node.speed = basespd
				player_node.knockbackResistance = 1
				player_node.immortal = 0
				$AttackCollision.disabled = true
				ability = 0
