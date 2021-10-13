extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var attack_speed = 0
var timer #Stoper
var damage
var ability1ManaCost=1 #koszt do zmiany w balansie
var ability2ManaCost=1 #koszt do zmiany w balansie
var weaponKnockback
var a = 1
var smoothing = 1
var swing_to = 0.3
var swing_back = 0.6
var animation_step = 0.02
var ability = 0

func _physics_process(delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(animation_step)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/bloodsword.png")
		$AttackCollision.scale.x = 1.5
		$AttackCollision.scale.y = 0.3
		$AttackCollision.position.x = 12
		$AttackCollision.position.y = 0
		$WeaponSprite.scale.x = 1.2
		$WeaponSprite.scale.y = -1.2
		
		a = 0
	if !attack: #Jeżeli nie atakuje to się porusza
		mouse_position = get_local_mouse_position()
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * smoothing
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * smoothing
		else:
			rotation += mouse_position.angle() * smoothing
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.y = -1.2
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry
		else:
			$WeaponSprite.scale.y = 1.2
			$WeaponSprite.rotation_degrees=0 #Obróć broń ostrzem do góry


	if Input.is_action_just_pressed("use_ability_1"):
		#Really powerful blow - 40 bonus damage
		if player_node.mana>=ability1ManaCost and !ability:
			player_node.updateMana(-ability1ManaCost)
			ability1()
		else:
			print("Insufficient mana, " + String(ability1ManaCost) +" required to cast ability")
	
	if Input.is_action_just_pressed("use_ability_2"):
		#Increase next attack damage by 12 costs 20 mana
		if player_node.mana>=ability2ManaCost and !ability:
			player_node.updateMana(-ability2ManaCost)
			ability2()
		else:
			print("Insufficient mana, " + String(ability2ManaCost) +" required to cast ability")

	

func reset_pivot(): #Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281


func _on_Player_attacked():
	if !attack:#Sprawdza czy broń nie jest w trakcie ataku
		attack = true
		$AttackCollision.disabled = false
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation))
		timer.start()

func _on_Timer_timeout(): #Wykonuje się kiedy zejdzie cooldown ataku
	attack_speed += animation_step
	if attack_speed <= swing_to:
		position += attack_vector * (animation_step/swing_to)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees += -90 * (animation_step/swing_to)
		else:
			$WeaponSprite.rotation_degrees += 90 * (animation_step/swing_to)
		
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

func _on_EquippedWeapon_body_entered(body): #Zadaje obrażenia przy kolizji z przeciwnikiem
	if body.is_in_group("Enemy"):
		body.get_dmg(damage, weaponKnockback)

func ability1(): #obraca wokoło siebie włucznią i odpycha przeciników
	ability = 1
	attack = true
	weaponKnockback += 3 #zwiększamy odżut
	$AttackCollision.scale.x = 3 #zwiększamy hitboxy żeby były tak długie jak włucznia przy pełym oddaleniu
	$AttackCollision.disabled = false
	var s = 30 #ilość kroków w obrocie
	for i in 4: #ilość obrotów
		for n in s:
			rotation_degrees = n*(360/s) #ustawiamy pozycję co odpowiedni krok
			$WeaponSprite.rotation_degrees = n*(360/s) #sprawia że broń robi SPINNNNNNNNN
			yield(get_tree().create_timer(0.001), "timeout") #czas pomiedzy krokiem żeby wszystko nie stało się w sekundę
	weaponKnockback -= 3 #wracamy do bazowego odżutu
	$AttackCollision.scale.x = 1.1 #wracamy do bazowej kolizji
	$AttackCollision.disabled = true
	attack = false
	reset_pivot()
	ability = 0

func ability2(): #seria szybkich nieprecyzyjnych ataków w stożku
	
	ability = 1
	swing_to = 0.1 #zmieniamy zmienne od ataku żeby były szybsze
	swing_back = 0.1 
	
	var ticks = 30 #ilość ataków
	for n in ticks:
		var rng = RandomNumberGenerator.new() #generujemy randomowy numer
		rng.randomize() 
		_on_Player_attacked() #używamy zwykłego ataku
		yield(get_tree().create_timer(0.1), "timeout") #przerwy bo wszystko by się stało na raz
	
	swing_to = 0.3 #wracamy do bazowych zmiennych ataku
	swing_back = 0.5
	ability = 0


