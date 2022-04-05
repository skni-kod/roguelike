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
		Bufor.potions = player.potions
		Bufor.potions_amount = player.potions_amount
		Bufor.weapons = player.weapons
		Bufor.first_weapon_stats = player.first_weapon_stats
		Bufor.second_weapon_stats = player.second_weapon_stats
		Bufor.equipped = player.equipped
		Bufor.POZIOM += 1
		var _c = get_tree().change_scene("res://Scenes/title_screen/TitleScreen.tscn")


func _on_Portal_body_shape_exited(_body_id, body, _body_shape, _local_shape):
	if body.name == "Player":
		$E.visible = false
		wPortalu = false # jeśli gracz wyszedł z portalu
		# nacisniecie E nie spowoduje teleportacji
