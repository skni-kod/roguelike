extends Area2D

func _on_Portal_body_entered(body):
	if body.name == "Player":
		Bufor.coins = body.coins
		Bufor.i += 1
		get_tree().change_scene("res://Scenes/Levels/Main.tscn")
