extends Node2D

### This script is a script that is all behind the logic of the status effects
### it redirects effects to player and the enemies
### Connect signal of spawned enemies f.e. "give_effect"(reciever node or ID or pointer to node, 
###	effect, duration, stack, probability) emitted from an entity with a list of effects
### that it can cause in another entity (probably enemy -> player)
### connect signal from the main node to StatusNode, from there on -> StatusBar if player
### status effects if any other entity then -> StatusNode methods cause effects on monsters
### in the future maybe centralise status effects overall for player and enemy in this script
### redirect to status bar to show effect on player

func _on_give_effect(reciever, effect, duration, stack, probability):
	match reciever:
		"player":
			match effect:
				"bleeding":
					# player bleed(reciever, duration, stack, probability)
					pass
				"burning":
					# player burn(reciever, duration, stack, probability)		
					pass
				"freezing":
					# player freeze(reciever, duration, stack, probability)
					pass
				"healing":
					# player healing(reciever, duration, stack, probability)
					pass
				"knockback":
					# player knockback(reciever, duration, stack, probability)
					pass
				"poison":
					# player poison(reciever, duration, stack, probability)
					pass
				"weakness":
					# player weakness(reciever, duration, stack, probability)
					pass
		_:
			match effect:
				"bleeding":
					bleed(reciever, duration, stack, probability)
				"burning":
					burn(reciever, duration, stack, probability)		
				"freezing":
					freeze(reciever, duration, stack, probability)
				"healing":
					healing(reciever, duration, stack, probability)
				"knockback":
					knockback(reciever, duration, stack, probability)
				"poison":
					poison(reciever, duration, stack, probability)
				"weakness":
					weakness(reciever, duration, stack, probability)



func bleed(reciever, duration, stack, probability):
	pass


func burn(reciever, duration, stack, probability):
	pass 


func freeze(reciever, duration, stack, probability):
	pass 


func healing(reciever, duration, stack, probability):
	pass 


func knockback(reciever, duration, stack, probability):
	pass 


func poison(reciever, duration, stack, probability):
	pass 


func weakness(reciever, duration, stack, probability):
	pass 
