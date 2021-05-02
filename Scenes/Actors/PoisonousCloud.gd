# PoisonousCloud.gd
extends Area2D
# PoisonousCloud - pojedyncza czesc trujacej chmury

signal tick # Deklaracja sygnalu "siedzenia" w chmurze
signal quitted # Deklaracja sygnalu wyjscia z chmury

func _on_TimerDuration_timeout(): # Usun chmure po danym czasie
	queue_free()


func _on_PoisonousCloud_body_entered(body): # Jesli gracz wejdzie do chmury, uruchom timer wysylajacy sygnal "tick"
	if(body.name == "Player"):
		$TimerDamage.start()


func _on_PoisonousCloud_body_exited(body): # Jesli gracz wyjdzie z chmury, zatrzymaj timer wysylajacy sygnal "tick"
	if(body.name == "Player"):
		$TimerDamage.stop()
		emit_signal("quitted")


func _on_TimerTick_timeout(): # Wysylaj stgnal "tick" jesli gracz jest w chmurze
	emit_signal("tick")
