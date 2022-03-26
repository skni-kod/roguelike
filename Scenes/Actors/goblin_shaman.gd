extends KinematicBody2D

signal died(body)

var playerIsInRange: bool = false # bool variable that changes to true when the Player is in attack range
var move = Vector2.ZERO		#Zmienna inicjująca wektor poruszania
export var speed = 0.5		#Zmienna przechowująca szybkość poruszania
var right = 0.17		#Kierunek obrócenia
var attack = false		#Czy atakuje
var max_hp = 60		#Zmienna przechowywująca ilość życia
var hp:float = max_hp	#Zmienna przechowuje ilość pozostałego życia
var summon = false		#Czy przywołuje
onready var main := get_tree().get_root().find_node("Main", true, false)

export var health = 100		#Pozostałe życie w procentach
var drop = {"minCoins":0,"maxCoins":5}	#Przedział definiujący ile goblin shaman może zostawić po sobie coinów
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0
var enemyPos
# === ===================== === #

# === ZMIENNE DO ELITY === #
var is_elite = false

func elite():
	rng.randomize()
	var rgb = rng.randi_range(0,2) 	# od 1 do 3 rodzaj elity 
	var elite = rng.randf_range(1,100)	# zakres losowania szansy na stworzenie elity
	if elite <=25 :		# w jakim zakresie musi być wylosowana liczba 
		is_elite = true		# może się przydać później 
		if rgb == 0 :	# rodzaj czerwony przywołuję szybciej mniejsze gobliny
			$Goblin_shaman.modulate = Color(1, 0, 0, 1 )	#Zmiana koloru sprite (czerwony , zielony , niebieski, przezroczystość )
			$summon.set_wait_time(2.0)	#ustawienie timera
		if rgb == 1 :	#rodzaj zielony więcej hp wolniejszy
			$Goblin_shaman.modulate = Color(0, 1, 0, 1 )
			max_hp = max_hp * 1.5	# zwiększenie zdrowia o 1.5 razy
			hp = max_hp
			health = 100
			speed -= 0.1
		if rgb == 2 :	# rodzaj niebieski szybciej atakuje i szybciej biega
			$Goblin_shaman.modulate = Color( 0, 0, 1, 1 )
			speed += 0.3
			$attack.set_wait_time(0.8)
# === ===================== === #

func _ready():
	elite()
	health_bar.on_health_updated(health)

	
func _physics_process(delta):
	move = Vector2.ZERO
	enemyPos = self.global_position
	if playerIsInRange and health>0 and !summon :	# wykonuje się jeśli widzi gracza i nie atakuje oraz żyje
		$Goblin_shaman.scale.x = right		# obrót w stronę gracza
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(Bufor.PLAYER.global_position) * -speed # odsuwanie się od gracza, gdy jest za blisko
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if Bufor.PLAYER.global_position.x-self.global_position.x < 0:		# sprawdzenie w którą stone jest obrócony gracz
			right = 0.17
		else:
			right = -0.17
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")

	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === #
	

func summon():		# funkcja odpowiadająca za przywoływanie goblinów
	var goblinscene = load("res://Scenes/Actors/Little_Goblin.tscn")
	goblinscene = goblinscene.instance()
	var spawnposition = Vector2.ZERO
	if right >0 :
		spawnposition = Vector2(self.global_position.x+20,self.global_position.y)
	else:
		spawnposition = Vector2(self.global_position.x-20,self.global_position.y)
	goblinscene.position=spawnposition
	goblinscene.add_to_group(name)
	main.add_child(goblinscene)
	
func fire():		# funkcja odpowiadająca za tworzenie pocisków
	var ball_scene = load("res://Scenes/Actors/goblin_ball.tscn")
	ball_scene= ball_scene.instance()
	ball_scene.position = self.global_position + $Position2D.position
	ball_scene.player_Pos = get_tree().get_root().find_node("Player", true, false).global_position
	main.add_child(ball_scene)
	
func _on_wzrok_body_entered(body):
	if body != self and body.name == "Player":	#Jeśli gracz znajduję się w polu wzrok przypisz jego węzeł do zmiennej i przywołuj
		playerIsInRange = true
		summon = true

func _on_wzrok_body_exited(body):		#Jeżeli gracz nie znajduję się w polu wzrok to zmień Player na null i nie przywołuj 
	if body != self and body.name == "Player":
		playerIsInRange = false
		summon = false
	
func _on_Area2D_body_entered(body):		#Jeżeli gracz wszedł w pole atak (Area2D) to atakuj nie przywołuj
	if body != self and body.name == "Player":
		attack = true
		summon = false 

func _on_Area2D_body_exited(body):		#Jeżeli gracz wyszedł z pola atak (Area2D) to przywołuj nie atakuj
	if body.name == "Player":
		attack = false
		summon = true
		
func _on_summon_timeout():
	if playerIsInRange and health>0 and !attack:		# Jeżeli gracza znajduje się w polu wzrok ,żyje oraz nie atakuje to przywołuje gobliny
		summon()


func _on_attack_timeout():
	if playerIsInRange and health>0 and attack:		# Jeżeli gracza znajduje się w polu wzrok ,żyje oraz gracz znajduję się w polu atak strzelaj
		fire()
		
		
func get_dmg(dmg, weaponKnockback):
	if health > 0 :
		
#		# ======= KNOCKBACK ======= #
		if weaponKnockback != 0:
			knockback = -global_position.direction_to(Bufor.PLAYER.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		
		hp-=dmg
		health = hp/max_hp*100
		health_bar.on_health_updated(health)
		health_bar.visible = true
		SoundController.play_hit()
	if health <=0:
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		random_potion()
		for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			main.add_child(coin)
		for summoners in get_tree().get_nodes_in_group(name):
			summoners.queue_free()
		emit_signal("died", self)
		SoundController.play_hit()
		queue_free()
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	
func random_potion():
	rng.randomize()
	var potion
	if is_elite == true:
		potion = int(rng.randi_range(2,3))
	else:
		potion = int(rng.randi_range(0,2))
	print("[INFO]: at " + self.name + ": potion dropped: " + str(potion))
	var tmp
	
	if potion == 0:
		tmp = load("res://Scenes/Loot/20healthPotion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
	elif potion == 1:
		tmp = load("res://Scenes/Loot/50%Potion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
	elif potion == 2:
		tmp = load("res://Scenes/Loot/60healthPotion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
	elif potion == 3:
		tmp = load("res://Scenes/Loot/100%Potion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
