# Lil Devil.gd
extends KinematicBody2D
# bazowane na slime.gd
const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
const SPEED = 100 # szybkość fireballa

signal died(body) # sygnał, czy Lil Devil umarł

export var speed = 0.5 # prędkość własna Lil Devila

# deklaracje pomocnych zmiennych
var player = null 
var move = Vector2.ZERO
var right = 1 # zwrot prawo/lewo sprite'a
var attack = false
export var max_hp = 30 # wartość życia Lil Devila
var hp:float = max_hp

export var health = 100 # procentowa wartość życia do healthbara
onready var health_bar = $HealthBar # deklaracja odwołania do node $HealthBar

var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń

var drop = {"minCoins":0,"maxCoins":5} # zakres minimalnej i maksymalnej ilości pieniędzy
var randomPosition # zmienna losowej pozycji dla coinsów
var rng = RandomNumberGenerator.new() # zmienna generująca nowy generator losowej liczby

# === STATUS EFFECT VARIABLES === #
var ownStatusEffects = {}
# === ======================= === #

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0
# === ===================== === #
 
func _ready():
	health_bar.on_health_updated(health)
	$Timer.stop()


func _physics_process(delta):
	move = Vector2.ZERO
	if player != null and health>0:
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * -speed # odsuwanie się od gracza, gdy jest za blisko
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if player.global_position.x - self.global_position.x < 0: # warunek odwracania się sprite względem pozycji playera (do playera, od playera)
			$Sprites.scale.x = -0.5 # sprite'y zostają obrócone
		else:
			$Sprites.scale.x = 0.5 # sprite'y zostają obrócone
		$BodyAnimationPlayer.play("Walk") # Animacja chodzenia zostaje włączona
	elif !attack and health>0:
		$HeadAnimationPlayer.play("Idle") # Animacja Idle zostaje aktywowana
	
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === #


func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": # gdy body o nazwie Player wejdzie do Area2D o nazwie Wzrok, ustawia player jako body
		player = body


func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": # gdy body o nazwie Player wyjdzie z Area2D o nazwie Wzrok, ustawia player jako body
		player = null


func _on_Atak_body_entered(body):
	if body != self and body.name == "Player": # gdy body o nazwie Player wejdzie do Area2D o nazwie Atak, włącza przełącznik attack
		attack = true
		$Timer.start() # gdy wchodzi player do sfery ataku, to startuje timer

func _on_Atak_body_exited(body):
	if body.name == "Player": # gdy body o nazwie Player wyjdzie z Area2D o nazwie Atak, wyłącza przełącznik attack
		attack = false
		$Timer.stop() # gdy wychodzi player ze sfery ataku, to stopuje timer


func _on_Timer_timeout():
	if attack and health>0: # gdy przełącznik attack jest włączony i Lil Devil żyje, to wykonuje funkcje
		$HeadAnimationPlayer.play("Attack") # włącza animację ataku gdy animacja Idle nie jest włączona
		shoot() # wykonanie funkcji shoot()


func shoot():
	var fireball = FIREBALL_SCENE.instance() # stworzenie nowej instancji fireballa
	var main = get_tree().get_root().find_node("Main", true, false) # odwołanie do node Main  
	fireball.position = self.global_position + $Position2D.position  # pozycja fireballa to pozycja elementu $Position2D Lil Devila ( w jego paszczy )
	fireball.player_Pos = get_tree().get_root().find_node("Player", true, false).global_position # wprowadzam player_Pos do fireballa jako pozycję playera
	main.add_child(fireball) # ustawiam fireballa jako child maina


func get_dmg(dmg, weaponKnockback):
	if health>0:
		
		# ======= KNOCKBACK ======= #
		knockback = -global_position.direction_to(player.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
			
		hp -= dmg
		health = hp/max_hp*100
		# Animacje obrażeń zostają aktywowane na sprite Body i Head
		$BodyAnimationPlayer.play("Hurt")
		$HeadAnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
		
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true) # maska kolizji zostaje dezaktywowana aby nie móc atakować po śmierci
		# Animacje śmierci zostają aktywowane na sprite'ach
		$BodyAnimationPlayer.play("Die")
		$HeadAnimationPlayer.play("Die")
		# Czekanie aż animacje zostaną zakończone
		yield($BodyAnimationPlayer,"animation_finished")
		yield($HeadAnimationPlayer,"animation_finished")
		var level = get_tree().get_root().find_node("Main", true, false) # odwołanie do node'a Main
		rng.randomize() # losowanie generatora liczb
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"]) # wylosowanie ilości coinsów
		for i in range(0,coins): # pętla tworząca monety
			randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) # precyzowanie losowej pozycji monet
			var coin = load("res://Scenes/Loot/GoldCoin.tscn") # zmienna coin to odwołanie do sceny GoldCoin.tscn
			coin = coin.instance() # coin staje się nową instacją coina
			coin.position = randomPosition # pozycją coina jest wylosowana wcześniej pozycja
			level.add_child(coin) # coin jest dzieckiem level
		emit_signal("died", self) # zostaje wyemitowany sygnał, że Lil Devil umarł
		queue_free() # instancja Lil Devila zostaje usunięta
		
	# floating_dmg zostaje stworzony poprzed dodanie nowej instancji sceny floating_dmg jako zmienna text
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
		
