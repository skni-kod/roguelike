extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
var attack_rotation=45
export var attack_range = 5
var timer #Cooldown pomiędzy atakami
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var passiveAbilityDamageMultiplier=0.35 #Pasywna umiejętność, dodatkowe obrażenia w procentach
var passiveAbilityStacks=0 #Obecny stopień umiejętności
var passiveAbilityMaxStacks=20 #Maksymalny stopień umiejętności
var abilityDamage=0 #Temporary variable: Holds additional damaga inflicted by ability
var abilityManaCost=25
var weaponKnockback
var spell = 0
var weaponName = 'katana'
var isWeaponReady=1 #Sprawdź czy broń jest gotowa do ataku
var smoothing = 1

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var attack_speed=0 #Animacja ataku
var swing_to = 0.1
var paused = 0.15
var swing_back = 0.3
var animation_step = 0.01
var isEnemyHit = 0


func _physics_process(_delta):
	if isWeaponReady==1: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/katana.png")
		#Ustaw wartość kolizji dla broni
		$AttackCollision.scale.x = 2.6
		$AttackCollision.scale.y = 0.4
		$AttackCollision.position.x = 15
		$AttackCollision.position.y = 0		
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
			$WeaponSprite.scale.x = 0.6
			$WeaponSprite.scale.y = -0.6
			$WeaponSprite.rotation_degrees=45
		else:
			$WeaponSprite.scale.x = 0.6
			$WeaponSprite.scale.y = 0.6
			$WeaponSprite.rotation_degrees=-45

	if Input.is_action_just_pressed("use_ability_1"):
		#Really powerful blow - 40 bonus damage
		if player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.start_skill_cooldown(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				abilityDamage=12
				_on_Player_attacked()
				spell = 0
				
	if Input.is_action_just_pressed("use_ability_2"):
		if player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.start_skill_cooldown(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				abilityDamage=45
				_on_Player_attacked()
				spell = 0
func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281

func _on_Player_attacked():
	if !attack and attack_speed==0:
		attack = true
		isWeaponReady=0
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))	
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	attack_speed+=animation_step
	if attack_speed<swing_to:		
		position += attack_vector*(animation_step/swing_to)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90*(animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90*(animation_step/swing_to)
	elif attack_speed<paused:
		pass
	elif attack_speed<swing_back:
		position-=attack_vector*(animation_step/swing_back)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees -= -90*(animation_step/swing_back)
		else:
			$WeaponSprite.rotation_degrees -= 90*(animation_step/swing_back)
	else:
		$WeaponSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		attack_speed=0
		if isEnemyHit == 1:#passive ability revelant shit
			passiveAbilityStacks+=1
		else:
			passiveAbilityStacks=0#Reset marksman stack on miss
		if passiveAbilityStacks<0:#Clamp value
			passiveAbilityStacks=0
		if passiveAbilityStacks>passiveAbilityMaxStacks:
			passiveAbilityStacks=passiveAbilityMaxStacks
		timer.stop()
		isEnemyHit=0 
		reset_pivot()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):
	if body.is_in_group("Enemy"):
		isEnemyHit=1	
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage*(1+(float(passiveAbilityStacks)/passiveAbilityMaxStacks*passiveAbilityDamageMultiplier))+abilityDamage, weaponKnockback)	
		if crit:
			damage /= crit_damage
		abilityDamage=0 #Reset ability damage
		
