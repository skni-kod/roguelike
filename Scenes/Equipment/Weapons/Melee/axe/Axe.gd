extends Node2D

signal axeability1used(direction, currPos)

export var attacking = false setget set_attack_state, get_attack_state #Czy postać atakuje

onready var StatusBar_node = get_tree().get_root().find_node("StatusBar", true, false)

var damage
var weaponKnockback
var attack_speed

var weaponName = "Axe"
var spell = 0

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

#do um1
var ability1range = 100
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


func _ready() -> void:
	if get_parent() != null:
		connect("axeability1used", Bufor.PLAYER.get_node("Hand"), "_on_axeAbility1Used")
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
			if Bufor.PLAYER.mana>=25:
				if (Bufor.PLAYER.activeWeapon["slot"] == 1 and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left() or Bufor.PLAYER.activeWeapon["slot"] == 2 and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
					Bufor.PLAYER.start_skill_cooldown(1, 5, 30)
	#				print("[INFO]: Axe abilty 1 used")
					tmpdmg = damage 
					damage *= ability1damagemultipler
					spell = 0
					var axeHandDirectionVariable: int = get_parent().scale.y
					var axeThrowStartScale = scale.x
					match axeHandDirectionVariable:
						-1:
							$AnimationPlayer.get_animation("Throw").track_set_key_value(8, 0, -axeThrowStartScale)
							$AnimationPlayer.get_animation("Throw").track_set_key_value(8, 1, -axeThrowStartScale)
						1:
							$AnimationPlayer.get_animation("Throw").track_set_key_value(8, 0, axeThrowStartScale)
							$AnimationPlayer.get_animation("Throw").track_set_key_value(8, 1, axeThrowStartScale)
					$AnimationPlayer.get_animation("Throw").bezier_track_set_key_value(0, 0, global_position.x)
					$AnimationPlayer.get_animation("Throw").bezier_track_set_key_value(1, 0, global_position.y)
					$AnimationPlayer.get_animation("Throw").bezier_track_set_key_value(2, 0, rotation_degrees)
					$AnimationPlayer.get_animation("Throw").bezier_track_set_key_value(0, 1, get_global_mouse_position().x)
					$AnimationPlayer.get_animation("Throw").bezier_track_set_key_value(1, 1, get_global_mouse_position().y)
					$AnimationPlayer.get_animation("Throw").bezier_track_set_key_value(2, 1, 1180 * axeHandDirectionVariable)
					# Emits signal to the Hand, so that it disconnects the axe from the Player and reparents it to the main node
					emit_signal("axeability1used", rotation_degrees, global_position)
					# [WARNING]: At this point the parent of the axe is the "Main" node
					Bufor.PLAYER.deleteCurrentWeapon()
					$AnimationPlayer.play("Throw")
					yield($AnimationPlayer, "animation_finished")
					$AnimationPlayer.get_animation("Jump back").bezier_track_set_key_value(0, 0, global_position.x)
					$AnimationPlayer.get_animation("Jump back").bezier_track_set_key_value(1, 0, global_position.y)
					$AnimationPlayer.get_animation("Jump back").bezier_track_set_key_value(0, 1, global_position.x - axeHandDirectionVariable *45 * cos(get_angle_to(Bufor.PLAYER.global_position) - PI/2))
					$AnimationPlayer.get_animation("Jump back").bezier_track_set_key_value(1, 1, global_position.y - axeHandDirectionVariable * 45 * sin(get_angle_to(Bufor.PLAYER.global_position) - PI/2))
					$AnimationPlayer.play("Jump back")
					yield($AnimationPlayer, "animation_finished")
					var lootableAxe = load("res://Scenes/Loot/Weapon.tscn")
					lootableAxe = lootableAxe.instance()
					lootableAxe.weaponName = weaponName
					lootableAxe.position = position
					get_parent().call_deferred("add_child", lootableAxe)
					queue_free()
	#				tmpknockback = weaponKnockback
	#				weaponKnockback = 0
					spell = 0
			else:
				print("[INFO]: No mana left for axe ability 1 to be used")
		elif event.is_action_pressed("use_ability_2"):
			if Bufor.PLAYER.mana>=50:
				if (Bufor.PLAYER.equippedWeapons[1]==weaponName and !Bufor.PLAYER.get_node("CoolDownS2").get_time_left()) or (Bufor.PLAYER.equippedWeapons[2]==weaponName and !Bufor.PLAYER.get_node("CoolDownS4").get_time_left()):
					Bufor.PLAYER.start_skill_cooldown(2, 50, 50)
					spell = 1
					StatusBar_node.immune = true
					tmpspeed = Bufor.PLAYER.speed
					Bufor.PLAYER.speed *= speedmultipler
					tmpdmg = damage
					damage *= dmgmultipler
					tmpattack_speed = attack_speed
					attack_speed *= attack_speedmultipler
					print("[INFO]: Axe ability 2 used")
					
					var t = Timer.new()   			
					t.set_wait_time(ability2duration)
					t.set_one_shot(true)			
					self.add_child(t)				
					t.start()						
					yield(t, "timeout")
					t.queue_free()
					
					Bufor.PLAYER.speed = tmpspeed
					damage = tmpdmg
					attack_speed = tmpattack_speed
					StatusBar_node.immune = false
					spell = 0
			else:
				print("[INFO]: No mana left for axe ability 2 to be used")


func _on_Player_attacked() -> void:
	if !attacking: #Sprawdza czy broń nie jest w trakcie ataku
		set_attack_state(true)
		$AttackCollision.disabled = false


func change_weapon(texture) -> void:
	$WeaponSprite.texture = texture


func _on_Axe_body_entered(body) -> void:
#	print("[INFO]: Axe collided with ", body)
	if body.is_in_group("Enemy"):
		print("[INFO]: Axe hit: ", body)
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
	SoundController.play_player_swoosh1()

# === SET/GET FOR THE ATTACK STATE === #
# setter is called at the animations
func set_attack_state(value: bool) -> void:
	attacking = value


# getter is called at _unhandled_input() to check if not already attacking
func get_attack_state() -> bool:
	return attacking
# === ============================ === #
