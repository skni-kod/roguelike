# Lil Devil.gd
extends KinematicBody2D
# bazowane na slime.gd
const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
const SPEED = 100 # szybkość fireballa

var player = null # shit i atrybuty obiektu i zmienne przydatne potem
var move = Vector2.ZERO
export var speed = 0.5
var right = 1
var attack = false
export var max_hp = 30
var hp:float = max_hp

export var health = 100
var drop = {"minCoins":0,"maxCoins":5}
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

 
func _ready():
	health_bar.on_health_updated(health)
	$Timer.stop()


func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and health>0:
		$Sprite.scale.x = right
		move = position.direction_to(player.position) * -speed # poruszanie się w stronę odwrotną od playera, uciekanie od niego (dlatego -speed)
		if player.position.x-self.position.x < 0: # warunek odwracania się sprite względem pozycji playera (do playera, od playera)
			right = 1
		else:
			right = -1
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")
	move_and_collide(move)


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
		if !$AnimationPlayer.play("Idle"):
			$AnimationPlayer.play("Attack") # włącza animację ataku gdy animacja Idle nie jest włączona
		shoot() # wykonanie funkcji shoot()


func shoot():
	var fireball = FIREBALL_SCENE.instance() # stworzenie nowej instancji fireballa
	var main = get_tree().get_root().find_node("Main", true, false) 
	fireball.position = self.position + $Position2D.position  # pozycja fireballa to pozycja elementu $Position2D Lil Devila ( w jego paszczy )
	fireball.player_Pos = get_tree().get_root().find_node("Player", true, false).position # wprowadzam player_Pos do fireballa jako pozycję playera
	main.add_child(fireball) # ustawiam fireballa jako child maina


# do opisania po reworku
func get_dmg(dmg):
	if health>0:
#		if player.position.x-self.position.x < 0:
#			self.position.x += 10
#		else:
#			self.position.x -= 10
			
		hp -= dmg
		health = hp/max_hp*100
		$AnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
		
	if health<=0:
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		var level = get_tree().get_root().find_node("Main", true, false)
		rng.randomize()
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.position.x-10,self.position.x+10),rng.randf_range(self.position.y-10,self.position.y+10))
			var coin = load("res://Scenes/Loot/GoldCoin.tscn")
			coin = coin.instance()
			coin.position = randomPosition
			level.add_child(coin)
		queue_free()
		
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
		
