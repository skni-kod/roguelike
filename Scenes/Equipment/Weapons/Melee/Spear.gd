extends Node2D

var player_node = get_tree().get_root().find_node("Player", true, false)

var mouse_position
var attack = false
var attack_vector = Vector2.ZERO
export var attack_range = 15
var timer #Cooldown pomiędzy atakami
var damage #Obrażenia zadawane przez broń. Wartość pobierana z pliku
var ability1ManaCost=1 #koszt do zmiany w balansie
var ability2ManaCost=1 #koszt do zmiany w balansie
var SR=0 #Stab rotation, potrzebne do ability 2
var weaponKnockback
var isWeaponReady=1 #Sprawdź czy broń jest gotowa do ataku
var smoothing = 1
var attack_speed = 0 #Zmienna służąca do animacji 
var swing_to = 0.3
var paused = 0.4
var swing_back = 0.5
var animation_step = 0.02


func _physics_process(delta):
	if isWeaponReady==1: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(0.01)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/spear.png")
		#Ustaw wartość kolizji dla broni
		$AttackCollision.scale.x = 1.1
		$AttackCollision.scale.y = 0.5
		$AttackCollision.position.x= 20
		$AttackCollision.position.y= 0	
		isWeaponReady = 0
	if !attack:
		mouse_position = get_local_mouse_position()
		
		if rotation < -PI:
			rotation = PI + mouse_position.angle() * smoothing
		elif rotation > PI:
			rotation = -PI + mouse_position.angle() * smoothing
		else:
			rotation += mouse_position.angle() * smoothing
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.scale.x = 1.1
			$WeaponSprite.scale.y = -1.1
			$WeaponSprite.rotation_degrees=-90 #Obróć broń przodem do przeciwnika
		else:
			$WeaponSprite.scale.x = 1.1
			$WeaponSprite.scale.y = 1.1
			$WeaponSprite.rotation_degrees=90 #Obróć broń przodem do przeciwnika

	if Input.is_action_just_pressed("use_ability_1"):
		#Really powerful blow - 40 bonus damage
		if player_node.mana>=ability1ManaCost:
			player_node.updateMana(-ability1ManaCost)
			ability1()
		else:
			print("Insufficient mana, " + String(ability1ManaCost) +" required to cast ability")
	
	if Input.is_action_just_pressed("use_ability_2"):
		#Increase next attack damage by 12 costs 20 mana
		if player_node.mana>=ability2ManaCost:
			player_node.updateMana(-ability2ManaCost)
			ability2()
		else:
			print("Insufficient mana, " + String(ability2ManaCost) +" required to cast ability")

func reset_pivot():#Zresetuj broń. Nawet jak animacja jest spieprzona to broń nie oddali się od gracza
	position.x=0.281
	position.y=0.281

func _on_Player_attacked():
	if !attack and attack_speed==0:
		attack = true
		attack_vector = Vector2(attack_range * cos(rotation), attack_range * sin(rotation)+SR)
		if rotation < -PI/2 or rotation > PI/2:
			$WeaponSprite.rotation_degrees = -90-SR#-90
		else:
			$WeaponSprite.rotation_degrees = 90+SR#90
		$AttackCollision.disabled = false
		timer.start()

func _on_Timer_timeout():
	attack_speed+=animation_step
	if attack_speed<swing_to:
		position += attack_vector*(animation_step/swing_to)
	elif attack_speed<paused:
		pass
	elif attack_speed<swing_back:
		position -= attack_vector*(animation_step/swing_back)
	else:
		$AttackCollision.disabled = true
		attack = false
		attack_speed=0		
		timer.stop()
		reset_pivot()
		##########PASSIVE####### po każdym ataku można wykonać doskok
		player_node.skok_vector=Vector2.ZERO #sprawia że nie skaczesz jak się nie poruszasz
		player_node.speed=70 #zmniejsza prędkość żeby skok był krótszy od zwykłego
		player_node.jump() #skok ten sam co normalny
		yield(get_tree().create_timer(0.5), "timeout") #czas po którym speed gracza ma wrócić do normalnej wartości
		player_node.speed=100 #wracamy do bazowej prędkości gracza
		player_node.skok_vector=player_node.direction #wracamy do normalnej wartości by gracz mógł skakać stojąc w miejscu
		########################
func change_weapon(texture):
	$WeaponSprite.texture = texture

func _on_EquippedWeapon_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_dmg(damage, weaponKnockback)

func ability1(): #obraca wokoło siebie włucznią i odpycha przeciników
	
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

func ability2(): #seria szybkich nieprecyzyjnych ataków w stożku
	
	swing_to = 0.1 #zmieniamy zmienne od ataku żeby były szybsze
	paused = 0.1 
	swing_back = 0.1 
	
	var ticks = 30 #ilość ataków
	for n in ticks:
		var rng = RandomNumberGenerator.new() #generujemy randomowy numer
		rng.randomize() 
		SR = rng.randi_range(-10, 10) #szerokość stożka
		_on_Player_attacked() #używamy zwykłego ataku
		yield(get_tree().create_timer(0.1), "timeout") #przerwy bo wszystko by się stało na raz
	
	swing_to = 0.3 #wracamy do bazowych zmiennych ataku
	paused = 0.4 
	swing_back = 0.5
	SR=0 #resetujemy stab rotation bo atak by został na zawsze z rotacja ostatniego z serii



