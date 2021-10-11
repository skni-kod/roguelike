extends Node2D

signal burn(giver, reciever, lvl, prob, time)
signal bleed(giver, reciever, lvl, prob, time)
signal poison(giver, reciever, lvl, prob, time)

signal freeze(giver, reciever, lvl, prob, time)
signal knockback(giver, reciever, lvl, prob, time) 
signal weakness(giver, reciever, lvl, prob, time)
signal healing(giver, reciever, lvl, prob, time)


func _on_bleed(giver, reciever, lvl, prob, time):
	reciever.statusEffect = giver.givesStatusEffect


func _on_burn(giver, reciever, lvl, prob, time):
	pass 


func _on_freeze(giver, reciever, lvl, prob, time):
	pass 


func _on_healing(giver, reciever, lvl, prob, time):
	pass 


func _on_knockback(giver, reciever, lvl, prob, time):
	pass 


func _on_poison(giver, reciever, lvl, prob, time):
	pass 


func _on_weakness(giver, reciever, lvl, prob, time):
	pass 
