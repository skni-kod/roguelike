extends KinematicBody2D

signal health_updated(health, amount) #deklaracja sygnału który będzie emitowany po zmianie ilości punktów życia bohatera
signal mana_updated(mana, amount) #deklaracja sygnału który będzie emitowany po zmianie ilości punktów many bohatera
signal attacked(damage) #deklaracja sygnału który będzie emitowany podczas ataku bohatera
signal open() #deklaracja sygnału który będzie emitowany podczas otwarcia skrzyni przez bohatera
signal player_moved(movement_vec)

onready var statusEffect = get_node("../UI/StatusBar")
onready var hand = $Hand

var velocity = Vector2.ZERO #wektor prędkości bohatera
var got_hitted = false #czy bohater jest aktualnie uderzany
export var speed = 100 #wartośc szybkości bohatera
var direction = Vector2() #wektor kierunku bohatera
export var health = 100 #ilośc punktów życia bohatera
export var mana = 100 #ilość many (1pkt many ~= 1 użycie umki)
var max_health = 100 #maksymalna ilość życia gracza, może zostać zmieniona w trakcie rozgrywki
var max_mana = 200 #maksymalna ilość many
var manaRegenRate=2.5 #Temorary value calculated according to equipment used. If you wish to change it permamently go to statusEffect.gd
var additionalManaRegen=0 #Dodatkowa regenacja many jako procent podstawowej
var coins = 0 #ilośc coinsów bohatera
var currentlyEquippedWeapon # Aktualnie używana broń
var chest = null #Zmienna określająca czy gracz stoi przy skrzyni
var level #przypisanie sceny głównej
var equippedWeapons = {} #posiadane bronki

var stepsoundvar

onready var UISlotWeaponSprite1 = get_node("../UI/Slots/Background/Weaponslot1/weaponsprite1")
onready var UISlotWeaponSprite2 = get_node("../UI/Slots/Background/Weaponslot2/weaponsprite2")
onready var skillSlots = get_tree().get_root().find_node("Slots", true, false)

onready var w1slot_visibility = get_node("../UI/Slots/Background/w1slotbg")
onready var w2slot_visibility = get_node("../UI/Slots/Background/w2slotbg")

# --- WEAPON VARS --- #
var weaponToTake = null		# Variable for holding a weapon to pick up
# --- ----------- --- #

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

var skok = false
var skok_vector = Vector2.DOWN
var stamina = 3

# === ZMIENNE DO KNOCKBACKU === #
var knockback = Vector2.ZERO
var knockbackResistance = 1 # rezystancja knockbacku zakres -> (0.6-nieskończoność), poniżej 0.6 przeciwnicy za daleko odlatują
# === ===================== === #

var immortal = 0 #jezeli rowne 1 to niesmiertelny

func UpdatePotions() -> void: #funkcja aktualizująca status potek
	if potions_amount[potions[1]] == 0: #jeżeli ilosc potek na slocie 1 jest rowna 0 to:
		ui_access_pslot1.texture = null  # usuniecie tekstury z slotu pierwszego
		potion1_amount.text = "" # ustawienie textu ilosci potek na nic
		potions[1] = "Empty" #przypisanie potxe z slotu 1 nazwe Empty potrzebne do poprawnego działania
	if potions_amount[potions[2]] == 0: #to samo co wyżej tylko dla slotu 2
		ui_access_pslot2.texture = null
		potion2_amount.text = ""
		potions[2] = "Empty"
		
	if potions[2] != "Empty" and potions[1] != "Empty": #jeżeli niema potki na slocie pierwszy ani drugim to:
		ui_access_pslot1.texture = all_potions[potions[1]] #przypisanie do textury slotu pierwszego textury aktualnego pierwszego potka
		ui_access_pslot2.texture = all_potions[potions[2]] #przypisanie do textury slotu drugiego textury aktualnego drugiego potka
		potion1_amount.text = str(potions_amount[potions[1]]) #aktualizacja textu ilości potek w eq
		potion2_amount.text = str(potions_amount[potions[2]]) #aktualizacja textu ilości potek w eq
	elif potions[1] != "Empty":
		ui_access_pslot1.texture = all_potions[potions[1]] #przypisanie do textury slotu pierwszego textury aktualnego pierwszego potka
		potion1_amount.text = str(potions_amount[potions[1]]) #aktualizacja textu ilości potek w eq
		

