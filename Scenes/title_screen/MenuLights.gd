extends Node2D


func _process(delta):
	get_node("CursorLight").position = get_viewport().get_mouse_position()
