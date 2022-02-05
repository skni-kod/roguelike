extends KinematicBody2D

const LIMIT_PRZECIWNIKOW = 192

signal died(body)
var health = 10
export var dps = 50 # Zmienna przechowująca wartość ataku
var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn")
var gracz = false
var kopia = load("res://Scenes/Actors/kwiatek/kwiatek.tscn")
var KOLOR = 0
var kwiatek = false
var t = [4.5, 3.5, 0.7, 1.8]
var dmgg = [1,3,2,1]

func _ready():
	KOLOR = floor(rand_range(0,4)) # losuje jeden z czterech kolorów
	$atak.wait_time = t[KOLOR]

func wzrost():
	kwiatek = true
	$Sprite.z_index = 1
	$Sprite.region_rect = Rect2(KOLOR*18,0,18,24)
	$ziarno.queue_free()
	$atak.start()
	$wzrost.queue_free()

func atak():
	if gracz:
		if sqrt((global_position.x - gracz.global_position.x)*(global_position.x - gracz.global_position.x) + (global_position.y-gracz.global_position.y)*(global_position.y-gracz.global_position.y)) < 32:
			# jeżeli gracz znajduje się w zasięgu kwiatka
			gracz.take_dmg(dmgg[KOLOR], 1.2, Vector2(gracz.global_position.x, gracz.global_position.y + 10))
		if get_parent().get_child_count() < LIMIT_PRZECIWNIKOW: # kopia nie jest tworzona, jeżeli w pokoju znajduje się zbyt wielu przeciwników
			var k = kopia.instance()
			k.position = self.position # zostawia nasiona
			k.gracz = gracz # przekazuje nasionom informacje o graczu
			get_parent().add_child(k) # dodaje nasiona do sceny
		global_position = Vector2(floor(gracz.global_position.x + rand_range(-100,100)), gracz.global_position.y + floor(rand_range(-50,50))) # skacze do pozycji gracza

func _on_ziarno_body_entered(body): # nadepnięcie na nasiona
	if body.name == "Player":
		emit_signal("died", self)
		queue_free() # powoduje ich zniszczenie

func _on_zasieg_body_entered(body):
	if body.name == "Player":
		gracz = body

func get_dmg(dmg, _weaponKnockback):
	health -= dmg
	if (health <= 0):
		#drop_coins()
		emit_signal("died", self)
		queue_free()
	# == EFEKTY WIZUALNE ==
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	# == =============== ==
