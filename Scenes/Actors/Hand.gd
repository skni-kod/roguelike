extends Position2D

onready var diff = global_position - get_parent().get_node("HandRotationalPoint").global_position
onready var main = get_tree().get_root().find_node("Main", true, false)

func _physics_process(delta):
	global_position = get_parent().get_node("HandRotationalPoint").global_position + diff.rotated(get_parent().get_node("HandRotationalPoint").get_angle_to(get_global_mouse_position()))
	rotate(get_parent().get_node("HandRotationalPoint").get_angle_to(get_global_mouse_position()) - rotation)
	# If condition that makes the weapon turn around when it's to either side of the player (HandRotationalPoint - Position2D on Player)
	if position.x > get_parent().get_node("HandRotationalPoint").position.x:
		scale.y = 1
	else:
		scale.y = -1
	# If condition that makes the weapon show up behind the player if it's aimed up
	if position.y > get_parent().position.y:
		z_index = 0
	else:
		z_index = -1
	# If condition that resets the angle of the hand so that it doesn't go over 360 degrees in either way
	if rotation_degrees > 360 or rotation_degrees < -360:
		rotation_degrees = 0
#	print(self.scale, " ", rotation_degrees)


func _on_axeAbility1Used(direction, currPos) -> void:
	if get_node("Axe"):
		print("[INFO]: Axe throw direction: ", direction, " starting position: ", currPos)
		var equippedAxe = get_node("Axe")
		get_parent().equippedWeapons[get_parent().getCurrentWeaponSlot()] = "Empty"
		match get_parent().getCurrentWeaponSlot():
			1:
				get_parent().UISlotWeaponSprite1.texture = null
			2:
				get_parent().UISlotWeaponSprite2.texture = null
		remove_child(equippedAxe)
		main.add_child(equippedAxe)

