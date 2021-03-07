extends KinematicBody2D

onready var BULLET_SCENE = preload("res://Scenes/Actors/CucksBullet.tscn")

var player = null
var move = Vector2.ZERO
export var speed = 0.1
export var dps = 10
var right = 1
var max_hp = 10
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
	
	if player !=null:
		$Sprite.scale.x= right
		move = position.direction_to(player.position) * speed
		if player.position.x - self.position.x < 0:
			right = -1
		else:
			right = 1
		$AnimationPlayer.play("Walk")
	elif player == null:
		move = Vector2.ZERO
		$AnimationPlayer.play("Idle")
		
	move = move.normalized()
	move = move_and_collide(move)

func _on_Area2D_body_entered(body):
	if body != self and body.name == "Player":
		player = body


func _on_Area2D_body_exited(body):
	player = null

func fire():
	var bullet = BULLET_SCENE.instance()
	bullet.position = get_global_position()
	bullet.player = player
	get_parent().add_child(bullet)
	$Timer.set_wait_time(1)
	$AnimationPlayer.play("Attack")
	yield($AnimationPlayer,"animation_finished")

func _on_Timer_timeout():
	if player !=null and health>0:
		fire()
		
		
func get_dmg(dmg):
	if health>0:
		if player.position.x - self.position.x < 0:
			self.position.x += 10
		else:
			self.position.x -= 10
		hp -= dmg
		health = hp/max_hp*100
		$AnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
	if health<=0:
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		var level = get_tree().get_root().find_node("Main",true,false)
		rng.randomize()
		var coins = rng.randf_range(drop["minCoins"], drop["maxCoins"])
		for i in range(0,coins):
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

