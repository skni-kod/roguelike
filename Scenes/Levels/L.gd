#nazwa węzła/skryptu do zmiany
extends Node2D #generacja terenu/dekoracji 

var totem = preload("res://Assets/Light/Lamp_1.tscn")
var krysztal = preload("res://Assets/Light/Lamp_2.tscn")
var pomnik = preload("res://Assets/Light/Lamp_3.tscn")
var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	#"duża struktura" - tylko jedna
	if (randi() % 10 == 0): #szansa generacji totemu 10%
		add_child(totem.instance())
	elif (randi() % 4 == 0): #szansa generacji pomników 25%
		var p = pomnik.instance()
		if (randi() % 2 == 0):
			p.Cuckshooter = true
		add_child(p)
	#małe struktury
	#kryształy
	var i = 1
	while (rand.randi_range(0,i) == 0): #z każdą generacją maleje szansa na kolejną
		i += 1
		var k = krysztal.instance()
		k.colour = randi() % 6 #losujemy kolor
		#losowanie pozycji
		var x
		var y
		if (randi() % 2): #na ścianie g-d
			if (randi() % 2): #górna
				k.rotation_degrees = 180
				x = rand.randi_range(-225,225)
				while (x < 32 and x > -32): #żeby nie pojawiały się na drzwiach
					x = rand.randi_range(-225,225)
				y = rand.randi_range(-132,-110)
				k.position = Vector2(x, y)
			else: #dolna
				k.rotation_degrees = 0
				x = rand.randi_range(-225,225)
				while (x < 32 and x > -32): #żeby nie pojawiały się na drzwiach
					x = rand.randi_range(-225,225)
				y = rand.randi_range(110,132)
				k.position = Vector2(x, y)
		else: #na ścianie l-p
			if (randi() % 2): #lewa
				k.rotation_degrees = 90
				x = rand.randi_range(-227,-212)
				y = rand.randi_range(-130,130)
				while (y < 32 and y > -32): #żeby nie pojawiały się na drzwiach
					y = rand.randi_range(-130,130)
				k.position = Vector2(x, y)
			else: #prawa
				x = rand.randi_range(212,227)
				y = rand.randi_range(-130,130)
				while (y < 32 and y > -32): #żeby nie pojawiały się na drzwiach
					y = rand.randi_range(-130,130)
				k.rotation_degrees = 270
				k.position = Vector2(x, y)
		add_child(k)
