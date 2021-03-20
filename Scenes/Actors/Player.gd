extends KinematicBody2D

signal health_updated(health, amount) #deklaracja sygnału który będzie emitowany po zmianie ilości punktów życia bohatera
signal attacked(damage) #deklaracja sygnału który będzie emitowany podczas ataku bohatera
signal open() #deklaracja sygnału który będzie emitowany podczas otwarcia skrzyni przez bohatera

var velocity = Vector2.ZERO #wektor prędkości bohatera
var got_hitted = false #czy bohater jest aktualnie uderzany
export var speed = 2 #wartośc szybkości bohatera
var direction = Vector2() #wektor kierunku bohatera
export var health = 100 #ilośc punktów życia bohatera
var coins = 0 #ilośc coinsów bohatera
var weapon = null #Zmienna określająca czy gracz stoi przy broni leżącej na ziemi
var equipped = "Blade" #Aktualnie używana broń
var chest = null #Zmienna określająca czy gracz stoi przy skrzyni
var level #przypisanie sceny głównej

var base_health = health #zmienna przechowująca bazowe hp bohatera
onready var statusEffect = get_node("../UI/StatusBar")


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
	
	#Rozwiązanie tymczasowe związane z wyświetlaniem aaktualnej broni gracza
	$EquippedWeapon.set_script(load("res://Scenes/Equipment/Weapons/Melee/Blade.gd"))
	$EquippedWeapon.damage = 10
	$EquippedWeapon.timer = $EquippedWeapon/Timer


func _physics_process(delta): #funkcja wywoływana co klatkę
	if Input.is_action_just_pressed("attack"): #jeżeli przycisk "attack" został wsciśnięty
		emit_signal("attacked") #wyemituj sygnał że bohater zaatakował
	else: #Jeżeli nie atakuje to
		movement() #wywołanie funkcji poruszania się
	if weapon != null: #Jeżeli gracz stoi przy broni do podniesienia
		if Input.is_action_just_pressed("pick"): #Jeżeli nacisnął przycisk podniesienia
			var weaponName = weapon.WeaponName #Przypisz nazwę broni leżącej na ziemi do zmiennej
			if equipped != weaponName: #Jeżeli nazwa aktualnej broni jak tej do podniesienia to nic nie rób (najpewniej rozwiązanie tymczasowe)
				var weaponUsed = load("res://Scenes/Loot/Weapon.tscn") #Wczytaj scenę broni aby utworzyć węzeł dla broni którą gracz upuści
				weaponUsed = weaponUsed.instance()
				weaponUsed.position = weapon.position #Upuść broń na tą samą pozycję co broń podnoszona
				weaponUsed.WeaponName = equipped #Ustaw nazwę broni upuszczanej na broń wcześniej wyekwipowaną
				level.add_child(weaponUsed) #utwórz węzeł broni leżącej na ziemi
				equipped = weaponName #Zmień nazwę aktualnej broni na tą podniesioną
				#Wycentruj broń na graczu, zmień broń
				$EquippedWeapon.position=Vector2.ZERO
				$EquippedWeapon.set_script(load('res://Scenes/Equipment/Weapons/'+weapon.Stats['range']+'/'+weaponName+'.gd')) #Wczytuje skrypt odpowiedni dla danej broni
				$EquippedWeapon.timer = $EquippedWeapon/Timer #Przypisuje do zmiennej stoper
				$EquippedWeapon.damage = int(weapon.Stats['attack']) #Przypisz broni wartość ataku
				weapon.queue_free() #Usuń instancję podniesionej broni
				weapon = null
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
	
func movement(): #funkcja poruszania się
	direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() # Określenie kierunku poruszania się
	velocity = direction * speed #pomnożenie wektora kierunku z wartością szybkości daje prędkość
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
	health = health - dps #aktualizacja ilości życia
	emit_signal("health_updated", health) #wyemitowanie sygnału o zmianie ilości punktów życia
	got_hitted = true #bohater jest uderzany
	$AnimationPlayer.play("Hit") #włącz animację "Hit"
	yield($AnimationPlayer, "animation_finished") #poczekaj do końca animacji
	got_hitted = false #bohater nie jest uderzany



func _on_Pick_body_entered(body): #Jeśli coś do podniesienia jest w zasięgu gracza to przypisz do zmiennych węzeł
	if body.is_in_group("Pickable"):
		if "GoldCoin" in body.name:
			coins += 10
			body.queue_free()
		elif "Weapon" in body.name:
			weapon = body
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
	weapon = null
	chest = null