func _ready() -> void: #po inicjacji bohatera
	level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
	emit_signal("health_updated", health) #emitowanie sygnału o zmianie życia bohatera 100%/100% 
	emit_signal("mana_updated", mana) #emitowanie sygnału o zmianie many bohatera 100%/100% 
	if Bufor.coins:
		coins = Bufor.coins
	level.get_node("UI/Coins").text = "Coins:"+str(coins) #aktualizacja napisu z ilością coinsów bohatera
	
	equippedWeapons = {
		1 : "Axe",
		2 : "Empty"
	}
#	UISlotWeaponSprite1.texture = Weapons.all_weapons_textures[weapons[1]]
#	currentlyEquippedWeapon = Weapons.all_weapons_scenes[weapons[1]]
	
	
#	if Bufor.weapons: # jeśli bufor nie jest pusty
#		# bronie są ładowane z bufora
#		weapons = Bufor.weapons
#		first_weapon_stats = Bufor.first_weapon_stats
#		currentlyEquippedWeapon = Bufor.currentlyEquippedWeapon
#		if weapons[2] != "Empty":
#			second_weapon_stats = Bufor.second_weapon_stats
#			UISlotWeaponSprite2.texture = Weapons.all_weapons_textures[weapons[2]]
#		UISlotWeaponSprite1.texture = Weapons.all_weapons_textures[weapons[1]]
#		if weapons[1] == "katana": # naprawia błąd wielkiej katany w interfejsie
#				UISlotWeaponSprite1.scale.x = .8
#				UISlotWeaponSprite1.scale.y = .8
#		if weapons[2] == "katana":
#				UISlotWeaponSprite2.scale.x = .8
#				UISlotWeaponSprite2.scale.y = .8
	
	all_potions = { #słownik przechowujący png poszczegolnych potek
		"50%Potion" : preload("res://Assets/Loot/Potions/Potion50.png"),
		"100%Potion" : preload("res://Assets/Loot/Potions/Potion100.png"),
		"20healthPotion" : preload("res://Assets/Loot/Potions/Potion+20hp.png"),
		"60healthPotion" : preload("res://Assets/Loot/Potions/Potion+60hp.png"),
		"Empty" : preload("res://Assets/Loot/Potions/Empty.png")
	}
	if Bufor.potions: # jeżeli w buforze są dane
		# mikstury są ładowane z bufora
		potions = Bufor.potions
		potions_amount = Bufor.potions_amount
	else:
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
	stepsoundvar = 0

	
func _process(delta) -> void:	
	updateMana((statusEffect.manaRegenRate+additionalManaRegen)*0.0167)
	

