extends Area2D

var wPortalu = false # czy gracz wszedł do portalu
var player # zmienna do przerzucenia gracza
#między on_Portal_body_entered a procesem

func _ready():
	set_process(true) # włącza proces, który czeka na nacisniecie E
	$AnimationPlayer.play("portal") # odtwarza animację

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
		Bufor.equipped_armor = player.equipped_armor
		Bufor.armor_durability = player.armor_durability
		get_tree().change_scene("res://Scenes/Levels/Main.tscn")



func _on_Portal_body_shape_exited(_body_id, body, _body_shape, _local_shape):
	if body.name == "Player":
		$E.visible = false
		wPortalu = false # jeśli gracz wyszedł z portalu
		# nacisniecie E nie spowoduje teleportacji
