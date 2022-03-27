extends Node2D

onready var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
var attack_rotation=45
export var attack_range = 5
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
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("attack") and isWeaponReady:
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("RESET")
	
	if Input.is_action_just_pressed("use_ability_1") and isWeaponReady:
		#Really powerful blow - 40 bonus damage
		if player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.start_skill_cooldown(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				abilityDamage=12
				_on_Player_attacked()
				spell = 0
				
	if Input.is_action_just_pressed("use_ability_2") and isWeaponReady:
		if player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.start_skill_cooldown(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				abilityDamage=45
				_on_Player_attacked()
				spell = 0


func _on_Player_attacked():
	if !attack and attack_speed==0:
		attack = true
		isWeaponReady=0
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))	
		$AttackCollision.disabled = false


func _on_Katana_body_entered(body):
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
		


	
