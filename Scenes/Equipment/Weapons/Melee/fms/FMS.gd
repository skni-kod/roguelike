extends Node2D

signal fmsability2used(direction, currPos)

export var attack_range = 15 #Zasięg ataku
export var attacking = false setget set_attack_state, get_attack_state #Czy postać atakuje

onready var Player_node = get_tree().get_root().find_node("Player", true, false)
onready var StatusBar_node = get_tree().get_root().find_node("StatusBar", true, false)

var damage
var weaponKnockback
var attack_speed

var weaponName = "Fms"
var spell = 0

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

#for passive 
var phase = 0
var basedmg 
#for ability1
var EhpHero = preload("res://Assets/Hero/FmsEphermalForm.png")
var NormalHero = preload("res://Assets/Hero/RedHero.png")
#for ability2
onready var main = get_tree().get_root().find_node("Main", true, false)
var Projectiles = load("res://Scenes/Equipment/Weapons/Melee/fms/Ability2.tscn")
var Ability2Active = 0
func _fire_projectile() -> void:
	var Projectile = Projectiles.instance()
	var diry: int = get_parent().scale.y
	var dirx = scale.x
	match diry:
		-1:
			Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 0, -dirx)
			Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 1, -dirx)
		1:
			Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 0, dirx)
			Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 1, dirx)
	Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(0, 0, global_position.x)
	Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(0, 1, get_global_mouse_position().x)
	Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(1, 0, global_position.y)
	Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(1, 1, get_global_mouse_position().y)
	var flip = 0
	if abs(Bufor.PLAYER.get_node("Hand").rotation_degrees) > 90:
		flip = 180
	Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(2, 0, flip+Bufor.PLAYER.get_node("Hand").rotation_degrees) 
	Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(2, 1, flip+Bufor.PLAYER.get_node("Hand").rotation_degrees) 
	main.add_child(Projectile)
	Projectile.get_node("Ab2Attack").play("Attack")
	yield(Projectile.get_node("Ab2Attack"), "animation_finished")
	Projectile.queue_free()


func _ready() -> void:
	damage = float(Weapons.all_weapons.Axe["attack"])
	basedmg = damage
	weaponKnockback = float(Weapons.all_weapons.Axe["knc"])
	attack_speed = float(Weapons.all_weapons.Axe["spd"])
	$WeakAttack.play("RESET")
func _physics_process(_delta):
#	print("[INFO]: Axe rotation: ", rotation_degrees)
	pass

func _unhandled_input(event) -> void:

	if !attacking:
		if Input.is_action_just_pressed("attack"):
			print("[INFO]: Event identified as BUTTON_LEFT pressed")
			$WeakAttack.playback_speed = attack_speed
			$WeakAttack.play("Attack")
			if Ability2Active == 1:
				_fire_projectile()
			yield($WeakAttack, "animation_finished")
			$WeakAttack.play("RESET")


		if event.is_action_pressed("use_ability_1"):
			if Player_node.mana>=25:
				if (Player_node.equippedWeapons[1]==weaponName and !Player_node.get_node("CoolDownS1").get_time_left()) or (Player_node.equippedWeapons[2]==weaponName and !Player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
					Player_node.start_skill_cooldown(1, 10, 5)
					spell = 1
					Bufor.PLAYER.get_node("PlayerSprite").set_texture(EhpHero)
					Bufor.PLAYER.speed = Bufor.PLAYER.speed*2
					yield(get_tree().create_timer(3.0), "timeout")
					Bufor.PLAYER.speed = Bufor.PLAYER.speed/2
					Bufor.PLAYER.get_node("PlayerSprite").set_texture(NormalHero)
					spell = 0
		elif event.is_action_pressed("use_ability_2"):
			if Player_node.mana>=50:
				if (Player_node.equippedWeapons[1]==weaponName and !Player_node.get_node("CoolDownS2").get_time_left()) or (Player_node.equippedWeapons[2]==weaponName and !Player_node.get_node("CoolDownS4").get_time_left()):
					Player_node.start_skill_cooldown(2, 1, 0)
					spell = 1
					Ability2Active = 1
					yield(get_tree().create_timer(5.0), "timeout")
#					var Projectile = Projectiles.instance()
#					var diry: int = get_parent().scale.y
#					var dirx = scale.x
#					match diry:
#						-1:
#							Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 0, -dirx)
#							Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 1, -dirx)
#						1:
#							Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 0, dirx)
#							Projectile.get_node("Ab2Attack").get_animation("Attack").track_set_key_value(3, 1, dirx)
#					Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(0, 0, global_position.x)
#					Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(0, 1, get_global_mouse_position().x)
#					Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(1, 0, global_position.y)
#					Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(1, 1, get_global_mouse_position().y)
#					var flip = 0
#					if abs(Bufor.PLAYER.get_node("Hand").rotation_degrees) > 90:
#						flip = 180
#					Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(2, 0, flip+Bufor.PLAYER.get_node("Hand").rotation_degrees) 
#					Projectile.get_node("Ab2Attack").get_animation("Attack").bezier_track_set_key_value(2, 1, flip+Bufor.PLAYER.get_node("Hand").rotation_degrees) 
#					main.add_child(Projectile)
#					Projectile.get_node("Ab2Attack").play("Attack")
#					yield(Projectile.get_node("Ab2Attack"), "animation_finished")
#					Projectile.queue_free()
					Ability2Active = 0
					spell = 0
					
	match phase:
		0:
			$Phase9.visible=false
			$Phase0.visible=true
			damage = basedmg*1
		1:
			$Phase0.visible=false
			$Phase1.visible=true
			damage = basedmg*1.25
		2:
			$Phase1.visible=false
			$Phase2.visible=true
			damage = basedmg*1.5
		3:
			$Phase2.visible=false
			$Phase3.visible=true
			damage = basedmg*1.75
		4:
			$Phase3.visible=false
			$Phase4.visible=true
			damage = basedmg*2
		5:
			$Phase4.visible=false
			$Phase5.visible=true
			damage = basedmg*2.5
		6:
			$Phase5.visible=false
			$Phase6.visible=true
			damage = basedmg*2
		7:
			$Phase6.visible=false
			$Phase7.visible=true
			damage = basedmg*1.75
		8:
			$Phase7.visible=false
			$Phase8.visible=true
			damage = basedmg*1.5
		9:
			$Phase8.visible=false
			$Phase9.visible=true
			damage = basedmg*1.25

func _on_Player_attacked() -> void:
	if !attacking: #Sprawdza czy broń nie jest w trakcie ataku
		set_attack_state(true)
		$AttackCollision.disabled = false


func change_weapon(texture) -> void:
	$WeaponSprite.texture = texture


func _on_Fms_body_entered(body) -> void:
#	print("[INFO]: Axe collided with ", body)
	if body.is_in_group("Enemy"):
		print("[INFO]: Fms hit: ", body)
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




