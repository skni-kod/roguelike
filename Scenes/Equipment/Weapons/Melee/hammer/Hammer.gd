extends Node2D

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage
var weaponKnockback
var a = 1
onready var player_node := get_tree().get_root().find_node("Player", true, false)
var smoothing = 1
var weaponName = 'hammer'

var spell = 0
var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2

var attack_speed = 0
var swing_to = 0.4
var paused = 0.9
var swing_back = 2
var animation_step = 0.02

var t #do timera

#do um 1
var active_ability1 = 0
var damage_multipler = 3
var knockback_multipler = 15
var range_x = 3
var range_y = 6

#do um 2
var immortal_time = 5 #czas niesmiertelnosci w sekundach
var immortal_knockback = 20
func _physics_process(delta):
	if Input.is_action_just_pressed("use_ability_1"):
		if active_ability1!=1 and player_node.mana>=25:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				active_ability1 = 1
		
				var equipped_weapon := get_tree().get_root().find_node("EquippedWeapon", true, false)
				
				var tmp = {
					'position_x' : $AttackCollision.position.x,
					'position_y' : $AttackCollision.position.y,
					'scale_x' : $AttackCollision.scale.x,
					'scale_y' : $AttackCollision.scale.y,
					'damage' : equipped_weapon.damage,
					'weaponKnockback' : equipped_weapon.weaponKnockback,
				}
				player_node.jump()
				
				t = Timer.new()
				t.set_wait_time(0.75) #recznie ustawiony wait time taki sam jak na timerze 'skok' w playerze
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				
				$AttackCollision.disabled = false
				$AttackCollision.position.x = 0
				$AttackCollision.position.y = 0
				$AttackCollision.scale.x = range_x
				$AttackCollision.scale.y = range_y
				equipped_weapon.damage *= damage_multipler
				equipped_weapon.weaponKnockback *= knockback_multipler
				
				t = Timer.new()
				t.set_wait_time(0.1) 
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
			
				$AttackCollision.disabled = true
				$AttackCollision.position.x = tmp['position_x']
				$AttackCollision.position.y = tmp['position_y']
				$AttackCollision.scale.x = tmp['scale_x']
				$AttackCollision.scale.y = tmp['scale_y']
				equipped_weapon.damage = tmp['damage']
				equipped_weapon.weaponKnockback = tmp['weaponKnockback']
				spell = 0
				active_ability1 = 0
		
	if Input.is_action_just_pressed("use_ability_2"):
		
		if active_ability1!=1 and player_node.mana>=50:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				var player_node := get_tree().get_root().find_node("Player", true, false)
				var equipped_weapon := get_tree().get_root().find_node("EquippedWeapon", true, false)
				
				var tmp = {
					'position_x' : $AttackCollision.position.x,
					'position_y' : $AttackCollision.position.y,
					'scale_x' : $AttackCollision.scale.x,
					'scale_y' : $AttackCollision.scale.y,
					'damage' : equipped_weapon.damage,
					'weaponKnockback' : equipped_weapon.weaponKnockback,
				}
				
				$AttackCollision.disabled = false
				$AttackCollision.position.x = 0
				$AttackCollision.position.y = 0
				$AttackCollision.scale.x = range_x
				$AttackCollision.scale.y = range_y
				equipped_weapon.damage = 0
				equipped_weapon.weaponKnockback *= immortal_knockback
				
				t = Timer.new()
				t.set_wait_time(0.1) 
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
			
				$AttackCollision.disabled = true
				$AttackCollision.position.x = tmp['position_x']
				$AttackCollision.position.y = tmp['position_y']
				$AttackCollision.scale.x = tmp['scale_x']
				$AttackCollision.scale.y = tmp['scale_y']
				equipped_weapon.damage = tmp['damage']
				equipped_weapon.weaponKnockback = tmp['weaponKnockback']
				
				var level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
				level.get_node("Player").immortal = 1 
				t.set_wait_time(immortal_time) 
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				level.get_node("Player").immortal = 0
				spell =0


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")


func reset_pivot():#Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
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
			$WeaponSprite.rotation_degrees += -90 * (animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90 * (animation_step/swing_to)
	elif attack_speed < paused:
		pass
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
