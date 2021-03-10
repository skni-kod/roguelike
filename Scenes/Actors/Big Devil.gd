# Big Devil.gd
extends KinematicBody2D
# UWAGA WORK IN PROGRESS
# UWAGA WORK IN PROGRESS
const LASER_SCENE = preload("Laser.tscn") # wczytuję laser jako LASER_SCENE
#const LASER_LOAD = preload("Laser_Load.tscn") # wczytuję laser jako LASER_LOAD
const SPEED = 100 

var player = null
var move = Vector2.ZERO
export var speed = 0.25
export var dps = 1
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

# pozycje do celowania i strzelania
var hit_pos
var target
var laser_color = Color(1.0, 0, 0, 0.1)
 
func _ready():
	health_bar.on_health_updated(health)
	$Laser_Load.visible = false
	$Timer.stop()
	
func _physics_process(delta):
	move = Vector2.ZERO
	if target != null and int(delta*100) % 5 == 0:
		aim()
	if player != null and health>0:
		$Sprite.scale.x = right
		move = position.direction_to(player.position) * -speed
		if player.position.x-self.position.x < 0:
			right = 1
		else:
			right = -1
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
		target = body
		attack = true
		$Laser_Load.visible = true
		$Timer.start()
	
func _on_Atak_body_exited(body):
	if body.name == "Player":
		$Laser_Load.visible = false
		target = null
		attack = false
		$Timer.stop()

# celowanie na podstawie bool result, który określa czy ray intersectuje
# z daną collision_mask + celuje w gracza
func aim(): 
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, target.position, [self], collision_mask)
	if result:
		hit_pos = result.position
		if result.collider.name == "Player":
			$Laser.rotation = (target.position - position).angle() + 2 * Vector2(0.5, -0.5).angle() + 10 * (target.position + target.velocity) # doprecyzowanie rotacji raya
		
		
# strzelanie do target -> pozycja (Vector2) 
func shoot(target_poz):
	$AnimationPlayer.play("Attack")
	var laser = LASER_SCENE.instance()
	var main = get_tree().get_root().find_node("Main", true, false)
	laser.position = self.position + $Position2D.position
	laser.player_Pos = get_tree().get_root().find_node("Player", true, false).position
	main.add_child(laser)
		
		
func _on_Timer_timeout():
	if health>0 and attack and target: # funkcje gdy żyje
		shoot(target.position)
		$Laser_Load.visible = false
		$Cooldown.start()
		
		
func _on_Cooldown_timeout():
	if health>0 and attack and target:
		$Laser_Load.visible = true
		$Timer.start()
		
		
func get_dmg(dmg):
	if health>0:
		if player.position.x-self.position.x < 0:
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
		


