extends KinematicBody2D

signal health_updated(health, amount) #deklaracja sygnału który będzie emitowany po zmianie ilości punktów życia bohatera
signal attacked(damage) #deklaracja sygnału który będzie emitowany podczas ataku bohatera
signal open() #deklaracja sygnału który będzie emitowany podczas otwarcia skrzyni przez bohatera

onready var statusEffect = get_node("../UI/StatusBar")

var velocity = Vector2.ZERO #wektor prędkości bohatera
var got_hitted = false #czy bohater jest aktualnie uderzany
export var speed = 100 #wartośc szybkości bohatera
var direction = Vector2() #wektor kierunku bohatera
export var health = 100 #ilośc punktów życia bohatera
var base_health = 100 # bazowa ilość życia gracza
var coins = 0 #ilośc coinsów bohatera
var weaponToTake = null #Zmienna określająca czy gracz stoi przy broni leżącej na ziemi

var chest = null #Zmienna określająca czy gracz stoi przy skrzyni
var level #przypisanie sceny głównej
var all_weapons = {} #wszystkie bronki
var weapons = {} #posiadane bronki
var current_weapon
var all_weapons_script
var first_weapon_stats = {"attack":float(7.5)}
var second_weapon_stats = {}
var actual_slot = 1

onready var ui_access_wslots = {
	1: get_node("../UI/Slots/Background/Weaponslot1/weaponsprite1"),
	2: get_node("../UI/Slots/Background/Weaponslot2/weaponsprite2")
}
onready var wslots_visibility = {
	1: get_node("../UI/Slots/Background/w1slotbg"),
	2: get_node("../UI/Slots/Background/w2slotbg")
}
onready var actualweapon_access = get_node("../Player/EquippedWeapon/WeaponSprite")

#zmienne do funkcji potionów
onready var ui_access_pslot1 = get_node("../UI/Slots/Background/Potionslot1/potionsprite1")
onready var ui_access_pslot2 = get_node("../UI/Slots/Background/Potionslot2/potionsprite2")
onready var potion1_amount = get_node("../UI/Slots/Background/Potionslot1/potion1_amount")
onready var potion2_amount = get_node("../UI/Slots/Background/Potionslot2/potion2_amount")

var equipped_potion = "Potion+20hp"
var potions_amount = {}
var potions = {}
var all_potions = {}
var potion = null
var base_hp = null  

var Potion_in_time = 0

func UpdatePotions(): #funkcja aktualizująca status potek
	if potions[2] == "Empty": #jeżeli niema potki na slocie drugim to:
		ui_access_pslot1.texture = all_potions[potions[1]] #przypisanie do textury slotu pierwszego textury aktualnego pierwszego potka
		potion1_amount.text = str(potions_amount[potions[1]]) #aktualizacja textu ilości potek w eq
		ui_access_pslot2.texture = null # usuniecie tekstury z slotu drugiego
		potion2_amount.text = "" # ustawienie textu ilosci potek na nic
	else:
		ui_access_pslot1.texture = all_potions[potions[1]] #przypisanie do textury slotu pierwszego textury aktualnego pierwszego potka
		ui_access_pslot2.texture = all_potions[potions[2]] #przypisanie do textury slotu drugiego textury aktualnego drugiego potka
		potion1_amount.text = str(potions_amount[potions[1]]) #aktualizacja textu ilości potek w eq
		potion2_amount.text = str(potions_amount[potions[2]]) #aktualizacja textu ilości potek w eq
		
		if potions_amount[potions[1]] == 0: #jeżeli ilosc potek na slocie 1 jest rowna 0 to:
			ui_access_pslot1.texture = null  # usuniecie tekstury z slotu pierwszego
			potion1_amount.text = "" # ustawienie textu ilosci potek na nic
			potions[1] = "Empty" #przypisanie potxe z slotu 1 nazwe Empty potrzebne do poprawnego działania
		if potions_amount[potions[2]] == 0: #to samo co wyżej tylko dla slotu 2
			ui_access_pslot2.texture = null
			potion2_amount.text = ""
			potions[2] = "Empty"


