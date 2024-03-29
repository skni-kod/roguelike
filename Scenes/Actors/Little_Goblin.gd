extends KinematicBody2D
#Little_Goblin

signal died(body)

var playerIsInRange: bool = false # bool variable that changes to true when the Player is in attack range
var move = Vector2.ZERO		#Zmienna inicjująca wektor poruszania
export var speed = 1.5		#Zmienna przechowująca szybkość poruszania
export var dps = 10		#Zmienna przechowująca wartość ataku
var right = 0.155		#Kierunek obrócenia
var attack = false		#Czy atakuje
var max_hp = 30		#Zmienna przechowywująca ilość życia
var hp:float = max_hp	#Zmienna przechowuje ilość pozostałego życia

export var health = 100 	#Pozostałe życie w procentach

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0.3
# === ===================== === #

# === ZMIENNE DO ELITY === #
var is_elite = false
var rng = RandomNumberGenerator.new()
onready var main := get_tree().get_root().find_node("Main", true, false)

func elite():
	rng.randomize()
	var rgb = rng.randi_range(0,2) 	# od 1 do 3 rodzaj elity 
	var elite = rng.randf_range(1,100)	# zakres losowania szansy na stworzenie elity
	if elite <=25 :		# w jakim zakresie musi być wylosowana liczba 
		is_elite = true		# może się przydać później 
		if rgb == 0 :	# rodzaj czerwony mocniej biję 
			$Sprite.modulate = Color(1, 0, 0, 1 )	#Zmiana koloru sprite (czerwony , zielony , niebieski, przezroczystość )
			dps = dps * 2
		if rgb == 1 :	#rodzaj zielony więcej hp wolniejszy
			$Sprite.modulate = Color(0, 1, 0, 1 )
			max_hp = max_hp * 1.5	# zwiększenie zdrowia o x razy
			hp = max_hp
			health = 100
			speed -= 0.1
		if rgb == 2 :	# rodzaj niebieski szybciej atakuje i szybciej biega mniej życia
			$Sprite.modulate = Color( 0, 0, 1, 1 )
			speed += 0.3
			max_hp = max_hp * 0.9	# zmiana zdrowia o x razy
			hp = max_hp
			health = 100
			$Timer.set_wait_time(0.6)
# === ===================== === #

func _ready():
	elite()
	health_bar.on_health_updated(health)

func _physics_process(delta):
	
	var level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
	var player = level.get_node("Player")
	if player.equipped_armor == "Ninja":
		$wzrok.scale = Vector2(0.5,0.5)
	else:
		$wzrok.scale = Vector2(1,1)
	
	move = Vector2.ZERO
	if playerIsInRange and !attack and health>0 and Bufor.PLAYER != null:	# wykonuje się jeśli widzi gracza i nie atakuje oraz żyje
		$Sprite.scale.x = right		# obrót w stronę gracza
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO and Bufor.PLAYER != null:
			move = global_position.direction_to(Bufor.PLAYER.global_position) * speed # podhcodzenie do gracza
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if Bufor.PLAYER.global_position.x-self.global_position.x < 0:		# sprawdzenie w którą stone jest obrócony gracz
			right = -0.155
		else:
			right = 0.155
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")
		
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO and Bufor.PLAYER != null:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === #
	
func _on_wzrok_body_entered(body):
	if body != self and body.name == "Player":	#Jeśli gracz znajduję się w polu wzrok przypisz jego węzeł do zmiennej
		playerIsInRange = true

func _on_wzrok_body_exited(body):
	if body != self and body.name == "Player":	#Jeżeli gracz nie znajduję się w polu wzrok to zmień Player na null
		playerIsInRange = false


func _on_Atak_body_entered(body):	
	if body != self and body.name == "Player":	#Jeśli gracz znajduję się w polu atak to ustaw attack na true
		attack = true


func _on_Atak_body_exited(_body): #Jeśli gracz nie znajduję się w polu Atak to ustaw attack na false
	attack = false


func _on_Timer_timeout():		
	if attack and health>0 and Bufor.PLAYER:		#Jeśli gracz znajduję się w polu Atak i goblin żyje to zadaj obrażenia
		Bufor.PLAYER.take_dmg(dps, enemyKnockback, self.global_position)
		
		if Bufor.PLAYER.equipped_armor == "Cactus":
			get_dmg(dps,enemyKnockback)
		
		yield($AnimationPlayer,"animation_finished")
		$AnimationPlayer.play("Atak")
		yield($AnimationPlayer,"animation_finished")

func get_dmg(dmg, weaponKnockback):
	if health > 0 and Bufor.PLAYER != null:
		
		# ======= KNOCKBACK ======= #
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
		var text = floating_dmg.instance()
		text.amount = dmg
		text.type = "Damage"
		add_child(text)
		
	if health <=0 :
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		var _level = get_tree().get_root().find_node("Main", true, false)
		if is_elite == true:
			random_potion()
		var text = floating_dmg.instance()
		text.amount = dmg
		text.type = "Damage"
		add_child(text)
		emit_signal("died", self)
		SoundController.play_hit()
		queue_free()	#Usuń węzeł goblina


func random_potion():
	rng.randomize()
	var potion
	potion = int(rng.randi_range(0,1))
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
