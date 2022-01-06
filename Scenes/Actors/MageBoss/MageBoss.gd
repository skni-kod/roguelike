# MageBoss.gd
extends KinematicBody2D
#MageBoss - glowny boss, aktualnie zywiolowa kula wokol ktorej kreca sie inne kule

signal died(body)  #Deklaracja sygnalu smierci

export var speed = 0.15  #Zmienna definujaca szybkosc poruszania
export var max_hp = 500  #Zmienna definiujaca ilosc zycia
export var angular_velocity = 1.0  #Zmienna definujaca predkosc pociskow (katowa)
export var change_speed_WF = 0.3  #Zmienna definujaca predkosc do srodka/zewnatrz pociksu wodnego i ognistego
export var change_speed_EW = 1  #Zmienna definujaca predkosc do srodka/zewnatrz pociksu ziemnego i powietrznego
export var earthball_dmg = 8.0  #Zmienna definiujaca obrazenia pocisku ziemnego
export var windball_dmg = 6.0  #Zmienna definiujaca obrazenia pocisku powietrznego
export var fireball_dmg = 4.0  #Zmienna definiujaca obrazenia pocisku ognistego
export var waterball_dmg = 5.0  #Zmienna definiujaca obrazenia pocisku wodnego
var alive = true # zmienna czy boss żyje
var player = null  #Zmienna przechowujaca wezel gracza
var move = Vector2.ZERO  #Zmienna inicjujaca wektor poruszania
var hp: float = max_hp  #Zmienna przechowujaca ilosc pozostalego zycia
var health = 100  #Pozostale zycie w procentach
var drop = {"minCoins": 40, "maxCoins": 50}  #Przedzial definicujacy ile boos zostawia po sobie monet
var rng = RandomNumberGenerator.new()  #Inicjalizacja obiektu losowania
onready var main := get_tree().get_root().find_node("Main", true, false)  #Zmienna przechowujaca wezel main
onready var UI := get_tree().get_root().find_node("UI", true, false)  #Zmienna przechowujaca wezel UI
onready var statusEffect := get_tree().get_root().find_node("StatusBar", true, false)  #Zmienna przechowujaca wezel StatusBar
var health_bar = load("res://scenes/ui/ui_scenes/BossHealthBar.tscn")  #Zaladowanie do zmiennej paska zycia bossa
var floating_dmg = preload("res://Scenes/ui/ui_scenes/FloatingDmg.tscn")  #Zaladowanie wyswietlanego zadanego dmg
var portal = preload("res://Scenes/levels/levels_scenes/Portal.tscn") #Zaladowanie portalu umożliwiającego "następny poziom"
var randomPosition = Vector2.ZERO  #Zmienna inicjujaca pozycje monet
var outer_rotation_WF = false  #Zmienna przechowuje informacje o tym, czy kule wodna i ognista sa na zewnetrznej orbicie
var change_rotation_WF = true  #Zmienna przechowuje informacje o tym, czy kule wodna i ognista sa w trakcie zmiany swoich orbit
var outer_rotation_EW = false  #Zmienna przechowuje informacje o tym, czy kule ziemna i powietrzna sa na zewnetrznej orbicie
var change_rotation_EW = true  #Zmienna przechowuje informacje o tym, czy kule ziemna i powietrzna sa w trakcie zmiany swoich orbit
var phase = 0  #Zmienna przechowuje informacje o tym, w ktorej fazie aktualnie znajduje sie boss (lub znajdowal sie ostatnio)
var phase_active = false  #Zmienna przechowuje informacje o tym, czy faza bossa jest jeszcze aktywna

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 9999 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
var projectileKnockback = 1
# === ===================== === #

func _ready():
	#Dodanie paska zycia bossa
	health_bar = health_bar.instance()
	UI.add_child(health_bar)
	health_bar.value = health

func _physics_process(delta):
	#Ruch bossa
	move = Vector2.ZERO
	if alive:
		if player != null and health>0: #Jeżeli gracz jest w polu widzenia i MageBoss nie atakuje oraz życie jest większe niż 0 to
			# === WEKTORY MOVE I KNOCKBACK === #
			if knockback == Vector2.ZERO:
				if global_position.distance_to(player.global_position) < 55.0:
					move = -global_position.direction_to(player.global_position) * speed
				elif global_position.distance_to(player.global_position) > 65.0:
					move = global_position.direction_to(player.global_position) * speed
			else:
				knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
			# === ======================== === #
		# === PORUSZANIE SIĘ I KNOCKBACK === #
		if knockback == Vector2.ZERO:
			move_and_collide(move) # ruch o Vector2D move
		elif knockback != Vector2.ZERO and health > 0:
			knockback = move_and_slide(knockback)
			knockback *= 0.95
		# === ========================== === #
		rotate_water_fire()
		rotate_earth_wind()
		control_phases()  #Kontroluj aktywacje faz bossa
		if phase_active == true:  #Wykonuj animacje tarczy, jesli boss jest w trakcie fazy
			$ShieldCenter.rotate(0.5)

