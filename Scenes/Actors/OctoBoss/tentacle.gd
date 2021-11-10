extends KinematicBody2D

var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń

func _ready():
	$AnimationPlayer.play("intro")
	yield($AnimationPlayer,"animation_finished")
	$AnimationPlayer.play("idle")

func get_dmg(dmg, weaponKnockback):
	get_parent().dmg(dmg) #obrażenia są odejmowane od zdrowia głównego bossa
	# == EFEKTY WIZUALNE ==
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	# == =============== ==

func _on_Timer_timeout():
	$AnimationPlayer.play("outro")
	yield($AnimationPlayer,"animation_finished")
	self.queue_free()
