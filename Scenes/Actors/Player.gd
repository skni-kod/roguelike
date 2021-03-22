extends KinematicBody2D

signal health_updated(health, amount) #deklaracja sygnału który będzie emitowany po zmianie ilości punktów życia bohatera
signal attacked(damage) #deklaracja sygnału który będzie emitowany podczas ataku bohatera
signal open() #deklaracja sygnału który będzie emitowany podczas otwarcia skrzyni przez bohatera

onready var statusEffect = get_node("../UI/StatusBar")

var velocity = Vector2.ZERO #wektor prędkości bohatera
var got_hitted = false #czy bohater jest aktualnie uderzany
export var speed = 2 #wartośc szybkości bohatera
var direction = Vector2() #wektor kierunku bohatera
export var health = 100 #ilośc punktów życia bohatera
var base_health = 100 # bazowa ilość życia gracza
var coins = 0 #ilośc coinsów bohatera
var weaponToTake = null #Zmienna określająca czy gracz stoi przy broni leżącej na ziemi
var equipped #Aktualnie używana broń
var chest = null #Zmienna określająca czy gracz stoi przy skrzyni
var level #przypisanie sceny głównej
var all_weapons = {} #wszystkie bronki
var weapons = {} #posiadane bronki
var current_weapon
var first_weapon_stats = {"attack":float(10)}
var second_weapon_stats = {}

onready var ui_access_wslot1 = get_node("../UI/Slots/Background/Weaponslot1/weaponsprite1")
onready var ui_access_wslot2 = get_node("../UI/Slots/Background/Weaponslot2/weaponsprite2")
onready var actualweapon_access = get_node("../Player/EquippedWeapon/WeaponSprite")
onready var w1slot_visibility = get_node("../UI/Slots/Background/w1slotbg")
onready var w2slot_visibility = get_node("../UI/Slots/Background/w2slotbg")

#zmienne do funkcji potionów
var potion = null
var base_hp = null  
var Half_hp_Potion = 0
var Full_hp_Potion = 0
var Potion20 = 0
var Potion60 = 0
var Potion100 = 0
var Potion_in_time = 0

func ClearPotions(): #funkcja resetująca ilość potionów
	Half_hp_Potion = 0
	Full_hp_Potion = 0
	Potion20 = 0
	Potion60 = 0
	Potion100 = 0
	Potion_in_time = 0

func _ready(): #po inicjacji bohatera
	level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
	emit_signal("health_updated", health) #emitowanie sygnału o zmianie życia bohatera 100%/100% 
	level.get_node("UI/Coins").text = "Coins:"+str(coins) #aktualizacja napisu z ilością coinsów bohatera
	
	#Rozwiązanie tymczasowe związane z wyświetlaniem aktualnej broni gracza
	$EquippedWeapon.set_script(load("res://Scenes/Equipment/Weapons/Melee/Blade.gd"))
	$EquippedWeapon.damage = 10
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
		"Spear" : preload("res://Assets/Loot/Weapons/spear.png")
	}
	weapons = {
		1 : "Blade",
		2 : "Empty"
	}
	ui_access_wslot1.texture = all_weapons[weapons[1]]
	equipped = "Blade"
	
