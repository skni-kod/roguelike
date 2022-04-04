extends Node

func _ready() -> void:
	connect("body_entered", Bufor.PLAYER.get_node("Hand").get_child(0), "_on_Fms_body_entered")

