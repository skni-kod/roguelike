# Slime.gd
extends KinematicBody2D
#slime

signal died(body)

var player = null #Zmienna przechowująca węzeł gracza
var move = Vector2.ZERO #Zmienna inicjująca wektor poruszania
export var speed = 0.5 #Zmienna przechowująca szybkość poruszania
export var dps = 5 #Zmienna przechowująca wartość ataku
var right = 1 #Czy slime jest obrócony w prawo
var attack = false #Czy slime jest w trakcie ataku
var max_hp =61 #Zmienna definiująca ilość życia
var hp:float = max_hp #Zmienna przechowuje ilość pozostałego życia
var health = 100 #Pozostałe życie w procentach
var drop = {"minCoins":0,"maxCoins":5} #Przedział definiujący ile slime może zostawić po sobie coinów
var rng = RandomNumberGenerator.new() #Maszyna Lotto (losuje liczby)

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null and !attack and health>0: #Jeżeli gracz jest w polu widzenia i slime nie atakuje oraz życie jest większe niż 0 to
		$Sprite.scale.x = right #Obróć slime
		move = position.direction_to(player.position) * speed #Ustaw wektor na pozycję gracza
		if player.position.x-self.position.x < 0:
			right = 1 #Slime ma być obrócony w prawo
		else:
			right = -1 #Slime ma być obrócony w lewo
		$AnimationPlayer.play("Walk")
	elif !attack and health>0:
		$AnimationPlayer.play("Idle")

	move_and_collide(move)

func _on_Wzrok_body_entered(body):
	if body != self and body.name == "Player": #Jeśli gracz wejdzie w pole widzenia to przypisz jego węzeł do zmiennej
		player = body

func _on_Wzrok_body_exited(body):
	if body != self and body.name == "Player": #Jeżeli gracz wyjdzie z pola widzenia to zmienną player ustaw na null
		player = null


func _on_Atak_body_entered(body): 
	if body != self and body.name == "Player": #Jeżeli gracz znajdzie się w zasięgu ataku
		attack = true #Slime atakuje

func _on_Atak_body_exited(body): #Jeżeli gracz wyjdzie z zasięgu ataku
	attack = false #Slime nie atakuje

func _on_Timer_timeout():
	if attack and health>0: # funkcje wykonane gdy atakuje
		player.take_dmg(dps)
		$AnimationPlayer.play("Attack")
		yield($AnimationPlayer,"animation_finished")
			
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
		$CollisionShape2D.set_deferred("disabled",true)
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
		emit_signal("died", self)
		queue_free() #Usuń węzeł slime
		
	
		
