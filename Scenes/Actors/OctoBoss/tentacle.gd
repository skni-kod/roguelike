extends KinematicBody2D

var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń
var uderzyla = false

func _ready():
	$AnimationPlayer.play("intro")
	yield($AnimationPlayer,"animation_finished")
	if uderzyla: # macka, która trafiła w gracza, chowa się po udanym ataku
		$AnimationPlayer.play("outro2")
		yield($AnimationPlayer,"animation_finished")
		self.queue_free()
	else:
		$AnimationPlayer.play("idle")

func get_dmg(dmg, _weaponKnockback):
	get_parent().dmg(dmg) # obrażenia są odejmowane od zdrowia głównego bossa
	# == EFEKTY WIZUALNE ==
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	# == =============== ==

func _on_Timer_timeout(): # po kilku sekundach macka chowa się pod ziemię
	$AnimationPlayer.play("outro")
	yield($AnimationPlayer,"animation_finished")
	self.queue_free()