func _physics_process(delta): #funkcja wywoływana co klatkę
	if Input.is_action_just_pressed("attack"): #jeżeli przycisk "attack" został wsciśnięty
		emit_signal("attacked") #wyemituj sygnał że bohater zaatakował
	else: #Jeżeli nie atakuje to
		movement() #wywołanie funkcji poruszania się
	
	if weaponToTake != null: #Jeżeli gracz stoi przy broni do podniesienia
		if Input.is_action_just_pressed("pick"): #Jeżeli nacisnął przycisk podniesienia
			print(equipped)
			if equipped != weaponToTake.WeaponName:
				if weapons[2] == "Empty":
					swap_weapon(2,weaponToTake)
				else:
					if current_weapon != null:
						swap_weapon(current_weapon,weaponToTake)
	if chest != null: #Jeżeli gracz stoi przy skrzyni
		if Input.is_action_just_pressed("pick"):
			emit_signal("open") #Wyślij sygnał otwórz
			chest = null
	
	if potion != null:
		if Input.is_action_just_pressed("pick"):
			var potion_name = potion.name
			ClearPotions() #zeruje ilość wszystkich potek
			if "50%Potion" in potion_name:
				level.get_node("Player").Half_hp_Potion += 1 #zwieksza ilość potek 50% o 1
			elif "100%Potion" in potion_name:
				level.get_node("Player").Full_hp_Potion += 1 #zwieksza ilość potek 100% o 1
			elif "20healthPotion" in potion_name:
				level.get_node("Player").Potion20 += 1 #zwieksza ilość potek 20hp o 1
			elif "60healthPotion" in potion_name:
				level.get_node("Player").Potion60 += 1 #zwieksza ilość potek 60hp o 1
			potion = null
			print("Fullhp: ",Full_hp_Potion)
			print("Halfhp: ",Half_hp_Potion)	
			print("potek+20: ",Potion20)	
			print("potek+60:",Potion60)	
			level.get_node(potion_name).queue_free()


	if Input.is_action_just_pressed("use_potion"): #funkcja wywoływana jak nacisniety zostanie przycisk uzycia potionu
		level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
		base_hp = level.get_node("Player").base_health
		if level.get_node("Player").health == base_hp: #gdy player ma pełne hp niemożna użyc potki
			return
		if Half_hp_Potion > 0: 									#jeżeli gracz posiada jakieś potki half hp to:
			if level.get_node("Player").health > 0.5*base_hp:	#jeżeli gracz ma ponad pół hp to:
				level.get_node("Player").health = base_hp		#ustawia jego hp na wartość bazowego czyli 100% (zabezpieczenie żeby niedodawało wiecej hp niż bazówka)
			else: 	#jeżeli ma mniej niż pół hp
				level.get_node("Player").health += 0.5*base_hp #leczy o pół hp

			emit_signal("health_updated", health) #emituje sygnał do aktualizacji paska hp
			Half_hp_Potion -= 1 #odejmuje jedną potke halp hp
		elif Full_hp_Potion > 0: #jeżeli gracz posiada potki full hp to:
			level.get_node("Player").health = base_hp #ustawia hp playera na bazowe hp
			emit_signal("health_updated", health) #emituje sygnał do aktualizacji paska hp
			Full_hp_Potion -= 1 #odejmuje jednego potka full hp
		elif Potion20 > 0:
			if level.get_node("Player").health > base_hp-20:
				level.get_node("Player").health = base_hp
			else:
				level.get_node("Player").health += 20
			emit_signal("health_updated", health)
			Potion20 -= 1
		elif Potion60 > 0:
			if level.get_node("Player").health > base_hp-60:
				level.get_node("Player").health = base_hp
			else:
				level.get_node("Player").health += 60
			emit_signal("health_updated", health)
			Potion60 -= 1
		elif Potion100 > 0:
			if level.get_node("Player").health > base_hp-100:
				level.get_node("Player").health = base_hp
			else:
				level.get_node("Player").health += 1000
			emit_signal("health_updated", health)
			Potion100 -= 1
		elif Potion_in_time > 0:
			statusEffect.healAmount = 50
			statusEffect.healing = true
			Potion_in_time -= 1


		print("Fullhp: ",Full_hp_Potion)
		print("Halfhp: ",Half_hp_Potion)	
		print("potek+20: ",Potion20)		
		print("potek+60:",Potion60)
		
	if weaponToTake != null: #Jeżeli gracz stoi przy broni do podniesienia
		if Input.is_action_just_pressed("pick"): #Jeżeli nacisnął przycisk podniesienia
			if equipped != weaponToTake.WeaponName:
				if weapons[2] == "Empty":
					swap_weapon(2,weaponToTake)
				else:
					if current_weapon != null:
						swap_weapon(current_weapon,weaponToTake)
	if chest != null: #Jeżeli gracz stoi przy skrzyni
		if Input.is_action_just_pressed("pick"):
			emit_signal("open") #Wyślij sygnał otwórz
			chest = null
	if weapons[2] != "Empty":
		if Input.is_action_just_pressed("change_weapon_slot"):
			current_weapon = check_current_weapon()
			change_weapon_slot(current_weapon)
			