func _ready(): #po inicjacji bohatera
	level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
	emit_signal("health_updated", health) #emitowanie sygnału o zmianie życia bohatera 100%/100% 
	level.get_node("UI/Coins").text = "Coins:"+str(coins) #aktualizacja napisu z ilością coinsów bohatera
	
	#Rozwiązanie tymczasowe związane z wyświetlaniem aktualnej broni gracza
	$EquippedWeapon.set_script(load("res://Scenes/Equipment/Weapons/Melee/Blade.gd")) # Wczytanie danej broni na starcie
	$EquippedWeapon.damage = first_weapon_stats["attack"]
	$EquippedWeapon.timer = $EquippedWeapon/Timer
	
	all_weapons = {
		"Axe" : preload("res://Assets/Loot/Weapons/axe.png"),
		"Blade" : preload("res://Assets/Loot/Weapons/blade.png"),
		"BloodSword" : preload("res://Assets/Loot/Weapons/bloodsword.png"),
		"Fire Scepter" : preload("res://Assets/Loot/Weapons/firescepter.png"),
		"FMS" : preload("res://Assets/Loot/Weapons/fms.png"),
		"Hammer" : preload("res://Assets/Loot/Weapons/hammer.png"),
		"Katana" : preload("res://Assets/Loot/Weapons/katana.png"),
		"Knife" : preload("res://Assets/Loot/Weapons/knife.png"),
		"Spear" : preload("res://Assets/Loot/Weapons/spear.png"),
	}
	all_weapons_script = {
		"Axe" : preload("res://Scenes/Equipment/Weapons/Melee/Axe.gd"),
		"Blade" : preload("res://Scenes/Equipment/Weapons/Melee/Blade.gd"),
		"BloodSword" : preload("res://Scenes/Equipment/Weapons/Melee/BloodSword.gd"),
		"Fire Scepter" :preload("res://Scenes/Equipment/Weapons/Magic/Fire Scepter.gd"),
		"FMS" : preload("res://Scenes/Equipment/Weapons/Melee/FMS.gd"),
		"Hammer" :preload("res://Scenes/Equipment/Weapons/Melee/Hammer.gd"),
		"Katana" : preload("res://Scenes/Equipment/Weapons/Melee/Katana.gd"),
		"Knife" : preload("res://Scenes/Equipment/Weapons/Melee/Knife.gd"),
		"Spear" : preload("res://Scenes/Equipment/Weapons/Melee/Spear.gd"),
	}
	weapons = {
		1 : "Blade",
		2 : "Empty"
	}
	ui_access_wslots[1].texture = all_weapons[weapons[1]]
	
	all_potions = { #słownik przechowujący png poszczegolnych potek
		"50%Potion" : preload("res://Assets/Loot/Potions/Potion50.png"),
		"100%Potion" : preload("res://Assets/Loot/Potions/Potion100.png"),
		"20healthPotion" : preload("res://Assets/Loot/Potions/Potion+20hp.png"),
		"60healthPotion" : preload("res://Assets/Loot/Potions/Potion+60hp.png")
	}
	potions = { #słownik przechowujący jaki potek jest na danym slocie
		1 : "20healthPotion",
		2 : "Empty"
	}
	
	potions_amount = { #słownik przechowujący ilość danych potek
		"50%Potion" : 0,
		"100%Potion" : 0,
		"20healthPotion" : 1,
		"60healthPotion" : 0,
		"Empty" : 0
	}
	UpdatePotions() 