func _physics_process(delta) -> void: #funkcja wywoływana co klatkę
	if ($CoolDownS1.get_time_left()):
		skillSlots.get_node('Background/Skillslot1/VBoxContainer/Label').text = str(round($CoolDownS1.get_time_left()))
	else:
		skillSlots.get_node('Background/Skillslot1/VBoxContainer/Label').text = 'R'
	
	if ($CoolDownS2.get_time_left()):
		skillSlots.get_node('Background/Skillslot2/VBoxContainer/Label').text = str(round($CoolDownS2.get_time_left()))
	else:
		skillSlots.get_node('Background/Skillslot2/VBoxContainer/Label').text = 'F'
		
	if ($CoolDownS3.get_time_left()):
		skillSlots.get_node('Background/Skillslot3/VBoxContainer/Label').text = str(round($CoolDownS3.get_time_left()))
	else:
		skillSlots.get_node('Background/Skillslot3/VBoxContainer/Label').text = 'R'
		
	if ($CoolDownS4.get_time_left()):
		skillSlots.get_node('Background/Skillslot4/VBoxContainer/Label').text = str(round($CoolDownS4.get_time_left()))
	else:
		skillSlots.get_node('Background/Skillslot4/VBoxContainer/Label').text = 'F'
	if Input.is_action_just_pressed("attack"): #jeżeli przycisk "attack" został wsciśnięty
		emit_signal("attacked") #wyemituj sygnał że bohater zaatakował
	else: #Jeżeli nie atakuje to
		# === KNOCKBACK === #
		knockback = knockback.move_toward(Vector2.ZERO, 500*delta) # gdy zaistnieje knockback, to przesuń o dany wektor knockback
		# === ========= === #
		# === PORUSZANIE SIĘ I KNOCKBACK === #
		if knockback == Vector2.ZERO :
			movement(delta) #wywołanie funkcji poruszania się
		elif knockback != Vector2.ZERO and health > 0:
			knockback = move_and_slide(knockback)
			knockback *= 0.95
			emit_signal("player_moved", knockback)
		# === ========================== === #
	
	# Pick weapon event
	if weaponToTake != null: #Jeżeli gracz stoi przy broni do podniesienia
		if Input.is_action_just_pressed("pick"): #Jeżeli nacisnął przycisk podniesienia
			print("[INFO]: Weapons[1] - ", equippedWeapons[1], " Weapons[2] - ", equippedWeapons[2])
			swapWeaponOnSlot(getCurrentWeaponSlot(), weaponToTake)
			weaponToTake.queue_free()
			

	if chest != null: #Jeżeli gracz stoi przy skrzyni
		if Input.is_action_just_pressed("pick"):
			emit_signal("open") #Wyślij sygnał otwórz
			chest = null
	  
	if potion != null: #Jeżeli gracz stoi przy potionie
		if Input.is_action_just_pressed("pick"): #jeżeli gracz naciśnie przycisk pick
			var potion_name = potion.get_node("PotionNameHolder").text #zmienna przechowująca nazwe potka bez oznaczenia kopii np 50%Potion
			var potion_tmp = potion.name #zmienna przechowująca rzeczywistą nazwe danego potka w scenie np 50%Potion2
			if potions[1]=="Empty": #jeżeli niema potka na slocie 1 to:
				swap_potion(1,potion_name) #ustawienie na slot 1 potka przy ktorym stoi gracz
			elif potions[2]=="Empty": #jeżeli niema potka na slocie 2 to:
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
		

	if Input.is_action_just_pressed("use_potion_1"): #funkcja wywoływana jak nacisniety zostanie przycisk uzycia potionu
		level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
		base_hp = level.get_node("Player").max_health #pobranie maksymalnego hp gracza
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

	if Input.is_action_just_pressed("use_potion_2"): #funkcja wywoływana jak nacisniety zostanie przycisk uzycia potionu
		level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
		base_hp = level.get_node("Player").max_health #pobranie maksymalnego hp gracza
		if level.get_node("Player").health == base_hp: #gdy player ma pełne hp niemożna użyc potki
			return
		if potions_amount["50%Potion"] > 0 and potions[2] == "50%Potion": 									#jeżeli gracz posiada jakieś potki half hp to:
			if level.get_node("Player").health > 0.5*base_hp:	#jeżeli gracz ma ponad pół hp to:
				level.get_node("Player").health = base_hp		#ustawia jego hp na wartość bazowego czyli 100% (zabezpieczenie żeby niedodawało wiecej hp niż bazówka)
			else: 	#jeżeli ma mniej niż pół hp
				level.get_node("Player").health += 0.5*base_hp #leczy o pół hp

			emit_signal("health_updated", health) #emituje sygnał do aktualizacji paska hp
			potions_amount["50%Potion" ] -= 1 #odejmuje jedną potke halp hp
		elif potions_amount["100%Potion"] > 0 and potions[2] == "100%Potion": #jeżeli gracz posiada potki full hp to:
			level.get_node("Player").health = base_hp #ustawia hp playera na bazowe hp
			emit_signal("health_updated", health) #emituje sygnał do aktualizacji paska hp
			potions_amount["100%Potion"] -= 1 #odejmuje jednego potka full hp
		elif potions_amount["20healthPotion"] > 0 and potions[2] == "20healthPotion":
			if level.get_node("Player").health > base_hp-20:
				level.get_node("Player").health = base_hp
			else:
				level.get_node("Player").health += 20
			emit_signal("health_updated", health)
			potions_amount["20healthPotion"] -= 1
		elif  potions_amount["60healthPotion"] > 0 and potions[2] == "60healthPotion":
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

	if equippedWeapons[2] != "Empty": 
		if Input.is_action_just_pressed("changeWeaponSlot"):
			if ($Hand.get_child(0) and $Hand.get_child(0).spell):
				changeWeaponSlot(getCurrentWeaponSlot())

	if potions[2] != "Empty": 									#jeżeli jest potek na 2 slocie i:
		if Input.is_action_just_pressed("change_potion_slot"): 	#jeżeli zostanie nacisniety przycisk zmiany slota potionu
			change_potion_slot() #potki zamieniają się miejscami w slotach


