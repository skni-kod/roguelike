extends Node

signal body_entered()

func _ready() -> void:
	if !is_connected("body_entered", Bufor.PLAYER.get_node("Hand").get_child(0), "_on_Fms_body_entered"):
		connect("body_entered", Bufor.PLAYER.get_node("Hand").get_child(0), "_on_Fms_body_entered")

