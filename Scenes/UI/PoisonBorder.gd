extends Control

func end():
	$AnimationPlayer.play("End")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
