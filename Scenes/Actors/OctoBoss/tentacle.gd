extends KinematicBody2D

var floating_dmg = preload("res://Scenes/UI/FloatingDmg.tscn") # wizualny efekt zadanych obrażeń
var gracz
var u = 10 #macki nie posiadają określonej ilości HP
#po przyjęciu u ciosów chowają się

func _ready():
	$AnimationPlayer.play("idle")

func get_dmg(dmg, weaponKnockback):
	get_parent().dmg(dmg) #obrażenia są odejmowane od zdrowia głównego bossa
	# == EFEKTY WIZUALNE ==
	var text = floating_dmg.instance()
	text.amount = dmg
	text.type = "Damage"
	add_child(text)
	# == =============== ==
	u -= 1
	if (u <= 0):
		self.queue_free() #po u ciosach macka znika

func _on_Zasieg_body_entered(body):
	if body.name == "Player":
		gracz = body

func _on_Zasieg_body_exited(body):
	if body.name == "Player":
		gracz = null

func _on_Timer_timeout():
	if gracz:
		gracz.take_dmg(20, 0.7, self.global_position)