# ============= WEAPONS ============== #  
# Returns the number of the current chosen weapon slot if the Hand node has 
# a child if there is no child in the Hand node, then returns 0
func getCurrentWeaponSlot() -> int:
	if $Hand.get_child(0):
		if equippedWeapons[1] == $Hand.get_child(0).weaponName:
			return 1
		else:
			return 2
	else:
		return 1


# Zmiana ze slotu na inny slot (1 lub 2)
func changeWeaponSlot(currentSlot: int) -> void:
	match currentSlot:
		1:
			currentSlot = 2
		2:
			currentSlot = 1

# Deletes the currently currentlyEquippedWeapon weapon or every child of the $Hand node
func deleteCurrentWeapon() -> void:
	if $Hand.get_child(0) and $Hand.get_child_count() == 1:
		$Hand.get_child(0).queue_free()
		
	# If there is more children in the $Hand node, the method removes them all
	elif $Hand.get_child_count() > 1:
		for child in $Hand.get_children():
			child.queue_free()


# Method that swaps the weapon on the given slot 
func swapWeaponOnSlot(slot: int, weaponOnGround) -> void:
	if weaponOnGround:
		equippedWeapons[slot] = weaponOnGround.weaponName
		dropCurrentWeapon(slot)
		$Hand.add_child(Weapons.all_weapons_scenes[weaponOnGround.weaponName].instance())
		match slot:
			1:
				UISlotWeaponSprite1 = Weapons.all_weapons_textures[weaponOnGround.weaponName]
				w1slot_visibility.visible = true
				w2slot_visibility.visible = false
			2:
				UISlotWeaponSprite2 = Weapons.all_weapons_textures[weaponOnGround.weaponName]
				w1slot_visibility.visible = false
				w2slot_visibility.visible = true
		


# Method that drops the current weapon from the player to the parent scene (main)
func dropCurrentWeapon(slot):
	if $Hand.get_child(0) and $Hand.get_child_count() == 1:
		var temporaryChildVariable = $Hand.get_child(0)
		temporaryChildVariable.position = global_position
		$Hand.remove_child(temporaryChildVariable)
		var droppedWeapon = load("res://Scenes/Loot/Weapon.tscn") #Ładuje scenę broni do zmiennej 
		droppedWeapon = droppedWeapon.instance()
		droppedWeapon.weaponName = temporaryChildVariable.weaponName #Przypisuje nazwę broni dla losowego indeksu zmiennej names
		temporaryChildVariable.queue_free()
		droppedWeapon.position = global_position #Przypisuje pozycję broni
		get_parent().call_deferred('add_child', droppedWeapon) #Tworzy broń na podłodze


# Skill cooldown method
func startSkillCooldown(ability: int, mana_used: int) -> void:
	updateMana(-mana_used)
	if(currentlyEquippedWeapon == equippedWeapons[1]):
		if(ability==1):
			$CoolDownS1.start(25)
		else:
			$CoolDownS2.start(50)
	else:
		if(ability==1):
			$CoolDownS3.start(25)
		else:
			$CoolDownS4.start(50)

# ============= ====== ============== #  


func updateMana(value: int) -> void:
	level.get_node("Player").mana += value
	if mana<0: 
		level.get_node("Player").mana=0
	if mana>max_mana:
		level.get_node("Player").mana=max_mana
	emit_signal("mana_updated", mana/max_mana*100)


func resetStats() -> void:#Reset player perks to default
	manaRegenRate=statusEffect.manaRegenRate


		


func change_potion_slot() -> void: #funcja zamieniająca potki miejscami
	var tmp = potions[1]
	potions[1] = potions[2]
	potions[2] = tmp
	UpdatePotions()


func swap_potion(slot,potionOnGround) -> void: #funkcja do podnoszenia potionów
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


	


func movement(delta) -> void: #funkcja poruszania się
	direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() # Określenie kierunku poruszania się
	if direction != Vector2.ZERO:
		skok_vector = direction
	if Input.is_action_just_pressed("skok") and !skok and stamina > 0 :
		jump() 
		stamina = stamina - 1
	if skok :
		velocity = velocity.move_toward(skok_vector * speed * 2, 500 * delta)
	else :
		velocity = direction * speed * statusEffect.speedMultiplier #pomnożenie wektora kierunku z wartością szybkości daje prędkość
	move() #wywołanie poruszania się
	if !got_hitted: #jeżeli nie jest uderzany
		if direction == Vector2.ZERO and !skok: #jeżeli stoi w miejscu
			$AnimationPlayer.play("Idle") #włącz animację "Idle"
		elif !skok:
			$AnimationPlayer.play("Run")


