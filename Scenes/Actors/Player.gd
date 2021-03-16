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
var coins = 0 #ilośc coinsów bohatera
var weapon = null #??????
var equipped = "Blade" #???aktualnie wyekwipowana broń???
var chest = null #??????
var level #przypisanie sceny głównej

func _ready(): #po inicjacji bohatera
	level = get_tree().get_root().find_node("Main", true, false) #pobranie głównej sceny
	emit_signal("health_updated", health) #emitowanie sygnału o zmianie życia bohatera 100%/100% 
	level.get_node("UI/Coins").text = "Coins:"+str(coins) #aktualizacja napisu z ilośćią coinsów bohatera
	$EquippedWeapon.set_script(load("res://Scenes/Equipment/Weapons/Melee/Blade.gd"))
	$EquippedWeapon.damage = 10
	$EquippedWeapon.timer = $EquippedWeapon/Timer


func _physics_process(delta): #funkcja wywoływana co klatkę
	if Input.is_action_just_pressed("attack"): #jeżeli przycisk "attack" został wsciśnięty
		emit_signal("attacked") #wyemituj sygnał że bohater zaatakował
	else: #Jeżeli nie atakuje to
		movement() #wywołanie funkcji poruszania się
	if weapon != null:
		if Input.is_action_just_pressed("pick"):
			var weaponName = weapon.WeaponName
			if equipped != weaponName:
				var weaponUsed = load("res://Scenes/Loot/Weapon.tscn")
				weaponUsed = weaponUsed.instance()
				weaponUsed.position = weapon.position
				weaponUsed.WeaponName = equipped
				level.add_child(weaponUsed)
				equipped = weaponName
				#Wycentruj broń na graczu, zmień broń
				$EquippedWeapon.position=Vector2.ZERO
				$EquippedWeapon.set_script(load('res://Scenes/Equipment/Weapons/'+weapon.Stats['range']+'/'+weaponName+'.gd'))
				$EquippedWeapon.timer = $EquippedWeapon/Timer
				$EquippedWeapon.damage = int(weapon.Stats['attack'])
				weapon.queue_free()
				weapon = null
	if chest != null:
		if Input.is_action_just_pressed("pick"):
			emit_signal("open")
			chest = null
	
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
	health = health - (dps * statusEffect.damageMultiplier) #aktualizacja ilości życia
	emit_signal("health_updated", health) #wyemitowanie sygnału o zmianie ilości punktów życia
	got_hitted = true #bohater jest uderzany
	$AnimationPlayer.play("Hit") #włącz animację "Hit"
	yield($AnimationPlayer, "animation_finished") #poczekaj do końca animacji
	got_hitted = false #bohater nie jest uderzany

func _on_Pick_body_entered(body):
	if body.is_in_group("Pickable"):
		if "GoldCoin" in body.name:
			coins += 10
			body.queue_free()
		elif "Weapon" in body.name:
			weapon = body
		elif "Chest" in body.name:
			chest = body
	level.get_node("UI/Coins").text = "Coins:"+str(coins)

func _on_Player_health_updated(health): #pusta funkcja która pozwala na poprawne działanie sygnałów
	pass

func _on_Pick_body_exited(body):
	weapon = null

