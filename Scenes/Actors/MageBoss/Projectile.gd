#Projectile.gd
extends Area2D
#Projectile - pocisk bossa oraz summonow, moze byc ognista, wodna, powietrzna lub ziemna kula

onready var direction = Vector2.ZERO  #Kat odchylenia toru pocisku
var player_Pos = Vector2.ZERO  #Pozycja gracza w ktorego celuje pocisk
onready var origin = self.position  #Miejsce startowe pocisku
var dps = 0.0  #Obrazenia zadawane przez pocisk
const ball_speed = 100  #Szybkosc pocisku
onready var statusEffect := get_tree().get_root().find_node("StatusBar", true, false)  #Zmienna przechowujaca wezel StatusBar
onready var boss := get_tree().get_root().find_node("MageBoss", true, false)  #Zmienna przechowuje wezel bossa

func _ready():
	direction = (player_Pos - origin).normalized()  #Ustawienie kata jako znormalizowany wektor pozycji gracza i przeciwnika
	#Wczytanie odpowiedniej tekstury pocisku, koloru czastek oraz obrazen w zaleznosci od fazy bossa
	if boss.phase == 1:
		$Light2D.color = Color("f78a01")
		$Sprite.texture = load("res://Assets/Enemies/fireball_new.png")
		$Particles2D.process_material.set_color(Color("f78a01"))
		dps = 4.0
	elif boss.phase == 2:
		$Light2D.color = Color("0051d7")
		$Sprite.texture = load("res://Assets/Enemies/waterball.png")
		$Particles2D.process_material.set_color(Color("0051d7"))
		dps = 5.0
	elif boss.phase == 3:
		$Light2D.color = Color("ff2700")
		$Sprite.texture = load("res://Assets/Enemies/earthball.png")
		$Particles2D.process_material.set_color(Color("312523"))
		dps = 8.0
	elif boss.phase == 4:
		$Light2D.color = Color("9fcade")
		$Sprite.texture = load("res://Assets/Enemies/windball.png")
		$Particles2D.process_material.set_color(Color("9fcade"))
		dps = 6.0

func _physics_process(delta):
	self.position += (direction * delta * ball_speed)  #Przemiszczenie pocisku

func _on_Projectile_body_entered(body):  #Jesli gracz wejdzie w pocisk
	if body.name == "Player":
		body.take_dmg(dps, 0, self.global_position)  #Gracz otrzymuje obrazenia
		#Szansa na podpalenie, zamrozenie lub oslabienie w zaleznosci od rodzaju kuli
		if boss.phase == 1:
			statusEffect.burning = true
		elif boss.phase == 2:
			statusEffect.freezing = true
		elif boss.phase == 4:
			statusEffect.weakness = true
	queue_free()  #Usun pocisk
