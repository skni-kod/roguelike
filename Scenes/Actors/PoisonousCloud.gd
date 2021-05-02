extends Area2D

signal tick
signal quitted

func _on_TimerDuration_timeout():
	queue_free()


func _on_PoisonousCloud_body_entered(body):
	if(body.name == "Player"):
		$TimerDamage.start()


func _on_PoisonousCloud_body_exited(body):
	if(body.name == "Player"):
		$TimerDamage.stop()
		emit_signal("quitted")


func _on_TimerTick_timeout():
	emit_signal("tick")
