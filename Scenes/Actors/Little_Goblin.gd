extends KinematicBody2D
#Little_Goblin

signal died(body)

var player = null		#Zmienna przechowująca węzeł gracza
var move = Vector2.ZERO		#Zmienna inicjująca wektor poruszania
export var speed = 1.5		#Zmienna przechowująca szybkość poruszania
export var dps = 10		#Zmienna przechowująca wartość ataku
var right = 0.155		#Kierunek obrócenia
var attack = false		#Czy atakuje
var max_hp = 30		#Zmienna przechowywująca ilość życia
var hp:float = max_hp	#Zmienna przechowuje ilość pozostałego życia

export var health = 100 	#Pozostałe życie w procentach

onready var health_bar = $HealthBar
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var randomPosition

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var weaponKnockback = 1.0
# === ===================== === #

func _ready():
	health_bar.on_health_updated(health)

func _physics_process(delta):
	move = Vector2.ZERO
	if player != null and !attack and health>0:	# wykonuje się jeśli widzi gracza i nie atakuje oraz żyje
		$sprite.scale.x = right		# obrót w stronę gracza
		# === WEKTORY MOVE I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move = global_position.direction_to(player.global_position) * speed # podhcodzenie do gracza
		else:
			knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ======================== === #
		if player.global_position.x-self.global_position.x < 0:		# sprawdzenie w którą stone jest obrócony gracz
			right = -0.155
		else:
			right = 0.155
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
	
func _on_wzrok_body_entered(body):
	if body != self and body.name == "Player":	#Jeśli gracz znajduję się w polu wzrok przypisz jego węzeł do zmiennej
		player = body

func _on_wzrok_body_exited(body):
	if body != self and body.name == "Player":	#Jeżeli gracz nie znajduję się w polu wzrok to zmień player na null
		player = null
func _on_Atak_body_entered(body):	
	if body != self and body.name == "Player":	#Jeśli gracz znajduję się w polu atak to ustaw attack na true
		attack = true


func _on_Atak_body_exited(body): #Jeśli gracz nie znajduję się w polu Atak to ustaw attack na false
	attack = false


func _on_Timer_timeout():		
	if attack and health>0:		#Jeśli gracz znajduję się w polu Atak i goblin żyje to zadaj obrażenia
		$AnimationPlayer.play("Atak")
		yield($AnimationPlayer,"animation_finished")
		player.take_dmg(dps)

func get_dmg(dmg):
	if health > 0 :
		
#		# ======= KNOCKBACK ======= #
		knockback = -global_position.direction_to(player.global_position)*100*(weaponKnockback+1) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		
		hp-=dmg
		health = hp/max_hp*100
		health_bar.on_health_updated(health)
		health_bar.visible = true
	if health <=0 :
		$CollisionShape2D.set_deferred("disabled",true)
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer,"animation_finished")
		var _level = get_tree().get_root().find_node("Main", true, false)
		emit_signal("died", self)
		queue_free()	#Usuń węzeł goblina
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)