func check_current_weapon():
	if weapons[2] == "Empty":
		return 1
	else:
		if all_weapons[weapons[1]] == actualweapon_access.texture:
			return 1
		if all_weapons[weapons[2]] == actualweapon_access.texture:
			return 2

func change_weapon_slot(currentSlot):
	if currentSlot == 1:
		equipped = weapons[2]
		w2slot_visibility.visible = true
		w1slot_visibility.visible = false
		$EquippedWeapon.position=Vector2.ZERO
		$EquippedWeapon.set_script(load('res://Scenes/Equipment/Weapons/Melee/'+str(weapons[2])+'.gd')) #Tylko melee poki co ;/
		$EquippedWeapon.timer = $EquippedWeapon/Timer
		$EquippedWeapon.damage = second_weapon_stats['attack']
	if currentSlot == 2:
		equipped = weapons[1]
		w1slot_visibility.visible = true
		w2slot_visibility.visible = false
		$EquippedWeapon.position=Vector2.ZERO
		$EquippedWeapon.set_script(load('res://Scenes/Equipment/Weapons/Melee/'+str(weapons[1])+'.gd'))
		$EquippedWeapon.timer = $EquippedWeapon/Timer
		$EquippedWeapon.damage = first_weapon_stats['attack']

func swap_weapon(slot,weaponOnGround):
	if weapons[2] != "Empty":
		if slot == 1:
			ui_access_wslot1.texture = all_weapons[weaponOnGround.WeaponName]
			first_weapon_stats = weaponOnGround.Stats
			w1slot_visibility.visible = true
			w2slot_visibility.visible = false
		elif slot == 2:
			ui_access_wslot2.texture = all_weapons[weaponOnGround.WeaponName]
			second_weapon_stats = weaponOnGround.Stats
			w2slot_visibility.visible = true
			w1slot_visibility.visible = false
		var weaponUsed = load("res://Scenes/Loot/Weapon.tscn")
		weaponUsed = weaponUsed.instance()
		weaponUsed.WeaponName = str(weapons[slot])
		weaponUsed.position = weaponOnGround.position
		level.add_child(weaponUsed)
		weapons[slot] = weaponOnGround.WeaponName
		equipped = weapons[slot]
		$EquippedWeapon.position=Vector2.ZERO
		$EquippedWeapon.set_script(load('res://Scenes/Equipment/Weapons/'+weaponOnGround.Stats['range']+'/'+weaponOnGround.WeaponName+'.gd'))
		$EquippedWeapon.timer = $EquippedWeapon/Timer
		$EquippedWeapon.damage = weaponOnGround.Stats['attack']
		weaponOnGround.queue_free()
	else:
		ui_access_wslot2.texture = all_weapons[weaponOnGround.WeaponName]
		weapons[2] = weaponOnGround.WeaponName
		equipped = weapons[2]
		second_weapon_stats = weaponOnGround.Stats
		w2slot_visibility.visible = true
		w1slot_visibility.visible = false
		$EquippedWeapon.position=Vector2.ZERO
		$EquippedWeapon.set_script(load('res://Scenes/Equipment/Weapons/'+weaponOnGround.Stats['range']+'/'+weaponOnGround.WeaponName+'.gd'))
		$EquippedWeapon.timer = $EquippedWeapon/Timer
		$EquippedWeapon.damage = float(weaponOnGround.Stats['attack'])
		weaponOnGround.queue_free()
	
