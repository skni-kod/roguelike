# Slime.gd
extends KinematicBody2D
#slime

signal died(body)

var player = null #Zmienna przechowująca węzeł gracza
var move = Vector2.ZERO #Zmienna inicjująca wektor poruszania
export var speed = 0.5 #Zmienna przechowująca szybkość poruszania
export var dps = 5 #Zmienna przechowująca wartość ataku
var right = 1 #Czy slime jest obrócony w prawo
var attack = false #Czy slime jest w trakcie ataku
var max_hp =61 #Zmienna definiująca ilość życia
var hp:float = max_hp #Zmienna przechowuje ilość pozostałego życia
var health = 100 #Pozostałe życie w procentach
var drop = {"minCoins":0,"maxCoins":5} #Przedział definiujący ile slime może zostawić po sobie coinów
var rng = RandomNumberGenerator.new() #Maszyna Lotto (losuje liczby)

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0.4
# === ===================== === #

# === ZMIENNE DO ELITY === #
var is_elite = false
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
			$Timer.set_wait_time(0.5)
# === ===================== === #

func _ready():
	elite()
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	if player != null and !attack and health>0: #Jeżeli gracz jest w polu widzenia i slime nie atakuje oraz życie jest większe niż 0 to
		$Sprite.scale.x = right #Obróć slime
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * speed # podchodzenie do gracza
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if player.global_position.x-self.global_position.x < 0:
			right = 1 #Slime ma być obrócony w prawo
		else:
			right = -1 #Slime ma być obrócony w lewo
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

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": #Jeśli gracz wejdzie w pole widzenia to przypisz jego węzeł do zmiennej
		player = body

func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #Jeżeli gracz wyjdzie z pola widzenia to zmienną player ustaw na null
		player = null


func _on_Atak_body_entered(body): 
	if body != self and body.name == "Player": #Jeżeli gracz znajdzie się w zasięgu ataku
		attack = true #Slime atakuje

func _on_Atak_body_exited(body): #Jeżeli gracz wyjdzie z zasięgu ataku
	attack = false #Slime nie atakuje

func _on_Timer_timeout():
	if attack and health>0: # funkcje wykonane gdy atakuje
		player.take_dmg(dps, enemyKnockback, self.global_position)
		yield($AnimationPlayer,"animation_finished")
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer,"animation_finished")
			
func get_dmg(dmg, weaponKnockback):
	
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
	
	if health>0:
		
		# ======= KNOCKBACK ======= #
		if weaponKnockback != 0:
			knockback = -global_position.direction_to(player.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		
		#Ustal aktualny poziom zdrowia w procentach
		hp -= dmg
		health = hp/max_hp*100
		$AnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
		SoundController.play_hit()
	#Jeżeli poziom zdrowia spadnie do 0
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		#Po zakończeniu animacji umierania wyrzuć losową liczbę coinów
		var level = get_tree().get_root().find_node("Main", true, false)
		rng.randomize()
		if is_elite == true:
			random_potion()
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			level.add_child(coin)
		emit_signal("died", self)
		SoundController.play_hit()
		queue_free() #Usuń węzeł slime
		
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
