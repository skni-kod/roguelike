# Big Devil.gd

# LEGENDA
# BD - Big Devil

extends KinematicBody2D


const LASER_SCENE = preload("Laser.tscn") # wczytuję laser jako LASER_SCENE
const SPEED = 100 

signal died(body)

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

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0
var enemyPos
# === ===================== === #

# === ZMIENNE DO STRZELANIA === #
var hit_pos
var target
var laser_color = Color(1.0, 0, 0, 0.1)
var level
var target_pos
var near = false
# === ===================== === #
 
func _ready():
	health_bar.on_health_updated(health) # wczytuję życie do paska życia
	$Laser_Load.emit = false
	level = get_tree().get_root().find_node("Main", true, false)
	
func _physics_process(delta):
	move = Vector2.ZERO
	enemyPos = self.global_position
	# === CELOWANIE === #
	if target != null and delta == 0:
		aim() # strzał w czasie, gdy jakiś target został wyznaczony
	# === ========= === #
	
	if player != null and health>0: # gdy BD żyje oraz w jego zasięgu jest gracz
		$Sprite.scale.x = right
		
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * -speed # odsuwanie się od gracza, gdy jest za blisko
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		
		# === ZWROT SPRITE === #
		if player.global_position.x-self.global_position.x < 0: # ustawianie zwrotu sprite w zależności od pozycji gracza wobec BD
			right = 0.75
			$AnimationPlayer.play("Walk") 
		else:
			right = -0.75
			$AnimationPlayer.play("Walk") 
		# === ======================= === #
	elif !attack and health>0: # gdy nie atakuje, a żyje, to wykojune animację Idle
		$AnimationPlayer.play("Idle")
	
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === #
	
	
# ========== FUNKCJE INTERSEKCJI Z NODEM WZROK ========== #
func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player":
		player = body # player zostaje przypisane jako body, które jest Playerem, gdy wejdzie w Wzrok
		
func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player":
		player = null # player zostaje przypisany jako null/nic jak Player opuści Wzrok
# ========== ================================= ========== #
		
		
# ========== FUNKCJE INTERSEKCJI Z NODEM ATAK ========== #
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
# ========== ================================ ========== #


# celowanie na podstawie bool result, który określa czy ray intersectuje
# z daną collision_mask + celuje w gracza
func aim(): 
	var space_state = get_world_2d().direct_space_state # pozyskanie obecnego stanu fizycznego danego World2D w celu wyznaczeń kolizji
	var result = space_state.intersect_ray(global_position, target.global_position, [self], collision_mask) # rzucanie rayem, aby intersectował z danym targetem
	if result:
		hit_pos = result.position # pozycja trafienia to pozycja trafienia przez ray targetu
		if result.collider.name == "Player":
			$Laser.rotation = (target.global_position - global_position).angle() + 2 * Vector2(0.5, -0.5).angle() + 10 * (target.global_position + target.velocity) # doprecyzowanie rotacji raya
		
		
# === STRZELANIE === #
# strzelanie do target -> pozycja (Vector2) 
func shoot(target_poz):
	$AnimationPlayer.play("Attack")
	var laser = LASER_SCENE.instance() # załadowanie instancji lasera
	var main = get_tree().get_root().find_node("Main", true, false) # pozyskanie danego node sceny
	laser.position = self.global_position + $Position2D.position # ustawienie pozycji lasera na pozycję Position2D
	laser.player_Pos = get_tree().get_root().find_node("Player", true, false).global_position # pozyskanie pozycji gracza
	main.add_child(laser) # dodanie lasera do sceny
# === ========== === #
		
		
# === TIMER === #
func _on_Timer_timeout():
	if health>0 and attack and target: # funkcje gdy żyje
		shoot(target.position) # strzał w stronę pozycji targetu
		$Laser_Load.emit = false # ładowanie lasera zostaje zatrzymane
		$Cooldown.start() # timer Cooldown zostaje aktywowany
# === ===== === #
		
		
# === COOLDOWN === #
func _on_Cooldown_timeout():
	if health>0 and attack and target: # gdy BD żyje, atakuje i ma cel
		$Laser_Load.emit = true # Laser Load zostaje emitowany
		$Timer.start() # Timer zostaje aktywowany w celu oddania strzału
# === ======== === #
		
		
func get_dmg(dmg, weaponKnockback):
	if health>0:
		# ======= KNOCKBACK ======= #
		if weaponKnockback != 0:
			knockback = -self.global_position.direction_to(player.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		
		# ======= USUWANIE ŻYCIA ======= #
		hp -= dmg
		health = hp/max_hp*100
		$AnimationPlayer.play("Hurt")
		health_bar.on_health_updated(health)
		health_bar.visible = true
		# ======= ============== ======= #
	if health<=0:
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		rng.randomize()
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		random_potion()
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
	
func random_potion():
	rng.randomize()
	var potion = int(rng.randf_range(0,3))
	print(potion)
	var tmp
	
	if potion == 0:
		tmp = load("res://Scenes/Loot/20healthPotion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		level.add_child(tmp)
	elif potion == 1:
		tmp = load("res://Scenes/Loot/50%Potion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		level.add_child(tmp)
	elif potion == 2:
		tmp = load("res://Scenes/Loot/60healthPotion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		level.add_child(tmp)
	elif potion == 3:
		tmp = load("res://Scenes/Loot/100%Potion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		level.add_child(tmp)

