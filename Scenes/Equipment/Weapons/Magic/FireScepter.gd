extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var timer #Stoper
var damage = 1
var attack_speed = 0.0
var additionalManaRegen=1.5 #Passive ability - faster mana regen
var a = 1
var projectile
var level

func _ready():
	player_node.manaRegenRate+=additionalManaRegen

func _physics_process(delta):
	if a:#Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/fire scepter.png")
		level = get_tree().get_root().find_node("Main", true, false)
		$AttackCollision.scale.x = 0
		$AttackCollision.scale.y = 0
		$AttackCollision.position.x = 0
		$AttackCollision.position.y = 0
		a = 0
	if !attack: #Jeżeli nie atakuje to się porusza
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * 0.1
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * 0.1
		else:
			rotation += mouse_position.angle() * 0.1
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.y = -1
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.y = 1
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry

func _on_Player_attacked():
	if !attack:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		projectile = preload("res://Scenes/Equipment/Weapons/Magic/Projectiles/Fireball.tscn")
		projectile = projectile.instance()
		projectile.position = get_parent().position
		projectile.rotation = self.rotation
		level.add_child(projectile)
		timer.start()

func _on_Timer_timeout():#Wykonuje się kiedy zejdzie cooldown ataku
	attack_speed += 0.01
	if attack_speed <= 0.15:
		position += attack_vector * (0.01/0.15)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90 * (0.01/0.15)
		else:
			$WeaponSprite.rotation_degrees += 90 * (0.01/0.15)
		
	elif attack_speed > 0.3:
		position -= attack_vector
		$WeaponSprite.rotation_degrees = 0
		$AttackCollision.disabled = true
		attack = false
		attack_speed = 0
		timer.stop()

func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):#Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		body.get_dmg(damage)
