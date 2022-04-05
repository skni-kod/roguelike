extends Node2D

var spell = 0
var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var smoothing = 1

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

#	Weapon Stats
var damage
var weaponKnockback
var attack_speed
var weaponName = "Knife"
var isWeaponReady = true
# 	============

#	Ability 1
var ability1ManaNeeded = 0
var ability1Cooldown = 0
var ability1Multiplier = 1.5
#	=========

#	Ability 2
var ability2ManaNeeded = 0
var ability2Cooldown = 0
var ability2Duration = 5
#	=========


func _ready():
	damage = float(Weapons.ALL_WEAPONS_STATS.Knife["attack"])
	weaponKnockback = float(Weapons.ALL_WEAPONS_STATS.Knife["knc"])
	attack_speed = float(Weapons.ALL_WEAPONS_STATS.Knife["spd"])


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and Bufor.PLAYER and !Bufor.PLAYER.dying:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")


func _unhandled_input(_event):
	if Bufor.PLAYER and !Bufor.PLAYER.dying and isWeaponReady:
		if Input.is_action_just_pressed("use_ability_1"):
			if Bufor.PLAYER.mana >= ability1ManaNeeded:
				if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
					Bufor.PLAYER.start_skill_cooldown(1, ability1Cooldown, ability1ManaNeeded) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
					isWeaponReady = false
					var tmpDmg = damage
					damage *= ability1Multiplier
					$AnimationPlayer.play("MultiStab")
					yield($AnimationPlayer, "animation_finished")
					$AnimationPlayer.play("RESET")
					damage = tmpDmg
					isWeaponReady = true
					
		if Input.is_action_just_pressed("use_ability_2"):
			if Bufor.PLAYER.mana >= ability2ManaNeeded:
				if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
					Bufor.PLAYER.start_skill_cooldown(2, ability2Cooldown, ability2ManaNeeded) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
					isWeaponReady = false
					Bufor.PLAYER.set_collision_layer(0)
					Bufor.PLAYER.modulate = Color( 1, 1, 1, 0.25 )
					yield(get_tree().create_timer(ability2Duration), "timeout")
					Bufor.PLAYER.set_collision_layer(1)
					Bufor.PLAYER.modulate = Color( 1, 1, 1, 1 )
					isWeaponReady = true
					

func _on_Player_attacked():
	if !attack and attack_speed==0:
		attack = true
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees = -90#-90
		else:
			$WeaponSprite.rotation_degrees = 90#90
		$AttackCollision.disabled = false


func _on_Knife_body_entered(body):
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


func play_swoosh() -> void:
	SoundController.play_player_swoosh1()
