# summon.gd
extends KinematicBody2D
#summon
var playerIsInRange: bool = false # bool variable that changes to true when the Player is in attack range
var move = Vector2.ZERO #Zmienna inicjująca wektor poruszania
export var speed = 0.8 #Zmienna przechowująca szybkość poruszania
var attack = false #Czy summon jest w trakcie ataku
var max_hp = 100 #Zmienna definiująca ilość życia
var hp:float = max_hp #Zmienna przechowuje ilość pozostałego życia
onready var main := get_tree().get_root().find_node("Main", true, false)

var health = 100 #Pozostałe życie w procentach
var drop = {"minCoins":0,"maxCoins":5} #Przedział definiujący ile summon może zostawić po sobie coinów
var rng = RandomNumberGenerator.new() #Maszyna Lotto (losuje liczby)

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 2 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 1
var enemyPos
# === ===================== === #

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	enemyPos = self.global_position
	# === WEKTORY MOVE I KNOCKBACK === #
	if knockback == Vector2.ZERO:
		if playerIsInRange and health>0: #Jeżeli gracz jest w polu widzenia i summon nie atakuje oraz życie jest większe niż 0 to
			move = position.direction_to(Bufor.PLAYER.position) * speed
	else:
		knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
	# === ======================== === #
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === #

func _on_Atak_body_entered(body): 
	if body != self and body.name == "Player": #Jeżeli gracz znajdzie się w zasięgu ataku
		attack = true #summon atakuje
		playerIsInRange = true

func _on_Atak_body_exited(body): #Jeżeli gracz wyjdzie z zasięgu ataku
	if body != self and body.name == "Player":
		attack = false #summon nie atakuje
		playerIsInRange = false

func _on_Timer_timeout():
	if attack and health>0: # funkcje wykonane gdy atakuje
		$Timer.start()
		fire()
		
func get_dmg(dmg, weaponKnockback):
	
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
	
	if health>0:
		# ======= KNOCKBACK ======= #
		if weaponKnockback != 0:
			knockback = -global_position.direction_to(Bufor.PLAYER.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
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
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		#Po zakończeniu animacji umierania wyrzuć losową liczbę coinów
		var boss = get_tree().get_root().find_node("MageBoss", true, false)
		boss.phase_active = false
		boss.find_node("FireTimer", true, false).stop()
		SoundController.play_hit()
		queue_free() #Usuń węzeł summon
		
func fire():		# funkcja odpowiadająca za tworzenie pocisków
	var ball_scene = load("res://Scenes/Actors/MageBoss/SummonWindball.tscn")
	ball_scene= ball_scene.instance()
	ball_scene.position = self.position
	ball_scene.player_Pos = get_tree().get_root().find_node("Player", true, false).position
	main.add_child(ball_scene)
