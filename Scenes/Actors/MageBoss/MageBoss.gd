# MageBoss.gd
extends KinematicBody2D
#MageBoss
var player = null #Zmienna przechowująca węzeł gracza
var move = Vector2.ZERO #Zmienna inicjująca wektor poruszania
export var speed = 0.2 #Zmienna przechowująca szybkość poruszania
export var dps = 20 #Zmienna przechowująca wartość ataku
var right = 1 #Czy MageBoss jest obrócony w prawo
var max_hp = 500 #Zmienna definiująca ilość życia
var hp:float = max_hp #Zmienna przechowuje ilość pozostałego życia
onready var main := get_tree().get_root().find_node("Main", true, false)

var health = 100 #Pozostałe życie w procentach
var drop = {"minCoins":30,"maxCoins":60} #Przedział definiujący ile MageBoss może zostawić po sobie coinów
var rng = RandomNumberGenerator.new() #Maszyna Lotto (losuje liczby)

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

export var angular_velocity = 2.0
export var speed_during_change1 = 0.3
export var speed_during_change2 = 1
var outer_rotation1 = false
var change_rotation1 = true
var outer_rotation2 = false
var change_rotation2 = true

var phase = 0
var phase_active = false

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and health>0: #Jeżeli gracz jest w polu widzenia i MageBoss nie atakuje oraz życie jest większe niż 0 to
		$Sprite.scale.x = right #Obróć MageBoss
		if position.distance_to(player.position) < 35.0:
			move = -position.direction_to(player.position) * speed
		elif position.distance_to(player.position) > 60.0:
			move = position.direction_to(player.position) * speed
		if player.position.x-self.position.x < 0:
			right = 1 #MageBoss ma być obrócony w prawo
		else:
			right = -1 #MageBoss ma być obrócony w lewo
		$AnimationPlayer.play("Walk")
	elif health>0:
		$AnimationPlayer.play("Idle")
	move_and_collide(move)
	rotate_water_fire()
	rotate_earth_wind()
	control_phases()

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": #Jeśli gracz wejdzie w pole widzenia to przypisz jego węzeł do zmiennej
		player = body

func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #Jeżeli gracz wyjdzie z pola widzenia to zmienną player ustaw na null
		player = null

func _on_MissilesTimer_timeout():
	change_rotation1 = true
	
func _on_EarthWindTimer_timeout():
	change_rotation2 = true
	
func _on_Fireball_body_entered(body):
	if body.name == "Player":
		player.take_dmg(5.0)

func _on_Waterball_body_entered(body):
	if body.name == "Player":
		player.take_dmg(5.0)
		
func _on_WindBall_body_entered(body):
	if body.name == "Player":
		player.take_dmg(5.0)

func _on_EarthBall_body_entered(body):
	if body.name == "Player":
		player.take_dmg(5.0)

func get_dmg(dmg):
	if phase_active == false:
		var text = floating_dmg.instance()
		text.amount = dmg
		text.type = "Damage"
		add_child(text)	
		if health>0:
			#Ustal aktualny poziom zdrowia w procentach
			hp -= dmg
			health = hp/max_hp*100
			$AnimationPlayer.play("Hurt")
			health_bar.on_health_updated(health)
			health_bar.visible = true
		#Jeżeli poziom zdrowia spadnie do 0
		if health<=0:
			$AnimationPlayer.play("Die")
			yield($AnimationPlayer,"animation_finished")
			#Po zakończeniu animacji umierania wyrzuć losową liczbę coinów
			var level = get_tree().get_root().find_node("Main", true, false)
			rng.randomize()
			var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
			for i in range(0,coins):
				randomPosition = Vector2(rng.randf_range(self.position.x-10,self.position.x+10),rng.randf_range(self.position.y-10,self.position.y+10))
				var coin = load("res://Scenes/Loot/GoldCoin.tscn")
				coin = coin.instance()
				coin.position = randomPosition
				level.add_child(coin)
			queue_free() #Usuń węzeł MageBoss
		
func rotate_water_fire():
	var radius = $WaterFireCenter/Fireball.position.distance_to($WaterFireCenter.position)
	var angle = angular_velocity/radius
	$WaterFireCenter.rotate(angle)
	for missile in $WaterFireCenter.get_children():
		missile.rotate(0.1)
		if outer_rotation1 == false && change_rotation1 == true:
			if missile.position.distance_to($WaterFireCenter.position) > 30:
				missile.position += missile.position.direction_to($WaterFireCenter.position) * speed_during_change1
			else:
				outer_rotation1 = true
				change_rotation1 = false
				$MissilesTimer.start()
		elif change_rotation1 == true:
			if missile.position.distance_to($WaterFireCenter.position) < 60:
				missile.position -= missile.position.direction_to($WaterFireCenter.position) * speed_during_change1
			else:
				outer_rotation1 = false
				change_rotation1 = false
				$MissilesTimer.start()

func rotate_earth_wind():
	var radius = $EarthWindCenter/WindBall.position.distance_to($EarthWindCenter.position)
	var angle = angular_velocity/radius
	$EarthWindCenter.rotate(angle)
	for missile in $EarthWindCenter.get_children():
		missile.rotate(0.1)
		if outer_rotation2 == false && change_rotation2 == true:
			if missile.position.distance_to($EarthWindCenter.position) > 40:
				missile.position += missile.position.direction_to($EarthWindCenter.position) * speed_during_change2
			else:
				outer_rotation2 = true
				change_rotation2 = false
				$EarthWindTimer.start()
		elif change_rotation2 == true:
			if missile.position.distance_to($EarthWindCenter.position) < 100:
				missile.position -= missile.position.direction_to($EarthWindCenter.position) * speed_during_change2
			else:
				outer_rotation2 = false
				change_rotation2 = false
				$EarthWindTimer.start()

func control_phases():
	if health < 80 and phase == 0 and phase_active == false:
		phase = 1
		phase_active = true
		phase1_start()
	elif health < 60 and phase == 1 and phase_active == false:
		phase = 2
		phase_active = true
		phase2_start()
	elif health < 40 and phase == 2 and phase_active == false:
		phase = 3
		phase_active = true
		phase3_start()
	elif health < 20 and phase == 3 and phase_active == false:
		phase = 4
		phase_active = true
		phase4_start()

func phase1_start():
	var summon1 = load("res://Scenes/Actors/MageBoss/MageBossSummon1.tscn")
	summon1 = summon1.instance()
	main.add_child(summon1)
	summon1.position = self.position
	
func phase2_start():
	var summon2 = load("res://Scenes/Actors/MageBoss/MageBossSummon2.tscn")
	summon2 = summon2.instance()
	main.add_child(summon2)
	summon2.position = self.position
	
func phase3_start():
	var summon3 = load("res://Scenes/Actors/MageBoss/MageBossSummon3.tscn")
	summon3 = summon3.instance()
	main.add_child(summon3)
	summon3.position = self.position
	
func phase4_start():
	var summon4 = load("res://Scenes/Actors/MageBoss/MageBossSummon4.tscn")
	summon4 = summon4.instance()
	main.add_child(summon4)
	summon4.position = self.position
