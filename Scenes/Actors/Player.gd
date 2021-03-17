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
var weaponToTake = null #Zmienna określająca czy gracz stoi przy broni leżącej na ziemi
var equipped = "Blade" #Aktualnie używana broń
var chest = null #Zmienna określająca czy gracz stoi przy skrzyni
var level #przypisanie sceny głównej
var all_weapons = {} #wszystkie bronki
var weapons = {} #posiadane bronki

onready var ui_access_wslot1 = get_node("../UI/Slots/Background/Weaponslot1/weaponsprite1")
onready var ui_access_wslot2 = get_node("../UI/Slots/Background/Weaponslot2/weaponsprite2")
onready var actualweapon_access = get_node("../Player/EquippedWeapon/WeaponSprite")

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
		"BloodSword" : preload("res://Assets/Loot/Weapons/BloodSword.png"),
		"FireScepter" : preload("res://Assets/Loot/Weapons/firescepter.png"),
		"FMS" : preload("res://Assets/Loot/Weapons/FMS.png"),
		"Hammer" : preload("res://Assets/Loot/Weapons/Hammer.png"),
		"Katana" : preload("res://Assets/Loot/Weapons/Katana.png"),
		"Knife" : preload("res://Assets/Loot/Weapons/Knife.png"),
		"Spear" : preload("res://Assets/Loot/Weapons/Spear.png")
	}
	weapons = {
		"Slot1" : "Blade",
		"Slot2" : "Empty"
	}
	ui_access_wslot1.texture = all_weapons[weapons["Slot1"]]

func _physics_process(delta): #funkcja wywoływana co klatkę

	if Input.is_action_just_pressed("attack"): #jeżeli przycisk "attack" został wsciśnięty
		emit_signal("attacked") #wyemituj sygnał że bohater zaatakował
	else: #Jeżeli nie atakuje to
		movement() #wywołanie funkcji poruszania się
	if weaponToTake != null: #Jeżeli gracz stoi przy broni do podniesienia
		if Input.is_action_just_pressed("pick"): #Jeżeli nacisnął przycisk podniesienia
			var weaponName = weaponToTake.WeaponName
			if equipped != weaponName:
				if weapons["Slot2"] == "Empty":
					weapons["Slot2"] = weaponName
					ui_access_wslot2.texture = all_weapons[weaponName]
				else:
					var current_weapon = check_current_weapon()
					if current_weapon == 1:
						weapons["Slot1"] = all_weapons[weaponName]
						ui_access_wslot1.texture = all_weapons[weaponName]
						actualweapon_access.texture = all_weapons[weaponName]
					elif current_weapon == 2:
						weapons["Slot2"] = weaponName
						ui_access_wslot2.texture = all_weapons[weaponName]
						actualweapon_access.texture = all_weapons[weaponName]
						
	if chest != null: #Jeżeli gracz stoi przy skrzyni
		if Input.is_action_just_pressed("pick"):
			emit_signal("open") #Wyślij sygnał otwórz
			chest = null
			
func check_current_weapon():
	var current_weapon = actualweapon_access.texture
	if all_weapons[weapons["Slot1"]] == actualweapon_access.texture:
		return 1
	elif all_weapons[weapons["Slot2"]] == actualweapon_access.texture:
		return 2

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
			weaponToTake = body
		elif "Chest" in body.name:
			chest = body
	level.get_node("UI/Coins").text = "Coins:"+str(coins)

func _on_Player_health_updated(health): #pusta funkcja która pozwala na poprawne działanie sygnałów
	pass

func _on_Pick_body_exited(body): #Rozwiązanie tymczasowe
	weaponToTake = null
	chest = null

