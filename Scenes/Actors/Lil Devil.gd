# Lil Devil.gd
extends KinematicBody2D
# bazowane na slime.gd
const FIREBALL_SCENE = preload("Fireball.tscn") # ładuję fireballa jako FIREBALL_SCENE
const SPEED = 100 # szybkość fireballa

signal died(body)

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
		move = -global_position.direction_to(player.global_position) * speed # poruszanie się w stronę odwrotną od playera, uciekanie od niego (dlatego -speed)
		if player.global_position.x - self.global_position.x < 0: # warunek odwracania się sprite względem pozycji playera (do playera, od playera)
			$Sprites.scale.x = -0.5
		else:
			$Sprites.scale.x = 0.5
		$BodyAnimationPlayer.play("Walk")
	elif !attack and health>0:
		#$BodyAnimationPlayer.play("Idle")
		$HeadAnimationPlayer.play("Idle")
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
		$HeadAnimationPlayer.play("Attack") # włącza animację ataku gdy animacja Idle nie jest włączona
		shoot() # wykonanie funkcji shoot()


func shoot():
	var fireball = FIREBALL_SCENE.instance() # stworzenie nowej instancji fireballa
	var main = get_tree().get_root().find_node("Main", true, false) 
	fireball.position = self.global_position + $Position2D.position  # pozycja fireballa to pozycja elementu $Position2D Lil Devila ( w jego paszczy )
	fireball.player_Pos = get_tree().get_root().find_node("Player", true, false).global_position # wprowadzam player_Pos do fireballa jako pozycję playera
	main.add_child(fireball) # ustawiam fireballa jako child maina


func get_dmg(dmg):
	if health>0:
#		if player.position.x-self.position.x < 0:
#			self.position.x += 10
#		else:
#			self.position.x -= 10
			
		hp -= dmg
		health = hp/max_hp*100
		$BodyAnimationPlayer.play("Hurt")
		$HeadAnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
		
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true)
		$BodyAnimationPlayer.play("Die")
		$HeadAnimationPlayer.play("Die")
		yield($BodyAnimationPlayer,"animation_finished")
		yield($HeadAnimationPlayer,"animation_finished")
		var level = get_tree().get_root().find_node("Main", true, false)
		rng.randomize()
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10))
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
		
