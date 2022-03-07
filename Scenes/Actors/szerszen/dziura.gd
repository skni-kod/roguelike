extends Area2D

func _on_dziura_body_entered(body):
	if body.name == "Player":
		body.take_dmg(128000, 0, self.global_position)