func _physics_process(delta): #funkcja wywoływana co klatkę
	if Input.is_action_just_pressed("attack"): #jeżeli przycisk "attack" został wsciśnięty
		emit_signal("attacked") #wyemituj sygnał że bohater zaatakował
	else: #Jeżeli nie atakuje to
		movement() #wywołanie funkcji poruszania się
	
	if weaponToTake != null: #Jeżeli gracz stoi przy broni do podniesienia
		if Input.is_action_just_pressed("pick"): #Jeżeli nacisnął przycisk podniesienia
			if weapons[2] == "Empty":
				swap_weapon(2,weaponToTake) #jezeli gracz ma 1 bronke to podniesiona bronka jest na drugim slocie
			else:
				swap_weapon(actual_slot,weaponToTake) #zamiana bronki lezacej z uzywanej
				
	if chest != null: #Jeżeli gracz stoi przy skrzyni
		if Input.is_action_just_pressed("pick"):
			emit_signal("open") #Wyślij sygnał otwórz
			chest = null
	  
	if potion != null: #Jeżeli gracz stoi przy potionie
		if Input.is_action_just_pressed("pick"): #jeżeli gracz naciśnie przycisk pick
			var potion_name = potion.get_node("PotionNameHolder").text #zmienna przechowująca nazwe potka bez oznaczenia kopii np 50%Potion
			var potion_tmp = potion.name #zmienna przechowująca rzeczywistą nazwe danego potka w scenie np 50%Potion2
			if potions[2]=="Empty": #jeżeli niema potka na slocie 2 to:
				swap_potion(2,potion_name) #ustawienie na slot 2 potka przy ktorym stoi gracz
			else:
				potions_amount[potions[1]] = 0 #wyzerowanie ilości potków aktualnego potka na miejscu 1
				swap_potion(1,potion_name) #ustawienie na slot 1 potka przy ktorym stoi gracz
		
			if "50%Potion" in potion_name:
				potions_amount["50%Potion"]+=1 #zwieksza ilość potek 50% o 1
			elif "100%Potion" in potion_name:
				potions_amount["100%Potion"]+=1#zwieksza ilość potek 100% o 1
			elif "20healthPotion" in potion_name:
				potions_amount["20healthPotion"]+=1 #zwieksza ilość potek 20hp o 1
			elif "60healthPotion" in potion_name:
				potions_amount["60healthPotion"]+=1 #zwieksza ilość potek 60hp o 1
			potion = null #wyzerowanie zmiennej potion, czyli gracz niestoi już przy potku
			
			level.get_node(potion_tmp).queue_free() #usuniecie podniesionego potka z sceny
			UpdatePotions()
	
	if potions_amount[potions[2]] != 0 and  potions_amount[potions[1]] == 0: #jeżeli potek z 1 slota został zużyty i jest jakiś potek na slocie 2 to:
		change_potion_slot()  											# potek z 2 slota zostaje przeniesiony do slota 1
		

	if Input.is_action_just_pressed("use_potion"): #funkcja wywoływana jak nacisniety zostanie przycisk uzycia potionu
		level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
		base_hp = level.get_node("Player").base_health #pobranie bazowego hp gracza
		if level.get_node("Player").health == base_hp: #gdy player ma pełne hp niemożna użyc potki
			return
		if potions_amount["50%Potion"] > 0 and potions[1] == "50%Potion": 									#jeżeli gracz posiada jakieś potki half hp to:
			if level.get_node("Player").health > 0.5*base_hp:	#jeżeli gracz ma ponad pół hp to:
				level.get_node("Player").health = base_hp		#ustawia jego hp na wartość bazowego czyli 100% (zabezpieczenie żeby niedodawało wiecej hp niż bazówka)
			else: 	#jeżeli ma mniej niż pół hp
				level.get_node("Player").health += 0.5*base_hp #leczy o pół hp

			emit_signal("health_updated", health) #emituje sygnał do aktualizacji paska hp
			potions_amount["50%Potion" ] -= 1 #odejmuje jedną potke halp hp
		elif potions_amount["100%Potion"] > 0 and potions[1] == "100%Potion": #jeżeli gracz posiada potki full hp to:
			level.get_node("Player").health = base_hp #ustawia hp playera na bazowe hp
			emit_signal("health_updated", health) #emituje sygnał do aktualizacji paska hp
			potions_amount["100%Potion"] -= 1 #odejmuje jednego potka full hp
		elif potions_amount["20healthPotion"] > 0 and potions[1] == "20healthPotion":
			if level.get_node("Player").health > base_hp-20:
				level.get_node("Player").health = base_hp
			else:
				level.get_node("Player").health += 20
			emit_signal("health_updated", health)
			potions_amount["20healthPotion"] -= 1
		elif  potions_amount["60healthPotion"] > 0 and potions[1] == "60healthPotion":
			if level.get_node("Player").health > base_hp-60:
				level.get_node("Player").health = base_hp
			else:
				level.get_node("Player").health += 60
			emit_signal("health_updated", health)
			potions_amount["60healthPotion"] -= 1
		#elif Potion_in_time > 0:
		#	statusEffect.healAmount = 50
		#	statusEffect.healing = true
		#	Potion_in_time -= 1
		UpdatePotions()

	if weapons[2] != "Empty": 
		if Input.is_action_just_pressed("change_weapon_slot"): #jezeli drugi slot nie jest pusty
			change_weapon_slot(actual_slot)
	if potions[2] != "Empty": 									#jeżeli jest potek na 2 slocie i:
		if Input.is_action_just_pressed("change_potion_slot"): 	#jeżeli zostanie nacisniety przycisk zmiany slota potionu
			change_potion_slot() #potki zamieniają się miejscami w slotach
			
