extends KinematicBody2D

signal died(body)

onready var statusEffect = get_node("../../../UI/StatusBar")

var player = null
var move = Vector2.ZERO
export var speed = 2
export var dps = 15
var right = 1
var attack = false
var max_hp = 9
var hp:float = max_hp

export var health = 100
var drop = {"minCoins":0,"maxCoins":5}
var rng = RandomNumberGenerator.new()

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/ui/ui_scenes/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var enemyKnockback = 0.3
# === ===================== === #
 
# === ZMIENNE DO ELITY === #
var is_elite = false
onready var main := get_tree().get_root().find_node("Main", true, false)

func elite():
	rng.randomize()
	var rgb = rng.randi_range(0,2) 	# od 1 do 3 rodzaj elity 
	var elite = rng.randf_range(1,100)	# zakres losowania szansy na stworzenie elity
	if elite <=25 :		# w jakim zakresie musi być wylosowana liczba 
		is_elite = true		# może się przydać później 
		if rgb == 0 :	# rodzaj czerwony mocniej biję 
			$Sprite.modulate = Color(1, 0, 0, 1 )	#Zmiana koloru sprite (czerwony , zielony , niebieski, przezroczystość )
			dps = dps * 2
		if rgb == 1 :	#rodzaj zielony więcej hp wolniejszy
			$Sprite.modulate = Color(0, 1, 0, 1 )
			max_hp = max_hp * 1.5	# zwiększenie zdrowia o x razy
			hp = max_hp
			health = 100
			speed -= 0.1
		if rgb == 2 :	# rodzaj niebieski szybciej atakuje i szybciej biega mniej życia
			$Sprite.modulate = Color( 0, 0, 1, 1 )
			speed += 0.3
			max_hp = max_hp * 0.9	# zmiana zdrowia o x razy
			hp = max_hp
			health = 100
			$Timer.set_wait_time(0.6)
# === ===================== === #

func _ready():
	elite()
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	if player != null and !attack and health>0:
		$Sprite.scale.x = right
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * speed # podchodzenie do gracza
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if player.global_position.x-self.global_position.x < 0:
			right = -1
		else:
			right = 1
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")
		
	# === PORUSZANIE SIĘ I KNOCKBACK === #
	if knockback == Vector2.ZERO:
		move_and_collide(move) # ruch o Vector2D move
	elif knockback != Vector2.ZERO and health > 0:
		knockback = move_and_slide(knockback)
		knockback *= 0.95
	# === ========================== === #

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
		statusEffect.poison = true
		player.take_dmg(dps, enemyKnockback, self.global_position)
		yield($AnimationPlayer,"animation_finished")


			
func get_dmg(dmg, weaponKnockback):
	
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)	
	
	if health>0:
		
#		# ======= KNOCKBACK ======= #
		if weaponKnockback != 0:
			knockback = -global_position.direction_to(player.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		
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
		if is_elite == true:
			random_potion()
		var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
		for i in range(0,coins):
			randomPosition = Vector2(rng.randf_range(self.global_position.x-10,self.global_position.x+10),rng.randf_range(self.global_position.y-10,self.global_position.y+10))
			var coin = load("res://Scenes/loot/objects/objects_scenes/GoldCoin.tscn")
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
		
func random_potion():
	rng.randomize()
	var potion
	potion = int(rng.randi_range(0,1))
	print(potion)
	var tmp
	
	if potion == 0:
		tmp = load("res://Scenes/loot/potions/potions_scenes/20healthPotion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
	elif potion == 1:
		tmp = load("res://Scenes/loot/potions/potions_scenes/50%Potion.tscn")
		tmp = tmp.instance()
		tmp.position = global_position
		main.add_child(tmp)
