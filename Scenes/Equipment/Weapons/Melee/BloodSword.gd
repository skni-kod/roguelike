extends Node2D

const K1 = preload("Blood_particles_1.tscn") #pobieramy particle do umiejek
const K2 = preload("Blood_particles_2.tscn")
var main = get_tree().get_root().find_node("Main", true, false) # odwołanie do node Main, potrzebne do particli

var player_node = get_tree().get_root().find_node("Player", true, false)

var rng = RandomNumberGenerator.new()
var crit_chance = rng.randi_range(0,10)
var crit = false
var crit_damage = 2
var spell = 0;

var mouse_position #Pozycja kursora
var attack = false #Czy postać atakuje
var attack_vector = Vector2.ZERO #Wektor po którym porusza się broń podczas ataku
export var attack_range = 15 #Zasięg ataku
var attack_speed = 0
var timer #Stoper
var damage
var ability1ManaCost=25 #koszt do zmiany w balansie
var ability2ManaCost=50 #koszt do zmiany w balansie
var weaponKnockback
var a = 1
var weaponName = "bloodsword" #potrzebne do sprawdzenia na którym miejscu jest wyekwipowane
var smoothing = 1
var swing_to = 0.3
var swing_back = 0.6
var animation_step = 0.02
var ability = 0 
var life_steal=0.1 #Potrzebna do pasywy, będzie mnożona przez damage
var krew_vector #potrzebne żeby krew leciała w dobrym kierunku

func _physics_process(delta):
	if a: #Zmienia ustawienia timera i teksturę a także skaluje kolizję (_ready() nie działa)
		timer.set_wait_time(animation_step)
		$WeaponSprite.texture = load("res://Assets/Loot/Weapons/bloodsword.png")
		$AttackCollision.scale.x = 2
		$AttackCollision.scale.y = 0.3
		$AttackCollision.position.x = 16
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
		if player_node.mana>=ability1ManaCost and !ability:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS1").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS3").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(1,ability1ManaCost) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				ability1()
				spell = 0
	
	if Input.is_action_just_pressed("use_ability_2"):
		if player_node.mana>=ability2ManaCost and !ability:
			if (player_node.weapons[1]==weaponName and !player_node.get_node("CoolDownS2").get_time_left()) or (player_node.weapons[2]==weaponName and !player_node.get_node("CoolDownS4").get_time_left()): #if sprawdzający czy nie ma cooldownu na umce
				player_node.on_skill_used(2,ability2ManaCost) #Wywolanie funkcji playera odpowiedzialnej za cooldowny
				spell = 1
				ability2()
				spell = 0

	

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
		rng.randomize()
		crit_chance = rng.randi_range(0,10)
		crit = false
		if(crit_chance == 0):
			damage *= crit_damage
			crit = true
		body.get_dmg(damage, weaponKnockback)
		########PASSIVE######## "Transfusion" każdy atak leczy za % obrażeń
		player_node.health += (life_steal*damage) #dodajemy życie zgodnie z ilością obrażeń przemnożoną przez współczynik lifestealu
		if crit:
			damage /= crit_damage
		if player_node.health > player_node.max_health: #jeśli przekroczymy max życia to ustawiamy max
			player_node.health = player_node.max_health
		player_node.emit_signal("health_updated", player_node.health) #emitujemy sygnał żeby pasek życia się zaktualizował
		
		var Krew = K2.instance() #towrzymy jedną instancję animacji krwi
		Krew.position = (get_tree().get_root().find_node("Player", true, false).global_position + (attack_vector*2)) #ustawiamy jej pozycję jako pozycja gracza + wektor kierunku broni
		Krew.rotation_degrees = rotation_degrees #krew idzie po tej samej lini co miecz
		main.add_child(Krew) #dodajemy krew do sceny
		Krew.scale = 1.5*Krew.scale #dostosowujemy wielkość krwi
		yield(get_tree().create_timer(0.3), "timeout") #czas stania krwi
		Krew.queue_free() #usuwamy krew
		#######################
		



func ability1(): # "Thirst" na krótki czas zwiększa prędkośc ataku i lifesteal
	ability = 1 
	swing_to = 0.1 #zmieniamy zmienne by zwiększyć statystyki
	swing_back = 0.1
	life_steal = 0.5
	yield(get_tree().create_timer(2), "timeout") #czas trwania umiejętności
	swing_to = 0.3 #wracamy do poprzednich zmiennych
	swing_back = 0.6
	life_steal = 0.1
	ability = 0

func ability2(): # "Gluttony" seria 4 ataków, każdy zadaje większe obrażenia na większej powierzchni, kosztuje życie
	
	ability = 1
	swing_to = 0.1 #zmieniamy zmienne by przyśpieszyć atak
	swing_back = 0.6 
	
	var ticks = 2 #ilość ataków
	for n in ticks:
		$AttackCollision.scale.x = 2+n*0.5 #wielkość ataków zależna od numeru ataku
		$AttackCollision.scale.y = (2+n*0.5)/2 #dzielimy przez 2 bo wtedy tworzy się mniej więcej koło
		damage *= n+2 #zwiększamy obrażenia zależnie od numeru ataku
		_on_Player_attacked() #używamy zwykłego ataku
		
		var Krew = K1.instance() #towrzymy jedną instancję animacji krwi
		Krew.position = (get_tree().get_root().find_node("Player", true, false).global_position + (attack_vector*2)) #ustawiamy jej pozycję jako pozycja gracza + wektor kierunku broni
		main.add_child(Krew) #dodajemy krew do sceny
		Krew.scale = (0.7+n*0.3)*Krew.scale #dostosowujemy wielkość krwi, używamy iteracji by była ona takiej samej wielkości co hitboxy
		
		yield(get_tree().create_timer(1), "timeout") #czas pomiędzy atakami
		damage /= n+2 #zmniejszamy obrażenia bo byśmy je wymnożyli do za dużych wartości, i żeby wszystkie ataki kosztowały tyle samo życia
		player_node.health -= (((n+1)*damage)/2.2) #odbieramy życie za każdy atak, można zmienić ile
		player_node.emit_signal("health_updated", player_node.health) #emitujemy sygnał żeby pasek życia się zaktualizował
		
		Krew.queue_free()
		
	swing_to = 0.3 #wracamy do poprzednich zmiennych
	swing_back = 0.6
	ability = 0
