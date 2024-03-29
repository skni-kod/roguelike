extends KinematicBody2D

signal died(body)

onready var statusEffect = get_node("../../../UI/StatusBar")

var playerIsInRange: bool = false # bool variable that changes to true when the Player is in attack range
var move = Vector2.ZERO
export var speed = 1.7
export var dps = 8
var right = 1
var attack = false
var max_hp = 42
var hp:float = max_hp

export var health = 100
var drop = {"minCoins":0,"maxCoins":5}
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0.5
# === ===================== === #

# === ZMIENNE DO ELITY === #
var is_elite = false
onready var main := get_tree().get_root().find_node("Main", true, false)



func elite():
	rng.randomize()
	var rgb = rng.randi_range(1,2) 	# od 1 do 3 rodzaj elity 
	var elite = rng.randf_range(1,100)	# zakres losowania szansy na stworzenie elity
	if elite <=25 :		# w jakim zakresie musi być wylosowana liczba 
		is_elite = true		# może się przydać później 
		if rgb == 1 :	#rodzaj zielony więcej hp wolniejszy
			$Sprite.modulate = Color(0, 1, 0, 1 )
			max_hp = max_hp * 1.5	# zwiększenie zdrowia o 1.5 razy
			hp = max_hp
			health = 100
			speed -= 0.1
		if rgb == 2 :	# rodzaj niebieski szybciej atakuje i szybciej biega
			$Sprite.modulate = Color( 0, 0, 1, 1 )
			speed += 0.3
			$Timer.set_wait_time(0.50)
# === ===================== === #

func _ready():
	elite()
	health_bar.on_health_updated(health)
	
func _physics_process(delta):
	
	var level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
	var player = level.get_node("Player")
	if player.equipped_armor == "Ninja":
		$Wzrok.scale = Vector2(0.5,0.5)
	else:
		$Wzrok.scale = Vector2(1,1)
	
	move = Vector2.ZERO
	if playerIsInRange and !attack and health>0 and Bufor.PLAYER != null: #jezeli playera jest w polu widzenia i cuck jest zywy
		$Sprite.scale.x= right
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO and Bufor.PLAYER != null:
			move = global_position.direction_to(Bufor.PLAYER.global_position) * speed #parametr, ktory przekazywany jest do move_and_collide() na samym dole funkcji, powoduje ze cuck idzie w strone playera
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if Bufor.PLAYER.global_position.x - self.global_position.x < 0: #sprite cucka jest obrocony w zaleznosci od ponizszego warunku
			right = -1
		else:
			right = 1
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
	
func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": #jezeli Player wszedl w pole wzrok (wzrok -> collisionshape) to:
		playerIsInRange = true
func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #jezeli Player wyszedl z pola wzrok (wzrok -> collisionshape) to:
		playerIsInRange = false
func  _on_Atak_body_entered(body):
	if body != self and body.name == "Player": #jezeli Player wszedl w pole ataku (atak -> collisionshape) to:
		attack = true #cuck atakuje playera
		
func _on_Atak_body_exited(body): # jezeli Player wyszedl z pola ataku (atak -> collisionshape) to:
	attack = false #cuck przestaje atakowac playera
	
func _on_Timer_timeout():
	if attack and health>0 and Bufor.PLAYER:
		statusEffect.bleeding = true
		Bufor.PLAYER.take_dmg(dps, enemyKnockback, self.global_position) #wywolywana jest funkcja zabierania dmg playerowi
		
		if Bufor.PLAYER.equipped_armor == "Cactus":
			get_dmg(dps,enemyKnockback)
		
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer,"animation_finished")
		
func get_dmg(dmg, weaponKnockback): 
	if health>0: #jezeli cuck zyje
		
#		# ======= KNOCKBACK ======= #
		if weaponKnockback != 0:
			knockback = -global_position.direction_to(Bufor.PLAYER.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		
		hp -= dmg
		health = hp/max_hp*100
		health_bar.on_health_updated(health)
		health_bar.visible = true
		SoundController.play_hit()
		var text = floating_dmg.instance()
		text.amount = dmg
		text.type = "Damage"
		add_child(text)
	if health<=0: #jezeli cuck nie zyje
		attack = false 
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die") #odtwarzana animacja umierana
		yield($AnimationPlayer,"animation_finished")
		var level = get_tree().get_root().find_node("Main",true,false)
		rng.randomize()
		if is_elite == true:
			random_potion()
		var coins = rng.randf_range(drop["minCoins"], drop["maxCoins"])
		for _i in range(0,coins): #losowane ilosc coinsow ktore wypadna po zabiciu
			randomPosition= Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			level.add_child(coin)
		var text = floating_dmg.instance()
		text.amount = dmg
		text.type = "Damage"
		add_child(text)
		emit_signal("died", self)
		SoundController.play_hit()
		queue_free()

func random_potion():
	rng.randomize()
	var potion = int(rng.randi_range(0,1))
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
