extends Area2D

var wPortalu = false # czy gracz wszedł do portalu
var player # zmienna do przerzucenia gracza
#między on_Portal_body_entered a procesem

func _ready():
	set_process(true) # włącza proces, który czeka na nacisniecie E

func _on_Portal_body_entered(body):
	if body.name == "Player":
		player = body
		wPortalu = true
		$E.visible = true

func _process(_delta):
	if Input.is_action_just_pressed("pick") and wPortalu:
		Bufor.COINS = player.coins
		Bufor.POTIONS = player.potions
		Bufor.POTIONS_AMOUNT = player.potions_amount
		Bufor.WEAPONS = player.equippedWeapons
		Bufor.EQUIPPED = player.currentlyEquippedWeapon
		Bufor.POZIOM += 1
		Bufor.PLAYER = null
		get_tree().change_scene("res://Scenes/Levels/Main.tscn")


func _on_Portal_body_shape_exited(body_id, body, body_shape, local_shape):
	if body.name == "Player":
		$E.visible = false
		wPortalu = false # jeśli gracz wyszedł z portalu
		# nacisniecie E nie spowoduje teleportacji
