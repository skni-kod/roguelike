extends KinematicBody2D

var gracz
var u = 10 #macki nie posiadają określonej ilości HP
#po przyjęciu u ciosów chowają się

func _ready():
	$AnimationPlayer.play("idle")

func get_dmg(dmg, weaponKnockback):
	get_parent().get_node("OctoBoss").dmg(dmg) #obrażenia są odejmowane od zdrowia głównego bossa
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
		gracz.take_dmg(20, 0, 0)