func check_current_weapon(): #funkcja sprawdza aktualnie uzywana bron gracza porownujac tekstury
	if weapons[2] == "Empty": #jezeli drugi slot jest pusty to zawsze zwracany jest slot nr 1
		return 1
	else:
		if all_weapons[weapons[1]] == actualweapon_access.texture: 
			return 1
		elif all_weapons[weapons[2]] == actualweapon_access.texture:
			return 2
		


func change_potion_slot(): #funcja zamieniająca potki miejscami
	var tmp = potions[1]
	potions[1] = potions[2]
	potions[2] = tmp
	UpdatePotions()
	

func change_weapon_slot(currentSlot):
	match currentSlot:
		1:
			actual_slot = 2
			wslots_visibility[2].visible = true #zielone tlo na ui pojawia sie pod aktualnie uzywana bronka
			wslots_visibility[1].visible = false
			$EquippedWeapon.set_script(all_weapons_script[weapons[actual_slot]]) #Tylko melee poki co ;/
			$EquippedWeapon.damage = second_weapon_stats['attack']
		2:
			actual_slot = 1
			wslots_visibility[1].visible = true
			wslots_visibility[2].visible = false
			$EquippedWeapon.set_script(all_weapons_script[weapons[actual_slot]]) #Tylko melee poki co ;/
			$EquippedWeapon.damage = first_weapon_stats['attack']	
	$EquippedWeapon.position=Vector2.ZERO
	$EquippedWeapon.timer = $EquippedWeapon/Timer


func swap_weapon(slot,weaponOnGround):
	match slot:
		1:
			ui_access_wslots[1].texture = all_weapons[weaponOnGround.WeaponName]
			first_weapon_stats = weaponOnGround.Stats
			wslots_visibility[1].visible = true
			wslots_visibility[2].visible = false
		2: 
			ui_access_wslots[2].texture = all_weapons[weaponOnGround.WeaponName]
			second_weapon_stats = weaponOnGround.Stats
			wslots_visibility[2].visible = true
			wslots_visibility[1].visible = false
	if weapons[slot] != "Empty":
		var weaponUsed = load("res://Scenes/Loot/Weapon.tscn") #wczytanie scenki bronki
		weaponUsed = weaponUsed.instance() #stworzenie instancji, aby aktualnie uzywana bronka byla na ziemi a jej miejsce zastapila
		weaponUsed.WeaponName = str(weapons[slot]) #przypisanie nazwy broni do instancji
		weaponUsed.position = weaponOnGround.global_position #bronka, ktora mamy w rece i zaraz ja zamienimy pobiera pozycje bronki ktora aktualnie na ziemi lezy
		level.add_child(weaponUsed) #"odlozenie bronki" aktualnie uzywanej
	weapons[slot] = weaponOnGround.WeaponName #przypisanie bronki podniesionej z ziemi do aktualnie uzywanego slota
	$EquippedWeapon.position=Vector2.ZERO
	$EquippedWeapon.set_script(all_weapons_script[weaponOnGround.WeaponName])
	$EquippedWeapon.timer = $EquippedWeapon/Timer #przypisanie wlasciwosci bronki damage, speed itd
	$EquippedWeapon.damage = weaponOnGround.Stats['attack']
	weaponOnGround.queue_free()
	
			
func swap_potion(slot,potionOnGround): #funkcja do podnoszenia potionów
	if potions[2] !="Empty":
		if slot == 1:
			ui_access_pslot1.texture = all_potions[potionOnGround]
		elif slot == 2:
			ui_access_pslot2.texture = all_potions[potionOnGround]
		potions[slot] = potionOnGround
		equipped_potion = potions[slot]
	else:
		ui_access_pslot2.texture = all_potions[potionOnGround]
		potions[2] = potionOnGround
		equipped_potion = potions[2]

