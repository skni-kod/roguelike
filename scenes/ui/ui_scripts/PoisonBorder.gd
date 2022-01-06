# PoisonBorder.gd
extends Control
# PoisonBorder - obramowanie informujace gracza o staniu w truajcej chmurze

func end(): # Funkcja niszczaca obramowanie
	$AnimationPlayer.play("End")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
