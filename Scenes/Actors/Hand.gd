extends Position2D

onready var diff = global_position - Bufor.PLAYER.get_node("HandRotationalPoint").global_position
onready var main = get_tree().get_root().find_node("Main", true, false)


func _physics_process(_delta):
	if Bufor.PLAYER != null and !Bufor.PLAYER.katanaDash and !Bufor.PLAYER.hammerSmash:
		global_position = Bufor.PLAYER.get_node("HandRotationalPoint").global_position + diff.rotated(Bufor.PLAYER.get_node("HandRotationalPoint").get_angle_to(get_global_mouse_position()))
		rotate(Bufor.PLAYER.get_node("HandRotationalPoint").get_angle_to(get_global_mouse_position()) - rotation)
		# If condition that makes the weapon turn around when it's to either side of the Player (HandRotationalPoint - Position2D on Player)
		if position.x > Bufor.PLAYER.get_node("HandRotationalPoint").position.x:
			scale.y = 1
		else:
			scale.y = -1
		# If condition that makes the weapon show up behind the Player if it's aimed up
		if global_position.y > Bufor.PLAYER.global_position.y:
			z_index = 0
		else:
			z_index = -1
		# If condition that resets the angle of the hand so that it doesn't go over 360 degrees in either way
		if rotation_degrees > 360 or rotation_degrees < -360:
			rotation_degrees = 0
#	print(self.scale, " ", rotation_degrees)


func _on_axeAbility1Used(direction, currPos) -> void:
	if get_node("Axe") and Bufor.PLAYER != null:
		print("[INFO]: Axe throw direction: ", direction, " starting position: ", currPos)
		var equippedAxe = get_node("Axe")
		Bufor.PLAYER.equippedWeapons[Bufor.PLAYER.getCurrentWeaponSlot()] = "Empty"
		match Bufor.PLAYER.getCurrentWeaponSlot():
			1:
				Bufor.PLAYER.UISlotWeaponSprite1.texture = null
			2:
				Bufor.PLAYER.UISlotWeaponSprite2.texture = null
		remove_child(equippedAxe)
		main.add_child(equippedAxe)


func _on_katana_dash_used(dashDestination) -> void:
	if get_node("Katana") and Bufor.PLAYER != null:
		print("[INFO]: Katana dash singnal arrived")
		print("[INFO]: Animation player: ", Bufor.PLAYER.get_node("AnimationPlayer"))
		print("[INFO]: Animation Katana Dash: ", Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash"))
		Bufor.PLAYER.katanaDash = true
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(0, 0, Bufor.PLAYER.global_position.x)
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(1, 0, Bufor.PLAYER.global_position.y)
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(0, 1, Bufor.PLAYER.global_position.x + dashDestination.direction_to(Bufor.PLAYER.global_position).x * 200 * 0.1)
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(1, 1, Bufor.PLAYER.global_position.y + dashDestination.direction_to(Bufor.PLAYER.global_position).y * 200 * 0.1)
		var distancefactor = Bufor.PLAYER.global_position.distance_to(dashDestination)
		if distancefactor < 200:
			distancefactor = fmod(Bufor.PLAYER.global_position.distance_to(dashDestination), 200)
		else:
			distancefactor = 200
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(0, 2, Bufor.PLAYER.global_position.x - dashDestination.direction_to(Bufor.PLAYER.global_position).x * distancefactor)
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(1, 2, Bufor.PLAYER.global_position.y - dashDestination.direction_to(Bufor.PLAYER.global_position).y * distancefactor)
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(0, 3, Bufor.PLAYER.global_position.x - dashDestination.direction_to(Bufor.PLAYER.global_position).x * distancefactor)
		Bufor.PLAYER.get_node("AnimationPlayer").get_animation("Katana Dash").bezier_track_set_key_value(1, 3, Bufor.PLAYER.global_position.y - dashDestination.direction_to(Bufor.PLAYER.global_position).y * distancefactor)
		Bufor.PLAYER.immortal = 1
		Bufor.PLAYER.get_node("AnimationPlayer").play("Katana Dash")
		yield(Bufor.PLAYER.get_node("AnimationPlayer"), "animation_finished")
		Bufor.PLAYER.immortal = 0
		Bufor.PLAYER.global_position = Bufor.PLAYER.position
		Bufor.PLAYER.get_node("AnimationPlayer").play("RESET")
		Bufor.PLAYER.katanaDash = false
		

func _on_hammer_smash_initiated() -> void:
	# doesn't play the animation <- [DEV]
	if get_node("Hammer") and Bufor.PLAYER != null:
		Bufor.PLAYER.hammerSmash = true
#		yield(Bufor.PLAYER.get_node("AnimationPlayer"), "animation_finished")
		Bufor.PLAYER.get_node("AnimationPlayer").play("Hammer Smash")
		yield(Bufor.PLAYER.get_node("AnimationPlayer"), "animation_finished")
		Bufor.PLAYER.hammerSmash = false
