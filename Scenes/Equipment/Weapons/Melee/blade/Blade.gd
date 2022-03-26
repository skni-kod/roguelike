extends Node2D

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

var active_ability2 = 0
var active_ability1 = 0
#zmienne do wirka miecza
var wirek_range = 25
var wirek_smoothing = 0.01
var wirek_speed = 0.3
var wirek_time = 100

#zmienne do um2
var hits_amount = 3
var hits_speed = 0.05

func _physics_process(delta):
#	if !attack: #Jeżeli nie atakuje to się porusza
#		if active_ability1!=1:
#			mouse_position = get_local_mouse_position()
#			if rotation < -PI:
#				rotation = PI + mouse_position.angle() * smoothing
#			elif rotation > PI:
#				rotation = -PI + mouse_position.angle() * smoothing
#			else:
#				rotation += mouse_position.angle() * smoothing
#			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
	
	
	if Input.is_action_just_pressed("use_ability_1"):
		if active_ability1!=1 and active_ability2!=1 and Bufor.PLAYER.mana>=25:
			if (Bufor.PLAYER.weapons[1]==weaponName and !Bufor.PLAYER.get_node("CoolDownS1").get_time_left()) or (Bufor.PLAYER.weapons[2]==weaponName and !Bufor.PLAYER.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.on_skill_used(1,25) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				active_ability1 = 1;
				$WeaponSprite/WirMiecza.emitting = true
				$AttackCollision.disabled = false
				$WeaponSprite.position.x=wirek_range
				for o in range(wirek_time):
													#----------------------
					var t = Timer.new()   			# Timer do wirka
					t.set_wait_time(wirek_smoothing)#
					t.set_one_shot(true)			#
					self.add_child(t)				#
					t.start()						#
					yield(t, "timeout")				#
													#----------------------
					rotation += wirek_speed
					
#					if rotation < -PI/2 or rotation > PI/2:
#						$WeaponSprite.scale.x = 1.2
#						$WeaponSprite.scale.y = -1.2
#						$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
#					else:
#						$WeaponSprite.scale.x = 1.2
#						$WeaponSprite.scale.y = 1.2
#						$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
			$WeaponSprite/WirMiecza.emitting = false
			$WeaponSprite.rotation_degrees = 0
#			$WeaponSprite.position.x=13
#			$WeaponSprite.position.y=0
			$AttackCollision.disabled = true
			active_ability1 = 0
			spell = 0
			
	if Input.is_action_just_pressed("use_ability_2"):
		if active_ability1!=1 and active_ability2!=1 and Bufor.PLAYER.mana>=50:
			if (Bufor.PLAYER.weapons[1]==weaponName and !Bufor.PLAYER.get_node("CoolDownS2").get_time_left()) or (Bufor.PLAYER.weapons[2]==weaponName and !Bufor.PLAYER.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				Bufor.PLAYER.on_skill_used(2,50) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				active_ability2 = 1
				
				for o in range(hits_amount):
					_on_Player_attacked()
					var t = Timer.new() 
					t.set_wait_time(0.25)
					t.set_one_shot(true)
					self.add_child(t)
					t.start()
					yield(t, "timeout")	
					
				active_ability2 = 0
				spell = 0
		

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("RESET")


func _on_Player_attacked():
	if !attacking: #Sprawdza czy broń nie jest w trakcie ataku
		set_attack_state(true)
		$AttackCollision.disabled = false

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body): #Zadaje obrażenia przy kolizji z przeciwnikiem
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


# === SET/GET FOR THE ATTACK STATE === #
# setter is called at the animations
func set_attack_state(value: bool) -> void:
	attacking = value


# getter is called at _unhandled_input() to check if not already attacking
func get_attack_state() -> bool:
	return attacking
# === ============================ === #
