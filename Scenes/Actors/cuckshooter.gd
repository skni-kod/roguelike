extends KinematicBody2D

onready var BULLET_SCENE = preload("res://Scenes/Actors/CucksBullet.tscn") #zaladowanie sceny pocisku cuckshootera
onready var main = get_tree().get_root().find_node("Main", true, false)

signal died(body)

var player = null
var move = Vector2.ZERO
export var speed = 0.5 
var right = 1
export var max_hp = 10
var hp:float = max_hp
var attack = false #sluzy do informowania czy player jest w polu strzelanie (strzelanie -> colisionshape2d)
var eyes = false #sluzy do informowania czy player jest w polu wzrok (wzrok -> collisionshape2d)

export var health = 100
var drop = {"minCoins":0,"maxCoins":5}
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	if player !=null and health>0: #jezeli playera jest w polu widzenia i jest zywy
		move = global_position.direction_to(player.global_position) * speed #parametr, ktory przekazywany jest do move_and_collide() na samym dole funkcji, powoduje ze cuck idzie w strone playera
		$Sprite.scale.x= right #sprite cucka jest obrocony w zaleznosci od ponizszego warunku
		if player.global_position.x - self.global_position.x < 0:
			right = -1 #obraca sie sprite cucka w zaleznosci od umiejscowienia playera
		else:
			right = 1
		if eyes:
			if !attack: #jezeli player znajduje sie w polu widzenia (wzrok -> collisionshape2d), a nie znajduje sie w polu strzelania (strzelanie -> collisionshape2d)
				$AnimationPlayer.play("Walk") #odtwarzana jest animacja chodzenia cucka
			else:
				$AnimationPlayer.play("Attack") #odtwarzana jest animacja ataku cucka
	elif player == null and health>0:
		move = Vector2.ZERO #parametr przekazywany do move_and_collide, z racji tego ze jest .ZERO to sobie stoi
		$AnimationPlayer.play("Idle") #odtwarzana jest animacja spoczynku
	move_and_collide(move) 

func _on_Area2D_body_entered(body):
	if body != self and body.name == "Player": #jezeli player wszedl w pole strzelanie (strzelanie -> collisionshape) to:
		speed = 0 #cuck sobie stoi
		attack = true #i ciupie w playera

func _on_Area2D_body_exited(body): 
	if body != self and body.name == "Player": #jezeli player wyszedl z pola strzelanie (strzelanie -> collisionshape) to:
		attack = false #cuck przestaje strzelac
		speed = 0.5 #zmienia sie predkosc cucka dzieki czemu zaczyna sie poruszac
		
func _on_Wzrok_body_entered(body):  
	if body != self and body.name == "Player": #jezeli player wszedl w pole wzrok (wzrok -> collisionshape) to:
		player = body #player juz nie jest nullem, dzieki czemu cuck moze isc w jego strone (patrz -> _physics_process(delta))
		eyes = true #jezeli jest w polu wzrok a nie jest w polu strzelanie to odgrywana jest animacja chodzenia (patrz ->_physics_process(delta))

func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #jezeli player wyszedl z pola wzrok (wzrok -> collisionshape) to:
		player = null #player  jest nullem, dzieki czemu cuck sobie stoi(patrz -> _physics_process(delta))
		eyes = false #player wyszedl z pola widzenia, odgrywana jest animacja spoczynku (patrz ->_physics_process(delta))

func fire():
	var bullet = BULLET_SCENE.instance() #tworzy sie instancja bulletu
	bullet.position = get_global_position() + $Position2D.position
	bullet.player = player #Przekazywany jest obiekt gracza dzięki któremu później pocisk wylicza wektor w którym kierunku ma lecieć pocisk.
	main.add_child(bullet)
	$Timer.set_wait_time(0.75) #powtarzane jest co pol sekundy, dopoki player jest w polu strzelanie

func _on_Timer_timeout():
	if player !=null and health>0 and attack: #jezeli player znajduje sie w polu strzelanie to:
		fire() #wywolywana jest funkcja strzelania
			
func get_dmg(dmg):
	if health>0:
#		if player.position.x - self.position.x < 0: #knockback
#			self.position.x += 10
#		else:
#			self.position.x -= 10
		hp -= dmg
		health = hp/max_hp*100
		health_bar.on_health_updated(health) 
		health_bar.visible = true 
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished") 
		var level = get_tree().get_root().find_node("Main",true,false)
		rng.randomize() #zmienna sluzaca do losowania coinsow
		var coins = rng.randf_range(drop["minCoins"], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition= Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10)) #"losowanie" pozycji monety
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			level.add_child(coin)
		emit_signal("died", self)
		queue_free()
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)		
