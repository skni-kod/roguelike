# Summon.gd
extends KinematicBody2D
# Summon - mob przywolywany przez bossa podczas kazdej fazy

export var speed = 0.8  #Zmienna definujaca szybkosc poruszania
export var max_hp = 100  #Zmienna definiujaca ilosc zycia
var player = null  #Zmienna przechowujaca wezel gracza
var move = Vector2.ZERO  #Zmienna inicjujaca wektor poruszania
var hp: float = max_hp  #Zmienna przechowujaca ilosc pozostalego zycia
var health = 100  #Pozostale zycie w procentach
onready var main := get_tree().get_root().find_node("Main", true, false)  #Zmienna przechowujaca wezel main
onready var boss := get_tree().get_root().find_node("MageBoss", true, false)  #Zmienna przechowuje wezel bossa
onready var health_bar = $HealthBar  #Zmienna przechowujaca pasek zycia
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")  #Zaladowanie wyswietlanego zadanego dmg

func _ready():
	health_bar.on_health_updated(health)  #Zaktualizowanie paska zycia
	#Wczytanie odpowiedniej do fazy bossa tekstury
	if boss.phase == 1:
		$Particles2D.texture = load("res://Assets/Enemies/fireball_new.png")
	elif boss.phase == 2:
		$Particles2D.texture = load("res://Assets/Enemies/WaterBall.png")
	elif boss.phase == 3:
		$Particles2D.texture = load("res://Assets/Enemies/EarthBall.png")
	elif boss.phase == 4:
		$Particles2D.texture = load("res://Assets/Enemies/WindBall.png")

func _physics_process(delta):
	move = Vector2.ZERO
	if player != null and health > 0:  #Jezeli gracz jest w polu widzenia bossa oraz jego zycie jest wieksze od 0
		#Podejdz do gracza
		move = position.direction_to(player.position) * speed
	move_and_collide(move)

func _on_Wzrok_body_entered(body):
	if body.name == "Player":  #Jesli gracz wejdzie w pole widzenia, przypisz jego wezel do zmiennej
		player = body

func _on_Wzrok_body_exited(body):
	if body.name == "Player":  #Jesli gracz wyjdzie z pola widzenia, ustaw zmienna na null
		player = null

func _on_FireTimer_timeout():
	if health > 0:  #Jesli zycie jest wieksze od 0, atakuj
		fire()

func get_dmg(dmg, weaponKnockback):
	#Utworz tekst z obrazeniami
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	if health > 0:
		#Zaktualizuj zdrowie
		hp -= dmg
		health = hp / max_hp * 100
		health_bar.on_health_updated(health)
		health_bar.visible = true
	if health <= 0:  #Jezeli summon nie ma juz zycia
		#Rozpocznij animacje smierci
		$AnimationPlayer.play("Die")
		yield($AnimationPlayer, "animation_finished")
		#Zakoncz faze bossa
		boss.phase_active = false
		boss.get_node("FireTimer").stop()
		boss.get_node("ShieldCenter/Shield").emitting = false
		queue_free()  #Usun wezel summon

func fire():  #Strzelanie przez summona
	var ball_scene = load("res://Scenes/Actors/MageBoss/Projectile.tscn")  #Wczytaj scene pocisku
	ball_scene = ball_scene.instance()  #Stworz pocisk
	ball_scene.position = self.position  #Ustaw pozycje pocisku na summona
	ball_scene.player_Pos = get_tree().get_root().find_node("Player", true, false).position  #Ustaw pozycje gracza
	main.add_child(ball_scene)  #Dodaj pocisk do glownej sceny
