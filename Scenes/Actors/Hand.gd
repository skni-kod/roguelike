extends Position2D

onready var diff = global_position - get_parent().get_node("PlayerSprite").global_position
onready var main = get_tree().get_root().find_node("Main", true, false)

onready var savedpos = position

func _physics_process(delta):
	global_position = get_parent().get_node("PlayerSprite").global_position + diff.rotated(get_parent().get_node("PlayerSprite").get_angle_to(get_global_mouse_position()))
	rotate(get_parent().get_node("PlayerSprite").get_angle_to(get_global_mouse_position()) - rotation)
	if position.x > get_parent().get_node("PlayerSprite").position.x:
		scale.y = 1
	else:
		scale.y = -1
	if rotation_degrees > 360 or rotation_degrees < -360:
		rotation_degrees = 0
#	print(self.scale, " ", rotation_degrees)


func _on_axeAbility1Used(direction, currPos) -> void:
	if get_node("Axe"):
		print("[INFO]: Axe throw direction: ", direction, " starting position: ", currPos)
		var equippedAxe = get_node("Axe")
		get_parent().weapons[get_parent().get_current_weapon_slot()] = "Empty"
		if (get_parent().get_current_weapon_slot() == 1):
			get_parent().w1slot_visibility.visible = false
			get_parent().ui_access_wslot1.texture = null
		else:
			get_parent().w2slot_visibility.visible = false
			get_parent().ui_access_wslot2.texture = null
		remove_child(equippedAxe)
		main.add_child(equippedAxe)

