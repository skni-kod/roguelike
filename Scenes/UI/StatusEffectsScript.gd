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
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)
				"burning":
					burn(reciever, duration, stack, probability)
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)
				"freezing":
					freeze(reciever, duration, stack, probability)
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)
				"healing":
					healing(reciever, duration, stack, probability)
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)
				"knockback":
					knockback(reciever, duration, stack, probability)
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)
				"poison":
					poison(reciever, duration, stack, probability)
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)
				"weakness":
					weakness(reciever, duration, stack, probability)
					if(reciever.ownStatusEffects.count(effect) == 0):
						reciever.ownStatusEffects.append(effect)


func bleed(reciever, duration, stack, probability):
	var bleed_timer = get_tree().create_timer(duration)
	var damage = 0
	bleed_timer.set_one_shot(true)
	while(bleed_timer.get_time_left()):
		var bleed_damage_timer = get_tree().create_timer(0.2)
		bleed_damage_timer.set_one_shot(true)
		if(bleed_damage_timer.get_time_left()):
			match stack:
				1:
					damage += 2
				_:
					damage += 1.5 * stack
		if(bleed_damage_timer.time_left == 0):
			reciever.get_dmg(damage, 0)

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
