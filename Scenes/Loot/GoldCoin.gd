extends StaticBody2D

func _on_Pick_body_entered(body):
	if body.name=='Player':
		queue_free()
	$AnimationPlayer.play("Idle")
