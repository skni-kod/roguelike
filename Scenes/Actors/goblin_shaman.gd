extends KinematicBody2D

var player = null	#Zmienna przechowująca węzeł gracza
var move = Vector2.ZERO		#Zmienna inicjująca wektor poruszania
export var speed = 0.4		#Zmienna przechowująca szybkość poruszania
var right = 0.1		#Kierunek obrócenia
var attack = false		#Czy atakuje
var max_hp = 50		#Zmienna przechowywująca ilość życia
var hp:float = max_hp	#Zmienna przechowuje ilość pozostałego życia
var summon = false		#Czy przywołuje
onready var main := get_tree().get_root().find_node("Main", true, false)

export var health = 100		#Pozostałe życie w procentach
var drop = {"minCoins":0,"maxCoins":5}	#Przedział definiujący ile goblin shaman może zostawić po sobie coinów
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and health>0 and !summon :	# wykonuje się jeśli widzi gracza i nie atakuje oraz żyje
		$sprite.scale.x = right		# obrót w stronę gracza
		move = -position.direction_to(player.position) * speed		# Ustaw wektor na ruch w stronę gracza
		if player.position.x-self.position.x < 0:		# sprawdzenie w którą stone jest obrócony gracz
			right = -0.1
		else:
			right = 0.1
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")

	move_and_collide(move)
	

func summon():		# funkcja odpowiadająca za przywoływanie goblinów
	var goblinscene = load("res://Scenes/Actors/Little_Goblin.tscn")
	goblinscene = goblinscene.instance()
	var spawnposition = Vector2.ZERO
	if right >0:
		spawnposition = Vector2(self.position.x+20,self.position.y)
	else:
		spawnposition = Vector2(self.position.x-20,self.position.y)
	goblinscene.position=spawnposition
	main.add_child(goblinscene)
	
func fire():		# funkcja odpowiadająca za tworzenie pocisków
	var ball_scene = load("res://Scenes/Actors/goblin_ball.tscn")
	ball_scene= ball_scene.instance()
	ball_scene.position = self.position + $Position2D.position
	ball_scene.player_Pos = get_tree().get_root().find_node("Player", true, false).position
	main.add_child(ball_scene)
	
func _on_wzrok_body_entered(body):
	if body != self and body.name == "Player":	#Jeśli gracz znajduję się w polu wzrok przypisz jego węzeł do zmiennej i przywołuj
		player = body
		summon = true

func _on_wzrok_body_exited(body):		#Jeżeli gracz nie znajduję się w polu wzrok to zmień player na null i nie przywołuj 
	if body != self and body.name == "Player":
		player = null
		summon = false
	
func _on_Area2D_body_entered(body):		#Jeżeli gracz wszedł w pole atak (Area2D) to atakuj nie przywołuj
	if body != self and body.name == "Player":
		attack = true
		summon = false 

func _on_Area2D_body_exited(body):		#Jeżeli gracz wyszedł z pola atak (Area2D) to przywołuj nie atakuj
	if body.name == "Player":
		attack = false
		summon = true
		
func _on_Timer_timeout():
	if player!=null and health>0 and !attack:		# Jeżeli gracza znajduje się w polu wzrok ,żyje oraz nie atakuje to przywołuje gobliny
		$Timer.set_wait_time(4.0)
		summon()

	if player != null and health>0 and attack:		# Jeżeli gracza znajduje się w polu wzrok ,żyje oraz gracz znajduję się w polu atak strzelaj
		$Timer.set_wait_time(1.0)
		fire()
		
		
func get_dmg(dmg):
	if health > 0 :
		if player.position.x-self.position.x < 0:
			self.position.x += 10
		else:
			self.position.x -= 10
		hp-=dmg
		health = hp/max_hp*100
		health_bar.on_health_updated(health)
		health_bar.visible = true
	if health <=0:
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.position.x-10,self.position.x+10),rng.randf_range(self.position.y-10,self.position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			main.add_child(coin)
		queue_free()
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
