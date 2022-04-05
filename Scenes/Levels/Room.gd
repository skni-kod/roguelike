extends Area2D

signal Cleared() #Fms

func _on_TopEntrance_body_entered(body):
	if body.name == "Player":
		print("[INFO]: Entered top room")
		Bufor.PLAYER.global_position.y -= 60


func _on_BottomEntrance_body_entered(body):
	if body.name == "Player":
		print("[INFO]: Entered bottom room")
		Bufor.PLAYER.global_position.y += 60


func _on_LeftEntrance_body_entered(body):
	if body.name == "Player":
		print("[INFO]: Entered left room")
		Bufor.PLAYER.global_position.x -= 90


func _on_RightEntrance_body_entered(body):
	if body.name == "Player":
		print("[INFO]: Entered right room")
		Bufor.PLAYER.global_position.x += 90

func _on_Enemies_Cleared() -> void:
	print("reeeeeadasdwadsa")
	emit_signal("Cleared")
