extends Node2D

signal axeability1used(direction, currPos)

onready var player_node = get_tree().get_root().find_node("Player", true, false)
onready var StatusBar_node = get_tree().get_root().find_node("StatusBar", true, false)

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper

var damage
var weaponKnockback
var attack_speed

var a = 1
var weaponName = "Axe"
var smoothing = 1
var spell = 0

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

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


func _ready() -> void:
	if get_parent() != null:
		connect("axeability1used", player_node.get_node("Hand"), "_on_axeAbility1Used")
	damage = float(Weapons.all_weapons.Axe["attack"])
	weaponKnockback = float(Weapons.all_weapons.Axe["knc"])
	attack_speed = float(Weapons.all_weapons.Axe["spd"])


func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")
		
	if event.is_action_pressed("use_ability_1"):
		if active_ability1==false and active_ability2==false and player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				attack_vector = Vector2(attack_range *ability1range* cos(rotation), attack_range *ability1range* sin(rotation))
				print("[INFO]: Axe abilty 1 used")
#				tmpdmg = damage 
#				damage *= ability1damagemultipler
#				spell = 0
				emit_signal("axeability1used", rotation_degrees, global_position)
				$AnimationPlayer.play("Throw")
				yield($AnimationPlayer, "animation_finished")
				global_position += global_position + position
				position = Vector2.ZERO
#				tmpknockback = weaponKnockback
#				weaponKnockback = 0
#				timer.start()
#				spell = 0
	elif event.is_action_pressed("use_ability_2"):
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
				print("[INFO]: Axe ability 2 used")
				
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


func reset_pivot() -> void: #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281


func _on_Player_attacked() -> void:
	if !attack:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()


func change_weapon(texture) -> void:
	$WeaponSprite.texture = texture


func _on_Axe_body_entered(body) -> void:
#	print("[INFO]: Axe collided with ", body)
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


func play_swoosh():
	SoundController.play_player_swoosh1()
