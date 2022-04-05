extends Node2D #generacja terenu/dekoracji 

var boss = false
var totem = preload("res://Assets/Light/Lamp_1.tscn")
var krysztal = preload("res://Assets/Light/Lamp_2.tscn")
var pomnik = preload("res://Assets/Light/Lamp_3.tscn")
var swietlik = preload("res://Assets/Light/swietlik.tscn")
var rand = RandomNumberGenerator.new()
onready var generation = get_node("../../../Main")
var id_list = [] #Lista ID pokojów, w których był już Player
var current_id #ID aktualnego pokoju

func check_boss(room): #sprawdzanie, czy w to pokój bossa
	if room.x == int(round(self.global_position.x/512)) and room.y == int(round(self.global_position.y/288)):
		boss = true

func _ready():
	generation.connect("boss", self, "check_boss")


func _on_Node2D_body_entered(body): #Funkcja,która się aktywuje po wejsciu w kolizje playere z polem("area")
	if body.name == "Player": 
		current_id = get_instance_id() #pobieranie aktualnego ID pokoju
		if not current_id in id_list:
			id_list.append(current_id) #Dodawanie pokoju do listy odwiedzonych
			rand.randomize()
			#"duża struktura" - tylko jedna
			#"duże struktury" nie mogą się pojawiać w pokoju bossa
			#(wystawałyby z portalu)
			if (randi() % 100 < min(Bufor.poziom*2,48) and !boss): #szansa generacji totemu zależna od poziomu
				call_deferred('add_child', totem.instance())
			elif (randi() % 4 == 0 and !boss): #szansa generacji pomników 25%
				var p = pomnik.instance()
				if (randi() % 2 == 0):
					p.Cuckshooter = true
				p.z_index = 1
				call_deferred('add_child', p)
			#małe struktury
			#kryształy
			var i = 4
			while (rand.randi_range(0,i) <= 3): #z każdą generacją maleje szansa na kolejną
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
				k.z_index = 1
				add_child(k)
			if (get_parent().get_parent().BIOM == 2):
				while randi() % 3 == 0:
					var s = swietlik.instance()
					add_child(s)