func movement(): #funkcja poruszania się
	direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() # Określenie kierunku poruszania się
	velocity = direction * speed * statusEffect.speedMultiplier #pomnożenie wektora kierunku z wartością szybkości daje prędkość
	velocity = move_and_collide(velocity) #wywołanie poruszania się
	if !got_hitted: #jeżeli nie jest uderzany
		if direction == Vector2.ZERO: #jeżeli stoi w miejscu
			$AnimationPlayer.play("Idle") #włącz animację "Idle"
		elif direction.y != 0: #jeżeli porusza się w pionie
			$AnimationPlayer.play("Run") #włącz animację "Run"
			if direction.x < 0: #jeżeli idzie w lewo
				$PlayerSprite.scale.x = -1 #obróć bohatera w lewo
			else: #jeżeli idzie w prawo
				$PlayerSprite.scale.x = 1 #obróć bohatera w prawo
		elif direction.x < 0: #jeżeli idzie w lewo
			$PlayerSprite.scale.x = -1 #obróć bohatera w lewo
			$AnimationPlayer.play("Run") #włącz animację "Run"
		elif direction.x > 0: #jeżeli idzie w prawo
			$PlayerSprite.scale.x = 1 #obróć bohatera w prawo
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
			current_weapon = check_current_weapon()
			weaponToTake = body
		elif "Chest" in body.name:
			chest = body
		elif "50%Potion" in body.name: #jeżeli player wejdzie w potka
			level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if level.get_node("Player").Half_hp_Potion != 0: #sprawdzenie czy player posiada jakieś potki 50%
				level.get_node("Player").Half_hp_Potion += 1 #jeżeli ma to ilosc potek 50% zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy

			else: #jeżeli nie posiada potki 50% to musi kliknąć pick żeby podnieść
				potion = body


			print("Fullhp: ",Full_hp_Potion)
			print("Halfhp: ",Half_hp_Potion)	
			print("potek+20: ",Potion20)	
			print("potek+60:",Potion60)	

		elif "100%Potion" in body.name: #jeżeli player wejdzie w potka
			level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if level.get_node("Player").Full_hp_Potion != 0: #sprawdzenie czy player posiada jakieś potki 100%
				level.get_node("Player").Full_hp_Potion += 1 #jeżeli ma to ilosc potek 100% zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy

			else: #jeżeli nie posiada potki 100% to musi kliknąć pick żeby podnieść
				potion = body

			print("Fullhp: ",Full_hp_Potion)
			print("Halfhp: ",Half_hp_Potion)	
			print("potek+20: ",Potion20)	
			print("potek+60:",Potion60)	

		elif "20healthPotion" in body.name: #jeżeli player wejdzie w potka
			level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if level.get_node("Player").Potion20 != 0: #sprawdzenie czy player posiada jakieś potki 20hp
				level.get_node("Player").Potion20 += 1 #jeżeli ma to ilosc potek 20hp zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy

			else: #jeżeli nie posiada potki 20 aktualna potka jest zamieniana na potke 20hp
				potion = body

			print("Fullhp: ",Full_hp_Potion)
			print("Halfhp: ",Half_hp_Potion)	
			print("potek+20: ",Potion20)	
			print("potek+60:",Potion60)	

		elif "60healthPotion" in body.name: #jeżeli player wejdzie w potka
			level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if level.get_node("Player").Potion60 != 0: #sprawdzenie czy player posiada jakieś potki 60hp
				level.get_node("Player").Potion60 += 1 #jeżeli ma to ilosc potek 60hp zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy

			else: #jeżeli nie posiada potki 60 aktualna potka jest zamieniana na potke 60hp
				potion = body

			print("Fullhp: ",Full_hp_Potion)
			print("Halfhp: ",Half_hp_Potion)	
			print("potek+20: ",Potion20)
			print("potek+60:",Potion60)
			
	level.get_node("UI/Coins").text = "Coins:"+str(coins)

func _on_Player_health_updated(health): #pusta funkcja która pozwala na poprawne działanie sygnałów
	pass

func _on_Pick_body_exited(body): #Rozwiązanie tymczasowe
	weaponToTake = null
	chest = null