func jump() -> void:
	skok = true
	$AnimationPlayer.play("skok")
	$skok.start()
	$stamina_regen.start()
	yield($skok,"timeout")
	skok = false


# Method used by the AnimationPlayer (skok) to call a SoundController audio playback
func play_jump_sound():
	SoundController.play_player_random_jump()


func _on_stamina_regen_timeout() -> void:
	if stamina < 3:
		stamina = stamina + 1
	else :
		$stamina_regen.stop()


func move() -> void:
	velocity = move_and_slide(velocity, Vector2.UP)
	if direction.x < 0 :
		$PlayerSprite.scale.x = -abs($PlayerSprite.scale.x) #obróć bohatera w lewo
	elif direction.x > 0:
		$PlayerSprite.scale.x = abs($PlayerSprite.scale.x) #obróć bohatera w lewo
	emit_signal("player_moved", velocity)


# Method used by AnimationPlayer (RUN) to call a SoundController audio playback
func sound_play_step() -> void:
	SoundController.play_player_random_hardstep()


func take_dmg(dps, enemyKnockback, enemyPos) -> void: #otrzymanie obrażeń przez bohatera
	# ======= KNOCKBACK ======= #
	if !skok and !immortal:
		if enemyKnockback != 0:
			knockback = -global_position.direction_to(enemyPos)*(100+(100*enemyKnockback))*(statusEffect.knockbackMultiplier) # knockback w przeciwną stronę od gracza z uwzględnieniem knockbacku broni
		if knockbackResistance != 0:
			knockback /= knockbackResistance
		elif knockbackResistance <= 0.6:
			knockback /= 0.6
		# ======= ========= ======= #
		health = health - (dps * statusEffect.damageMultiplier) # aktualizacja ilości życia z uwzględnieniem współczynnika damage
		emit_signal("health_updated", health) #wyemitowanie sygnału o zmianie ilości punktów życia
		got_hitted = true #bohater jest uderzany
		$AnimationPlayer.play("Hit") #włącz animację "Hit"
		yield($AnimationPlayer, "animation_finished") #poczekaj do końca animacji
		got_hitted = false #bohater nie jest uderzany
		SoundController.play_player_hit()
		if (health <= 0):
			get_tree().change_scene("res://Scenes/UI/DeathScene.tscn")


func _on_Pick_body_entered(body) -> void: #Jeśli coś do podniesienia jest w zasięgu gracza to przypisz do zmiennych węzeł
	if body.is_in_group("Pickable"):
		if "GoldCoin" in body.name:
			coins += 3
			body.queue_free()
		if "Chest" in body.name:
			chest = body
		if "50%Potion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["50%Potion" ] != 0: #sprawdzenie czy player posiada jakieś potki 50%
				potions_amount["50%Potion" ] += 1 #jeżeli ma to ilosc potek 50% zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 50% to musi kliknąć pick żeby podnieść
				potion = body

		if "100%Potion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["100%Potion" ] != 0: #sprawdzenie czy player posiada jakieś potki 100%
				potions_amount["100%Potion" ] += 1 #jeżeli ma to ilosc potek 100% zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 100% to musi kliknąć pick żeby podnieść
				potion = body

		if "20healthPotion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["20healthPotion" ] != 0: #sprawdzenie czy player posiada jakieś potki 20hp
				potions_amount["20healthPotion" ] += 1 #jeżeli ma to ilosc potek 20hp zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 20 aktualna potka jest zamieniana na potke 20hp
				potion = body

		if "60healthPotion" in body.name: #jeżeli player wejdzie w potka
			#level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
			if potions_amount["60healthPotion" ] != 0: #sprawdzenie czy player posiada jakieś potki 60hp
				potions_amount["60healthPotion" ] += 1 #jeżeli ma to ilosc potek 60hp zwieksza się o 1
				body.queue_free() #powoduje znikniecie potka z mapy
				UpdatePotions()
			else: #jeżeli nie posiada potki 60 aktualna potka jest zamieniana na potke 60hp
				potion = body
	if body.is_in_group("PickableWeapon"): 
		if "Weapon" in body.name:
			weaponToTake = body		
	level.get_node("UI/Coins").text = "Coins:"+str(coins)


func _on_Pick_body_exited(body) -> void: #Rozwiązanie tymczasowe
	weaponToTake = null
	chest = null

