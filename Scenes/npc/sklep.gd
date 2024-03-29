extends StaticBody2D

var gracz # zmienna przechowująca gracza, aby móc dodać mikstury do jego ekwipunku
var k = 0 # k = 1 - naciśnięcie E powoduje zakup mikstury
# k = 2 - naciśnięcie E powoduje zakup broni

func _ready():
	if (randi() % 5 > 0): # sklep znajduje się w każdym pokoju
		# ale przy wczytywaniu gry z większości z nich jest usuwany
		queue_free()
	$AnimationPlayer.play("idle")
	$AnimationPlayer2.play("idle")
	set_process(false)

func _on_Area2D_body_entered(body): # gracz znajduje w zasięgu ikonki mikstury
	if body.name == "Player":
		get_node("ui/E").visible = true # pokazuje wskazówkę wizualną
		gracz = body
		set_process(true) # _process obsługuje naciśnięcie klawisza E
		k = 1

func _on_Area2D2_body_entered(body): # gracz znajduje w zasięgu ikonki mikstury
	if body.name == "Player":
		get_node("ui/E").visible = true # pokazuje wskazówkę wizualną
		gracz = body
		set_process(true) # _process obsługuje naciśnięcie klawisza E
		k = 2

func _on_Area2D2_body_exited(body):  # gracz znajduje się poza zasięgiem
	if body.name == "Player":
		get_node("ui/E").visible = false
		gracz = null
		set_process(false) # sklep nie rejestruje naciśnięć E

func _on_Area2D_body_exited(body): # gracz znajduje się poza zasięgiem
	if body.name == "Player":
		get_node("ui/E").visible = false
		set_process(false) # sklep nie rejestruje naciśnięć E

func _process(_delta): # _process obsługuje naciśnięcia klawisza E
	if Input.is_action_just_pressed("pick") and gracz: # po wciśnięciu E
		if k == 1: # jeżeli gracz stoi przy ikonce mikstury
			if gracz.coins >= 20:
				gracz.coins -= 20
				gracz.level.get_node("UI/Coins").text = "Coins:" + str(gracz.coins) # aktualizacja licznika monet
				if not gracz.potions[1] == "Empty" and not gracz.potions_amount[gracz.potions[1]] == 0: # jeżeli gracz posiada miksturę dostaje +1 sztukę posiadanej mikstury
					gracz.potions_amount[gracz.potions[1]] += 1
				else: # jeżeli nie, dostaje 1 miksturę na 20HP
					gracz.potions[1] = "20healthPotion"
					gracz.potions_amount[gracz.potions[1]] = 1
				if not gracz.potions[2] == "Empty" and not gracz.potions_amount[gracz.potions[2]] == 0: # jeżeli gracz posiada miksturę dostaje +1 sztukę posiadanej mikstury
					gracz.potions_amount[gracz.potions[2]] += 1
				else: # jeżeli nie, dostaje 1 miksturę na 20HP
					gracz.potions[2] = "20healthPotion"
					gracz.potions_amount[gracz.potions[2]] = 1
				gracz.UpdatePotions()
		else: # jeżeli gracz stoi przy ikonce miecza
			if gracz.coins >= 50:
				gracz.coins -= 50
				gracz.level.get_node("UI/Coins").text = "Coins:" + str(gracz.coins) # aktualizacja licznika monet
				get_node("../Enemies").weapon()
				# kupiona broń do podniesienia jest generowana w ten
				# sam sposób, co broń otrzymana po przejściu poziomu
				var x = 0
				for i in get_node("../Enemies").get_children():
					if "Weapon" in i.name:
						i.position.x = 60 - 45*x
						x += 1

func _on_Area2D3_body_entered(body):
	if body.name == "Player":
		get_node("ui/cennik").visible = true

func _on_Area2D3_body_exited(body):
	if body.name == "Player":
		get_node("ui/cennik").visible = false