func movement(): #funkcja poruszania się
	direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() # Określenie kierunku poruszania się
	velocity = direction * speed * statusEffect.speedMultiplier #pomnożenie wektora kierunku z wartością szybkości daje prędkość
	velocity = move_and_slide(velocity, Vector2.UP) #wywołanie poruszania się
	if !got_hitted: #jeżeli nie jest uderzany
		if direction == Vector2.ZERO: #jeżeli stoi w miejscu
			$AnimationPlayer.play("Idle") #włącz animację "Idle"
		elif direction.y != 0: #jeżeli porusza się w pionie
			$AnimationPlayer.play("Run") #włącz animację "Run"
			if direction.x < 0: #jeżeli idzie w lewo
				$PlayerSprite.scale.x = -abs($PlayerSprite.scale.x) #obróć bohatera w lewo
			else: #jeżeli idzie w prawo
				$PlayerSprite.scale.x = abs($PlayerSprite.scale.x) #obróć bohatera w prawo
		elif direction.x < 0: #jeżeli idzie w lewo
			$PlayerSprite.scale.x = -abs($PlayerSprite.scale.x) #obróć bohatera w lewo
			$AnimationPlayer.play("Run") #włącz animację "Run"
		elif direction.x > 0: #jeżeli idzie w prawo
			$PlayerSprite.scale.x = abs($PlayerSprite.scale.x) #obróć bohatera w prawo
			$AnimationPlayer.play("Run") #włącz animację "Run"

func take_dmg(dps): #otrzymanie obrażeń przez bohatera
	health = health - (dps * statusEffect.damageMultiplier) # aktualizacja ilości życia z uwzględnieniem współczynnika damage
	emit_signal("health_updated", health) #wyemitowanie sygnału o zmianie ilości punktów życia
	got_hitted = true #bohater jest uderzany
	$AnimationPlayer.play("Hit") #włącz animację "Hit"
	yield($AnimationPlayer, "animation_finished") #poczekaj do końca animacji
	got_hitted = false #bohater nie jest uderzany
	if (health <= 0):
		get_tree().change_scene("res://Scenes/UI/DeathScene.tscn")

func _on_Pick_body_entered(body): #Jeśli coś do podniesienia jest w zasięgu gracza to przypisz do zmiennych węzeł
	if body.is_in_group("Pickable"):
		if "GoldCoin" in body.name:
			coins += 10
			body.queue_free()
		elif "Weapon" in body.name:
			weaponToTake = body
		elif "Chest" in body.name:
			chest = body
		elif "50%Potion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["50%Potion" ] != 0: #sprawdzenie czy player posiada jakieś potki 50%
				potions_amount["50%Potion" ] += 1 #jeżeli ma to ilosc potek 50% zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 50% to musi kliknąć pick żeby podnieść
				potion = body

		elif "100%Potion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["100%Potion" ] != 0: #sprawdzenie czy player posiada jakieś potki 100%
				potions_amount["100%Potion" ] += 1 #jeżeli ma to ilosc potek 100% zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 100% to musi kliknąć pick żeby podnieść
				potion = body

		elif "20healthPotion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["20healthPotion" ] != 0: #sprawdzenie czy player posiada jakieś potki 20hp
				potions_amount["20healthPotion" ] += 1 #jeżeli ma to ilosc potek 20hp zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 20 aktualna potka jest zamieniana na potke 20hp
				potion = body


		elif "60healthPotion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["60healthPotion" ] != 0: #sprawdzenie czy player posiada jakieś potki 60hp
				potions_amount["60healthPotion" ] += 1 #jeżeli ma to ilosc potek 60hp zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 60 aktualna potka jest zamieniana na potke 60hp
				potion = body		

			
	level.get_node("UI/Coins").text = "Coins:"+str(coins)
	

func _on_Player_health_updated(health): #pusta funkcja która pozwala na poprawne działanie sygnałów
	pass

func _on_Pick_body_exited(body): #Rozwiązanie tymczasowe
	weaponToTake = null
	chest = null

