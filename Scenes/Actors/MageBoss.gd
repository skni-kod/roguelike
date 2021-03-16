# MageBoss.gd
extends KinematicBody2D
#MageBoss
var player = null #Zmienna przechowująca węzeł gracza
var move = Vector2.ZERO #Zmienna inicjująca wektor poruszania
export var speed = 0.3 #Zmienna przechowująca szybkość poruszania
export var dps = 20 #Zmienna przechowująca wartość ataku
var right = 1 #Czy MageBoss jest obrócony w prawo
var attack = false #Czy MageBoss jest w trakcie ataku
var max_hp = 500 #Zmienna definiująca ilość życia
var hp:float = max_hp #Zmienna przechowuje ilość pozostałego życia

var health = 100 #Pozostałe życie w procentach
var drop = {"minCoins":30,"maxCoins":60} #Przedział definiujący ile MageBoss może zostawić po sobie coinów
var rng = RandomNumberGenerator.new() #Maszyna Lotto (losuje liczby)

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

export var angular_velocity = 3.0
export var speed_during_change = 0.3
var outer_rotation = false
var change_rotation = true

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and !attack and health>0: #Jeżeli gracz jest w polu widzenia i MageBoss nie atakuje oraz życie jest większe niż 0 to
		$Sprite.scale.x = right #Obróć MageBoss
		move = position.direction_to(player.position) * speed #Ustaw wektor na pozycję gracza
		if position.distance_to(player.position) < 35:
			move = -position.direction_to(player.position) * speed
		elif position.distance_to(player.position) > 60:
			move = position.direction_to(player.position) * speed
		if player.position.x-self.position.x < 0:
			right = 1 #MageBoss ma być obrócony w prawo
		else:
			right = -1 #MageBoss ma być obrócony w lewo
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")
	move_and_collide(move)
	rotate_missiles()

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": #Jeśli gracz wejdzie w pole widzenia to przypisz jego węzeł do zmiennej
		player = body

func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #Jeżeli gracz wyjdzie z pola widzenia to zmienną player ustaw na null
		player = null

func _on_MissilesTimer_timeout():
	change_rotation = true
	
func _on_Fireball_body_entered(body):
	if body.name == "Player":
		player.take_dmg(5.0)

func _on_Waterball_body_entered(body):
	if body.name == "Player":
		player.take_dmg(5.0)

func get_dmg(dmg):
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
		
func rotate_missiles():
	var radius = $RotationCentre/Fireball.position.distance_to($RotationCentre.position)
	var angle = angular_velocity/radius
	$RotationCentre.rotate(angle)
#	$RotationCentre/Fireball/Particles2D.rotate(-0.03)
	$RotationCentre/Fireball.rotate(0.1)
	$RotationCentre/Waterball.rotate(0.1)
	if outer_rotation == false && change_rotation == true:
		if $RotationCentre/Fireball.position.distance_to($RotationCentre.position) > 30:
			$RotationCentre/Fireball.position += $RotationCentre/Fireball.position.direction_to($RotationCentre.position) * speed_during_change
			$RotationCentre/Waterball.position += $RotationCentre/Waterball.position.direction_to($RotationCentre.position) * speed_during_change
		else:
			outer_rotation = true
			change_rotation = false
			$MissilesTimer.start()
	elif change_rotation == true:
		if $RotationCentre/Fireball.position.distance_to($RotationCentre.position) < 60:
			$RotationCentre/Fireball.position -= $RotationCentre/Fireball.position.direction_to($RotationCentre.position) * speed_during_change
			$RotationCentre/Waterball.position -= $RotationCentre/Waterball.position.direction_to($RotationCentre.position) * speed_during_change
		else:
			outer_rotation = false
			change_rotation = false
			$MissilesTimer.start()
		
