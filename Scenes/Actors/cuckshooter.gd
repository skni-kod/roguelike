extends KinematicBody2D

onready var BULLET_SCENE = preload("res://Scenes/Actors/CucksBullet.tscn") #zaladowanie sceny pocisku cuckshootera
onready var main = get_tree().get_root().find_node("Main", true, false)

signal died(body)

var playerIsInRange: bool = false # bool variable that changes to true when the Player is in attack range
var move = Vector2.ZERO
export var speed = 0.5 
var right = 1
export var max_hp = 40
var hp:float = max_hp
var attack = false #sluzy do informowania czy Player jest w polu strzelanie (strzelanie -> colisionshape2d)
var eyes = false #sluzy do informowania czy Player jest w polu wzrok (wzrok -> collisionshape2d)

export var health = 100
var drop = {"minCoins":0,"maxCoins":5}
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 2 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0.3
var enemyPos
# === ===================== === #
# === ZMIENNE DO ELITY === #
var is_elite = false

func elite():
	rng.randomize()
	var rgb = rng.randi_range(1,2) 	# od 1 do 3 rodzaj elity 
	var elite = rng.randf_range(1,100)	# zakres losowania szansy na stworzenie elity
	if elite <=25 :		# w jakim zakresie musi być wylosowana liczba 
		is_elite = true		
		if rgb == 1 :	#rodzaj zielony więcej hp wolniejszy
			$Sprite.modulate = Color(0, 1, 0, 1 )
			max_hp = max_hp * 1.5	# zwiększenie zdrowia o 1.5 razy
			hp = max_hp
			health = 100
			speed -= 0.1
		if rgb == 2 :	# rodzaj niebieski szybciej atakuje i szybciej biega
			$Sprite.modulate = Color( 0, 0, 1, 1 )
			speed += 0.3
			$Timer.set_wait_time(0.70)
# === ===================== === #

func _ready():
	elite()
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	enemyPos = self.global_position
	if playerIsInRange and health>0: #jezeli playera jest w polu widzenia i jest zywy
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO and Bufor.PLAYER != null:
			move = global_position.direction_to(Bufor.PLAYER.global_position) * speed #parametr, ktory przekazywany jest do move_and_collide() na samym dole funkcji, powoduje ze cuck idzie w strone playera
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		$Sprite.scale.x= right #sprite cucka jest obrocony w zaleznosci od ponizszego warunku
		if Bufor.PLAYER.global_position.x - self.global_position.x < 0:
			right = -1 #obraca sie sprite cucka w zaleznosci od umiejscowienia playera
		else:
			right = 1
		if eyes:
			if !attack: #jezeli Player znajduje sie w polu widzenia (wzrok -> collisionshape2d), a nie znajduje sie w polu strzelania (strzelanie -> collisionshape2d)
				$AnimationPlayer.play("Walk") #odtwarzana jest animacja chodzenia cucka
			else:
				$AnimationPlayer.play("Attack") #odtwarzana jest animacja ataku cucka
	elif !playerIsInRange and health>0:
		move = Vector2.ZERO #parametr przekazywany do move_and_collide, z racji tego ze jest .ZERO to sobie stoi
		$AnimationPlayer.play("Idle") #odtwarzana jest animacja spoczynku
	
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO and Bufor.PLAYER != null:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === # 

func _on_Area2D_body_entered(body):
	if body != self and body.name == "Player": #jezeli Player wszedl w pole strzelanie (strzelanie -> collisionshape) to:
		speed = -0.1
		attack = true #i ciupie w playera

func _on_Area2D_body_exited(body): 
	if body != self and body.name == "Player": #jezeli Player wyszedl z pola strzelanie (strzelanie -> collisionshape) to:
		attack = false #cuck przestaje strzelac
		speed = 0.5 #zmienia sie predkosc cucka dzieki czemu zaczyna sie poruszac

		
func _on_Wzrok_body_entered(body):  
	if body != self and body.name == "Player": #jezeli Player wszedl w pole wzrok (wzrok -> collisionshape) to:
		playerIsInRange = true
		eyes = true #jezeli jest w polu wzrok a nie jest w polu strzelanie to odgrywana jest animacja chodzenia (patrz ->_physics_process(delta))

func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #jezeli Player wyszedl z pola wzrok (wzrok -> collisionshape) to:
		playerIsInRange = false
		eyes = false # Player wyszedl z pola widzenia, odgrywana jest animacja spoczynku (patrz ->_physics_process(delta))

func fire():
	var bullet = BULLET_SCENE.instance() #tworzy sie instancja bulletu
	bullet.position = get_global_position() + $Position2D.position
#	bullet.Player = Player #Przekazywany jest obiekt gracza dzięki któremu później pocisk wylicza wektor w którym kierunku ma lecieć pocisk.
	main.add_child(bullet)
	#$Timer.set_wait_time(0.75) #powtarzane jest co pol sekundy, dopoki Player jest w polu strzelanie

func _on_Timer_timeout():
	if playerIsInRange and health>0 and attack: #jezeli Player znajduje sie w polu strzelanie to:
		fire() #wywolywana jest funkcja strzelania
			
func get_dmg(dmg, weaponKnockback):
	if health>0 and Bufor.PLAYER != null:
		
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
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished") 
		var level = get_tree().get_root().find_node("Main",true,false)
		if is_elite == true:
			random_potion()
		rng.randomize() #zmienna sluzaca do losowania coinsow
		var coins = rng.randf_range(drop["minCoins"], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition= Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) #"losowanie" pozycji monety
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
	var potion
	potion = int(rng.randi_range(1,2))
	print("[INFO]: at " + self.name + ": potion dropped: " + str(potion))
	var tmp
	
	if potion == 1:
		tmp = load("res://Scenes/Loot/50%Potion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
	elif potion == 2:
		tmp = load("res://Scenes/Loot/60healthPotion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
