# Big Devil.gd

# LEGENDA
# BD - Big Devil

extends KinematicBody2D
const LASER_SCENE = preload("Laser.tscn") # wczytuję laser jako LASER_SCENE
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
	health_bar.on_health_updated(health) # wczytuję życie do paska życia
	$Laser_Load.visible = false
	
func _physics_process(delta):
	move = Vector2.ZERO
	if target != null and delta == 0:
		aim() # strzał w czasie, gdy jakiś target został wyznaczony
	if player != null and health>0: # gdy BD żyje oraz w jego zasięgu jest gracz
		$Sprite.scale.x = right
		move = position.direction_to(player.position) * -speed # odsuwanie się od gracza, gdy jest za blisko
		if player.position.x-self.position.x < 0: # ustawianie zwrotu sprite w zależności od pozycji gracza wobec BD
			right = 1
			$AnimationPlayer.play("Walk") 
		else:
			right = -1
			$AnimationPlayer.play("Walk") 
	elif !attack and health>0: # gdy nie atakuje, a żyje, to wykojune animację Idle
		$AnimationPlayer.play("Idle")
	move_and_collide(move) # ruch o Vector2D move
	
func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player":
		player = body # player zostaje przypisane jako body, które jest Playerem, gdy wejdzie w Wzrok
		
func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player":
		player = null # player zostaje przypisany jako null/nic jak Player opuści Wzrok
		
		
func _on_Atak_body_entered(body):
	if body != self and body.name == "Player": # gdy Player wejdzie do sfery Atak
		target = body
		attack = true # włącza atak
		$Laser_Load.emit = true # ładowanie lasera zostaje włączone
		$Timer.start() # włącza Timer
	
func _on_Atak_body_exited(body):
	if body.name == "Player": # gdy Player wyjdzie ze sfery Atak
		$Laser_Load.emit = false # ładowanie lasera zostaje wyłączone
		target = null 
		attack = false # wyłącza atak
		$Timer.stop() # wyłącza Timer

# celowanie na podstawie bool result, który określa czy ray intersectuje
# z daną collision_mask + celuje w gracza
func aim(): 
	var space_state = get_world_2d().direct_space_state # pozyskanie obecnego stanu fizycznego danego World2D w celu wyznaczeń kolizji
	var result = space_state.intersect_ray(position, target.position, [self], collision_mask) # rzucanie rayem, aby intersectował z danym targetem
	if result:
		hit_pos = result.position # pozycja trafienia to pozycja trafienia przez ray targetu
		if result.collider.name == "Player":
			$Laser.rotation = (target.position - position).angle() + 2 * Vector2(0.5, -0.5).angle() + 10 * (target.position + target.velocity) # doprecyzowanie rotacji raya
		
		
# strzelanie do target -> pozycja (Vector2) 
func shoot(target_poz):
	$AnimationPlayer.play("Attack")
	var laser = LASER_SCENE.instance() # załadowanie instancji lasera
	var main = get_tree().get_root().find_node("Main", true, false) # pozyskanie danego node sceny
	laser.position = self.position + $Position2D.position # ustawienie pozycji lasera na pozycję Position2D
	laser.player_Pos = get_tree().get_root().find_node("Player", true, false).position # pozyskanie pozycji gracza
	main.add_child(laser) # dodanie lasera do sceny
		
		
func _on_Timer_timeout():
	if health>0 and attack and target: # funkcje gdy żyje
		shoot(target.position) # strzał w stronę pozycji targetu
		$Laser_Load.emit = false # ładowanie lasera zostaje zatrzymane
		$Cooldown.start() # timer Cooldown zostaje aktywowany
		
		
func _on_Cooldown_timeout():
	if health>0 and attack and target: # gdy BD żyje, atakuje i ma cel
		$Laser_Load.emit = true # Laser Load zostaje emitowany
		$Timer.start() # Timer zostaje aktywowany w celu oddania strzału
		
		
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
		