func _on_Wzrok_body_entered(body):  #Jesli gracz wejdzie w pole widzenia, przypisz jego wezel do zmiennej
	if body.name == "Player":
		player = body

func _on_Wzrok_body_exited(body):  #Jesli gracz wyjdzie z pola widzenia, ustaw zmienna na null
	if body.name == "Player":
		player = null

func _on_WaterFireTimer_timeout():  #Zmieniaj orbity kul wodnej i ognistej co czas
	change_rotation_WF = true

func _on_EarthWindTimer_timeout():  #Zmieniaj orbity kul ziemnej i powietrznej co czas
	change_rotation_EW = true

func _on_Fireball_body_entered(body):  #Jesli gracz wejdzie w ognista kule
	if body.name == "Player":
		player.take_dmg(fireball_dmg, projectileKnockback, self.global_position)
		statusEffect.burning = true

func _on_Waterball_body_entered(body):  #Jesli gracz wejdzie w wodna kule
	if body.name == "Player":
		player.take_dmg(waterball_dmg, projectileKnockback, self.global_position)
		statusEffect.freezing = true
		
func _on_WindBall_body_entered(body):
	if body.name == "Player":
		player.take_dmg(windball_dmg, projectileKnockback, self.global_position)
		statusEffect.weakness = true

func _on_EarthBall_body_entered(body):  #Jesli gracz wejdzie w ziemna kule
	if body.name == "Player":
		player.take_dmg(earthball_dmg, projectileKnockback, self.global_position)

func _on_PhaseTimer_timeout():  #Po rozpoczeciu fazy i odpowiednim czasie stworz summona
	var summon = load("res://Scenes/Actors/MageBoss/Summon.tscn")
	summon = summon.instance()
	main.add_child(summon)
	summon.position = self.global_position

func _on_FireTimer_timeout():  #Strzelaj co okreslony czas podczas fazy
	fire()
	
func get_dmg(dmg, weaponKnockback):
	if phase_active == false and alive:
		var text = floating_dmg.instance()
		text.amount = dmg
		text.type = "Damage"
		add_child(text)	
		if health>0:
			# ======= KNOCKBACK ======= #
			if weaponKnockback != 0:
				knockback = -global_position.direction_to(player.global_position)*(100+(100*weaponKnockback)) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
			if knockbackResistance != 0:
				knockback /= knockbackResistance
			elif knockbackResistance <= 0.6:
				knockback /= 0.6
		# ======= ========= ======= #
			#Ustal aktualny poziom zdrowia w procentach
			hp -= dmg
			health = hp/max_hp*100
			$AnimationPlayer.play("Hurt")
			health_bar.value = health
		#Jeżeli poziom zdrowia spadnie do 0
		if health<=0:
			alive = false
			$WaterFireCenter.queue_free()
			$EarthWindCenter.queue_free()
			#Rozpocznij animacje smierci
			$AnimationPlayer.play("Die")
			yield($AnimationPlayer, "animation_finished")
			#Wyrzuc monety po zakonczeniu animacji
			var level = get_tree().get_root().find_node("Main", true, false)
			var p = portal.instance()
			p.global_position = get_node("../..").global_position
			level.add_child(p) #Tworzy portal
			rng.randomize()
			var coins = rng.randf_range(drop['minCoins'], drop["maxCoins"])
			for i in range(0, coins):
				randomPosition = Vector2(rng.randf_range(self.global_position.x - 10, self.global_position.x + 10), rng.randf_range(self.global_position.y - 10, self.global_position.y + 10))
				var coin = load("res://scenes/loot/objects/objects_scenes/GoldCoin.tscn")
				coin = coin.instance()
				coin.position = randomPosition
				level.add_child(coin)
			health_bar.queue_free()  #Usun pasek zycia bossa z UI
			emit_signal("died", self)
			queue_free()  #Usun caly wezel bossa

func rotate_water_fire():  #Obracaj kule wodna i ognista
	var radius = $WaterFireCenter/Fireball.global_position.distance_to($WaterFireCenter.global_position)  #Oblicz promien orbity
	var angle = angular_velocity / radius  #Oblicz kat o jaki bedzie obracana kula wzgledem bossa
	$WaterFireCenter.rotate(angle)  #Obroc kule o ten kat wzgledem bossa
	for missile in $WaterFireCenter.get_children():
		missile.rotate(0.1)  #Obroc kule wzgledem wlasnej osi
		#Jesli kule powinny zmienic swoje orbity i sa na orbicie zewnetrznej
		if outer_rotation_WF == true && change_rotation_WF == true:
			#Zmieniaj ich pozycje w kierunku bossa az do 30 jednostek odleglosci od bossa
			if missile.global_position.distance_to($WaterFireCenter.global_position) > 30:
				missile.global_position += missile.global_position.direction_to($WaterFireCenter.global_position) * change_speed_WF
			#W przeciwnym wypadku zakoncz zmiane pozycji
			else:
				outer_rotation_WF = false
				change_rotation_WF = false
				$WaterFireTimer.start()
		#Jesli kule powinny zmienic swoje orbity i sa na orbicie wewnetrznej
		elif change_rotation_WF == true:
			#Zmieniaj ich pozycje w kierunku przeciwnym do bossa az do 60 jednostek odleglosci od bossa
			if missile.global_position.distance_to($WaterFireCenter.global_position) < 60:
				missile.global_position -= missile.global_position.direction_to($WaterFireCenter.global_position) * change_speed_WF
			#W przeciwnym wypadku zakoncz zmiane pozycji
			else:
				outer_rotation_WF = true
				change_rotation_WF = false
				$WaterFireTimer.start()

