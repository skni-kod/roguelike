extends KinematicBody2D

var player = null
var move = Vector2.ZERO
export var speed = 3
export var dps = 10
var right = 1
var attack = false
var max_hp = 50
var hp:float = max_hp

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
	
	if player !=null and !attack and health>0: #jezeli playera jest w polu widzenia i jest zywy
		$Sprite.scale.x= right
		move = position.direction_to(player.position) * speed #parametr, ktory przekazywany jest do move_and_collide() na samym dole funkcji, powoduje ze cuck idzie w strone playera
		if player.position.x - self.position.x < 0: #sprite cucka jest obrocony w zaleznosci od ponizszego warunku
			right = -1
		else:
			right = 1
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")
	
	move_and_collide(move)
	
func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": #jezeli player wszedl w pole wzrok (strzelanie -> collisionshape) to:
		player = body #player juz nie jest nullem, dzieki czemu cuck moze isc w jego strone (patrz -> _physics_process(delta))
		
func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #jezeli player wyszedl z pola wzrok (wzrok -> collisionshape) to:
		player = null #player  jest nullem, dzieki czemu cuck sobie stoi(patrz -> _physics_process(delta))
		
func  _on_Atak_body_entered(body):
	if body != self and body.name == "Player": #jezeli player wszedl w pole ataku (atak -> collisionshape) to:
		attack = true #cuck atakuje playera
		
func _on_Atak_body_exited(body):#jezeli player wyszedl z pola ataku (atak -> collisionshape) to:
	attack = false #cuck przestaje atakowac playera
	
func _on_Timer_timeout():
	if attack and health>0:
		player.take_dmg(self) #wywolywana jest funkcja zabierania dmg playerowi
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer,"animation_finished")
		
func get_dmg(dmg): 
	if health>0: #jezeli cuck zyje
		if player.position.x - self.position.x < 0: #knockback
			self.position.x += 10
		else:
			self.position.x -= 10
		hp -= dmg
		health = hp/max_hp*100
		health_bar.on_health_updated(health)
		health_bar.visible = true
	if health<=0: #jezeli cuck nie zyje
		attack = false 
		$AnimationPlayer.play("Die") #odtwarzana animacja umierana
		yield($AnimationPlayer,"animation_finished")
		var level = get_tree().get_root().find_node("Main",true,false)
		rng.randomize()
		var coins = rng.randf_range(drop["minCoins"], drop["maxCoins"])
		for i in range(0,coins): #losowane coinsow
			randomPosition= Vector2(rng.randf_range(self.position.x-10,self.position.x+10),rng.randf_range(self.position.y-10,self.position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			level.add_child(coin)
		queue_free()
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)		
