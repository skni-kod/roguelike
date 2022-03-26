extends Node2D

export var attack_range = 15 #Zasięg ataku
export var attacking = false setget set_attack_state, get_attack_state #Czy postać atakuje

onready var Player_node = get_tree().get_root().find_node("Player", true, false)
onready var StatusBar_node = get_tree().get_root().find_node("StatusBar", true, false)

var damage
var weaponKnockback
var attack_speed

var weaponName = "Spear"
var spell = 0

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

#do um1

#do um2

func _ready() -> void:
	damage = float(Weapons.all_weapons.Axe["attack"])
	weaponKnockback = float(Weapons.all_weapons.Axe["knc"])
	attack_speed = float(Weapons.all_weapons.Axe["spd"])
	$AnimationPlayer.play("RESET")


func _physics_process(_delta):
#	print("[INFO]: Axe rotation: ", rotation_degrees)
	pass


func _unhandled_input(event) -> void:
	if !attacking:
		if Input.is_action_just_pressed("attack"):
			print("[INFO]: Event identified as BUTTON_LEFT pressed")
			$AnimationPlayer.playback_speed = attack_speed
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")
			
		if event.is_action_pressed("use_ability_1"):
			if Player_node.mana>=25:
				if (Player_node.equippedWeapons[1]==weaponName and !Player_node.get_node("CoolDownS1").get_time_left()) or (Player_node.equippedWeapons[2]==weaponName and !Player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
					Player_node.start_skill_cooldown(1, 5, 30)
					spell = 1
					spell = 0
		elif event.is_action_pressed("use_ability_2"):
			if Player_node.mana>=50:
				if (Player_node.equippedWeapons[1]==weaponName and !Player_node.get_node("CoolDownS2").get_time_left()) or (Player_node.equippedWeapons[2]==weaponName and !Player_node.get_node("CoolDownS4").get_time_left()):
					Player_node.start_skill_cooldown(2, 50, 50)
					spell = 1
					spell = 0


func _on_Player_attacked() -> void:
	if !attacking: #Sprawdza czy broń nie jest w trakcie ataku
		set_attack_state(true)
		$AttackCollision.disabled = false


func change_weapon(texture) -> void:
	$WeaponSprite.texture = texture


func _on_Spear_body_entered(body) -> void:
#	print("[INFO]: Axe collided with ", body)
	if body.is_in_group("Enemy"):
		print("[INFO]: Spear hit: ", body)
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		if crit:
			damage /= crit_damage


func play_swoosh():
	SoundController.play_Player_swoosh1()

# === SET/GET FOR THE ATTACK STATE === #
# setter is called at the animations
func set_attack_state(value: bool) -> void:
	attacking = value


# getter is called at _unhandled_input() to check if not already attacking
func get_attack_state() -> bool:
	return attacking
# === ============================ === #