func rotate_earth_wind():  #Obracaj kule ziemna i powietrzna
	var radius = $EarthWindCenter/WindBall.global_position.distance_to($EarthWindCenter.global_position)  #Oblicz promien orbity
	var angle = angular_velocity / radius  #Oblicz kat o jaki bedzie obracana kula wzgledem bossa
	$EarthWindCenter.rotate(-angle)  #Obroc kule o ten kat wzgledem bossa
	for missile in $EarthWindCenter.get_children():
		missile.rotate(0.1)  #Obroc kule wzgledem wlasnej osi
		#Jesli kule powinny zmienic swoje orbity i sa na orbicie zewnetrznej
		if outer_rotation_EW == true && change_rotation_EW == true:
			#Zmieniaj ich pozycje w kierunku bossa az do 40 jednostek odleglosci od bossa
			if missile.global_position.distance_to($EarthWindCenter.global_position) > 40:
				missile.global_position += missile.global_position.direction_to($EarthWindCenter.global_position) * change_speed_EW
			#W przeciwnym wypadku zakoncz zmiane pozycji
			else:
				outer_rotation_EW = false
				change_rotation_EW = false
				$EarthWindTimer.start()
		#Jesli kule powinny zmienic swoje orbity i sa na orbicie wewnetrznej
		elif change_rotation_EW == true:
			#Zmieniaj ich pozycje w kierunku przeciwnym do bossa az do 100 jednostek odleglosci od bossa
			if missile.global_position.distance_to($EarthWindCenter.global_position) < 100:
				missile.global_position -= missile.global_position.direction_to($EarthWindCenter.global_position) * change_speed_EW
			#W przeciwnym wypadku zakoncz zmiane pozycji
			else:
				outer_rotation_EW = true
				change_rotation_EW = false
				$EarthWindTimer.start()

func control_phases():  #Kontroluj fazy bossa
	#Jesli boss ma mniej niz 80 zycia i jego ostatnia faza to 0 i zadna faza nie jest aktywna, rozpocznij 1 faze
	if health < 80 and phase == 0 and phase_active == false:
		phase = 1
		phase_active = true
		phase_start()
	#Jesli boss ma mniej niz 60 zycia i jego ostatnia faza to 1 i zadna faza nie jest aktywna, rozpocznij 2 faze
	elif health < 60 and phase == 1 and phase_active == false:
		phase = 2
		phase_active = true
		phase_start()
	#Jesli boss ma mniej niz 40 zycia i jego ostatnia faza to 2 i zadna faza nie jest aktywna, rozpocznij 3 faze
	elif health < 40 and phase == 2 and phase_active == false:
		phase = 3
		phase_active = true
		phase_start()
	#Jesli boss ma mniej niz 20 zycia i jego ostatnia faza to 3 i zadna faza nie jest aktywna, rozpocznij 4 faze
	elif health < 20 and phase == 3 and phase_active == false:
		phase = 4
		phase_active = true
		phase_start()

func phase_start():  #Rozpocznij faze bossa
	angular_velocity += 0.5  #Przyspiesz kule
	#Zaladuj odpowiednia teksture tarczy w zaleznosci od fazy
	if phase == 1:
		$ShieldCenter/Shield.texture = load("res://Assets/Enemies/fireball_new.png")
	elif phase == 2:
		$ShieldCenter/Shield.texture = load("res://Assets/Enemies/waterball.png")
	elif phase == 3:
		$ShieldCenter/Shield.texture = load("res://Assets/Enemies/earthball.png")
	elif phase == 4:
		$ShieldCenter/Shield.texture = load("res://Assets/Enemies/windball.png")
	#Wlacz emitowanie czasteczek tarczy
	$ShieldCenter/Shield.emitting = true
	$PhaseTimer.start()  #Uruchom timer tworzacy summona
	$FireTimer.start()  #Uruchom timer odpowiadajacy za strzelanie

func fire():  #Strzelanie przez bossa
	var ball_scene = load("res://Scenes/Actors/MageBoss/Projectile.tscn")  #Wczytaj scene pocisku
	ball_scene = ball_scene.instance()  #Stworz pocisk
	#Ustaw pozycje poczatkowa pocisku na tarczy bossa
	ball_scene.position = self.global_position + Vector2(20.0, 0.0).rotated($ShieldCenter.rotation)
	ball_scene.player_Pos = get_tree().get_root().find_node("Player", true, false).global_position  #Ustaw pozycje gracza
	main.add_child(ball_scene)  #Dodaj pocisk do glownej sceny
