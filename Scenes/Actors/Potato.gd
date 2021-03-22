extends KinematicBody2D

signal died(body)

var player = null
var move = Vector2.ZERO
export var speed = 0.5
export var dps = 5
var right = 1
var attack = false
var max_hp = 20
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
	
	if player != null and !attack and health>0:
		$Sprite.scale.x = right
		move = position.direction_to(player.position) * speed
		if player.position.x-self.position.x < 0:
			right = -1
		else:
			right = 1
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")

	move_and_collide(move)

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player":
		player = body

func _on_Wzrok_body_exited(body):

	if body != self and body.name == "Player":

		player = null


func _on_Atak_body_entered(body):
	if body != self and body.name == "Player":
		attack = true

func _on_Atak_body_exited(body):
	attack = false

func _on_Timer_timeout():
	if attack and health>0:
		$AnimationPlayer.play("Attack")
		player.take_dmg(dps)
		yield($AnimationPlayer,"animation_finished")


			
func get_dmg(dmg):
	
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
	
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
		$CollisionShape2D.set_deferred("disabled",true)
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
#		var weapon = load("res://Scenes/Loot/Weapon.tscn")
#		weapon = weapon.instance()
#		weapon.WeaponName = drop["weapon"]
#		weapon.position = self.position
#		level.add_child(weapon)
		emit_signal("died", self)
		queue_free()
		
	
		
