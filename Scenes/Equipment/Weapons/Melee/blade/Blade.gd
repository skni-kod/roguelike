extends Node2D

export var attacking = false setget set_attack_state, get_attack_state #Czy postać atakuje

onready var StatusBar_node = get_tree().get_root().find_node("StatusBar", true, false)

var damage
var weaponKnockback
var attack_speed

var weaponName = "Blade"
var spell = 0

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var activeAbility2 = false
var activeAbility1 = false


func _ready() -> void:
	damage = float(Weapons.all_weapons.Blade["attack"])
	weaponKnockback = float(Weapons.all_weapons.Blade["knc"])
	attack_speed = float(Weapons.all_weapons.Blade["spd"])
	$AnimationPlayer.play("RESET")


func _physics_process(_delta):
	pass


func _input(event):
	if Input.is_action_just_pressed("attack") and !activeAbility1 and !activeAbility2:
			print("[INFO]: Blade event identified as BUTTON_LEFT pressed")
			$AnimationPlayer.playback_speed = attack_speed
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")


func _unhandled_input(_event):
	if Input.is_action_just_pressed("use_ability_1"):
		if !activeAbility1 and !activeAbility2 and Bufor.PLAYER.mana>=25:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(1, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				activeAbility1 = true;
				$AnimationPlayer.play("Vortex")
				yield($AnimationPlayer, "animation_finished")
			activeAbility1 = false
			
	if Input.is_action_just_pressed("use_ability_2"):
		if !activeAbility1 and !activeAbility2 and Bufor.PLAYER.mana>=50:
			if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS2").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.start_skill_cooldown(2, 0, 0) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				activeAbility2 = true
				$AnimationPlayer.play("Chopping")
				yield($AnimationPlayer, "animation_finished")
			activeAbility2 = false


func _on_Player_attacked():
	if !attacking: #Sprawdza czy broń nie jest w trakcie ataku
		set_attack_state(true)
		$AttackCollision.disabled = false


func _on_Blade_body_entered(body) -> void:
#	print("[INFO]: Blade collided with ", body)
	if body.is_in_group("Enemy"):
		print("[INFO]: Blade hit: ", body)
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if crit:
			damage /= crit_damage


# === SWOOSH SOUND FUNCTION === #
func play_swoosh() -> void:
	SoundController.play_player_swoosh1()
# === ===================== === #


# === SET/GET FOR THE ATTACK STATE === #
# setter is called at the animations
func set_attack_state(value: bool) -> void:
	attacking = value


# getter is called at _unhandled_input() to check if not already attacking
func get_attack_state() -> bool:
	return attacking
# === ============================ === #
